----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: VGA_TEXT_GENERATOR
--
-- Description: Generates the RGB signals for text to be displayed based on the 
--  the pixel xy-coordinates and the BCD values of the text parameters. The RGB
--  output should be multiplexed with the waveform generator circuit to complete
--  the display.
--
-- Inputs:
--      clk: 25MHz pixel clock
--      video_on: Video enable signal from VGA timing generator
--      pixel_x: Current pixel x-coordinate from VGA timing generator
--      pixel_y: Current pixel y-coordinate from VGA timing generator
--      horizontal_scale: BCD value of time/division in 100s of nanoseconds
--      vertical_scale: BCD value of volts/division in millivolts
--      trigger_mode: '1' -> Rising, '0' -> Falling edge trigger mode
--      frequency: BCD value of frequency measurement in Hz
--      trigger_level: BCD value of trigger level in millivolts
--      voltage_pp: BCD value of pk-pk voltage measurement in millivolts
--      voltage_avg: BCD value of average voltage measurement in millivolts
--      voltage_max: BCD value of max voltage measurement in millivolts
--      voltage_min: BCD value of min voltage measurement in millivolts
--
-- Outputs:
--      text_on: Text enable signal for multiplexing VGA RGB sources
--      rgb_text: RGB value of current pixel
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity VGA_TEXT_GENERATOR is
    port(
        clk : in std_logic;        
        video_on : in std_logic;       
        pixel_x  : in std_logic_vector(9 downto 0);
        pixel_y  : in std_logic_vector(9 downto 0);
        -- BCD digits
        horizontal_scale_bcd : in std_logic_vector(11 downto 0); 
        vertical_scale_bcd   : in std_logic_vector(11 downto 0);
        delay_bcd            : in std_logic_vector(11 downto 0);
        trigger_level_bcd    : in std_logic_vector(11 downto 0);
--        frequency_bcd        : in std_logic_vector(11 downto 0);
--        voltage_pkpk_bcd     : in std_logic_vector(11 downto 0);
--        voltage_avg_bcd      : in std_logic_vector(11 downto 0);
--        voltage_max_bcd      : in std_logic_vector(11 downto 0);
--        voltage_min_bcd      : in std_logic_vector(11 downto 0);       
        -- BCD digit units
        horizontal_unit      : in std_logic_vector(1 downto 0);
--        frequency_unit       : in std_logic_vector(1 downto 0);
        delay_unit           : in std_logic_vector(1 downto 0);        
        vertical_unit        : in std_logic;    
        trigger_mode         : in std_logic;
        trigger_level_unit    : in std_logic;  
--        voltage_pkpk_unit    : in std_logic;  
--        voltage_avg_unit     : in std_logic;  
--        voltage_max_unit     : in std_logic;  
--        voltage_min_unit     : in std_logic;  
        text_on              : out std_logic;
        rgb_text             : out std_logic_vector(11 downto 0)
    );
end VGA_TEXT_GENERATOR;

architecture MIXED of VGA_TEXT_GENERATOR is
    signal rom_addr : std_logic_vector(10 downto 0);    -- Font ROM address
    signal ascii_code : std_logic_vector(6 downto 0);    -- 7-bit ASCII code
    signal row_addr : std_logic_vector(3 downto 0);     -- Row of font character
    signal bit_addr : std_logic_vector(2 downto 0);     -- Column of font character
    signal font_word : std_logic_vector(7 downto 0);    -- Row of pixels for a character
    signal font_bit : std_logic;                        -- on/off for character pixel                 
    signal text_x : std_logic_vector(6 downto 0);       -- Character tile x-coordinate
    signal text_y : std_logic_vector(5 downto 0);       -- Character tile y-coordinate
    signal string_idx : integer range 0 to 15;   -- Index for 16 char string vector
    signal str_idx, str_idx_reg : std_logic_vector(3 downto 0);
    -- Array of 16 ASCII characters
    type char_array is array(0 to 15) of std_logic_vector(6 downto 0);
    signal ascii_string : char_array;
            
    function bcd_to_ascii (bcd : std_logic_vector(3 downto 0)) return std_logic_vector is
        variable ascii : std_logic_vector(6 downto 0) := (others => '0');
        constant ASCII_0 : std_logic_vector(6 downto 0) := "0110000";
    begin
        ascii := std_logic_vector(("000" & unsigned(bcd)) + unsigned(ASCII_0)); -- add the character 0 in ASCII
        return ascii;
    end function;        
    
    function char_to_slv (char : character) return std_logic_vector is
        variable slv : std_logic_vector(6 downto 0);
    begin
            slv := std_logic_vector(to_unsigned(character'pos(char), 7));
        return slv;
    end function;    
    
           
begin
    -- Instantiate Font ROM
    FONT_UNIT: entity font_rom
    port map(
      clock => clk,
      addr => rom_addr,
      data => font_word
    );
    
      -- Font ROM interface:
      -- Convert 1x1 pixel coordinate system to 8x16 character tile coordinate system
      text_x <= pixel_x(9 downto 3); -- Mod-8 
      text_y <= pixel_y(9 downto 4); -- Mod-16 
           
      ASCII_GEN:process(text_x, text_y)
        variable txt_x : integer range 0 to 80;
        variable txt_y : integer range 0 to 30;
        variable str : string(1 to 16) := (others => ' ');
      begin
        txt_x := to_integer(unsigned(text_x));
        txt_y := to_integer(unsigned(text_y));
        case txt_y is
        when 1 => 
            if txt_x > 0 and txt_x < 16 then  
                str := (others => ' ');          
                case vertical_unit is
                    when '0' => str(1 to 6) := "mV/DIV";
                    when others => str(1 to 5) := "V/DIV";
                end case;                              
                for i in 0 to 15 loop
                    if i < 3 then 
                        ascii_string(i) <= bcd_to_ascii(vertical_scale_bcd(4*(3-i)-1 downto 4*(2-i)));
                    elsif i < 12 then 
                        ascii_string(i) <= char_to_slv(str(i-3+1));
                    else
                        ascii_string(i) <= char_to_slv(' ');
                    end if;         
                end loop;
            elsif txt_x > 16 and txt_x < 32 then    
                str := (others => ' ');          
                case horizontal_unit is
                    when "00" => str(1 to 5) := "s/DIV";
                    when "01" => str(1 to 6) := "ms/DIV";
                    when "10" => str(1 to 6) := "us/DIV";
                    when others => str(1 to 6) := "ns/DIV";
                end case;                
                for i in 0 to 15 loop
                    if i < 3 then 
                        ascii_string(i) <= bcd_to_ascii(horizontal_scale_bcd(4*(3-i)-1 downto 4*(2-i)));
                    elsif i < 12 then 
                        ascii_string(i) <= char_to_slv(str(i-3+1));
                    else
                        ascii_string(i) <= char_to_slv(' ');
                    end if;         
                end loop;                          
            elsif txt_x > 32 and txt_x < 48 then
                str := (others => ' ');          
                str(1 to 6) := "Delay:";             
                for i in 0 to 15 loop
                    if i < 6 then 
                        ascii_string(i) <= char_to_slv(str(i+1));
                    elsif i < 9 then 
                        ascii_string(i) <= bcd_to_ascii(delay_bcd(4*(9-i)-1 downto 4*(8-i)));
                    elsif i = 9 then
                        case delay_unit is
                            when "00" => ascii_string(i) <= char_to_slv('s');
                            when "01" => ascii_string(i) <= char_to_slv('m');
                            when "10" => ascii_string(i) <= char_to_slv('u');
                            when others => ascii_string(i) <= char_to_slv('n');
                        end case; 
                    elsif i = 10 then
                        case delay_unit is
                            when "00" => ascii_string(i) <= char_to_slv(' ');
                            when others => ascii_string(i) <= char_to_slv('s');
                        end case;   
                    else
                        ascii_string(i) <= char_to_slv(' ');
                    end if;         
                end loop;       
            elsif txt_x > 48 and txt_x < 64 then
                str := (others => ' ');          
                str(1 to 9) := "TRGR LVL:";             
                for i in 0 to 15 loop
                    if i < 9 then 
                        ascii_string(i) <= char_to_slv(str(i+1));
                    elsif i < 12 then 
                        ascii_string(i) <= bcd_to_ascii(trigger_level_bcd(4*(12-i)-1 downto 4*(11-i)));
                    elsif i = 12 then
                        case trigger_level_unit is
                            when '0' => ascii_string(i) <= char_to_slv('m');
                            when others => ascii_string(i) <= char_to_slv('V');
                        end case;     
                    elsif i = 13 then
                        case trigger_level_unit is
                            when '0' => ascii_string(i) <= char_to_slv('V');
                            when others => ascii_string(i) <= char_to_slv(' ');
                        end case;   
                    else
                        ascii_string(i) <= char_to_slv(' ');
                    end if;         
                end loop;   
            elsif txt_x > 64 and txt_x < 80 then   
                str := (others => ' ');          
                case trigger_mode is
                    when '0'    => str(1 to 9) := "(FALLING)";
                    when others => str(1 to 8) := "(RISING)";
                end case;                               
                for i in 0 to 15 loop
                    if i < 10 then 
                        ascii_string(i) <= char_to_slv(str(i+1));
                    elsif i = 10 then
                        case trigger_mode is
                            when '0' => ascii_string(i) <= "0011001";
                            when others => ascii_string(i) <= "0011000";
                        end case;        
                    else
                        ascii_string(i) <= char_to_slv(' ');
                    end if;         
                end loop;      
            else         
                for i in 0 to 15 loop
                    ascii_string(i) <= char_to_slv(' ');
                end loop;   
            end if;
        when others => 
                for i in 0 to 15 loop
                    ascii_string(i) <= char_to_slv(' ');
                end loop; 
        end case;   
    
        str_idx <= text_x(3 downto 0); 
        str_idx_reg <= str_idx;
        string_idx <= to_integer(unsigned(str_idx));                               
      end process;
    
    ascii_code <= ascii_string(string_idx);           
    rom_addr <= ascii_code & row_addr;
    row_addr <= pixel_y (3 downto 0);
    bit_addr <= pixel_x (2 downto 0);     
    font_bit <= font_word(to_integer(unsigned(not bit_addr)));
    
    text_on <= '1' when 
        to_integer(unsigned(pixel_x)) < 512 and 
        to_integer(unsigned(pixel_y)) < 112 
    else '0'; 
    
    rgb_text <= x"AAA" when video_on = '1' and font_bit = '1' else x"000";
end MIXED;
