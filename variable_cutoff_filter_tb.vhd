library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.all;

entity variable_fir_filter_tb is
	-- Generic declarations of the tested unit
		generic(
		a : positive := 12;	-- filter cutoff select
		w : positive := 12 );	-- input/output width
end variable_fir_filter_tb;


architecture behavioral of variable_filter_tb is
    -- AXI4 Interface
    signal M_AXIS_DATA_0_tvalid : std_logic;
    signal S_AXIS_PHASE_0_tvalid : std_logic;
    
    -- Control and Data signals
    signal clk : std_logic := '0';
    signal reset : std_logic;
    signal filter_cutoff : std_logic_vector (a-1 downto 0);
    signal load_filter_cutoff : std_logic_vector (w-1 downto 0);
    signal input_signal : std_logic_vector (w-1 downto 0);
    signal output_signal :std_logic_vector (w-1 downto 0);

    constant period : time := 10 ns;
begin
	
	UUT: entity variable_fir_filter 
	generic map(a => a, w => w);
	port map(
         	M_AXIS_DATA_0_tvalid => M_AXIS_DATA_0_tvalid,
         	S_AXIS_PHASE_0_tvalid => S_AXIS_PHASE_0_tvalid,
		clk => clk,
		reset => reset,
		filter_cutoff => filter_cutoff,
		load_filter_cutoff => load_filter_cutoff,
		input_signal => input_signal,
		output_signal => output_signal);

	S_AXIS_PHASE_0_tvalid <= '1';	
	
	-- Assert then dessert reset
	reset <= '1', '0' after 5 * period;

	-- Load a cutoff frequency
	load_filter_cutoff <= '0';
	filter_cutoff <= "000011110000";
