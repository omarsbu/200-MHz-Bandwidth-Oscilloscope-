----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: Trigger Module
--
-- Description: Provides a positive pulse when the trigger condition is met.
--
-- Inputs:
--    clk : system clock
--    i_reset : Active-high Synchronous reset
--    i_enable: Active-high Enable
--    i_trigger_type : Trigger type (rising or falling edge)
--    i_trigger_lvl : Trigger threshold level
--    i_data : Input data sequence
--
-- Outputs:
--    o_trigger_pulse : Trigger pulse for data capture
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity TRIGGER_MODULE is
    generic (data_WIDTH : positive);
    port (
        clk            : in std_logic;
        i_sample_clk_en   : in std_logic;
        i_reset        : in std_logic;
        i_trigger_type : in std_logic;
        i_trigger_lvl  : in std_logic_vector(data_WIDTH - 1 downto 0);        
        i_data         : in std_logic_vector(data_WIDTH - 1 downto 0);
        o_trigger_en : out std_logic    
    );
end TRIGGER_MODULE;

architecture RTL of TRIGGER_MODULE is
    signal sample_reg, delay_reg, threshold_reg : signed(data_WIDTH - 1 downto 0);  
    signal flag_reg : std_logic_vector(1 downto 0);
    signal out_reg, trigger_pulse : std_logic;
    signal rising_edge_flag, falling_edge_flag : std_logic;
    signal delay_compare, sample_compare : std_logic;
begin            
    process(clk)
    begin
    if rising_edge(clk) then 
		  if i_reset = '1' then
		      sample_reg <= (others => '0');
		      delay_reg <= (others => '0');
		      threshold_reg <= (others => '0');
		      flag_reg <= (others => '0');		      
		      out_reg <= '0';
		  elsif i_sample_clk_en = '1' then 		      
		      sample_reg <= signed(i_data);    
		      delay_reg <= sample_reg;  		  
		      threshold_reg <=  signed(i_trigger_lvl);                
		      flag_reg <= std_logic_vector'(rising_edge_flag, falling_edge_flag);
		      out_reg <= trigger_pulse;
		  end if;
    end if;
    end process;
   
    -- Compare current and previous sample to trigger level
    delay_compare <= '1' when (delay_reg > threshold_reg) else '0';
    sample_compare <= '1' when (sample_reg > threshold_reg) else '0';
    
    -- Detect rising edge: previous sample < threshold AND current sample > threshold
    with std_logic_vector'(delay_compare & sample_compare) select
        rising_edge_flag <= '1' when "01",
                            '0' when others;        

    -- Detect falling edge: previous sample > threshold AND current sample < threshold
    with std_logic_vector'(delay_compare & sample_compare) select
        falling_edge_flag <= '1' when "10",
                            '0' when others;
    
    -- Select trigger signal based on trigger type
    with i_trigger_type select
        trigger_pulse <= flag_reg(0) when '1',
                            flag_reg(1) when others;
    
    -- Output buffer register                        
    o_trigger_en <= out_reg;                                                                         
end RTL;