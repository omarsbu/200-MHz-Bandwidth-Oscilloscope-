library ieee;
library std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use WORK.ALL;

entity VGA_TIMING_GENERATOR_TB is
end VGA_TIMING_GENERATOR_TB;

architecture TB of VGA_TIMING_GENERATOR_TB is
    function char_to_slv (char : character) return std_logic_vector is
        variable slv : std_logic_vector(6 downto 0);
    begin
            slv := std_logic_vector(to_unsigned(character'pos(char), 7));
        return slv;
    end function;      

    signal clk  : std_logic := '0';
    signal i_reset  : std_logic;
    signal i_enable : std_logic; 
    signal column   : std_logic_vector(9 downto 0);
    signal row      : std_logic_vector(9 downto 0);
    signal video_on : std_logic;    
    signal H_SYNC   : std_logic;
    signal V_SYNC   : std_logic;
    signal text_on   : std_logic;
    signal rgb_text : std_logic_vector(11 downto 0);
   
    signal horizontal_scale_str : std_logic_vector(111 downto 0);
    signal vertical_scale_str   : std_logic_vector(111 downto 0);
    signal delay_str            : std_logic_vector(111 downto 0);
    signal trigger_level_str    : std_logic_vector(111 downto 0);
    signal trigger_mode_str     : std_logic_vector(111 downto 0);
    signal sample_rate_str      : std_logic_vector(111 downto 0);
    signal frequency_str        : std_logic_vector(111 downto 0);
    signal voltage_pp_str       : std_logic_vector(111 downto 0);
    signal voltage_avg_str      : std_logic_vector(111 downto 0);
    signal voltage_max_str      : std_logic_vector(111 downto 0);
    signal voltage_min_str      : std_logic_vector(111 downto 0);
    signal x1_cursor_str        : std_logic_vector(111 downto 0);
    signal x2_cursor_str        : std_logic_vector(111 downto 0);
    signal x_cursor_delta_str   : std_logic_vector(111 downto 0);
    signal y1_cursor_str        : std_logic_vector(111 downto 0);
    signal y2_cursor_str        : std_logic_vector(111 downto 0);
    signal y_cursor_delta_str   : std_logic_vector(111 downto 0);  

    constant period : time :=  40 ns;   -- 25MHz clock

    constant space : string := " ";
    constant colon : string := ":";

    constant str1 : string  := "100mV/DIV       ";
    constant str2 : string  := "100us/DIV       ";
    constant str3 : string  := "Delay: 100us    ";
    constant str4 : string  := "TRG LVL: 100mV  ";
    constant str5 : string  := "(RISING)        ";
    constant str6  : string := "100MSa/s        ";
    constant str7  : string := "Freq: 100MHz    ";
    constant str8  : string := "V(max): 100mV   ";
    constant str9  : string := "V(min): 100mV   ";
    constant str10 : string := "V(avg): 100mV   ";
    constant str11 : string := "V(p-p): 100mV   ";
    constant str12 : string := "X1: 100us       ";
    constant str13 : string := "X2: 100us       ";
    constant str14 : string := "Y1: 100mV       ";
    constant str15 : string := "Y2: 100mV       ";
    constant str16 : string := "(X2-X1): 100us  ";
    constant str17 : string := "(Y2-Y1): 100mV  ";

begin
	i_reset <= '1', '0' after 10 * period;
	i_enable <= '1';
    
    process    
    begin       
        for i in 0 to 15 loop
            vertical_scale_str(7*(i+1) - 1 downto 7*i)   <= char_to_slv(str1(i+1));
            horizontal_scale_str(7*(i+1) - 1 downto 7*i) <= char_to_slv(str2(i+1));                   
            delay_str(7*(i+1) - 1 downto 7*i)            <= char_to_slv(str3(i+1));
            trigger_level_str(7*(i+1) - 1 downto 7*i)    <= char_to_slv(str4(i+1));
            trigger_mode_str(7*(i+1) - 1 downto 7*i)     <= char_to_slv(str5(i+1));
            sample_rate_str(7*(i+1) - 1 downto 7*i)      <= char_to_slv(str6(i+1));
            frequency_str(7*(i+1) - 1 downto 7*i)        <= char_to_slv(str7(i+1));

            voltage_max_str(7*(i+1) - 1 downto 7*i)      <= char_to_slv(str8(i+1));
            voltage_min_str(7*(i+1) - 1 downto 7*i)      <= char_to_slv(str9(i+1));
            voltage_avg_str(7*(i+1) - 1 downto 7*i)      <= char_to_slv(str10(i+1));
            voltage_pp_str(7*(i+1) - 1 downto 7*i)       <= char_to_slv(str11(i+1));

            x1_cursor_str(7*(i+1) - 1 downto 7*i)        <= char_to_slv(str12(i+1));
            x2_cursor_str(7*(i+1) - 1 downto 7*i)        <= char_to_slv(str13(i+1));
            y1_cursor_str(7*(i+1) - 1 downto 7*i)        <= char_to_slv(str14(i+1));
            y2_cursor_str(7*(i+1) - 1 downto 7*i)        <= char_to_slv(str15(i+1));
            x_cursor_delta_str(7*(i+1) - 1 downto 7*i)   <= char_to_slv(str16(i+1));
            y_cursor_delta_str(7*(i+1) - 1 downto 7*i)   <= char_to_slv(str17(i+1));      
        end loop;
        
        wait;
    end process;
              
	-- Instantiate Unit Under Test
	U0: entity VGA_TIMING_GENERATOR  
    port map(
        clk => clk,
        i_reset => i_reset,
        i_enable => i_enable,
        o_column => column,
        o_row => row,
        o_video_on => video_on,
        H_SYNC => H_SYNC,
        V_SYNC => V_SYNC
    );	  

    U1: entity VGA_TEXT_GENERATOR
    port map(
        clk => clk,
        video_on => video_on,        
        pixel_x => column,
        pixel_y => row,
        horizontal_scale_str  => horizontal_scale_str,
        vertical_scale_str    => vertical_scale_str,
        delay_str             => delay_str,
        trigger_level_str     => trigger_level_str,
        trigger_mode_str      => trigger_mode_str,
        sample_rate_str       => sample_rate_str,
        frequency_str         => frequency_str,
        voltage_pp_str        => voltage_pp_str,
        voltage_avg_str       => voltage_avg_str,
        voltage_max_str       => voltage_max_str,
        voltage_min_str       => voltage_min_str,
        x1_cursor_str         => x1_cursor_str,
        x2_cursor_str         => x2_cursor_str,
        x_cursor_delta_str    => x_cursor_delta_str,
        y1_cursor_str         => y1_cursor_str,
        y2_cursor_str         => y2_cursor_str,
        y_cursor_delta_str    => y_cursor_delta_str,
        text_on => text_on,
        rgb_text => rgb_text
    );
    
    output_process : process (clk)
        file vga_log : text is out "vga_log.txt";
        variable vga_line : line;
    begin
        if (rising_edge(clk)) then
            write(vga_line, now);
            write(vga_line, colon & space);
            write(vga_line, H_SYNC);
            write(vga_line, space);
            write(vga_line, V_SYNC);
            write(vga_line, space);
            write(vga_line, rgb_text(11 DOWNTO 8));
            write(vga_line, space);
            write(vga_line, rgb_text(7 DOWNTO 4));
            write(vga_line, space);
            write(vga_line, rgb_text(3 DOWNTO 0));
            writeline(vga_log, vga_line);
        end if;
    end process;


    -- Process to generate pixel clock
	CLOCK: process				
	begin
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
	end process;
	
end TB;
