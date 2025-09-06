----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: VGA_TEXT_GENERATOR
--
-- Description: Generates the RGB signals for text to be displayed based on the 
--  the pixel xy-coordinates and the strings created by the softcore processor. 
--  The RGB output should be multiplexed with the waveform generator circuit to 
--  complete the display.
--
-- Inputs:
--      clk: 25MHz pixel clock
--      video_on: Video enable signal from VGA timing generator
--      pixel_x: Current pixel x-coordinate from VGA timing generator
--      pixel_y: Current pixel y-coordinate from VGA timing generator
--      horizontal_scale_str: Horizontal scale settings string
--      vertical_scale_str: Vertical scale settings string 
--      delay_str: Delay settings string
--      trigger_level_str: Trigger level settings string
--      trigger_mode_str: Trigger mode settings string
--      sample_rate_str: Sample rate settings string
--      frequency_str: Frequency settings string
--      voltage_pp_str: Peak-peak voltage settings string
--      voltage_avg_str: Average voltage settings string
--      voltage_max_str: Maximum voltage settings string
--      voltage_min_str: Minimum voltage settings string
--      x1_cursor_str: X1 cursor settings string
--      x2_cursor_str: X2 cursor settings string
--      x_cursor_delta_str: X cursor delta (X2-X1) settings string
--      y1_cursor_str: Y1 cursor settings string
--      y2_cursor_str: Y2 cursor settings string
--      y_cursor_delta_str: Y cursor delta (Y2-Y1) settings string
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
use ieee.math_real.all;
use work.all;

entity VGA_TEXT_GENERATOR is
    port(
        clk : in std_logic;
        i_clk_enable : std_logic;
        video_on : in std_logic;
        pixel_x  : in std_logic_vector(9 downto 0);
        pixel_y  : in std_logic_vector(9 downto 0);
        horizontal_scale_str : in std_logic_vector(111 downto 0);
        vertical_scale_str   : in std_logic_vector(111 downto 0);
        delay_str            : in std_logic_vector(111 downto 0);
        trigger_level_str    : in std_logic_vector(111 downto 0);
        trigger_mode_str     : in std_logic_vector(111 downto 0);
        sample_rate_str      : in std_logic_vector(111 downto 0);
        frequency_str        : in std_logic_vector(111 downto 0);
        voltage_pp_str       : in std_logic_vector(111 downto 0);
        voltage_avg_str      : in std_logic_vector(111 downto 0);
        voltage_max_str      : in std_logic_vector(111 downto 0);
        voltage_min_str      : in std_logic_vector(111 downto 0);
        x1_cursor_str        : in std_logic_vector(111 downto 0);
        x2_cursor_str        : in std_logic_vector(111 downto 0);
        x_cursor_delta_str   : in std_logic_vector(111 downto 0);
        y1_cursor_str        : in std_logic_vector(111 downto 0);
        y2_cursor_str        : in std_logic_vector(111 downto 0);
        y_cursor_delta_str   : in std_logic_vector(111 downto 0);
        text_on              : out std_logic;
        rgb_text             : out std_logic_vector(11 downto 0)
    );
end VGA_TEXT_GENERATOR;

architecture MIXED of VGA_TEXT_GENERATOR is
    -- Converts a character type to a 7-bit ASCII-code of type SLV
    function char_to_slv (char : character) return std_logic_vector is
        variable slv : std_logic_vector(6 downto 0);
    begin
            slv := std_logic_vector(to_unsigned(character'pos(char), 7));
        return slv;
    end function;      
    
    signal rom_addr : std_logic_vector(10 downto 0);    -- Font ROM address
    signal ascii_code : std_logic_vector(6 downto 0);   -- 7-bit ASCII code
    signal row_addr : std_logic_vector(3 downto 0);     -- Row of font character
    signal bit_addr : std_logic_vector(2 downto 0);     -- Column of font character
    signal font_word : std_logic_vector(7 downto 0);    -- Row of pixels for a character
    signal font_bit : std_logic;                        -- on/off for character pixel                 
    signal text_x : std_logic_vector(6 downto 0);       -- Character tile x-coordinate
    signal text_y : std_logic_vector(5 downto 0);       -- Character tile y-coordinate
    signal string_idx : integer range 0 to 15;          -- Index for 16 char string vector
    signal str_idx, str_idx_reg : std_logic_vector(3 downto 0);
    signal text_on_reg : std_logic;
    -- Array of 16 ASCII characters
    signal ascii_string : std_logic_vector(111 downto 0);      
begin
    -- Instantiate Font ROM
    FONT_UNIT: entity font_rom
    port map(
      clock => clk,
      addr => rom_addr,
      data => font_word
    );
    
      -- Font ROM interface:
      -- Convert 1x1 pixel to 8x16 character tile, new coordinate system
      text_x <= pixel_x(9 downto 3); -- Mod-8 
      text_y <= pixel_y(9 downto 4); -- Mod-16 
          
      -- Process to generate ascii codes to index font ROM
      ASCII_GEN:process(clk, text_x, text_y)
        variable txt_x : integer range 0 to 80; -- 80 horizontal character tiles
        variable txt_y : integer range 0 to 30; -- 30 vertical character tiles
      begin
        txt_x := to_integer(unsigned(text_x));
        txt_y := to_integer(unsigned(text_y));
        if rising_edge(clk) then    
            if i_clk_enable = '1' then
                case txt_y is        
                
                -- Text Region 1
                when 1 =>         
                    if txt_x > 0 and txt_x < 16 then 
                        ascii_string <= vertical_scale_str; 
                    elsif txt_x > 16 and txt_x < 32 then    
                        ascii_string <= horizontal_scale_str;
                    elsif txt_x > 32 and txt_x < 48 then
                        ascii_string <= delay_str;
                    elsif txt_x > 48 and txt_x < 64 then
                        ascii_string <= trigger_level_str;
                    elsif txt_x > 64 and txt_x < 80 then   
                        ascii_string <= trigger_mode_str;
                    end if;
                
                    text_on_reg <= '1';
                    
                -- Text region 2
                when 5 => 
                    if txt_x > 64 and txt_x < 80 then           
                        ascii_string <= sample_rate_str;    
                        text_on_reg <= '1';         
                    else
                        text_on_reg <= '0';
                    end if;
                when 7 => 
                    if txt_x > 64 and txt_x < 80 then           
                        ascii_string <= frequency_str;             
                        text_on_reg <= '1';         
                    else
                        text_on_reg <= '0';
                    end if;           
                when 9 => 
                    if txt_x > 64 and txt_x < 80 then           
                        ascii_string <= voltage_max_str;
                        text_on_reg <= '1';         
                    else
                        text_on_reg <= '0';
                    end if;
                when 11 =>
                    if txt_x > 64 and txt_x < 80 then           
                        ascii_string <= voltage_min_str;
                        text_on_reg <= '1';         
                    else
                        text_on_reg <= '0';
                    end if; 
                when 13 =>
                    if txt_x > 64 and txt_x < 80 then           
                        ascii_string <= voltage_avg_str;
                        text_on_reg <= '1';         
                    else
                        text_on_reg <= '0';
                    end if;
                when 15 =>
                    if txt_x > 64 and txt_x < 80 then           
                        ascii_string <= voltage_pp_str;
                        text_on_reg <= '1';         
                    else
                        text_on_reg <= '0';
                    end if;
        
                -- Text Region 3
                when 25 => 
                    if txt_x > 0 and txt_x < 16 then 
                        ascii_string <= x1_cursor_str; 
                        text_on_reg <= '1';         
                    elsif txt_x > 16 and txt_x < 32 then    
                        ascii_string <= y1_cursor_str;
                        text_on_reg <= '1';         
                    else
                        text_on_reg <= '0';         
                    end if;            
                    
                when 27 => 
                    if txt_x > 0 and txt_x < 16 then
                        ascii_string <= x2_cursor_str;
                        text_on_reg <= '1';         
                    elsif txt_x > 16 and txt_x < 32 then
                        ascii_string <= y2_cursor_str;
                        text_on_reg <= '1';         
                    else
                        text_on_reg <= '0';         
                    end if;            
                when 29 => 
                    if txt_x > 0 and txt_x < 16 then
                        ascii_string <= x_cursor_delta_str;
                        text_on_reg <= '1';                         
                    elsif txt_x > 16 and txt_x < 32 then
                        ascii_string <= y_cursor_delta_str;
                        text_on_reg <= '1';         
                    else
                        text_on_reg <= '0';         
                    end if;              
                                               
                -- No text                                   
                when others => 
                    text_on_reg <= '0';         
                    for i in 0 to 15 loop
                        ascii_string(7*(i+1) - 1 downto 7*i) <= char_to_slv(' ');
                    end loop; 
                end case;   
            
                str_idx <= text_x(3 downto 0); 
                str_idx_reg <= str_idx;
                string_idx <= to_integer(unsigned(str_idx));                               
            end if;
      end if;
      end process;
    
    ascii_code <= ascii_string(7*(string_idx+1) - 1 downto 7*string_idx);           
    rom_addr <= ascii_code & row_addr;
    row_addr <= pixel_y (3 downto 0);
    bit_addr <= pixel_x (2 downto 0);     
    font_bit <= font_word(to_integer(unsigned(not bit_addr)));
    text_on <= text_on_reg;

    rgb_text <= x"0BF" when (video_on = '1' and font_bit = '1') and text_on_reg = '1' else x"000";
end MIXED;