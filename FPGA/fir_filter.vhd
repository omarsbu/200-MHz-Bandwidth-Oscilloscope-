----------------------------------------------------------------------------------
-- FIR Filter
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
----------------------------------------------------------
entity fir_filter is          
  generic (W1 : INTEGER := 9;   -- Input bit width
           W2 : INTEGER := 18;  -- Multiplier bit width 2*W1
           W3 : INTEGER := 19;  -- Adder width = W2+log2(L)-1
           W4 : INTEGER := 11;  -- Output bit width
           L  : INTEGER := 4    -- Filter length 
           );
  port (clk    : IN STD_LOGIC;     -- System clock
        reset  : IN STD_LOGIC;     -- Asynchron reset
        Load_x : IN  STD_LOGIC;    -- Load/run switch
        x_in   : IN  STD_LOGIC_VECTOR(W1-1 DOWNTO 0);  -- System input
        c_in   : IN  STD_LOGIC_VECTOR(W1-1 DOWNTO 0);  -- Coefficient data input 
        y_out  : OUT STD_LOGIC_VECTOR(W4-1 DOWNTO 0)); -- Coefficient output
END fir_filter;
-- --------------------------------------------------------
architecture behavioral of fir_filter is
  subtype SLV_W1 IS STD_LOGIC_VECTOR(W1-1 DOWNTO 0);     -- Subtype with width of input signal
  subtype SLV_W2 IS STD_LOGIC_VECTOR(W2-1 DOWNTO 0);     -- Subtype with width of multiplier
  subtype SLV_W3 IS STD_LOGIC_VECTOR(W3-1 DOWNTO 0);     -- Subtype with width of adder
  type A0_L1SLV_W1 IS ARRAY (0 TO L-1) OF SLV_W1;         -- Array of input signals
  type A0_L1SLV_W2 IS ARRAY (0 TO L-1) OF SLV_W2;         -- Array of multiplier signals
  type A0_L1SLV_W3 IS ARRAY (0 TO L-1) OF SLV_W3;         -- Array of adder signals

  SIGNAL  x  :  SLV_W1;     -- Internal signal for current input sample
  SIGNAL  y  :  SLV_W3;     -- Internal signal for current output sample  
  SIGNAL  c  :  A0_L1SLV_W1 ;       -- Coefficient array RAM 
  SIGNAL  p  :  A0_L1SLV_W2 ;       -- Product array RAM
  SIGNAL  a  :  A0_L1SLV_W3 ;       -- Adder array RAM
                                                        
BEGIN
  Load: PROCESS(clk, reset, c_in, c, x_in)            
  BEGIN                   ------> Load data or coefficients
    IF reset = '1' THEN -- clear data and coefficients register
      x <= (OTHERS => '0');
      FOR K IN 0 TO L-1 LOOP
        c(K) <= (OTHERS => '0');
      END LOOP; 
    ELSIF rising_edge(clk) THEN  
    IF Load_x = '0' THEN
      c(L-1) <= c_in;      -- Store coefficient in register
      FOR I IN L-2 DOWNTO 0 LOOP  -- Coefficients shift one
        c(I) <= c(I+1);
      END LOOP;
    ELSE
      x <= x_in;           -- Get one data sample at a time
    END IF;
    END IF;
  END PROCESS Load;

  SOP: PROCESS (clk, reset, a, p)-- Compute sum-of-products
  BEGIN
    IF reset = '1' THEN -- clear tap registers
      FOR K IN 0 TO L-1 LOOP
        a(K) <= (OTHERS => '0');
      END LOOP; 
    ELSIF rising_edge(clk) THEN
    FOR I IN 0 TO L-2  LOOP      -- Compute the transposed
      a(I) <= (p(I)(W2-1) & p(I)) + a(I+1); -- filter adds
    END LOOP;
    a(L-1) <= p(L-1)(W2-1) & p(L-1);     -- First TAP has 
    END IF;                              -- only a register
    y <= a(0);
  END PROCESS SOP;

  -- Instantiate L multipliers 
  MulGen: FOR I IN 0 TO L-1 GENERATE  
    p(i) <= c(i) * x;
  END GENERATE;

  y_out <= y(W3-1 DOWNTO W3-W4);  
END behavioral;

      
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
	file coef_file : text open read_mode is "coefficients.txt";
begin	  

-- Process to read the file and populate the LUT
	process
		variable line_buf : line;
		variable data_buf : std_logic_vector(w-1 downto 0);
	begin
		-- Read coefficients from the file and store them in the LUT
		for i in 0 to 2**a - 1 loop
			if not endfile(coef_file) then
				readline(coef_file, line_buf);
				read(line_buf, data_buf);
				coefficient_lut(i) <= data_buf;
			else
				-- In case the file has fewer entries than expected, pad with zeros
				coefficient_lut(i) <= (others => '0');
			end if;
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
