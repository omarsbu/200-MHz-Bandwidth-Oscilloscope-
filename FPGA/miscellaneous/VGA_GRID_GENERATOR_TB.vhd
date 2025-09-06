library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity VGA_GRID_GENERATOR_TB is
end entity;

architecture TB of VGA_GRID_GENERATOR_TB is

    -- Constants
    constant CLK_PERIOD       : time := 40 ns;  -- 25 MHz
    constant data_WIDTH       : integer := 10;
    constant LEN              : integer := 640;

    -- Signals
    signal i_pixel_clk    : std_logic := '0';
    signal i_reset        : std_logic := '0';
    signal i_enable       : std_logic := '1';


    signal o_RED          : std_logic_vector(3 downto 0);
    signal o_GREEN        : std_logic_vector(3 downto 0);
    signal o_BLUE         : std_logic_vector(3 downto 0);
    signal H_SYNC         : std_logic;
    signal V_SYNC         : std_logic;

    constant space : string := " ";
    constant colon : string := ":";

begin

    ----------------------------------------------------------------
    -- Clock Generation
    ----------------------------------------------------------------
    clk_proc : process
    begin
        while true loop
            i_pixel_clk <= '0';
            i_sampling_clk <= '0';
            wait for CLK_PERIOD/2;
            i_pixel_clk <= '1';
            i_sampling_clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    ----------------------------------------------------------------
    -- Reset Logic
    ----------------------------------------------------------------
    reset_proc : process
    begin
        i_reset <= '1';
        wait for 100 ns;
        i_reset <= '0';
        wait;
    end process;

    ----------------------------------------------------------------
    -- Instantiate Unit Under Test (UUT)
    ----------------------------------------------------------------
    UUT: entity work.VGA_GRID_GENERATOR
        port map (
            i_pixel_clk    => i_pixel_clk,
            i_reset        => i_reset,
            i_enable       => i_enable,
            o_RED          => o_RED,
            o_GREEN        => o_GREEN,
            o_BLUE         => o_BLUE,
            H_SYNC         => H_SYNC,
            V_SYNC         => V_SYNC
        );
    
    output_process : process (i_pixel_clk)
        file vga_log : text is out "vga_log.txt";
        variable vga_line : line;
    begin
        if (rising_edge(i_pixel_clk)) then
            write(vga_line, now);
            write(vga_line, colon & space);
            write(vga_line, H_SYNC);
            write(vga_line, space);
            write(vga_line, V_SYNC);
            write(vga_line, space);
            write(vga_line, o_RED);
            write(vga_line, space);
            write(vga_line, o_GREEN);
            write(vga_line, space);
            write(vga_line, o_BLUE);
            writeline(vga_log, vga_line);
        end if;
    end process;
        
end architecture;
