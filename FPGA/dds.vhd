----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/14/2024 01:50:08 PM
-- Design Name: 
-- Module Name: dds - Behavioral
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

----------------------------------------------------------------------------------
-- Frequency Register
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity frequency_reg is
	generic (a : positive);
	port(
		load : in std_logic; -- enable register to load data
		clk : in std_logic; -- system clock
		reset : in std_logic; -- active low asynchronous reset
		d : in std_logic_vector(a-1 downto 0); -- data input
		q : out std_logic_vector(a-1 downto 0) -- register output
		);
end frequency_reg;		 

architecture behavioral of frequency_reg is
begin
	process(clk, reset)	
		variable reg : std_logic_vector(a-1 downto 0);
	begin 			
		if reset = '1' then
			q <= (others => '0');
			reg := (others => '0');
		elsif rising_edge(clk) then
			if load = '1' then
				reg := d;
			end if;
			q <= reg;
		end if;
	end process;
end behavioral;	


----------------------------------------------------------------------------------
-- Phase Accumulator
----------------------------------------------------------------------------------
library ieee;				
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity phase_accumulator is
	generic(
		a : positive;-- width of phase accumulator
		m : positive -- width of phase accum output
		);
	port(
		clk : in std_logic; -- system clock
		reset : in std_logic; -- asynchronous reset
		d : in std_logic_vector(a - 1 downto 0); -- count delta
		pos : out std_logic;
		q : out std_logic_vector(m - 1 downto 0) -- phase acc. output	 
		);
end phase_accumulator;		   

architecture behavioral of phase_accumulator is	
	signal temp : std_logic_vector(a downto 0);	-- stores roll around value for 1 clock
	signal counter_reg : std_logic_vector(a-1 downto 0); 
	signal p : std_logic;
begin
	process(clk, reset)
		-- unsigned variables
		variable count_var : unsigned(a-1 downto 0);
		-- integer variables
		variable max_count, min_count : integer;
		variable delta : integer;
	begin
		if reset = '1' then 
			q <= (others => '0');				  
			counter_reg <= (others => '0');
			temp <= (others => '0');
			p <= '1';
		elsif rising_edge(clk) then	
			-- convert d input to integer
			delta := to_integer(unsigned(d));
			
			-- define limits
			max_count := (2**a)-1-delta;	-- count + delta cannot exceed all 1's
			min_count := delta;		-- count minus delta cannot go below all 0's 
			
			-- counter register	new value
			count_var := unsigned(counter_reg);	-- store register value
			
			if count_var(a-1) = '1' then-- check for roll around		
			    p <= '1';
			else 
			    p <= '0';					
			end if;		
            
            count_var := count_var + unsigned(d);
            	
			-- update counter register and output
			counter_reg <= std_logic_vector(count_var);
			q <= counter_reg(a-1 downto (a-m));
			pos <= p;
		end if;
	end process;
end behavioral;

----------------------------------------------------------------------------------
-- Adder Subtracter
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adder_subtracter is		
   generic(m : positive);
	port (
		pos : in std_logic;-- indicates pos. or neg. half of cycle
		sine_value : in std_logic_vector(m-1 downto 0);-- from sine table
		dac_sine_val : out std_logic_vector(m downto 0)-- output to DAC
		);
end adder_subtracter;

architecture behavioral of adder_subtracter is
begin 
--	process(pos, sine_value)
--		variable x : unsigned (m downto 0);
--	begin	
--		x := unsigned ('1' & sine_value);
--		if pos = '0' then	
--			dac_sine_val <= '1' & sine_value(m-2 downto 0); 		
--		else
--			dac_sine_val <= '0' & sine_value(m-2 downto 0); 
--		end if;
--	end process;

    dac_sine_val(m) <= not sine_value(m-1);
    dac_sine_val(m-1 downto 1) <= sine_value(m-2 downto 0);
    dac_sine_val(0) <= '1';

end behavioral;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity dds_w_freq_select is
	generic (a : positive; m : positive);
	 port(
		 clk : in std_logic;-- system clock
		 reset : in std_logic;-- asynchronous reset
		 freq_val : in std_logic_vector(a - 1 downto 0);-- selects frequency
		 load_freq : in std_logic;-- pulse to load a new frequency selection
		 dac_sine_value : out std_logic_vector(m downto 0);-- output to DAC
		 pos_sine : out std_logic; -- positive half of sine wave cycle
		 
		 -- MASTER AXIS DATA
--         M_AXIS_DATA_0_tdata : out STD_LOGIC_VECTOR (15 downto 0);
--         M_AXIS_DATA_0_tready : in STD_LOGIC;
         M_AXIS_DATA_0_tvalid : out STD_LOGIC;
         
         -- MASTER AXIS PHASE
--         M_AXIS_PHASE_0_tdata : out STD_LOGIC_VECTOR (15 downto 0);
--         M_AXIS_PHASE_0_tready : in STD_LOGIC;
--         M_AXIS_PHASE_0_tvalid : out STD_LOGIC;
      
         -- SLAVE AXIS PHASE
--         S_AXIS_PHASE_0_tdata : in STD_LOGIC_VECTOR (15 downto 0);
--         S_AXIS_PHASE_0_tready : out STD_LOGIC;
         S_AXIS_PHASE_0_tvalid : in STD_LOGIC		 		 
		 );
end dds_w_freq_select;


architecture structural of dds_w_freq_select is

  -- IP Block Diagram Component declaration
  component DDS_compiler
    port (
      M_AXIS_DATA_0_tdata : out STD_LOGIC_VECTOR (15 downto 0);
      M_AXIS_DATA_0_tvalid : out STD_LOGIC;
      S_AXIS_PHASE_0_tdata : in STD_LOGIC_VECTOR (15 downto 0);
      S_AXIS_PHASE_0_tvalid : in STD_LOGIC;
      clk_in1_0 : in STD_LOGIC;
      reset_0 : in STD_LOGIC
    );
  end component;
  
  -- DDS Internal Signals
	signal s1 : std_logic_vector(a-1 downto 0);	    -- frequency input
	signal s2 : std_logic_vector(a-1 downto 0);	    -- frequency register output
	signal s3 : std_logic_vector(m-1 downto 0);	    -- DDS compiler sine table input
	signal s4 : std_logic_vector(m-1 downto 0);	    -- DDS compiler sine table output
	signal s5: std_logic;	                        -- phase accumulator fsm 'pos' output 
	signal s6: std_logic_vector(m downto 0);	    -- dac sine value output	
begin		 
	s1 <= freq_val;
			
		u1: entity frequency_reg 
		generic map(a => a)
		port map(
			load => load_freq,
			clk => clk,
			reset => reset, 
			d => s1,
			q => s2);
		
	u2: entity phase_accumulator
		generic map(a => a, m=> m)
		port map(	 
			clk => clk, 
			reset => reset,
			d => s2,
			pos => s5,
			q => s3);
		
	u3: DDS_compiler
    port map (
      M_AXIS_DATA_0_tdata => s4,
      M_AXIS_DATA_0_tvalid => M_AXIS_DATA_0_tvalid,
           
      S_AXIS_PHASE_0_tdata => s3,
      S_AXIS_PHASE_0_tvalid => S_AXIS_PHASE_0_tvalid,
      
      clk_in1_0 => clk,
      reset_0 => reset
    );
	
	u6: entity adder_subtracter
		generic map(m=> m)
		port map(
			pos => s5, 
			sine_value => s4,
			dac_sine_val => s6);
		
		pos_sine <= s5;
		dac_sine_value <= s6;
end structural;