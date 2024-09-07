LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;

entity DDS_SINC_GENERATOR_TB is
	-- Generic declarations of the tested unit
		generic(
	   out_WIDTH : positive := 16;    -- output sinusoid width (IP CORE fixed at 16 bits)
	   pacc_WIDTH : positive := 16;   -- phase accumulator width (IP CORE fixed at 16 bits) 
	   cnt_WIDTH : positive := 20;    -- phase accumulator counter width
	   pinc_WIDTH : positive := 16    -- phase increment width -> same as counter
	   );
end DDS_SINC_GENERATOR_TB;

architecture TB of DDS_SINC_GENERATOR_TB is
	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : std_logic := '0';
	signal reset: std_logic;
	signal freq_value : std_logic_vector(cnt_WIDTH - 1 downto 0);
	signal load_freq : std_logic;
	signal phase_offset : std_logic_vector(cnt_width - 1 downto 0);
    signal phase_out : std_logic_vector(pacc_WIDTH - 1 downto 0);
    signal phase_count : std_logic_vector(cnt_WIDTH -1 downto 0);   -- Internal phase accumulator counter output
	signal sine_out : std_logic_vector(out_WIDTH - 1 downto 0);     -- Output sine signal
	signal cosine_out : std_logic_vector(out_WIDTH - 1 downto 0);     -- Output sine signal
    signal M_AXIS_tvalid : std_logic;     -- AXIS Master Interface
    signal S_AXIS_tvalid : std_logic;       -- AXIS Slave Interface

    signal x_in, a_in, b_in, y_out, y_out1 : std_logic_vector(out_WIDTH - 1 downto 0);
    signal load_coeff : std_logic;
	signal dec_factor :  std_logic_vector(out_WIDTH - 1 downto 0);
	signal down_sampled :  std_logic_vector(out_WIDTH - 1 downto 0);
	
	constant period : time := 10 ns;
begin
	-- Unit Under Test port map
	UUT0 : entity DDS_SIN_COS_GENERATOR
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
	
	UUT1: entity IIR 
        generic map (data_WIDTH => 16, L => 3)
        port map(
        clk => clk,
        reset => reset,
        load_coeff => load_coeff,
        x_in => sine_out,
        a_in => a_in,
        b_in => b_in,
        y_out => y_out1);

	UUT3: entity IIR 
        generic map (data_WIDTH => 16, L => 3)
        port map(
        clk => clk,
        reset => reset,
        load_coeff => load_coeff,
        x_in => y_out1,
        a_in => a_in,
        b_in => b_in,
        y_out => y_out);

	
	  S_AXIS_tvalid <= '1';
	
	phase_offset <= (others => '0');	
	
	
	dec_factor <= x"0001";
	
	UUT2: entity down_sampler
    generic map (data_WIDTH => 16)
	port map(
	    clk => clk,
	    reset => reset,
		data_in => y_out,
		decimation_factor => dec_factor,
		data_out => down_sampled);
	
	
	chirp: process
	begin
	
       for i in 2**2 to 2**10 loop
	       load_freq <= '1';
	       freq_value <= std_logic_vector(to_unsigned(i*512,cnt_WIDTH));
	       wait for 3*period;
	       load_freq <= '0';
	       wait for 1000*period;
	   end loop;
	
	   for i in 2**10 to 2**15 loop
	       load_freq <= '1';
	       freq_value <= std_logic_vector(to_unsigned(i,cnt_WIDTH));
	       wait for 3*period;
	       load_freq <= '0';
	       wait for 100*period;
	   end loop;
    end process;
		  
	reset <= '1', '0' after 5 * period;	-- reset signal
	
	load_coeff <= '1', '0' after 10*period;
    a_in <= x"2495", x"492A" after 8*period, x"2495" after 9*period;    -- 0.2858, 0.5716, 0.2858
    b_in <= x"06F1", x"E6B9" after 8*period, x"0000" after 9*period;    -- 0.05423, -0.1975
--	    b_in <= x"0000", x"E6B9" after 8*period, x"06F1" after 9*period;


	clock: process				-- system clock
	begin
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
	end process;
end TB;