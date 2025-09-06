----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: CIC Integrator
--
-- Description: Output accumulates input data through summation with previous 
--  input data. Uses signed 2's compliment "roll-over" arithmetic logic. The 
--  register width can be programmed from the input port for dynamic sample rate.
--
-- Inputs:
--    clk : system clock
--    i_reset : Active-high Synchronous reset
--    i_reg_width : Width of the accumulator register
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
	generic (REG_WIDTH : positive := 8);	
	port (
		clk : in std_logic;
		i_reset : in std_logic; 		
		i_reg_width :  integer range 0 to REG_WIDTH - 1;
		i_data : in signed(REG_WIDTH - 1 downto 0);
		o_data : out signed(REG_WIDTH - 1 downto 0)
	);
end CIC_INTEGRATOR;

architecture RTL of CIC_INTEGRATOR is
	signal in_reg, out_reg : signed(REG_WIDTH - 1 downto 0);
begin        
	process(clk)
	begin
		if rising_edge(clk) then
		  if i_reset = '1' then		      
		      in_reg <= (others => '0');
		      out_reg <= (others => '0');
		  else		  	  	  
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
--  every R clock cycles, the comb also works as a downsampler. The register 
--  width is programmable to allow for dynamic adjustment of the sample rate.
--
-- Inputs:
--    clk : system clock
--    i_sample_clk : new sample rate clk	
--    i_reg_width : Width of the comb register
--    i_reset : Active-high Synchronous reset
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
	generic (REG_WIDTH : positive := 8);	
	port (
		clk : in std_logic;
		i_sample_clk_en : std_logic;
		i_reset : in std_logic; 
		i_reg_width : integer range 0 to REG_WIDTH - 1;
		i_data : in signed(REG_WIDTH - 1 downto 0);
		o_data : out signed(REG_WIDTH - 1 downto 0)
	);
end CIC_COMB;

architecture RTL of CIC_COMB is
	signal in_reg, delay_reg, o_reg : signed(REG_WIDTH - 1 downto 0);
begin	
	process (clk)
	begin
	if rising_edge(clk) then
	   if i_reset = '1' then
           delay_reg <= (others => '0');
	       in_reg <= (others => '0');
	       o_reg <= (others => '0');	
	   elsif i_sample_clk_en = '1' then
		   in_reg <= i_data;
           delay_reg <= in_reg;
           o_reg <= in_reg - delay_reg;
	   end if;
	end if;   
	end process;
	
	o_data <= o_reg;
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
--    i_sample_rate : new sample rate	
--    i_reset : Active-high Synchronous reset
--    log_2_R : log base 2 of rate change R
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
	generic (data_WIDTH : positive := 8; N : positive := 3);	
	port (
		clk : in std_logic;
		i_sample_clk_en : std_logic;
		i_reset : in std_logic; 
		log_2_R : std_logic_vector(4 downto 0);
		i_data : in std_logic_vector(data_WIDTH - 1 downto 0);
	    m_axis_data_tvalid : out std_logic;
        o_data : out std_logic_vector(data_WIDTH - 1 downto 0)
	);
end CIC_FILTER;

architecture STRUCTURAL of CIC_FILTER is
    -- Compute the register widths and division factor of the CIC filter 
    constant REG_ALLOC : integer := integer(data_WIDTH) + 31*integer(N);
    
    signal in_reg : signed(data_WIDTH - 1 downto 0);                     
    signal shift_value : integer range 0 to 31*integer(N);
    signal reg_width : integer range 0 to REG_ALLOC - 1;
    signal out_reg : unsigned(data_WIDTH - 1 downto 0);                     

    type pipeline is array (0 to N) of signed(REG_ALLOC - 1 downto 0);
    signal integrator_pipeline : pipeline; 
    signal comb_pipeline : pipeline;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            shift_value <= integer(N)*to_integer(unsigned(log_2_R));
            reg_width <= integer(data_WIDTH) + shift_value;
            in_reg <= signed(i_data);
            integrator_pipeline(0) <= resize(in_reg, REG_ALLOC);      
            comb_pipeline(0) <= integrator_pipeline(N);                                                       
            out_reg <= resize(shift_right(unsigned(comb_pipeline(N)), shift_value), data_WIDTH);
        end if;
    end process;

    INTEGRATOR_STAGE: for i in 0 to N-1 generate
        INTEGRATOR: entity CIC_INTEGRATOR
        generic map(REG_WIDTH => REG_ALLOC)
        port map(
 		  clk => clk,
		  i_reset => i_reset,
		  i_reg_width => reg_width, 
		  i_data => integrator_pipeline(i),
		  o_data => integrator_pipeline(i+1)
        );
    end generate;

    COMB_STAGE: for i in 0 to N-1 generate
        COMB: entity CIC_COMB
        generic map(REG_WIDTH => REG_ALLOC)
        port map(
 		  clk => clk,
		  i_reset => i_reset, 
          i_reg_width => reg_width,
          i_sample_clk_en => i_sample_clk_en,
		  i_data => comb_pipeline(i),
		  o_data => comb_pipeline(i+1)      
        );
    end generate;
    
    o_data <= std_logic_vector(out_reg);
    m_axis_data_tvalid <= '1';
end STRUCTURAL;