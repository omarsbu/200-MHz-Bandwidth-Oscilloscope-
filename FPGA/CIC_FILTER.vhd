----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: CIC Integrator
--
-- Description: Output accumulates input data through summation with previous 
--  input data. Uses signed 2's compliment "roll-over" arithmetic logic.
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
USE IEEE.NUMERIC_STD.ALL;

entity CIC_INTEGRATOR is
	generic (data_WIDTH : positive);	
	port (
		clk : in std_logic;
		i_reset : in std_logic; 
		i_enable : in std_logic;
		i_data : in signed(data_WIDTH - 1 downto 0);
		o_data : out signed(data_WIDTH - 1 downto 0)
	);
end CIC_INTEGRATOR;

architecture RTL of CIC_INTEGRATOR is
	signal in_reg, out_reg : signed(data_WIDTH - 1 downto 0);
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
-- Name: CIC Comb
--
-- Description: Output combs the input through subtraction. The input is an 
--  accumulated summation from the integrator and the subtraction operation is
--  performed every R clock cycles to calculate the total change over the
--  interval being averaged. Since the subtraction operation is performed 
--  every R clock cycles, the comb also works as a downsampler
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
USE IEEE.NUMERIC_STD.ALL;

entity CIC_COMB is
	generic (data_WIDTH : positive; R : positive);	
	port (
		clk : in std_logic;
		i_reset : in std_logic; 
		i_enable : in std_logic;
		i_data : in signed(data_WIDTH - 1 downto 0);
		o_data : out signed(data_WIDTH - 1 downto 0)
	);
end CIC_COMB;

architecture RTL of CIC_COMB is
    signal delay_counter : integer range 0 to R-1;
	signal in_reg, delay_reg : signed(data_WIDTH - 1 downto 0);
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

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: CIC Filter
--
-- Description: A CIC decimation filter, the output signal is the input signal
--  decimated by a factor of R. The filter performs anti-aliasing by averaging
--  over an interval of R sample. The stopband attenuation is determined by the
--  number of integrator-comb stages N. A compensation FIR can be used to flatten  
--  the passband of the CIC filter. 
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
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;
USE WORK.ALL;

entity CIC_FILTER is
	generic (data_WIDTH : positive; R : positive; N : positive);	
	port (
		clk : in std_logic;
		i_reset : in std_logic; 
		i_enable : in std_logic;
		i_data : in signed(data_WIDTH - 1 downto 0);
		o_data : out signed(data_WIDTH - 1 downto 0)
	);
end CIC_FILTER;

architecture STRUCTURAL of CIC_FILTER is
    -- Compute the register widths of the CIC filter 
    constant REG_WIDTH : integer := integer (data_WIDTH) + integer(ceil(log2(real(N*R))));
    
    type pipeline is array (0 to N-1) of signed(REG_WIDTH - 1 downto 0);
    signal integrator_pipeline : pipeline; 
    signal comb_pipleine : pipeline;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            integrator_pipeline(0) <= resize(i_data, REG_WIDTH);        
            comb_pipleine(0) <= integrator_pipeline(N-1);        
            o_data <= resize(shift_right(signed(comb_pipleine(N-1)),R), data_WIDTH);
        end if;
    end process;
    
    INTEGRATOR_STAGE: for i in 1 to N-1 generate
        INTEGRATOR: entity CIC_INTEGRATOR
        generic map(data_WIDTH => data_WIDTH)	
        port map(
 		  clk => clk,
		  i_reset => i_reset, 
          i_enable => i_enable,
		  i_data => integrator_pipeline(i-1),
		  o_data => integrator_pipeline(i)
        );
    end generate;
   
    COMB_STAGE: for i in 1 to N-1 generate
        COMB:entity CIC_COMB
        generic map(data_WIDTH => data_WIDTH, R => R)	
        port map(
 		  clk => clk,
		  i_reset => i_reset, 
          i_enable => i_enable,
		  i_data => comb_pipleine(i-1),
		  o_data => comb_pipleine(i)      
        );
    end generate;
end STRUCTURAL;
