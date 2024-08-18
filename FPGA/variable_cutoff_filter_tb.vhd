library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity filter_tb_input_signal is
  port (
    M_AXIS_DATA_0_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 );
    M_AXIS_DATA_0_tvalid : out STD_LOGIC;
    aclk_0 : in STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of filter_tb_input_signal : entity is "filter_tb_input_signal,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=filter_tb_input_signal,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Hierarchical}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of filter_tb_input_signal : entity is "filter_tb_input_signal.hwdef";
end filter_tb_input_signal;

architecture STRUCTURE of filter_tb_input_signal is
  component filter_tb_input_signal_dds_compiler_0_0 is
  port (
    aclk : in STD_LOGIC;
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_phase_tvalid : out STD_LOGIC;
    m_axis_phase_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 )
  );
  end component filter_tb_input_signal_dds_compiler_0_0;
  signal aclk_0_1 : STD_LOGIC;
  signal dds_compiler_0_M_AXIS_DATA_TDATA : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal dds_compiler_0_M_AXIS_DATA_TVALID : STD_LOGIC;
  signal NLW_dds_compiler_0_m_axis_phase_tvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_dds_compiler_0_m_axis_phase_tdata_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of M_AXIS_DATA_0_tvalid : signal is "xilinx.com:interface:axis:1.0 M_AXIS_DATA_0 TVALID";
  attribute X_INTERFACE_INFO of aclk_0 : signal is "xilinx.com:signal:clock:1.0 CLK.ACLK_0 CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of aclk_0 : signal is "XIL_INTERFACENAME CLK.ACLK_0, ASSOCIATED_BUSIF M_AXIS_DATA_0, CLK_DOMAIN filter_tb_input_signal_aclk_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
  attribute X_INTERFACE_INFO of M_AXIS_DATA_0_tdata : signal is "xilinx.com:interface:axis:1.0 M_AXIS_DATA_0 TDATA";
  attribute X_INTERFACE_PARAMETER of M_AXIS_DATA_0_tdata : signal is "XIL_INTERFACENAME M_AXIS_DATA_0, CLK_DOMAIN filter_tb_input_signal_aclk_0, FREQ_HZ 100000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 0, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {TDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 12} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} array_type {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value chan} size {attribs {resolve_type generated dependency chan_size format long minimum {} maximum {}} value 1} stride {attribs {resolve_type generated dependency chan_stride format long minimum {} maximum {}} value 16} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 12} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} struct {field_cosine {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value cosine} enabled {attribs {resolve_type generated dependency cosine_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency cosine_width format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} real {fixed {fractwidth {attribs {resolve_type generated dependency cosine_fractwidth format long minimum {} maximum {}} value 11} signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true}}}}} field_sine {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value sine} enabled {attribs {resolve_type generated dependency sine_enabled format bool minimum {} maximum {}} value true} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency sine_width format long minimum {} maximum {}} value 12} bitoffset {attribs {resolve_type generated dependency sine_offset format long minimum {} maximum {}} value 0} real {fixed {fractwidth {attribs {resolve_type generated dependency sine_fractwidth format long minimum {} maximum {}} value 11} signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true}}}}}}}}}} TDATA_WIDTH 16 TUSER {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} struct {field_chanid {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value chanid} enabled {attribs {resolve_type generated dependency chanid_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency chanid_width format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} field_user {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value user} enabled {attribs {resolve_type generated dependency user_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency user_width format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency user_offset format long minimum {} maximum {}} value 0}}}}}} TUSER_WIDTH 0}, PHASE 0.0, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
begin
  M_AXIS_DATA_0_tdata(15 downto 0) <= dds_compiler_0_M_AXIS_DATA_TDATA(15 downto 0);
  M_AXIS_DATA_0_tvalid <= dds_compiler_0_M_AXIS_DATA_TVALID;
  aclk_0_1 <= aclk_0;
dds_compiler_0: component filter_tb_input_signal_dds_compiler_0_0
     port map (
      aclk => aclk_0_1,
      m_axis_data_tdata(15 downto 0) => dds_compiler_0_M_AXIS_DATA_TDATA(15 downto 0),
      m_axis_data_tvalid => dds_compiler_0_M_AXIS_DATA_TVALID,
      m_axis_phase_tdata(15 downto 0) => NLW_dds_compiler_0_m_axis_phase_tdata_UNCONNECTED(15 downto 0),
      m_axis_phase_tvalid => NLW_dds_compiler_0_m_axis_phase_tvalid_UNCONNECTED
    );
end STRUCTURE;





library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;library IEEE;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.all;

entity variable_fir_filter_tb is
	-- Generic declarations of the tested unit
		generic(
		a : positive := 12;	-- filter cutoff select
		w : positive := 12 );	-- input/output width
end variable_fir_filter_tb;

architecture behavioral of variable_fir_filter_tb is
    -- AXI4 Interface
    signal M_AXIS_DATA_0_tvalid : std_logic;
    signal S_AXIS_PHASE_0_tvalid : std_logic;
    
    -- Control and Data signals
    signal test_signal : std_logic_vector(15 downto 0);

    signal clk : std_logic := '0';
    signal reset : std_logic;
    signal filter_cutoff : std_logic_vector (a-1 downto 0);
    signal load_filter_cutoff : std_logic;
    signal input_signal : std_logic_vector (w-1 downto 0);
    signal output_signal :std_logic_vector (w-1 downto 0);

    constant period : time := 10 ns;
begin

	stim: entity filter_tb_input_signal
	 port map(
	 M_AXIS_DATA_0_tdata => test_signal,
     M_AXIS_DATA_0_tvalid => M_AXIS_DATA_0_tvalid,
     aclk_0 => clk);
	
	input_signal <= test_signal (15 downto (16-w));
	
	UUT: entity variable_fir_filter 
	generic map(a => a, w => w)
	port map(
        M_AXIS_DATA_0_tvalid => M_AXIS_DATA_0_tvalid,
        S_AXIS_PHASE_0_tvalid => S_AXIS_PHASE_0_tvalid,
		clk => clk,
		reset => reset,
		filter_cutoff => filter_cutoff,
		load_filter_cutoff => load_filter_cutoff,
		input_signal => input_signal,
		output_signal => output_signal);

    clock: process
    begin
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
    end process;

	S_AXIS_PHASE_0_tvalid <= '1';	
	M_AXIS_DATA_0_tvalid <= '1';
	-- Assert then dessert reset
	reset <= '1', '0' after 5 * period;

	-- Load a cutoff frequency
	load_filter_cutoff <= '0', '1' after 7 * period, '0' after 10 * period;
	filter_cutoff <= "000011110000";

end behavioral;
