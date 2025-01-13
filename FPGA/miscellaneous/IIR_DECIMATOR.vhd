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
    signal clk_counter :  std_logic_vector (data_WIDTH-1 downto 0) := (others => '0');  -- clk cycle counter
begin	  
    -- Process to increment clock cycle counter and check 
	process(clk)   
	begin
	   if rising_edge(clk) then
	       if reset = '1' then
	           clk_counter <= (others => '0'); 
               data_out <= (others => '0'); -- Reset data_out
	       elsif clk_counter = decimation_factor then
	           clk_counter <= (others => '0');     -- Reset counter 
	           data_out <= data_in;    -- Pass input to output
           else
	           clk_counter <= clk_counter + 1; -- increment clock cycle counter           
	       end if;
       end if;
	end process;	
end Behavioral;

----------------------------------------------------------------------------------
-- IIR Decimator
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;

entity IIR_DECIMATOR is
    generic (data_WIDTH : positive; L : positive);
    port(
        clk : in std_logic;	
        reset : in std_logic;					                
        load_coeff : in std_logic;
        x_in : in std_logic_vector (data_WIDTH - 1 downto 0);
        a_in : in std_logic_vector(data_WIDTH - 1 downto 0);
        b_in : in std_logic_vector(data_WIDTH - 1 downto 0);
        y_out : out std_logic_vector(data_WIDTH - 1 downto 0);
        decimation_factor : in std_logic_vector(data_WIDTH - 1 downto 0)
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
            data_out => y_out
        );  
end STRUCTURE;

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
        decimation_factor : in std_logic_vector(data_WIDTH - 1 downto 0)
    );
end MULTISTAGE_IIR_DECIMATOR;

architecture MULTISTAGE of MULTISTAGE_IIR_DECIMATOR is    
    subtype SLV_data_WIDTH is std_logic_vector(data_WIDTH - 1 downto 0);
    type RAM_N is array (0 to N-1) of SLV_data_WIDTH;
    
    -- DEMUX top level signals for each stage 
    signal x_n, a_n, b_n, y_n, d_n : RAM_N := (others => (others => '0')); 
      
  -- Internal Routing Signals
	signal s_xin: std_logic_vector(data_WIDTH - 1 downto 0);	
	signal s_yout : std_logic_vector (data_WIDTH - 1 downto 0);
begin		 
    
    s_xin <= x_in;
    -- Generate IIR Decimators
    GEN_IIR : for i in 0 to N - 1 generate
    IIR_FILTERS : entity IIR_DECIMATOR
      generic map (data_WIDTH => data_WIDTH, L => L)
      port map (
        clk => clk,
        reset => reset,					                
        load_coeff => load_coeff(i),
        x_in => x_n(i),
        a_in => a_n(i),
        b_in => b_n(i),
        y_out => y_n(i),
        decimation_factor => d_n(i)
      );
    end generate;   
     
    -- Process to load coefficients and decimation factor for each stage
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                    x_n <= (others => (others => '0'));
                    a_n <= (others => (others => '0'));
                    b_n <= (others => (others => '0'));
                    y_n <= (others => (others => '0'));
                    d_n <= (others => (others => '0'));                  
            else
                -- First stage gets input directly
                x_n(0) <= s_xin;

                -- Cascade input to the next stages
                for i in 1 to N - 1 loop
                    x_n(i) <= y_n(i-1);     
                end loop;           
            
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
                   end if;  
                end loop;         
            end if;
        end if;     
    end process;       
end MULTISTAGE;
