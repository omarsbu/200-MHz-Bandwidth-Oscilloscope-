----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- CIC Integrator
--
-- Description: Output accumulates input data through summation with previous 
--  input data. Uses signed 2's compliment "roll-over" arithmetic logic
--
-- Inputs:
--    clk : system clock
--    i_reset : Active-high Synchronous reset
--    i_enable: Active-high Enable
--    i_data : Input data sequence
--
-- Outputs:
--    o_data : Output data sequence
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CIC_INTEGRATOR is
	generic (data_WIDTH : positive);	
	port (
		clk : in std_logic;
		i_reset : in std_logic; 
		i_enable : in std_logic;
		i_data : in std_logic_vector(data_WIDTH - 1 downto 0);
		o_data : out std_logic_vector(data_WIDTH - 1 downto 0)
	);
end CIC_INTEGRATOR;

architecture RTL of CIC_INTEGRATOR is
	signal in_reg, out_reg : std_logic_vector(data_WIDTH - 1 downto 0);
begin
	process(clk)
	begin
		if rising_edge(clk) then
		  if i_reset = '1' then
		      in_reg <= (others => '0');
		      out_reg <= (others => '0');
		  elsif i_enable = '1' then
		      in_reg <= i_data;
		      out_reg <= in_reg + out_reg;
		  end if;
	   end if;
	end process;
				
	o_data <= out_reg;
end RTL;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- CIC Comb
--
-- Description: Output combs the input through subtraction. The input is an 
--  accumulated summation from the integrator and the subtraction operation is
--  performed every R clock cycles to calculate the total change over the
--  interval being averaged.
--
-- Inputs:
--    clk : system clock
--    i_reset : Active-high Synchronous reset
--    i_enable: Active-high Enable
--    i_data : Input data sequence
--
-- Outputs:
--    o_data : Output data sequence
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity CIC_COMB is
	generic (data_WIDTH : positive; R : positive);	
	port (
		clk : in std_logic;
		i_reset : in std_logic; 
		i_enable : in std_logic;
		i_data : in std_logic_vector(data_WIDTH - 1 downto 0);
		o_data : out std_logic_vector(data_WIDTH - 1 downto 0)
	);
end CIC_COMB;

architecture RTL of CIC_COMB is
    signal delay_counter : integer range 0 to R;
	signal in_reg, delay_reg : std_logic_vector(data_WIDTH - 1 downto 0);
begin
	process(clk)
	begin
		if rising_edge(clk) then
		  if i_reset = '1' then
		      delay_counter <= 0;
		      delay_reg <= (others => '0');
		      in_reg <= (others => '0');
		  elsif i_enable = '1' then
              if delay_counter = R-1 then    		  
                  delay_counter <= 0;
                  in_reg <= i_data;
                  delay_reg <= in_reg;
	   	      else
	   	          delay_counter <= delay_counter + 1;
              end if;
		  end if;
	   end if;
	end process;
				
	o_data <= in_reg - delay_reg;
end RTL;
