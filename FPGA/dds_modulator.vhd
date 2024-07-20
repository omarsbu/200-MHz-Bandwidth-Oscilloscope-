----------------------------------------------------------------------------------
-- Frequency Register
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity frequency_reg is
	generic (a : positive);
	port(
		load : in std_logic; 				-- enable register to load data
		clk : in std_logic; 				-- system clock
		reset : in std_logic; 				-- active low asynchronous reset
		d : in std_logic_vector(a-1 downto 0); 		-- data input
		q : out std_logic_vector(a-1 downto 0) 		-- register output
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
		clk : in std_logic; 					-- system clock		
		reset : in std_logic; 					-- asynchronous reset
		phase_inc : in std_logic_vector(a - 1 downto 0);	-- phase increment
		pos : out std_logic;					-- Pos or neg half of sinusoid: 0b => 0-pi radians; 1b => pi-2pi radians 
		phase_out : out std_logic_vector(m - 1 downto 0) 	-- phase accumulator output	 
		);
end phase_accumulator;		   

architecture behavioral of phase_accumulator is	
	signal counter_reg : std_logic_vector(a-1 downto 0); 
	signal pos_signal : std_logic;
begin
	process(clk, reset)
		variable count_var : unsigned(a-1 downto 0);
		variable delta : integer;	-- Phase increment variable
	begin
		if reset = '1' then 
			phase_out <= (others => '0');				  
			counter_reg <= (others => '0');
			pos_signal <= '0';
		elsif rising_edge(clk) then	
			delta := to_integer(unsigned(phase_inc));				
			count_var := unsigned(counter_reg);	

			-- Check for zero-crossing: Positive or Negative half of sinusoid?
			if count_var(a-1) = '1' then		
			    pos_signal <= '1';
			else 
			    pos_signal <= '0';					
			end if;		
            
            		count_var := count_var + unsigned(phase_inc);	-- Update counter variable
            	
			-- Update signals and output ports
			counter_reg <= std_logic_vector(count_var);
			phase_out <= counter_reg(a-1 downto (a-m));
			pos <= pos_signal;
		end if;
	end process;
end behavioral;

----------------------------------------------------------------------------------
-- 2's Compliment to Hexadecimal
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TwosComp_to_Hex is		
   generic(m : positive);
	port (
		pos : in std_logic;					-- 2's compliment MSB: 0b => positive; 1b => negative
		twos_comp_in : in std_logic_vector(m-1 downto 0);	-- 2's compliment input
		hex_out : out std_logic_vector(m-1 downto 0)		-- Hexadecimal output to
		);
end TwosComp_to_Hex;

architecture behavioral of TwosComp_to_Hex is
begin 
	-- Flip MSB in 2's compliment representation
	hex_out(m - 1) <= not twos_comp_in(m - 1);
	hex_out (m-2 downto 0) <= twos_comp_in(m-2 downto 0);
end behavioral;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity dds_modulator is
	generic (a : positive; m : positive);
	 port(
		 clk : in std_logic;					-- system clock
		 reset : in std_logic;					-- asynchronous reset
		 freq_val : in std_logic_vector(a - 1 downto 0);	-- selects modulating frequency (SLAVE AXIS TDATA)
		 load_freq : in std_logic;				-- pulse to load a new frequency selection
		 freq_in : in std_logic_vector (m - 1 downto 0);	-- input carrier frequency
		 freq_out : out std_logic_vector(2*m - 1 downto 0);	-- modulated output frequency
		 pos_sine : out std_logic; 				-- positive half of sine wave cycle
         	 M_AXIS_DATA_0_tvalid : out STD_LOGIC;			-- MASTER AXIS TVALID
         	 S_AXIS_PHASE_0_tvalid : in STD_LOGIC			-- SLAVE AXIS TVALID	 		  		 
		 );
end dds_modulator;

architecture structural of dds_modulator is

  -- IP Block Diagram Component declaration
  component DDS_compiler
    port ( 
    	A_0 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    	B_0 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    	M_AXIS_DATA_0_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 );
    	M_AXIS_DATA_0_tvalid : out STD_LOGIC;
    	P_0 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    	S_AXIS_PHASE_0_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
    	S_AXIS_PHASE_0_tvalid : in STD_LOGIC;
    	clk_in1_0 : in STD_LOGIC;
    	m_axis_data_tdata_0 : out STD_LOGIC_VECTOR ( 15 downto 0 );
    	reset_0 : in STD_LOGIC
    );
  end component;
  
  -- DDS Internal Signals
	signal s1 : std_logic_vector(a-1 downto 0);     -- frequency input
	signal s2 : std_logic_vector(a-1 downto 0);     -- frequency register output
	signal s3 : std_logic_vector(m-1 downto 0);     -- modulating DDS compiler input
	signal s4 : std_logic_vector(m-1 downto 0);     -- modulating DDS compiler output => 2's comliment
	signal s5: std_logic;	                        -- phase accumulator 'pos' output 
	signal s6: std_logic_vector(m-1 downto 0);	-- modulating frequency hexadecimal output	
	signal s7 : std_logic_vector(m-1 downto 0);    	-- carrier frequency => 2's compliment
	signal s8 : std_logic_vector(m-1 downto 0);     -- carrier frequency => hexadecimal
    signal s9 : std_logic_vector(2*m - 1 downto 0); 	-- modulated output	
begin		 
	s1 <= freq_val;

	-- Instantiate frequency register
	u1: entity frequency_reg 
		generic map(a => a)
		port map(
			load => load_freq,
			clk => clk,
			reset => reset, 
			d => s1,
			q => s2);
		
	-- Instantiate phase accumulator
	u2: entity phase_accumulator
		generic map(a => a, m=> m)
		port map(	 
			clk => clk, 
			reset => reset,
			phase_inc => s2,	-- phase increment <= frequency register output 
			pos => s5,	
			phase_out => s3);	

	u3: entity TwosComp_to_Hex
		generic map(m=> m)
		port map(
			pos => s5,
			twos_comp_in => s4,	-- Modulating DDS compiler 2's compliment value
			hex_out => s6);		-- Modulating DDS compiler hexadecimal output

	u4: entity TwosComp_to_Hex
		generic map(m=> m)
		port map(
			pos => s5,
			twos_comp_in => s7,	-- Carrier frequency 2's compliment value
			hex_out => s8);		-- Carrier frequency hexadecimal value

		
	-- Instantiate DDS compiler IP core
	u5: DDS_compiler
    		port map (
            		A_0 => s6,			-- Multiplier input A <= modulating frequency
             		B_0 => s8,			-- Multiplier input B <= carrier frequency
            		M_AXIS_DATA_0_tdata => s4,
            		M_AXIS_DATA_0_tvalid => M_AXIS_DATA_0_tvalid,	
            		P_0 => s9,			-- Multiplier output signal => modulated output 
            		S_AXIS_PHASE_0_tdata => s3,	-- Modulating frequency phase accumulator value	
            		S_AXIS_PHASE_0_tvalid => S_AXIS_PHASE_0_tvalid,
            		clk_in1_0 => clk,
            		m_axis_data_tdata_0 => s7,	-- carrier frequency <= output of test DDS_compiler
            		reset_0 => reset);
            	
	-- Update output signals
	pos_sine <= s5;
	freq_out <= s9;
	M_AXIS_DATA_0_tvalid <= '1';
end structural;
