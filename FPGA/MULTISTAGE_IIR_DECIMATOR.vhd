----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Two Pole Chebyshev IIR Filter
--
-- Description: A 2-pole IIR Chebyshev filter. Each filter coefficient input 
--   port, a_in and b_in, are given as inputs to the component in the form of a
--   packet that consists of three coefficients. The lower nibbles correspond to 
--   coefficients 0,1,2,... and the upper nibbles correspond to the coefficients
--   n,n-1,n-2,...
--
-- Inputs:
--    clk : system clock
--    i_sample_clk : sample clock of input sequence
--    i_reset : Active-high Synchronous reset
--    i_enable: Active-high Enable
--    x_in : Input data sequence
--    a_in : 3 coefficients connected in parallel [data+WIDTH - 1 : 0] => a0
--    b_in : 3 coefficients connected in parallel [data+WIDTH - 1 : 0] => b0
--
-- Outputs:
--    y_out : Output data sequence
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity BIQUAD_IIR_FILTER_CHEBYSHEV is
generic (data_WIDTH : positive);
port (
    clk : in std_logic; 
    i_sample_clk : in std_logic;  
    i_reset : in std_logic; 
    i_enable: in std_logic;
    x_in : in std_logic_vector (data_WIDTH - 1 downto 0);   
    a_in : in std_logic_vector(3*data_WIDTH - 1 downto 0);
    b_in : in std_logic_vector(3*data_WIDTH - 1 downto 0);  
    y_out : out std_logic_vector(data_WIDTH - 1 downto 0)   
    );
end BIQUAD_IIR_FILTER_CHEBYSHEV;

architecture Behavioral of BIQUAD_IIR_FILTER_CHEBYSHEV is
    subtype SLV_data_WIDTH is std_logic_vector(data_WIDTH - 1 downto 0);
    type RAM is array (0 to 2) of SLV_data_WIDTH;    
    signal x : RAM  := (others => (others => '0'));     -- Input signal vector x[n] registers
    signal y : RAM  := (others => (others => '0'));     -- Output signal vector y[n] registers
    signal y_buffer : signed(2*data_WIDTH - 1 downto 0) := (others => '0');
begin
    -- Filter processing is synchronous to input sample clock
    process(clk, i_sample_clk)    
        variable y_var : signed(2*data_WIDTH - 1 downto 0);
        variable idx_L, idx_R : integer;   -- boundaries for a_n and b_n 
    begin
        if rising_edge(clk) then
            -- Reset is synchronous to the system clock
            if i_reset = '1' then 
                for i in 0 to 2 loop
                    x(i) <= (others =>'0'); -- clear input signal vector registers
                    y(i) <= (others =>'0'); -- clear output signal vector registers
                end loop;
                y_buffer <= (others => '0');    -- clear output buffer register
            else
                -- Compute: y[n] = a0*x[n] + a1*x[n-1] + a2*x[n-2] + ... + b1*y[n-1] + b2*y[n-2] + ... 
                y_var := (others => '0');    -- Initialize y[n]
                for i in 0 to 2 loop
                    idx_L := (i+1)*data_WIDTH - 1;  -- Left boundary of a & b coefficients read from input port
                    idx_R := i*data_WIDTH;          -- Right boundary of a & b coefficients read from input port
                    y_var := y_var + (signed(x(i)) * signed(a_in(idx_L downto idx_R)));     -- x[n]*a_n
                    y_var := y_var + (signed(y(i)) * signed(b_in(idx_L downto idx_R)));     -- y[n-1]*b_n
                end loop;
                
                -- Divide by 2^data_WIDTH - 2 to convert from integer to Q2.30 fixed-point and update buffer
                y_var := shift_right(signed(y_var),data_WIDTH - 2);
                y_buffer <= y_var;
            end if;
        end if;    
    
        if rising_edge(i_sample_clk) and i_reset = '0' then
            -- Shift x[n] and y[n] data registers before loading new samples
            for i in 1 to 2 loop
                x(i) <= x(i-1); 
                y(i) <= y(i-1); 
            end loop;
            
            -- Load new input sample x[n] and previous output sample y[n-1]
            x(0) <=  x_in;     
            y(0) <= std_logic_vector(resize(signed(y_buffer), data_WIDTH));  
        end if;                                           
   end process; 
   
   -- Resize buffer width for feedback when filter enabled, when disabled pass input to output
   with i_enable select
        y_out <= std_logic_vector(resize(signed(y_buffer), data_WIDTH)) when '1', x_in when others; 
end Behavioral;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: Clock Divider
-- 
-- Description: The output signal is a clock signal with a frequency that is  
--   equal to the input clock frequency divided by an integer value. This can be
--   used to generate a new sampling clock for a downsampled signal
--
-- Inputs:
--    clk_in : Input clock
--    i_reset : Active-high Synchronous reset
--    i_clk_div : Clock divider input to output frequency ratio
--
-- Outputs:
--    clk_out : Output clock divided by i_clk_div
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CLK_DIVIDER is
    generic(d_WIDTH : integer);
    port(
      clk_in    : in  std_logic;
      i_reset   : in  std_logic;
      i_clk_div : in  std_logic_vector(5 downto 0);
      clk_out   : out std_logic
    );
end CLK_DIVIDER;

architecture RTL of CLK_DIVIDER is
    signal r_clk_counter        : unsigned(5 downto 0);
    signal r_clk_divider        : unsigned(5 downto 0);
    signal r_clk_divider_half   : unsigned(5 downto 0);
begin
    process(clk_in)
    begin
    if i_reset = '1' then
        r_clk_counter <= (others=>'0');
        r_clk_divider <= (others=>'0');
        r_clk_divider_half <= (others=>'0');
        clk_out <= '0';
    elsif rising_edge(clk_in) then
        r_clk_divider <= unsigned(i_clk_div) + 1;
        r_clk_divider_half  <= unsigned('0' & r_clk_divider(5 downto 1));

        if(r_clk_counter < r_clk_divider_half) then 
            r_clk_counter   <= r_clk_counter + 1;
            clk_out <= '0';
        elsif(r_clk_counter = r_clk_divider - 1) then
          r_clk_counter <= (others => '0');
          clk_out <= '1';
        else
          r_clk_counter <= r_clk_counter + 1;
          clk_out <= '1';
        end if;
      end if;
    end process;
end RTL;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: Downsampler
--
-- Description: Counts a number of clock cycles determined by the decimation 
--   factor. The internal resets after the correct number of clock cycles has 
--   ellapsed and the input signal is passed to the output signal along with an 
--   output clock that is synchronized to the new sampling rate
--
-- Inputs:
--    clk : System clock
--    i_sample_clk : Input sampling clock, synchronized with input sampling rate
--    i_reset : Active-high Synchronous reset
--    i_decimation_factor : Downsample factor, determines how many clks to  count before sampling the input signal
--    data_in : Input data sequency 
--
-- Outputs:
--    data_out : Output data sequence
--    o_sample_clk : Output clock, synchronized to new sampling rate
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE WORK.ALL;

entity DOWN_SAMPLER is
    generic (data_WIDTH : positive);
	port (
	    clk : in std_logic;
	    i_sample_clk : in std_logic;
	    i_reset : in std_logic;
		i_decimation_factor : in std_logic_vector(5 downto 0);
		data_in : in std_logic_vector(data_WIDTH-1 downto 0);
		data_out : out std_logic_vector(data_WIDTH-1 downto 0); 
		o_sample_clk : out std_logic
		);
end DOWN_SAMPLER;

architecture Behavioral of DOWN_SAMPLER is
    signal clk_counter :  std_logic_vector (data_WIDTH-1 downto 0) := (others => '0');  -- clk cycle counter
    signal data_buffer : std_logic_vector(data_WIDTH-1 downto 0) := (others => '0'); -- Buffer for synchronized data
    signal internal_clk : std_logic; -- Internal clock signal for data synchronization
begin	  
	process(clk, i_sample_clk, internal_clk)   
	begin
	   -- Reset is synchronous to the system clock
	   if rising_edge(clk) and i_reset = '1' then
	       clk_counter <= (others => '0'); -- Reset coutner
           data_buffer <= (others => '0'); -- Reset buffer
	       data_out <= (others => '0');    -- Reset output
       end if;	   
	
	   -- Increment clock cycle counter and update data_buffer, synchronous with input sampling clock
	   if rising_edge(i_sample_clk) and i_reset = '0' then
	       if clk_counter = i_decimation_factor then
	           clk_counter <= (others => '0');     -- Reset counter 
	           data_buffer <= data_in;             -- Load input into buffer
           else
	           clk_counter <= clk_counter + 1; -- increment clock cycle counter           
	       end if;
       end if;
       
       -- Synchronize output data with internal clock
	   if rising_edge(internal_clk) and i_reset = '0' then
	           data_out <= data_buffer;    -- Pass buffered data to output on internal_clk rising edge
	   end if;       
	   
	end process;	
	
    -- Divide sampling clock by same factor
	u0: entity CLK_DIVIDER 
    generic map(d_WIDTH => data_WIDTH)
    port map(
        clk_in => i_sample_clk,
        i_reset => i_reset,
        i_clk_div => i_decimation_factor,
        clk_out => internal_clk -- Use internal_clk
    );	

    -- Output o_sample_clk to match internal_clk
    o_sample_clk <= internal_clk; -- Drive o_sample_clk with internal_clk	
end Behavioral;
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: Two Pole Chebyshev IIR Decimator
--
-- Description: Cascades an 2-pole IIR Chebysev anti-aliasing filter with a  
--  downsampler to decimate an input sample sequence. It outputs both the  
--  decimated sample sequence and a new sampling clock that is synchronized to   
--  the decimated sequence. 
--
-- Inputs:
--    clk : System clock
--    i_sample_clk : sample clock of input sequence
--    i_reset : Active-high Synchronous reset
--    i_decimation_factor : Decimation factor, ratio between input and output sampling rates
--    x_in : Input data sequence
--    a_in : 3 coefficients connected in parallel [data+WIDTH - 1 : 0] => a0
--    b_in : 3 coefficients connected in parallel [data+WIDTH - 1 : 0] => b0

-- Outputs:
--    y_out: Output data sequence
--    o_sample_clk : sample clock of output sequence, synchronized to new sampling rate
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;

entity BIQUAD_IIR_DECIMATOR_CHEBYSHEV is
    generic (data_WIDTH : positive);
    port(
        clk : in std_logic;	
        i_sample_clk : in std_logic;          
        i_reset : in std_logic;	
        i_enable : in std_logic;				                
        i_decimation_factor : in std_logic_vector(5 downto 0);
        x_in : in std_logic_vector (data_WIDTH - 1 downto 0);
        a_in : in std_logic_vector(3*data_WIDTH - 1 downto 0);
        b_in : in std_logic_vector(3*data_WIDTH - 1 downto 0);
        y_out : out std_logic_vector(data_WIDTH - 1 downto 0);
        o_sample_clk : out std_logic  
    );
end BIQUAD_IIR_DECIMATOR_CHEBYSHEV;

architecture STRUCTURE of BIQUAD_IIR_DECIMATOR_CHEBYSHEV is    
  -- Internal Routing Signals
	signal IIR_xin: std_logic_vector(data_WIDTH - 1 downto 0) := (others => '0');	
	signal IIR_yout : std_logic_vector (data_WIDTH - 1 downto 0);
	signal sampler_din : std_logic_vector (data_WIDTH - 1 downto 0);
	signal sampler_dout : std_logic_vector (data_WIDTH - 1 downto 0);
begin		 
    -- Load input sample
    IIR_xin <= x_in;
    
    -- Bypass filter when decimation factor is 1, otherwise pass through filter
    sampler_din <= IIR_xin when i_decimation_factor = "000000" else IIR_yout;
    
	-- Instantiate IIR Filter
	u0: entity BIQUAD_IIR_FILTER_CHEBYSHEV
        generic map(data_WIDTH => data_WIDTH)
        port map(
            clk => clk, 
            i_sample_clk => i_sample_clk,
            i_reset => i_reset,
            i_enable => i_enable,
            x_in => IIR_xin,
            a_in => a_in,
            b_in => b_in,
            y_out => IIR_yout
        ); 
                       
	-- Instantiate Downsampler
	u1: entity DOWN_SAMPLER
        generic map(data_WIDTH => data_WIDTH)
        port map(
            clk => clk,
            i_sample_clk => i_sample_clk,
            i_reset => i_reset,
            data_in => sampler_din,
            i_decimation_factor => i_decimation_factor,
            data_out => sampler_dout,
            o_sample_clk => o_sample_clk
        );  
        
    y_out <= sampler_dout;    
end STRUCTURE;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: 4 to 1 Multiplexer
--
-- Description: This is a simple 4:1 multiplexer. The multi-stage decimator has
--  two LUTS, one for the a and b coefficients of the IIR filter. Each filter   
--  stage has its own MUX to select one of the coefficient sets from the LUTs.  
--  This allows the each filter stages's cutoff frequency to be programmed by  
--  using the MUX to select a coefficient set to be used. 
--
-- Inputs:
--    sel : Select line
--    a0 : Input channel 0
--    a1 : Input channel 1
--    a2 : Input channel 2 
--    a3 : Input channel 3   
--
-- Outputs:
--    y: Selected output signal
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;

entity MUX_4to1 is
generic (data_WIDTH : positive);
port (
	sel : in std_logic_vector(1 downto 0);
	a0  : in std_logic_vector(data_WIDTH - 1 downto 0);
    a1  : in std_logic_vector(data_WIDTH - 1 downto 0);
    a2  : in std_logic_vector(data_WIDTH - 1 downto 0);
    a3  : in std_logic_vector(data_WIDTH - 1 downto 0);
    y   : out std_logic_vector (data_WIDTH - 1 downto 0)
);
end MUX_4to1;

architecture RTL of MUX_4to1 is
begin
    with sel select
        y <= a0 when "00",
             a1 when "01",
             a2 when "10",
             a3 when "11",
             a0 when others;
end RTL;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: Decimation Encoder
-- 
-- Description: The IIR filter component requires a decimation_factor input as an
--  unsigned value that represents the amount of clock cycles the downsampler 
--  needs count before sampling the filtered signal. Since each filter has 4 
--  possible decimation factors (1,2,10,50) this encoder maps a 2-bit select 
--  value onto an unsigned integer value representing the number of clock cycles 
--  the downsampler needs to counter before sampling the filtered signal.
--
-- Inputs:
--    i_decimation_sel : Select line
--
-- Outputs:
--    o_decimation_factor: Number of clock cycles for downsampler to count before sampling input data sequence
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;

entity DECIMATION_ENCODER is
port (
	i_decimation_sel : in std_logic_vector(1 downto 0);      -- select value
	o_decimation_factor : out std_logic_vector(5 downto 0)   -- # of clk cycles to count
);
end DECIMATION_ENCODER;

architecture RTL of DECIMATION_ENCODER is
begin
    -- Decimation factor logic value is 1 less than its integer value
    with i_decimation_sel select
        o_decimation_factor <= 
             std_logic_vector(to_unsigned(1-1, 6))  when "00",   -- Decimation factor = 1
             std_logic_vector(to_unsigned(2-1, 6))  when "01",   -- Decimation factor = 2
             std_logic_vector(to_unsigned(10-1, 6)) when "10",   -- Decimation factor = 10
             std_logic_vector(to_unsigned(50-1, 6)) when "11",   -- Decimation factor = 50
             std_logic_vector(to_unsigned(1-1, 6))  when others;   -- Decimation factor = 1
end RTL;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Multistage Two Pole Chebyshev IIR Decimator
--
-- Description: A multistage decimator with 4 stages of cascaded IIR filters and
--  and downsamplers. An internal LUTS stores 3 sets of IIR coefficients and an 
--  8-bit select signal can be used to select the decimation factor for each of
--  the four stages. The IIR filter coefficients correspond to filters with the
--  cut-off frequencies required for decimation by a factor of 1,2,10,50, allowing
--  for a range of decimation by a factor of 1 all the way to 6,250,000.
--
-- Inputs:
--    clk : system clock
--    i_sample_clk : Input sampling clock, synchronous with input data sequence
--    i_reset : Active-high Synchronous reset
--    i_enable: Active-high enable
--    i_decimation_factor: Decimation factor, ratio between input and output sampling rates
--
-- Outputs:
--    o_decimation_factor: Number of clock cycles for downsampler to count before sampling input data sequence
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;

entity MULTISTAGE_BIQUAD_IIR_DECIMATOR_CHEBYSHEV is
    generic (data_WIDTH : positive);
    port(
        clk : in std_logic;	
        i_sample_clk : in std_logic;
        i_reset : in std_logic;
        i_enable : in std_logic;					                
        i_decimation_select : in std_logic_vector(7 downto 0);
        x_in : in std_logic_vector(data_WIDTH - 1 downto 0);
        y_out : out std_logic_vector(data_WIDTH - 1 downto 0);
        o_sample_clk : out std_logic
    );
end MULTISTAGE_BIQUAD_IIR_DECIMATOR_CHEBYSHEV;

architecture MULTISTAGE of MULTISTAGE_BIQUAD_IIR_DECIMATOR_CHEBYSHEV is
    subtype coeff_vector is std_logic_vector(3*data_WIDTH - 1 downto 0);
    type coeff_LUT is array (0 to 2) of coeff_vector;
    
    -- LUT of 3 sets of Q2.30 fixed point IIR a filter coefficients
    constant a_LUT : coeff_LUT := (
        x"124ABA38" & x"249574DC" & x"124ABA38",    -- Set 1: fc = 0.25*fs: 0.2858, 0.5716, 0.2858
        x"0132301E" & x"02646047" & x"0132301E",    -- Set 2: fc = 0.05*fs: 0.01868823, 0.3737647, 0.01868823
        x"000E31B0" & x"001C6361" & x"000E31B0");   -- Set 3: fc = 0.01*fs: 0.0008663387, 0.001732678, 0.0008663387
                
    -- LUT of 3 sets of Q2.30 fixed point IIR b filter coefficients
    constant b_LUT : coeff_LUT := (
        x"F35C8A45" & x"03788BED" & x"00000000",    -- Set 1: fc = 0.25*fs: 0.05423, -0.1975, 0.00
        x"D5342D99" & x"66031056" & x"00000000",    -- Set 2: fc = 0.05*fs: -0.6686903, 1.593937, 0.00
        x"F4F4370A" & x"7AD30271" & x"00000000");   -- Set 3: fc = 0.01*fs: -0.9225943, 1.919129, 0.00

  -- Routing signals for output of coefficient MUXs
    type MUX_coeff_reg is array (0 to 3) of coeff_vector;
    signal IIR_a_inputs, IIR_b_inputs : MUX_coeff_reg;
    
  -- Routing signals for input/output of each decimation stage
    subtype SLV_data_WIDTH is std_logic_vector(data_WIDTH - 1 downto 0);
    type RAM is array (0 to 4) of SLV_data_WIDTH;
    signal data : RAM := (others => (others => '0'));  
    
  -- Routing signals for decimation factor of each decimation stage
    type decimation_vector is array (0 to 3) of std_logic_vector (5 downto 0);
    signal decimation_values : decimation_vector := (others => (others => '0')); 

  -- Routing signals for input and outpu sampling clock of each stage
    signal sample_clks : std_logic_vector (4 downto 0);    
begin		 
    -- Input data and clock signals for first stage
    sample_clks(0) <= i_sample_clk;
    data(0) <= x_in;
                    
	GEN_IIR: for i in 0 to 3 generate
	-- Instantiate 4 Two Pole Chebyshev IIR Decimators	
	IIRs: entity BIQUAD_IIR_DECIMATOR_CHEBYSHEV 
    generic map(data_WIDTH => data_WIDTH)
    port map(
        clk => clk,
        i_sample_clk => sample_clks(i),
        i_reset => i_reset,
        i_enable => i_enable,
        i_decimation_factor => decimation_values(i),
        x_in => data(i),    
        a_in => IIR_a_inputs(i),    
        b_in => IIR_b_inputs(i),    
        y_out => data(i+1),   
        o_sample_clk => sample_clks(i+1)
    );
    
    -- Instantiate 4 encoders to convert decimation select bits to a decimation factor
    ENCODERs: entity DECIMATION_ENCODER
    port map(
	   i_decimation_sel => i_decimation_select((2*i)+1 downto 2*i),
	   o_decimation_factor => decimation_values(i)
    );

	-- Instantiate 4 4:1 MUXs to select a IIR coefficients from a-LUT
    aMUXs: entity MUX_4to1
    generic map (data_WIDTH => 3*data_WIDTH)
    port map(
        sel => i_decimation_select((2*i)+1 downto 2*i),
        a0  => a_LUT(0),
        a1  => a_LUT(0),
        a2  => a_LUT(1),
        a3  => a_LUT(2),
        y   => IIR_a_inputs(i)
    );
       
    -- Instantiate 4 4:1 MUXs to select b IIR coefficients from b-LUT 
    bMUXs: entity MUX_4to1
    generic map (data_WIDTH => 3*data_WIDTH)
    port map(
        sel => i_decimation_select((2*i)+1 downto 2*i),
        a0  => b_LUT(0),
        a1  => b_LUT(0),
        a2  => b_LUT(1),
        a3  => a_LUT(2),
        y   => IIR_b_inputs(i)
    );
    end generate;
    
    -- Output data sequence and sampling clock of last stage
    y_out <= data(4);
    o_sample_clk <= sample_clks(4);
end MULTISTAGE;
