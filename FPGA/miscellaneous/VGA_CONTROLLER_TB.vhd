library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.ALL;

entity VGA_TIMING_GENERATOR_TB is
end VGA_TIMING_GENERATOR_TB;

architecture TB of VGA_TIMING_GENERATOR_TB is
    signal clk  : std_logic := '0';
    signal i_reset  : std_logic;
    signal i_enable : std_logic; 
    signal H_SYNC   : std_logic;
    signal V_SYNC   : std_logic;
    
    constant period : time :=  40 ns;
begin
	i_reset <= '1', '0' after 10 * period;
	i_enable <= '1';
	
	-- Instantiate Unit Under Test
	UUT: entity VGA_TIMING_GENERATOR  
    port map(
        clk => clk,
        i_reset => i_reset,
        i_enable => i_enable,
        H_SYNC => H_SYNC,
        V_SYNC => V_SYNC
    );	  
    	
    -- Process to generate pixel clock
	CLOCK: process				
	begin
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
	end process;
end TB;
