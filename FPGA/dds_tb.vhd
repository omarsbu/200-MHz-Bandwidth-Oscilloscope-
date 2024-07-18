----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/14/2024 01:55:32 PM
-- Design Name: 
-- Module Name: dds_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity dds_w_freq_select_tb is
	-- Generic declarations of the tested unit
		generic(
		a : positive := 16;
		m : positive := 16 );
end dds_w_freq_select_tb;

architecture tb_architecture of dds_w_freq_select_tb is

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : std_logic := '0';
	signal reset: std_logic;
	signal freq_val : std_logic_vector(a-1 downto 0);
	signal load_freq : std_logic;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal freq_out : std_logic_vector(m-1 downto 0);

    signal M_AXIS_DATA_0_tvalid : STD_LOGIC;
    signal S_AXIS_PHASE_0_tvalid : STD_LOGIC;
	
	constant period : time := 1 us;

begin
	-- Unit Under Test port map
	UUT : entity dds_w_freq_select
		generic map (
			a => a,
			m => m
		)

		port map (
			clk => clk,
			reset => reset,
			freq_val => freq_val,
			load_freq => load_freq,
			freq_out => freq_out,
            M_AXIS_DATA_0_tvalid => M_AXIS_DATA_0_tvalid,
            S_AXIS_PHASE_0_tvalid => S_AXIS_PHASE_0_tvalid
		);
		
	  S_AXIS_PHASE_0_tvalid <= '1';
	
	-- insert integer value to observe a particular frequency
	freq_val <= std_logic_vector(to_unsigned(2**13,a));
	
	load_freq <= '0', '1' after 7 * period, '0' after 10 * period;
		
	reset <= '1', '0' after 4 * period;	-- reset signal
	
	clock: process				-- system clock
	begin
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
	end process;
end tb_architecture;
