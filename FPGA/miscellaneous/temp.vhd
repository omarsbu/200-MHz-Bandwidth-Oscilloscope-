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
 
    signal x : RAM := (others => (others => '0'));      -- Input signal vector x[n]
    signal y : RAM := (others => (others => '0'));      -- Output signal vector y[n]
    signal a : RAM := (others => (others => '0'));      -- a[n] coefficient vector
    signal b : RAM := (others => (others => '0')) ;      -- b[n] coefficient vector
    signal y_buffer : signed(2*data_WIDTH - 1 downto 0) := (others => '0'); 
begin
    -- Load order => a[n], a[n-1], a[n-2], ... , a[0] 
    -- Load order => b[n], b[n-1], b[n-2], ... , b[1]
    process(clk)
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
            end if;
       end if;       
   end process; 
   
    -- Resize buffer width for feedback
    y_out <= std_logic_vector(resize(signed(y_buffer), data_WIDTH));  
end Behavioral;

----------------------------------------------------------------------------------
-- Clock Divider
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CLK_DIVIDER is
    generic(d_WIDTH : integer);
    port(
      clk_in : in  std_logic;
      reset : in  std_logic;
      clk_div : in  std_logic_vector(d_WIDTH - 1 downto 0);
      clk_out : out std_logic
    );
end CLK_DIVIDER;

architecture RTL of CLK_DIVIDER is
    signal r_clk_counter        : unsigned(d_WIDTH - 1 downto 0);
    signal r_clk_divider        : unsigned(d_WIDTH - 1 downto 0);
    signal r_clk_divider_half   : unsigned(d_WIDTH - 1 downto 0);
begin
    process(clk_in)
    begin
    if reset = '1' then
        r_clk_counter <= (others=>'0');
        r_clk_divider <= (others=>'0');
        r_clk_divider_half <= (others=>'0');
        clk_out <= '0';
    elsif rising_edge(clk_in) then
        r_clk_divider <= unsigned(clk_div) + 1;
        r_clk_divider_half  <= unsigned('0' & r_clk_divider(d_WIDTH - 1 downto 1));

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
		data_out : out std_logic_vector(data_WIDTH-1 downto 0); -- Output data
		clk_out : out std_logic
		);
end DOWN_SAMPLER;

architecture Behavioral of DOWN_SAMPLER is
    signal clk_counter :  std_logic_vector (data_WIDTH-1 downto 0) := (others => '0');  -- clk cycle counter
    signal data_buffer : std_logic_vector(data_WIDTH-1 downto 0); -- Buffer for synchronized data
    signal internal_clk : std_logic; -- Internal clock signal for data synchronization
begin

    -- Process to increment clock cycle counter and update data_buffer
	process(clk)   
	begin
	   if rising_edge(clk) then
	       if reset = '1' then
	           clk_counter <= (others => '0'); 
               data_buffer <= (others => '0'); -- Reset buffer
           elsif clk_counter = decimation_factor then
	           clk_counter <= (others => '0');     -- Reset counter 
	           data_buffer <= data_in;    -- Load input into buffer
           else
	           clk_counter <= clk_counter + 1; -- increment clock cycle counter           
	       end if;
       end if;
	end process;
	
    -- Divide clock by same factor
	u0: entity WORK.CLK_DIVIDER 
    generic map(d_WIDTH => data_WIDTH)
    port map(
        clk_in => clk,
        reset => reset,
        clk_div => decimation_factor,
        clk_out => internal_clk -- Use internal_clk
    );	

    -- Output process synchronized with internal_clk
	process(internal_clk)
	begin
	   if rising_edge(internal_clk) then
	       if reset = '1' then
	           data_out <= (others => '0'); -- Reset output
	       else
	           data_out <= data_buffer;    -- Pass buffered data to output on internal_clk rising edge
	       end if;
	   end if;
	end process;

    -- Output clk_out to match internal_clk
    clk_out <= internal_clk; -- Drive clk_out with internal_clk

end Behavioral;

----------------------------------------------------------------------------------
-- IIR Decimator
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;

entity IIR_DECIMATOR is
    generic (data_WIDTH : positive; L : positive, a_WIDTH : positive);
    port(
        clk : in std_logic;	
        reset : in std_logic;					                
        load_coeff : in std_logic;
        x_in : in std_logic_vector (data_WIDTH - 1 downto 0);
        a_in : in std_logic_vector(data_WIDTH - 1 downto 0);
        b_in : in std_logic_vector(data_WIDTH - 1 downto 0);
        y_out : out std_logic_vector(data_WIDTH - 1 downto 0);
        decimation_factor : in std_logic_vector(data_WIDTH - 1 downto 0);
        clk_out : out std_logic  
    );
end IIR_DECIMATOR;

architecture STRUCTURE of IIR_DECIMATOR is    
  -- Internal Routing Signals
	signal IIR_xin: std_logic_vector(data_WIDTH - 1 downto 0);	
	signal IIR_yout : std_logic_vector (data_WIDTH - 1 downto 0);
begin		 
    IIR_xin <= x_in;
    
	-- Instantiate IIR Filter
	u0: entity IIR_FILTER
        generic map(data_WIDTH => data_WIDTH, L => L)
        port map(
            clk => clk, 
            reset => reset,
            load_coeff => load_coeff,
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
            reset => reset,
            data_in => IIR_yout,
            decimation_factor => decimation_factor,
            data_out => y_out,
            clk_out => clk_out
        );

  -- Instantiate Coefficient Loader
  u2: entity COEFFICIENT_LOADER
      generic map(data_WIDTH => data_WIDTH, L => L, a_WIDTH => a_WIDTH);
      port map(
        clk => clk, 
        reset => reset, 
        load => load_coeff,
        x_in => a_in, 
        y_out =>
      );
    

    
end STRUCTURE;


----------------------------------------------------------------------------------
-- Coefficient Loader
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;

entity COEFFICIENT_LOADER is
    generic (data_WIDTH : positive; L : positive; a_WIDTH : positive);
    port(
        clk : in std_logic;
        reset : in std_logic;
        load : in std_logic;
        x_in : in std_logic_vector(data_WIDTH - 1 downto 0);
        y_out : out std_logic_vector(data_WIDTH - 1 downto 0);
        address : out std_logic_vector(a_WIDTH - 1 downto 0);
        done : out std_logic
    );
end COEFFICIENT_LOADER;

architecture RTL of COEFFICIENT_LOADER is 
    signal address_counter : integer := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then 
                address_counter <= 0;
                done <= '0';
            elsif load = '1' then 
                address_counter <= address_counter + 1;
                y_out <= x_in;
            end if;
            
            if address_counter = 2**a_WIDTH - 1 then
                done <= '1';
            else
                done <= '0';
            end if;
        end if;    
    end process;
    
    address <= std_logic_vector(to_unsigned(address_counter, data_WIDTH));
end RTL;


----------------------------------------------------------------------------------
-- Coefficient Lookup Table
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity FILE_LUT is
    generic (a_WIDTH : positive; d_WIDTH : positive; FILE_NAME : string);
	port(
        address : in std_logic_vector(a_WIDTH - 1 downto 0);            
		y_out : out std_logic_vector(d_WIDTH - 1 downto 0)
    );
end FILE_LUT;

architecture Behavioral of FILE_LUT is
    -- LUT declaration
	type table is array(0 to 2**a_WIDTH - 1) of std_logic_vector(d_WIDTH-1 downto 0);
	signal lut : table;
	-- File declaration
	file coef_file : text;
begin	  

-- Process to read the file and populate the LUT
	process
		variable line_buf : line;
		variable data_buf : std_logic_vector(d_WIDTH - 1 downto 0);
		variable i : integer := 0;
	begin
	   file_open(coef_file, FILE_NAME, read_mode);

	   -- Populate LUT from txt file
	   while not endfile(coef_file) loop
	       readline(coef_file, line_buf);
	       read (line_buf, data_buf);
	       lut(i) <= data_buf; 
	       i := i +1 ;
	   end loop;
	   
	   -- Pad remaining LUT entries with all 0s
	   while i < 2**a_WIDTH loop
	       lut(i) <= (others => '0');
	       i := i + 1;
	   end loop;
	   wait;
	end process;	

-- Process to output coefficient based on input address	
	process(address)
	begin
		y_out <= lut(to_integer(unsigned(address)));	
	end process;
end Behavioral;


----------------------------------------------------------------------------------
-- Multi-stage IIR Decimator
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;

entity MULTISTAGE_IIR_DECIMATOR is
    generic (data_WIDTH : positive; L : positive; N : integer);
    port(
        clk : in std_logic;	
        reset : in std_logic;					                
        load_coeff : in std_logic_VECTOR(N - 1 downto 0);
        tap : in std_logic_vector(N - 1 downto 0);
        x_in : in std_logic_vector (data_WIDTH - 1 downto 0);
        a_in : in std_logic_vector(data_WIDTH - 1 downto 0);
        b_in : in std_logic_vector(data_WIDTH - 1 downto 0);
        y_out : out std_logic_vector(data_WIDTH - 1 downto 0);
        decimation_factor : in std_logic_vector(data_WIDTH - 1 downto 0);
        clk_out : out std_logic
    );
end MULTISTAGE_IIR_DECIMATOR;

architecture MULTISTAGE of MULTISTAGE_IIR_DECIMATOR is    
    subtype SLV_data_WIDTH is std_logic_vector(data_WIDTH - 1 downto 0);
    type RAM_N is array (0 to N-1) of SLV_data_WIDTH;
    
    -- DEMUX top level signals for each stage 
    signal x_n, a_n, b_n, d_n : RAM_N := (others => (others => '0')); 
    signal y_n : RAM_N; -- := (others => (others => '0'))
  -- Internal Routing Signals
	signal s_xin: std_logic_vector(data_WIDTH - 1 downto 0);	
	signal s_yout : std_logic_vector (data_WIDTH - 1 downto 0);
	signal in_clocks, out_clocks : std_logic_vector(N-1 downto 0);
begin		 
    in_clocks(0) <= clk;
    x_n(0) <= x_in;

    -- Cascade input and output clocks
    GEN_CLKS: for i in 1 to N-1 generate
        x_n(i) <= y_n(i-1);
        in_clocks(i) <= out_clocks(i-1);
    end generate;
    
    -- Generate IIR Decimators
    GEN_IIR : for i in 0 to N - 1 generate
    IIR_FILTERS : entity IIR_DECIMATOR
      generic map (data_WIDTH => data_WIDTH, L => L)
      port map (
        clk => in_clocks(i),
        reset => reset,					                
        load_coeff => load_coeff(i),
        x_in => x_n(i),
        a_in => a_n(i),
        b_in => b_n(i),
        y_out => y_n(i),
        decimation_factor => d_n(i),
        clk_out => out_clocks(i)
      );
    end generate;   
     
    -- Process to load coefficients and decimation factor for each stage
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                    a_n <= (others => (others => '0'));
                    b_n <= (others => (others => '0'));
                    d_n <= (others => (others => '0'));                  
            else      
                for i in 0 to N - 1 loop 
                    -- DEMUX input signals 
                   if load_coeff(i) = '1' then
                        a_n(i) <= a_in;
                        b_n(i) <= b_in;
                        d_n(i) <= decimation_factor;
                    end if;
                    
                    -- DEMUX output signals 
                   if tap(i) = '1' and load_coeff(i) = '0' then
                       y_out <= y_n(i);
                       clk_out <= out_clocks(i);
                   end if;  
                end loop;         
            end if;
        end if;     
    end process;       
end MULTISTAGE;
