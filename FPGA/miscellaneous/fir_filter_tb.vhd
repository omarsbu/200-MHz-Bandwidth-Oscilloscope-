library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.all;

entity fir_filter_tb is
	-- Generic declarations of the tested unit
		generic(
		a : positive := 12;
		w : positive := 12 );
end fir_filter_tb;

architecture Behavioral of fir_filter_tb is
    signal clk : std_logic := '0';
--    signal reset : std_logic;
    signal address : std_logic_vector (a-1 downto 0);
    signal coefficient_val : std_logic_vector (w-1 downto 0);
    constant period : time := 10 ns;
begin

    UUT : entity coefficient_LUT
        generic map (a => 12, w => 12)
        port map(
            address => address,
		    coefficient_val => coefficient_val
        );

--    clock: process
--    begin
--        clk <= '0';
--        wait for period/2;
--        clk <= '1';
--        wait for period/2;
--    end process;

    stimulus: process   
    begin
        for i in 0 to 2**a - 1 loop
            address <= std_logic_vector(to_unsigned(i, a));
            wait for 2*period;  -- Adjust as needed for simulation
        end loop;    
    end process;
end Behavioral;
