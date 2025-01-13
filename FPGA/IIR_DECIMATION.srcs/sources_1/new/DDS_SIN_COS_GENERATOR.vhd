----------------------------------------------------------------------------------
-- Frequency Register
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity FREQUENCY_REG is
	generic (reg_WIDTH : positive);
	port(
		clk : in std_logic;
		reset : in std_logic;
		load : in std_logic;  -- enable register to load data
		d : in std_logic_vector(reg_WIDTH - 1 downto 0); 	-- data input
		q : out std_logic_vector(reg_WIDTH - 1 downto 0) 	-- register output
		);
end FREQUENCY_REG;		 

architecture BEHAVIORAL of FREQUENCY_REG is
begin
	process(clk)	
		variable reg : std_logic_vector(reg_WIDTH - 1 downto 0);
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
end BEHAVIORAL;	

----------------------------------------------------------------------------------
-- Phase Accumulator
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity PHASE_ACCUMULATOR is
	generic(
	   cnt_WIDTH : positive;    -- phase accumulator counter width
	   pout_WIDTH : positive    -- phase accumulator output width
	);
	port(
		clk : in std_logic; 							
		reset : in std_logic;
		phase_inc : in std_logic_vector(cnt_WIDTH - 1 downto 0);	     -- phase increment
		phase_offset: in std_logic_vector(cnt_WIDTH - 1 downto 0);       -- phase offset from 0 degrees
		phase_counter : out std_logic_vector(cnt_WIDTH - 1 downto 0);    -- phase accumulator count 
		phase_out : out std_logic_vector(pout_WIDTH - 1 downto 0) 	     -- phase accumulator output	 
		);
end PHASE_ACCUMULATOR;		   

architecture BEHAVIORAL of phase_accumulator is	
	signal counter_reg : std_logic_vector(cnt_WIDTH - 1 downto 0); 
begin
	process(clk)
		variable count_var : unsigned(cnt_WIDTH - 1 downto 0);
	begin
		if reset = '1' then 
		    counter_reg <= phase_offset;  -- start counter at phase offset value
			phase_out <= counter_reg(cnt_WIDTH - 1 downto (cnt_WIDTH - pout_WIDTH));				  
			phase_counter <= counter_reg;
		elsif rising_edge(clk) then	
		    -- Update counter variable
			count_var := unsigned(counter_reg) + unsigned(phase_inc);
            	
			-- Update signals and output ports, phase_out <= MSBs of internal counter
			counter_reg <= std_logic_vector(count_var);
			phase_counter <= counter_reg;
			phase_out <= counter_reg(cnt_WIDTH - 1 downto (cnt_WIDTH - pout_WIDTH));
		end if;
	end process;
end BEHAVIORAL;

----------------------------------------------------------------------------------
-- DDS Sine Cosine Generator Top Level
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;

entity DDS_SIN_COS_GENERATOR is
	generic (
	   out_WIDTH : positive := 16;   -- output sinusoid width (IP CORE fixed at 16 bits)
	   pacc_WIDTH : positive := 16;  -- phase accumulator width (IP CORE fixed at 16 bits) 
	   cnt_WIDTH : positive;         -- phase accumulator counter width
	   pinc_WIDTH : positive         -- phase increment width -> same as counter
	);
	 port(
		 clk : in std_logic;	
		 reset : in std_logic;					                
		 freq_value : in std_logic_vector(cnt_WIDTH - 1 downto 0);   -- Selects output frequency (phase increment)
		 phase_offset : in std_logic_vector(cnt_width - 1 downto 0);  -- Selects phase offset from 0 degrees
		 load_freq : in std_logic;                                    -- Pulse to load new frequency (or phase offset)
		 phase_out : out std_logic_vector(pacc_WIDTH - 1 downto 0);   -- Internal phase accumulator output
		 phase_count : out std_logic_vector(cnt_WIDTH -1 downto 0);   -- Internal phase accumulator counter output
		 sine_out : out std_logic_vector(out_WIDTH - 1 downto 0);     -- Output sine signal
         cosine_out : out std_logic_vector(out_WIDTH - 1 downto 0);   -- Output cosine signal		
         M_AXIS_tvalid : out std_logic;     -- AXIS Master Interface
         S_AXIS_tvalid : in std_logic       -- AXIS Slave Interface
		 );
end DDS_SIN_COS_GENERATOR;

architecture STRUCTURE of DDS_SIN_COS_GENERATOR is

  -- IP Block Diagram Component declaration
  component SIGNAL_GENERATOR is
  port (
    M_AXIS_DATA_0_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXIS_DATA_0_tvalid : out STD_LOGIC;
    S_AXIS_PHASE_0_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
    S_AXIS_PHASE_0_tvalid : in STD_LOGIC;
    clk_in1_0 : in STD_LOGIC;
    locked_0 : out STD_LOGIC;
    reset_0 : in STD_LOGIC
    );
  end component;
  
  -- Internal Signals
	signal s1_freq_reg_in : std_logic_vector(cnt_WIDTH - 1 downto 0);	     -- Frequency input (phase increment)
	signal s2_poff_reg_in : std_logic_vector (cnt_WIDTH - 1 downto 0);      -- Phase offset (from 0 degrees) input
	signal s3_phase_inc : std_logic_vector(cnt_WIDTH - 1 downto 0);	     -- Frequency register output
	signal s4_phase_offset : std_logic_vector (cnt_width - 1 downto 0);      -- Phase offset register output
	signal s5_phase_out : std_logic_vector(pacc_WIDTH - 1 downto 0);	     -- Phase accumulator output (input to LUT)
    signal s6_phase_cnt : std_logic_vector(cnt_width - 1 downto 0);          -- Internal phase accumulator counter
    signal s7_dds_out : std_logic_vector(2*out_WIDTH - 1 downto 0);         -- DDS Compiler output (2s comp)
	signal s8_sin_out_2s_comp : std_logic_vector(out_WIDTH - 1 downto 0);    -- DDS Compiler sine wave output (2s comp)
	signal s9_cos_out_2s_comp: std_logic_vector(out_WIDTH - 1 downto 0);	 -- DDS Compiler cosine wave output (2s comp)
    
    signal s10_locked : std_logic;
begin		 
    -- Load input parameters into internal registers
	s1_freq_reg_in <= freq_value;
    s2_poff_reg_in <= phase_offset;
    
	-- Instantiate frequency register
	u1: entity frequency_reg 
		generic map(reg_WIDTH => cnt_WIDTH)
		port map(
		   load => load_freq,
		   clk => clk,
		   reset => reset, 
		   d => s1_freq_reg_in,
		   q => s3_phase_inc);
	
	-- Instantiate phase offset register
	u2: entity frequency_reg 
		generic map(reg_WIDTH => cnt_WIDTH)
		port map(
		   load => load_freq,
		   clk => clk,
		   reset => reset, 
		   d => s2_poff_reg_in,
		   q => s4_phase_offset);
		
	-- Instantiate phase accumulator
	u3: entity phase_accumulator
		generic map(cnt_WIDTH => cnt_WIDTH, pout_WIDTH => pacc_WIDTH)
		port map(	 
           clk => clk, 							
           reset => reset,
           phase_inc => s3_phase_inc,
           phase_offset => s4_phase_offset,
           phase_out => s5_phase_out,	        
           phase_counter => s6_phase_cnt); 

	-- Instantiate DDS compiler IP core
	u4: SIGNAL_GENERATOR
        port map (
           M_AXIS_DATA_0_tdata => s7_dds_out,
           M_AXIS_DATA_0_tvalid => M_AXIS_tvalid,
           S_AXIS_PHASE_0_tdata => s5_phase_out,
           S_AXIS_PHASE_0_tvalid => S_AXIS_tvalid,
           clk_in1_0 => clk,
           locked_0 => s10_locked,
           reset_0 => reset);    

	-- Update output signals
	phase_out <= s5_phase_out;
	phase_count <= s6_phase_cnt;
    sine_out <= s7_dds_out (2*out_WIDTH - 1 downto out_WIDTH);
    cosine_out <= s7_dds_out (out_WIDTH - 1 downto 0);
	M_AXIS_tvalid <= '1';
end STRUCTURE;