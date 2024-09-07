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
-- Two's Compliment to Hexadecimal
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TwosComp_TO_HEX is		
   generic(d_WIDTH : positive);	-- Width of input and output data
	port (
		twos_comp_in : in std_logic_vector(d_WIDTH - 1 downto 0);	-- 2's compliment input
		hex_out : out std_logic_vector(d_WIDTH - 1 downto 0)		-- Hexadecimal output to
		);
end TwosComp_TO_HEX;

architecture RTL of TwosComp_TO_HEX is
begin 
	-- Flip MSB in 2's compliment representation
	hex_out(d_WIDTH - 1) <= not twos_comp_in(d_WIDTH - 1);
	hex_out (d_WIDTH - 2 downto 0) <= twos_comp_in(d_WIDTH - 2 downto 0);
end RTL;

----------------------------------------------------------------------------------
-- Generic Counter
----------------------------------------------------------------------------------
library ieee;				
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity GENERIC_COUNTER is
	generic(
		w_counter : positive; 
		w_out : positive; 
		w_increment : integer
	);
	port(
		clk : in std_logic; 							
		reset : in std_logic; 					
		count : out std_logic_vector(w_out - 1 downto 0));
end GENERIC_COUNTER;		   

architecture RTL of GENERIC_COUNTER is	
	signal counter_reg : std_logic_vector(w_counter - 1 downto 0); 
begin
	process(clk)
		variable count_var : unsigned(w_counter - 1 downto 0);
	begin
		if reset = '1' then 
			count <= (others => '0');				  
			counter_reg <= (others => '0');
		elsif rising_edge(clk) then	
			count_var := unsigned(counter_reg);	
            count_var := count_var + to_unsigned(w_increment, w_counter);	-- Update counter variable
			counter_reg <= std_logic_vector(count_var);
			
			-- MSBs of counter are aligned with output value
			count <= counter_reg(w_counter-1 downto (w_counter - w_out));
		end if;
	end process;
end RTL;

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
  component SIN_COS_GEN_DDS_COMPILER is
  port (
    M_AXIS_DATA_0_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXIS_DATA_0_tvalid : out STD_LOGIC;
    S_AXIS_PHASE_0_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
    S_AXIS_PHASE_0_tvalid : in STD_LOGIC;
    clk_in1_0 : in STD_LOGIC;
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
	u4: SIN_COS_GEN_DDS_COMPILER
        port map (
           M_AXIS_DATA_0_tdata => s7_dds_out,
           M_AXIS_DATA_0_tvalid => M_AXIS_tvalid,
           S_AXIS_PHASE_0_tdata => s5_phase_out,
           S_AXIS_PHASE_0_tvalid => S_AXIS_tvalid,
           clk_in1_0 => clk,
           reset_0 => reset);    

	-- Update output signals
	phase_out <= s5_phase_out;
	phase_count <= s6_phase_cnt;
    sine_out <= s7_dds_out (2*out_WIDTH - 1 downto out_WIDTH);
    cosine_out <= s7_dds_out (out_WIDTH - 1 downto 0);
	M_AXIS_tvalid <= '1';
end STRUCTURE;



----------------------------------------------------------------------------------
-- IIR Filter
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity IIR_FILTER is
generic (data_WIDTH : positive; L : positive);
port (
    clk : in std_logic;
    reset : in std_logic;
    load_coeff : in std_logic;
    x_in : in std_logic_vector (data_WIDTH - 1 downto 0);
    a_in : in std_logic_vector(data_WIDTH - 1 downto 0);
    b_in : in std_logic_vector(data_WIDTH - 1 downto 0);
    y_out : out std_logic_vector(data_WIDTH - 1 downto 0)
    );
end IIR_FILTER;

architecture Behavioral of IIR_FILTER is
    subtype SLV_data_WIDTH is std_logic_vector(data_WIDTH - 1 downto 0);
    type RAM is array (0 to L-1) of SLV_data_WIDTH;
 
    signal x : RAM;      -- Input signal vector x[n]
    signal y : RAM;      -- Output signal vector y[n]
    signal a : RAM;      -- a[n] coefficient vector
    signal b : RAM;      -- b[n] coefficient vector
    signal y_buffer : signed(2*data_WIDTH - 1 downto 0); 
begin
    -- Load order => a[n], a[n-1], a[n-2], ... , a[0] 
    -- Load order => b[n], b[n-1], b[n-2], ... , b[1]
    process(clk, reset)
        variable y_var : signed(2*data_WIDTH - 1 downto 0);
    begin
        if rising_edge(clk) then
            if reset ='1' then
                for i in 0 to L-1 loop
                    x(i) <= (others =>'0');
                    y(i) <= (others =>'0');
                    a(i) <= (others =>'0');
                    b(i) <= (others =>'0');
                    y_buffer <= (others => '0');
                end loop;
            elsif load_coeff = '1' then
                a(L-1) <= a_in;
                b(L-1) <= b_in;
                
                -- Shift input coefficients into RAM
                for i in L-2 downto 0 loop
                    a(i) <= a(i+1);
                    b(i) <= b(i+1);   
                end loop;
            else
                x(L-1) <=  x_in;     -- Load input sample x[n]
                y(L-1) <= std_logic_vector(resize(signed(y_buffer), data_WIDTH));   -- Load previous output sample y[n-1]   

                -- Shift input and output data into sample arrays
                for i in L-2 downto 0 loop
                    x(i) <= x(i+1);
                    y(i) <= y(i+1);   
                end loop;

                y_var := (others => '0');    -- Initialize y[n]

                -- Compute: y[n] = a0*x[n] + a1*x[n-1] + a2*x[n-2) + ... + b1*y[n-1] + b2*y[n-2] + ... 
                for i in 0 to L-1 loop
                    y_var := y_var + (((signed(x(i)) * signed(a(i))) + (signed(y(i)) * signed(b(i)))));
                end loop;
                
                -- Divide by 2^data_WIDTH and update buffer
                y_var := shift_right(signed(y_var),data_WIDTH - 1);
                y_buffer <= y_var;
                
                -- Resize buffer width for feedback
                y_out <= std_logic_vector(resize(signed(y_buffer), data_WIDTH));                 
            
            end if;
       end if;       
   end process; 
end Behavioral;


----------------------------------------------------------------------------------
-- Downsampler
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity DOWN_SAMPLER is
    generic (data_WIDTH : positive);
	port (
	    clk : in std_logic;    -- clock signal
	    reset : in std_logic;  -- reset signal
		data_in : in std_logic_vector(data_WIDTH-1 downto 0);  -- Input data
		decimation_factor : in std_logic_vector(data_WIDTH-1 downto 0);    -- Downsampling factor
		data_out : out std_logic_vector(data_WIDTH-1 downto 0) -- Output data
		);
end DOWN_SAMPLER;

architecture Behavioral of DOWN_SAMPLER is
    signal clk_counter :  std_logic_vector (data_WIDTH-1 downto 0);  -- clk cycle counter
begin	  
    -- Process to increment clock cycle counter and check 
	process(clk, reset)   
	begin
	   if rising_edge(clk) then
	       if reset = '1' then
	           clk_counter <= (others => '0'); 
	       elsif clk_counter = decimation_factor then
	           clk_counter <= (others => '0');     -- Reset counter 
	           data_out <= data_in;    -- Pass input to output
           else
	           clk_counter <= clk_counter + 1; -- increment clock cycle counter           
	       end if;
       end if;
	end process;	
end Behavioral;