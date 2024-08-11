----------------------------------------------------------------------------------
-- FIR Filter
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
----------------------------------------------------------
entity fir_filter is          
  generic (W1 : integer;  -- Input bit width
           W2 : integer;  -- Multiplier bit width 2*W1
           W3 : integer;  -- Adder width = W2+log2(L)-1
           W4 : integer;  -- Output bit width
           L  : integer   -- Filter length 
           );
  port (clk    : in std_logic;     -- System clock
        reset  : in std_logic;     -- Asynchron reset
        Load_x : in  std_logic;    -- Load/run switch
        x_in   : in  std_logic_vector(W1-1 downto 0);  -- System input
        c_in   : in  std_logic_vector(W1-1 downto 0);  -- Coefficient data input 
        y_out  : out std_logic_vector(W4-1 downto 0)); -- Coefficient output
end fir_filter;
-- --------------------------------------------------------
architecture behavioral of fir_filter is
  subtype SLV_W1 is std_logic_vector(W1-1 downto 0);     -- Subtype with width of input signal
  subtype SLV_W2 is std_logic_vector(W2-1 downto 0);     -- Subtype with width of multiplier
  subtype SLV_W3 is std_logic_vector(W3-1 downto 0);     -- Subtype with width of adder
  type A0_L1SLV_W1 is array (0 to L-1) of SLV_W1;         -- Array of input signals
  type A0_L1SLV_W2 is array (0 to L-1) of SLV_W2;         -- Array of multiplier signals
  type A0_L1SLV_W3 is array (0 to L-1) of SLV_W3;         -- Array of adder signals

  signal  x  :  SLV_W1;     	    -- Internal signal for current input sample
  signal  y  :  SLV_W3;      	    -- Internal signal for current output sample  
  signal  c  :  A0_L1SLV_W1 ;       -- Coefficient array RAM 
  signal  p  :  A0_L1SLV_W2 ;       -- Product array RAM
  signal  a  :  A0_L1SLV_W3 ;       -- Adder array RAM
                                                        
begin
  Load:process(clk, reset, c_in, c, x_in)            
  begin                   ------> Load data or coefficients
    if reset = '1' then -- clear data and coefficients register
      x <= (others => '0');
      for k in 0 to L-1 loop
        c(k) <= (others => '0');
      end loop; 
    elsif rising_edge(clk) then  
    if Load_x = '0' then
      c(L-1) <= c_in;      -- Store coefficient in register
      for i in L-2 downto 0 loop  -- Coefficients shift one
        c(I) <= c(I+1);
      end loop;
    else
      x <= x_in;           -- Get one data sample at a time
    end if;
    end if;
  end process Load;

  SOP: process (clk, reset, a, p)-- Compute sum-of-products
  begin
    if reset = '1' then -- clear tap registers
      for k in 0 to L-1 loop
        a(k) <= (others => '0');
      end loop; 
    elsif rising_edge(clk) then
    for i in 0 to L-2  loop      -- Compute the transposed
      a(i) <= (p(i)(W2-1) & p(i)) + a(i+1); -- filter adds
    end loop;
    a(L-1) <= p(L-1)(W2-1) & p(L-1);     -- First TAP has 
    end if;                              -- only a register
    y <= a(0);
  end process SOP;

  -- Instantiate L multipliers 
  MulGen: for i in 0 to L-1 generate  
    p(i) <= c(i) * x;
  end generate;

  y_out <= y(W3-1 downto W3-W4);  
end behavioral;

----------------------------------------------------------------------------------
-- Coefficient Lookup Table
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity coefficient_LUT is
    generic ( 
              a : positive;     -- LUT address range, i.e, number of coefficients 
              w : positive      -- Coefficient width
            );
	port (
		address : in std_logic_vector(a-1 downto 0);            -- table address
		coefficient_val : out std_logic_vector(w-1 downto 0)    -- table entry value
		);
end coefficient_LUT;

architecture behavioral of coefficient_LUT is
    -- LUT declaration
	type lut is array(0 to 2**a - 1) of std_logic_vector(w-1 downto 0);
	signal coefficient_lut : lut;
	-- File declaration
	file coef_file : text;
begin	  

-- Process to read the file and populate the LUT
	process
		variable line_buf : line;
		variable data_buf : std_logic_vector(w-1 downto 0);
		variable i : integer := 0;
	begin
	   file_open(coef_file, "binary_filter_coefficients_truncated_to_n_bits.txt", read_mode);

	   -- Populate LUT from txt file
	   while not endfile(coef_file) loop
	       readline(coef_file, line_buf);
	       read (line_buf, data_buf);
	       coefficient_lut(i) <= data_buf; 
	       i := i +1 ;
	   end loop;
	   
	   -- Pad remaining LUT entries with all 0s
	   while i < 2**a loop
	       coefficient_lut(i) <= (others => '0');
	       i := i + 1;
	   end loop;
	   wait;
	end process;	

-- Process to output coefficient based on input address	
	process(address)
	begin
		coefficient_val <= coefficient_lut(to_integer(unsigned(address)));	
	end process;
end behavioral;


----------------------------------------------------------------------------------
-- Downsampler
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity down_sampler is
    generic (a : positive);     -- Data width
	port (
	    clk : in std_logic;    -- clock signal
	    reset : in std_logic;  -- reset signal
	    data_in : in std_logic_vector(a-1 downto 0);  -- Input data
	    decimation_factor : in std_logic_vector(a-1 downto 0);    -- Downsampling factor
	    data_out : out std_logic_vector(a-1 downto 0) -- Output data
	    );
end down_sampler;

architecture behavioral of down_sampler is
    signal clk_counter :  std_logic_vector (a-1 downto 0);  -- clk cycle counter
begin	  
-- Process to increment clock cycle counter
	process(clk, reset)   
	begin
	   if reset = '1' then
	       clk_counter <= (others => '0');
	   elsif rising_edge(clk) then
	       if clk_counter = decimation_factor then
	           clk_counter <= (others => '0');
	           data_out <= data_in;
           else
	           clk_counter <= clk_counter + 1; -- increment clock cycle counter           
	       end if;
       end if;
	end process;	
end behavioral;


----------------------------------------------------------------------------------
-- IP Block Diagram
----------------------------------------------------------------------------------
--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
--Date        : Sat Aug 10 18:55:32 2024
--Host        : OmarsLaptop running 64-bit major release  (build 9200)
--Command     : generate_target dds_modulator.bd
--Design      : dds_modulator
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity dds_modulator is
  port (
    A_1 : in STD_LOGIC_VECTOR ( 17 downto 0 );
    B_0 : in STD_LOGIC_VECTOR ( 17 downto 0 );
    M_AXIS_DATA_0_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 );
    M_AXIS_DATA_0_tvalid : out STD_LOGIC;
    P_0 : out STD_LOGIC_VECTOR ( 23 downto 0 );
    S_AXIS_PHASE_0_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
    S_AXIS_PHASE_0_tvalid : in STD_LOGIC;
    clk_in1_0 : in STD_LOGIC;
    reset_0 : in STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of dds_modulator : entity is "dds_modulator,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=dds_modulator,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=3,numReposBlks=3,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Hierarchical}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of dds_modulator : entity is "dds_modulator.hwdef";
end dds_modulator;

architecture STRUCTURE of dds_modulator is
  component dds_modulator_dds_compiler_0_0 is
  port (
    aclk : in STD_LOGIC;
    s_axis_phase_tvalid : in STD_LOGIC;
    s_axis_phase_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 )
  );
  end component dds_modulator_dds_compiler_0_0;
  component dds_modulator_mult_gen_0_0 is
  port (
    CLK : in STD_LOGIC;
    A : in STD_LOGIC_VECTOR ( 11 downto 0 );
    B : in STD_LOGIC_VECTOR ( 11 downto 0 );
    P : out STD_LOGIC_VECTOR ( 23 downto 0 )
  );
  end component dds_modulator_mult_gen_0_0;
  component dds_modulator_clk_wiz_0_0 is
  port (
    reset : in STD_LOGIC;
    clk_in1 : in STD_LOGIC;
    clk_out1 : out STD_LOGIC;
    locked : out STD_LOGIC
  );
  end component dds_modulator_clk_wiz_0_0;
  signal A_1_1 : STD_LOGIC_VECTOR ( 17 downto 0 );
  signal B_0_1 : STD_LOGIC_VECTOR ( 17 downto 0 );
  signal S_AXIS_PHASE_0_1_TDATA : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal S_AXIS_PHASE_0_1_TVALID : STD_LOGIC;
  signal clk_in1_0_1 : STD_LOGIC;
  signal clk_wiz_0_clk_out1 : STD_LOGIC;
  signal dds_compiler_0_M_AXIS_DATA_TDATA : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal dds_compiler_0_M_AXIS_DATA_TVALID : STD_LOGIC;
  signal mult_gen_0_P : STD_LOGIC_VECTOR ( 23 downto 0 );
  signal reset_0_1 : STD_LOGIC;
  signal NLW_clk_wiz_0_locked_UNCONNECTED : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of M_AXIS_DATA_0_tvalid : signal is "xilinx.com:interface:axis:1.0 M_AXIS_DATA_0 TVALID";
  attribute X_INTERFACE_INFO of S_AXIS_PHASE_0_tvalid : signal is "xilinx.com:interface:axis:1.0 S_AXIS_PHASE_0 TVALID";
  attribute X_INTERFACE_INFO of clk_in1_0 : signal is "xilinx.com:signal:clock:1.0 CLK.CLK_IN1_0 CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of clk_in1_0 : signal is "XIL_INTERFACENAME CLK.CLK_IN1_0, CLK_DOMAIN dds_modulator_clk_in1_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
  attribute X_INTERFACE_INFO of reset_0 : signal is "xilinx.com:signal:reset:1.0 RST.RESET_0 RST";
  attribute X_INTERFACE_PARAMETER of reset_0 : signal is "XIL_INTERFACENAME RST.RESET_0, INSERT_VIP 0, POLARITY ACTIVE_HIGH";
  attribute X_INTERFACE_INFO of A_1 : signal is "xilinx.com:signal:data:1.0 DATA.A_1 DATA";
  attribute X_INTERFACE_PARAMETER of A_1 : signal is "XIL_INTERFACENAME DATA.A_1, LAYERED_METADATA undef";
  attribute X_INTERFACE_INFO of B_0 : signal is "xilinx.com:signal:data:1.0 DATA.B_0 DATA";
  attribute X_INTERFACE_PARAMETER of B_0 : signal is "XIL_INTERFACENAME DATA.B_0, LAYERED_METADATA undef";
  attribute X_INTERFACE_INFO of M_AXIS_DATA_0_tdata : signal is "xilinx.com:interface:axis:1.0 M_AXIS_DATA_0 TDATA";
  attribute X_INTERFACE_PARAMETER of M_AXIS_DATA_0_tdata : signal is "XIL_INTERFACENAME M_AXIS_DATA_0, FREQ_HZ 100000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 0, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {TDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 12} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} array_type {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value chan} size {attribs {resolve_type generated dependency chan_size format long minimum {} maximum {}} value 1} stride {attribs {resolve_type generated dependency chan_stride format long minimum {} maximum {}} value 16} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 12} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} struct {field_cosine {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value cosine} enabled {attribs {resolve_type generated dependency cosine_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency cosine_width format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} real {fixed {fractwidth {attribs {resolve_type generated dependency cosine_fractwidth format long minimum {} maximum {}} value 11} signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true}}}}} field_sine {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value sine} enabled {attribs {resolve_type generated dependency sine_enabled format bool minimum {} maximum {}} value true} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency sine_width format long minimum {} maximum {}} value 12} bitoffset {attribs {resolve_type generated dependency sine_offset format long minimum {} maximum {}} value 0} real {fixed {fractwidth {attribs {resolve_type generated dependency sine_fractwidth format long minimum {} maximum {}} value 11} signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true}}}}}}}}}} TDATA_WIDTH 16 TUSER {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} struct {field_chanid {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value chanid} enabled {attribs {resolve_type generated dependency chanid_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency chanid_width format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} field_user {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value user} enabled {attribs {resolve_type generated dependency user_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency user_width format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency user_offset format long minimum {} maximum {}} value 0}}}}}} TUSER_WIDTH 0}, PHASE 0.0, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of P_0 : signal is "xilinx.com:signal:data:1.0 DATA.P_0 DATA";
  attribute X_INTERFACE_PARAMETER of P_0 : signal is "XIL_INTERFACENAME DATA.P_0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {DATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value data} bitwidth {attribs {resolve_type generated dependency bitwidth format long minimum {} maximum {}} value 24} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type generated dependency signed format bool minimum {} maximum {}} value FALSE}}}} DATA_WIDTH 24}";
  attribute X_INTERFACE_INFO of S_AXIS_PHASE_0_tdata : signal is "xilinx.com:interface:axis:1.0 S_AXIS_PHASE_0 TDATA";
  attribute X_INTERFACE_PARAMETER of S_AXIS_PHASE_0_tdata : signal is "XIL_INTERFACENAME S_AXIS_PHASE_0, FREQ_HZ 100000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 0, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
begin
  A_1_1(17 downto 0) <= A_1(17 downto 0);
  B_0_1(17 downto 0) <= B_0(17 downto 0);
  M_AXIS_DATA_0_tdata(15 downto 0) <= dds_compiler_0_M_AXIS_DATA_TDATA(15 downto 0);
  M_AXIS_DATA_0_tvalid <= dds_compiler_0_M_AXIS_DATA_TVALID;
  P_0(23 downto 0) <= mult_gen_0_P(23 downto 0);
  S_AXIS_PHASE_0_1_TDATA(15 downto 0) <= S_AXIS_PHASE_0_tdata(15 downto 0);
  S_AXIS_PHASE_0_1_TVALID <= S_AXIS_PHASE_0_tvalid;
  clk_in1_0_1 <= clk_in1_0;
  reset_0_1 <= reset_0;
clk_wiz_0: component dds_modulator_clk_wiz_0_0
     port map (
      clk_in1 => clk_in1_0_1,
      clk_out1 => clk_wiz_0_clk_out1,
      locked => NLW_clk_wiz_0_locked_UNCONNECTED,
      reset => reset_0_1
    );
dds_compiler_0: component dds_modulator_dds_compiler_0_0
     port map (
      aclk => clk_wiz_0_clk_out1,
      m_axis_data_tdata(15 downto 0) => dds_compiler_0_M_AXIS_DATA_TDATA(15 downto 0),
      m_axis_data_tvalid => dds_compiler_0_M_AXIS_DATA_TVALID,
      s_axis_phase_tdata(15 downto 0) => S_AXIS_PHASE_0_1_TDATA(15 downto 0),
      s_axis_phase_tvalid => S_AXIS_PHASE_0_1_TVALID
    );
mult_gen_0: component dds_modulator_mult_gen_0_0
     port map (
      A(11 downto 0) => A_1_1(11 downto 0),
      B(11 downto 0) => B_0_1(11 downto 0),
      CLK => clk_wiz_0_clk_out1,
      P(23 downto 0) => mult_gen_0_P(23 downto 0)
    );
end STRUCTURE;




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
		w : positive -- width of phase accum output
		);
	port(
		clk : in std_logic; 					-- system clock		
		reset : in std_logic; 					-- asynchronous reset
		phase_inc : in std_logic_vector(a - 1 downto 0);	-- phase increment
		phase_out : out std_logic_vector(w - 1 downto 0) 	-- phase accumulator output	 
		);
end phase_accumulator;		   

architecture behavioral of phase_accumulator is	
	signal counter_reg : std_logic_vector(a-1 downto 0); 
begin
	process(clk, reset)
		variable count_var : unsigned(a-1 downto 0);
		variable delta : integer;	-- Phase increment variable
	begin
		if reset = '1' then 
			phase_out <= (others => '0');				  
			counter_reg <= (others => '0');
		elsif rising_edge(clk) then	
			delta := to_integer(unsigned(phase_inc));				
			count_var := unsigned(counter_reg);	            
            count_var := count_var + unsigned(phase_inc);	-- Update counter variable
            	
			-- Update signals and output ports
			counter_reg <= std_logic_vector(count_var);
			phase_out <= counter_reg(a-1 downto (a-w));
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
--		pos : in std_logic;					-- 2's compliment MSB: 0b => positive; 1b => negative
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

----------------------------------------------------------------------------------
-- Variable FIR filter Top Level Entity
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity variable_fir_filter is
	generic (
	a : positive;  -- filter cutoff select bit width, i.e, filter cutoff resolution 
	w : positive); -- input/output signal bit widths
	 port(
		 clk : in std_logic;	-- system clock
		 reset : in std_logic;	-- asynchronous reset
		 filter_cutoff : in std_logic_vector(a - 1 downto 0);	-- sets filter cutoff frequency
		 load_filter_cutoff : in std_logic;	  -- pulse to load a new cutoff frequency
		 input_signal : in std_logic_vector (w - 1 downto 0);	  -- input signal
		 output_signal : out std_logic_vector(w - 1 downto 0);	      -- filtered output signal
         M_AXIS_DATA_0_tvalid : out STD_LOGIC;  -- MASTER AXIS TVALID
         S_AXIS_PHASE_0_tvalid : in STD_LOGIC	-- SLAVE AXIS TVALID	 		  		 
		 );
end variable_fir_filter;

architecture structural of variable_fir_filter is

  -- IP Block Diagram Component declaration
  component dds_modulator
    port ( 
    	A_0 : in STD_LOGIC_VECTOR ( 11 downto 0 );
    	B_0 : in STD_LOGIC_VECTOR ( 11 downto 0 );
    	M_AXIS_DATA_0_tdata : out STD_LOGIC_VECTOR ( 11 downto 0 );
    	M_AXIS_DATA_0_tvalid : out STD_LOGIC;
    	P_0 : out STD_LOGIC_VECTOR ( 23 downto 0 );
    	S_AXIS_PHASE_0_tdata : in STD_LOGIC_VECTOR ( 11 downto 0 );
    	S_AXIS_PHASE_0_tvalid : in STD_LOGIC;
    	clk_in1_0 : in STD_LOGIC;
    	reset_0 : in STD_LOGIC
    );
  end component;
  
  -- Internal Signals
	signal s1_cutoff_freq : std_logic_vector(a-1 downto 0);           -- filter cutoff frequency input
	signal s2_phase_inc : std_logic_vector(a-1 downto 0);             -- DDS phase accumulator phase increment 
	signal s3_phase_out : std_logic_vector(a-1 downto 0);             -- DDS phase accumulator output signal
	signal s4_dds_out : std_logic_vector(w-1 downto 0);               -- DDS synthesizer output signal
	signal s5_fir_coeff_lut_out : std_logic_vector(w-1 downto 0);     -- FIR coefficient LUT output signal
	signal s6_fir_coeff_lut_addr : std_logic_vector(a-1 downto 0);    -- FIR coefficient LUT address signal
    signal s7_coeff_mod_2s_comp : std_logic_vector(w-1 downto 0);	  -- Modulated FIR filter coefficients (2's compliment)
	signal s8_coeff_mod_hex : std_logic_vector(w-1 downto 0);         -- Modulated FIR filter coefficients (hexadecimal)
begin		 
	s1_cutoff_freq <= filter_cutoff;
    
	-- Instantiate frequency register
	u1: entity frequency_reg 
		generic map(a => a)
		port map(
			load => load_filter_cutoff,
			clk => clk,
			reset => reset, 
			d => s1_cutoff_freq,
			q => s2_phase_inc);
		
	-- Instantiate phase accumulator
	u2: entity phase_accumulator
		generic map(a => a, w => w)
		port map(	 
			clk => clk, 
			reset => reset,
			phase_inc => s2_phase_inc,	-- phase increment <= frequency register output 
			phase_out => s3_phase_out);	
		
	-- Instantiate IP Block Diagram
	u3: dds_modulator
    	port map(
            A_0 => s4_dds_out,
            B_0 => s5_fir_coeff_lut_out,
            M_AXIS_DATA_0_tdata(15 downto (16-w)) => s4_dds_out,
            M_AXIS_DATA_0_tvalid => M_AXIS_DATA_0_tvalid,
            P_0 => s7_coeff_mod_2s_comp (23 downto (23-w)),
            S_AXIS_PHASE_0_tdata(15 downto (16-w)) => s3_phase_out,
            S_AXIS_PHASE_0_tvalid => S_AXIS_PHASE_0_tvalid,
            clk_in1_0 => clk,
            reset_0 => reset);	
    
    -- Instantiate FIR filter coefficient LU
    u4: entity coefficient_LUT 
    generic map (a => a, w => w)
    port map(
        address => s6_fir_coeff_lut_addr, 
        coefficient_val => s5_fir_coeff_lut_out);
    
    -- Instantiate FIR filter
    u5:entity fir_filter           
    generic map(W1 => 12, W2 => 24, W3 => 25, W4 => 12, L  => 4081) 
    port map(
        clk => clk,
        reset => reset,
        Load_x => load_filter_cutoff,
        x_in => input_signal,
        c_in => s7_coeff_mod_2s_comp,        
        y_out => output_signal);  

end structural;
