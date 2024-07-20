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

----------------------------------------------------------------------------------
-- IP Core Block Diagram 
----------------------------------------------------------------------------------
--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
--Date        : Fri Jul 19 21:18:22 2024
--Host        : OmarsLaptop running 64-bit major release  (build 9200)
--Command     : generate_target DDS_compiler.bd
--Design      : DDS_compiler
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity DDS_compiler is
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
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of DDS_compiler : entity is "DDS_compiler,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=DDS_compiler,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=4,numReposBlks=4,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Hierarchical}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of DDS_compiler : entity is "DDS_compiler.hwdef";
end DDS_compiler;

architecture STRUCTURE of DDS_compiler is
  component DDS_compiler_dds_compiler_0_0 is
  port (
    aclk : in STD_LOGIC;
    s_axis_phase_tvalid : in STD_LOGIC;
    s_axis_phase_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 )
  );
  end component DDS_compiler_dds_compiler_0_0;
  component DDS_compiler_clk_wiz_0_0 is
  port (
    reset : in STD_LOGIC;
    clk_in1 : in STD_LOGIC;
    clk_out1 : out STD_LOGIC;
    locked : out STD_LOGIC
  );
  end component DDS_compiler_clk_wiz_0_0;
  component DDS_compiler_mult_gen_0_0 is
  port (
    CLK : in STD_LOGIC;
    A : in STD_LOGIC_VECTOR ( 15 downto 0 );
    B : in STD_LOGIC_VECTOR ( 15 downto 0 );
    P : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component DDS_compiler_mult_gen_0_0;
  component DDS_compiler_dds_compiler_1_0 is
  port (
    aclk : in STD_LOGIC;
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_phase_tvalid : out STD_LOGIC;
    m_axis_phase_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 )
  );
  end component DDS_compiler_dds_compiler_1_0;
  signal A_0_1 : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal B_0_1 : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal S_AXIS_PHASE_0_1_TDATA : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal S_AXIS_PHASE_0_1_TVALID : STD_LOGIC;
  signal clk_in1_0_1 : STD_LOGIC;
  signal clk_wiz_0_clk_out1 : STD_LOGIC;
  signal dds_compiler_0_M_AXIS_DATA_TDATA : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal dds_compiler_0_M_AXIS_DATA_TVALID : STD_LOGIC;
  signal dds_compiler_1_m_axis_data_tdata : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal mult_gen_0_P : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal reset_0_1 : STD_LOGIC;
  signal NLW_clk_wiz_0_locked_UNCONNECTED : STD_LOGIC;
  signal NLW_dds_compiler_1_m_axis_data_tvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_dds_compiler_1_m_axis_phase_tvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_dds_compiler_1_m_axis_phase_tdata_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of M_AXIS_DATA_0_tvalid : signal is "xilinx.com:interface:axis:1.0 M_AXIS_DATA_0 TVALID";
  attribute X_INTERFACE_INFO of S_AXIS_PHASE_0_tvalid : signal is "xilinx.com:interface:axis:1.0 S_AXIS_PHASE_0 TVALID";
  attribute X_INTERFACE_INFO of clk_in1_0 : signal is "xilinx.com:signal:clock:1.0 CLK.CLK_IN1_0 CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of clk_in1_0 : signal is "XIL_INTERFACENAME CLK.CLK_IN1_0, CLK_DOMAIN DDS_compiler_clk_in1_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
  attribute X_INTERFACE_INFO of reset_0 : signal is "xilinx.com:signal:reset:1.0 RST.RESET_0 RST";
  attribute X_INTERFACE_PARAMETER of reset_0 : signal is "XIL_INTERFACENAME RST.RESET_0, INSERT_VIP 0, POLARITY ACTIVE_HIGH";
  attribute X_INTERFACE_INFO of A_0 : signal is "xilinx.com:signal:data:1.0 DATA.A_0 DATA";
  attribute X_INTERFACE_PARAMETER of A_0 : signal is "XIL_INTERFACENAME DATA.A_0, LAYERED_METADATA undef";
  attribute X_INTERFACE_INFO of B_0 : signal is "xilinx.com:signal:data:1.0 DATA.B_0 DATA";
  attribute X_INTERFACE_PARAMETER of B_0 : signal is "XIL_INTERFACENAME DATA.B_0, LAYERED_METADATA undef";
  attribute X_INTERFACE_INFO of M_AXIS_DATA_0_tdata : signal is "xilinx.com:interface:axis:1.0 M_AXIS_DATA_0 TDATA";
  attribute X_INTERFACE_PARAMETER of M_AXIS_DATA_0_tdata : signal is "XIL_INTERFACENAME M_AXIS_DATA_0, FREQ_HZ 100000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 0, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {TDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 16} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} array_type {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value chan} size {attribs {resolve_type generated dependency chan_size format long minimum {} maximum {}} value 1} stride {attribs {resolve_type generated dependency chan_stride format long minimum {} maximum {}} value 16} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 16} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} struct {field_cosine {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value cosine} enabled {attribs {resolve_type generated dependency cosine_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency cosine_width format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} real {fixed {fractwidth {attribs {resolve_type generated dependency cosine_fractwidth format long minimum {} maximum {}} value 15} signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true}}}}} field_sine {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value sine} enabled {attribs {resolve_type generated dependency sine_enabled format bool minimum {} maximum {}} value true} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency sine_width format long minimum {} maximum {}} value 16} bitoffset {attribs {resolve_type generated dependency sine_offset format long minimum {} maximum {}} value 0} real {fixed {fractwidth {attribs {resolve_type generated dependency sine_fractwidth format long minimum {} maximum {}} value 15} signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true}}}}}}}}}} TDATA_WIDTH 16 TUSER {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} struct {field_chanid {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value chanid} enabled {attribs {resolve_type generated dependency chanid_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency chanid_width format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} field_user {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value user} enabled {attribs {resolve_type generated dependency user_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency user_width format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency user_offset format long minimum {} maximum {}} value 0}}}}}} TUSER_WIDTH 0}, PHASE 0.0, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of P_0 : signal is "xilinx.com:signal:data:1.0 DATA.P_0 DATA";
  attribute X_INTERFACE_PARAMETER of P_0 : signal is "XIL_INTERFACENAME DATA.P_0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {DATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value data} bitwidth {attribs {resolve_type generated dependency bitwidth format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type generated dependency signed format bool minimum {} maximum {}} value FALSE}}}} DATA_WIDTH 32}";
  attribute X_INTERFACE_INFO of S_AXIS_PHASE_0_tdata : signal is "xilinx.com:interface:axis:1.0 S_AXIS_PHASE_0 TDATA";
  attribute X_INTERFACE_PARAMETER of S_AXIS_PHASE_0_tdata : signal is "XIL_INTERFACENAME S_AXIS_PHASE_0, FREQ_HZ 100000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 0, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
begin
  A_0_1(15 downto 0) <= A_0(15 downto 0);
  B_0_1(15 downto 0) <= B_0(15 downto 0);
  M_AXIS_DATA_0_tdata(15 downto 0) <= dds_compiler_0_M_AXIS_DATA_TDATA(15 downto 0);
  M_AXIS_DATA_0_tvalid <= dds_compiler_0_M_AXIS_DATA_TVALID;
  P_0(31 downto 0) <= mult_gen_0_P(31 downto 0);
  S_AXIS_PHASE_0_1_TDATA(15 downto 0) <= S_AXIS_PHASE_0_tdata(15 downto 0);
  S_AXIS_PHASE_0_1_TVALID <= S_AXIS_PHASE_0_tvalid;
  clk_in1_0_1 <= clk_in1_0;
  m_axis_data_tdata_0(15 downto 0) <= dds_compiler_1_m_axis_data_tdata(15 downto 0);
  reset_0_1 <= reset_0;
clk_wiz_0: component DDS_compiler_clk_wiz_0_0
     port map (
      clk_in1 => clk_in1_0_1,
      clk_out1 => clk_wiz_0_clk_out1,
      locked => NLW_clk_wiz_0_locked_UNCONNECTED,
      reset => reset_0_1
    );
dds_compiler_0: component DDS_compiler_dds_compiler_0_0
     port map (
      aclk => clk_wiz_0_clk_out1,
      m_axis_data_tdata(15 downto 0) => dds_compiler_0_M_AXIS_DATA_TDATA(15 downto 0),
      m_axis_data_tvalid => dds_compiler_0_M_AXIS_DATA_TVALID,
      s_axis_phase_tdata(15 downto 0) => S_AXIS_PHASE_0_1_TDATA(15 downto 0),
      s_axis_phase_tvalid => S_AXIS_PHASE_0_1_TVALID
    );
dds_compiler_1: component DDS_compiler_dds_compiler_1_0
     port map (
      aclk => clk_wiz_0_clk_out1,
      m_axis_data_tdata(15 downto 0) => dds_compiler_1_m_axis_data_tdata(15 downto 0),
      m_axis_data_tvalid => NLW_dds_compiler_1_m_axis_data_tvalid_UNCONNECTED,
      m_axis_phase_tdata(15 downto 0) => NLW_dds_compiler_1_m_axis_phase_tdata_UNCONNECTED(15 downto 0),
      m_axis_phase_tvalid => NLW_dds_compiler_1_m_axis_phase_tvalid_UNCONNECTED
    );
mult_gen_0: component DDS_compiler_mult_gen_0_0
     port map (
      A(15 downto 0) => A_0_1(15 downto 0),








----------------------------------------------------------------------------------
-- DDS Modulator Top Level Entity
----------------------------------------------------------------------------------
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
