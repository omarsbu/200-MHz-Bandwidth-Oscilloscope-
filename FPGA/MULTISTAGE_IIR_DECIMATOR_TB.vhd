LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;

entity IIR_DECIMATOR_TB is
	-- Generic declarations of the tested unit
	generic(
	   out_WIDTH : positive := 16;    -- output sinusoid width (IP CORE fixed at 16 bits)
	   pacc_WIDTH : positive := 16;   -- phase accumulator width (IP CORE fixed at 16 bits) 
	   cnt_WIDTH : positive := 20;    -- phase accumulator counter width
	   pinc_WIDTH : positive := 16;   -- phase increment width -> same as counter
	   data_WIDTH : positive := 32;   -- IIR filter data width 
	   decimation : positive := 2     -- Decimation factor
	   );
end IIR_DECIMATOR_TB;

architecture TB of IIR_DECIMATOR_TB is
    -- Clock and control signals
	signal clk : std_logic := '0';
	signal reset: std_logic;
	signal enable : std_logic;
	
	-- Stimulus signals - signals mapped to the input and inout ports of signal generator 
	signal freq_value : std_logic_vector(cnt_WIDTH - 1 downto 0);
	signal load_freq : std_logic;
	signal phase_offset : std_logic_vector(cnt_width - 1 downto 0);
    signal phase_out : std_logic_vector(pacc_WIDTH - 1 downto 0);
    signal phase_count : std_logic_vector(cnt_WIDTH -1 downto 0);   -- Internal phase accumulator counter output
	signal sine_out : std_logic_vector(out_WIDTH - 1 downto 0);     -- Output sine signal
	signal cosine_out : std_logic_vector(out_WIDTH - 1 downto 0);     -- Output sine signal
    signal M_AXIS_tvalid : std_logic;     -- AXIS Master Interface
    signal S_AXIS_tvalid : std_logic;       -- AXIS Slave Interface

	-- Stimulus signals - signals mapped to the input and inout ports of UUT 
    signal x_in, y_out : std_logic_vector(data_WIDTH - 1 downto 0);
    signal a_in, b_in : std_logic_vector(3*data_WIDTH - 1 downto 0);
	signal o_sample_clk : std_logic;
    signal decimation_factor : std_logic_vector(5 downto 0);
    signal decimation_select : std_logic_vector(7 downto 0);

	constant period : time := 10 ns;
begin
    -- Initial reset
	reset <= '1', '0' after 5000 * period;
	enable <= '1';
    phase_offset <= (others => '0');	
	S_AXIS_tvalid <= '1';
	decimation_select <= "01" & "01" & "01" & "01";
    decimation_factor <= std_logic_vector(to_unsigned(1,6));
    a_in <= x"124ABA38" & x"249574DC" & x"124ABA38";    -- 0.2858, 0.5716, 0.2858
    b_in <= x"F35C8A45" & x"03788BED" & x"00000000";     -- 0.05423, -0.1975, 0.000

	-- DDS Synthesizer generates input sinusoid
	INPUT_SIGNAL: entity DDS_SIN_COS_GENERATOR
		  generic map (out_WIDTH => out_WIDTH, pacc_WIDTH => pacc_WIDTH, cnt_WIDTH => cnt_WIDTH, pinc_WIDTH => pinc_WIDTH)
		  port map (
			 clk => clk,
			 reset => reset,
			 freq_value => freq_value,
			 load_freq => load_freq,
			 phase_offset => phase_offset,
			 phase_out => phase_out,
			 phase_count => phase_count,
			 sine_out => sine_out,
			 cosine_out => cosine_out,
             M_AXIS_tvalid => M_AXIS_tvalid,
             S_AXIS_tvalid => S_AXIS_tvalid);   

	x_in <= sine_out & x"0000"; 
		  
	UUT: entity MULTISTAGE_BIQUAD_IIR_DECIMATOR_CHEBYSHEV  
    generic map (data_WIDTH => 32)
    port map(
        clk => clk,
        i_reset => reset,
        i_enable => enable,
        i_decimation_select => decimation_select,
        x_in => x_in,
        y_out => y_out
    );	  
	  
	-- Process to generate a chirp signal 
    CHIRP: process
	begin	
       for i in 2**2 to 2**6 loop
	       load_freq <= '1';
	       freq_value <= std_logic_vector(to_unsigned(i*2,cnt_WIDTH));
	       wait for 3*period;
	       load_freq <= '0';
	       wait for 500*period;
	   end loop;
	
	   for i in 2**12 to 2**13 loop
	       load_freq <= '1';
	       freq_value <= std_logic_vector(to_unsigned(i*1024,cnt_WIDTH));
	       wait for 3*period;
	       load_freq <= '0';
	       wait for 250*period;
	   end loop;
    end process CHIRP;
	 
    -- Process to generate system clock
	clock: process				
	begin
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
	end process;
end TB;
