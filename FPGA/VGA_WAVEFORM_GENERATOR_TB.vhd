library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity VGA_CONTROLLER_TB is
end entity;

architecture TB of VGA_CONTROLLER_TB is

    -- Constants
    constant CLK_PERIOD       : time := 40 ns;  -- 25 MHz
    constant data_WIDTH       : integer := 10;
    constant LEN              : integer := 640;

    -- Signals
    signal i_pixel_clk    : std_logic := '0';
    signal i_sampling_clk : std_logic := '0';
    signal i_reset        : std_logic := '0';
    signal i_enable       : std_logic := '1';

    signal o_address      : std_logic_vector(9 downto 0);
    signal data_in,d        : std_logic_vector(data_WIDTH-1 downto 0);
    signal o_RED          : std_logic_vector(3 downto 0);
    signal o_GREEN        : std_logic_vector(3 downto 0);
    signal o_BLUE         : std_logic_vector(3 downto 0);
    signal H_SYNC         : std_logic;
    signal V_SYNC         : std_logic;

    -- Sine ROM
    type sine_array_t is array(0 to LEN - 1) of std_logic_vector(data_WIDTH-1 downto 0);
    signal sine_rom : sine_array_t;

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
    UUT: entity work.VGA_CONTROLLER
        generic map (
            data_WIDTH => data_WIDTH,
            LEN        => LEN
        )
        port map (
            i_pixel_clk    => i_pixel_clk,
            i_reset        => i_reset,
            i_enable       => i_enable,
            o_address      => o_address,
            i_data        => data_in,
            o_RED          => o_RED,
            o_GREEN        => o_GREEN,
            o_BLUE         => o_BLUE,
            H_SYNC         => H_SYNC,
            V_SYNC         => V_SYNC
        );

    ----------------------------------------------------------------
    -- Sine ROM Initialization
    ----------------------------------------------------------------
    rom_init_proc : process
        variable angle : real;
        variable val   : integer;
    begin
        for j in 0 to 1000 loop
        for i in 0 to LEN-1 loop
            angle := 2.0 * math_pi * real(i) / real(LEN);
            val := integer(127.5 * sin(5*angle) + 127.5); -- unsigned 0 to 255
            sine_rom(i) <= std_logic_vector(to_unsigned(val, data_WIDTH));
        end loop;
        end loop;
        wait;
    end process;
    

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

    data_in <= sine_rom(to_integer(unsigned(o_address)));

        
end architecture;
