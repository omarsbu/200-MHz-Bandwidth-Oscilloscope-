LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity IIR is
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
end IIR;

architecture Behavioral of IIR is
    subtype SLV_data_WIDTH is std_logic_vector(data_WIDTH - 1 downto 0);
    type RAM is array (0 to L-1) of SLV_data_WIDTH;
 
    signal x : RAM;      -- Input signal vector x[n]
    signal y : RAM;      -- Output signal vector y[n]
    signal a : RAM;      -- a[n] coefficient vector
    signal b : RAM;      -- b[n] coefficient vector
    signal y_buffer : signed(2*data_WIDTH - 1 downto 0); 
begin
    -- Load order => a[n], a[n-1], a[n-2], ... , a[0]; b[n], b[n-1], b[n-2], ... , b[1]
    Load:process(clk, reset)
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
             
                for i in L-2 downto 0 loop
                    a(i) <= a(i+1);
                    b(i) <= b(i+1);   
                end loop;
            else
                x(L-1) <=  x_in;     -- Load input sample x[n]
                y(L-1) <= std_logic_vector(y_buffer(2*data_WIDTH - 1 downto data_WIDTH));     -- Load previous output sample y[n-1]
                
                -- Shift data input and output sample arrays
                for i in L-2 downto 0 loop
                    x(i) <= x(i+1);
                    y(i) <= y(i+1);   
                end loop;

                y_buffer <= (others => '0');    -- Initialize output buffer

                -- Compute: y[n] = a0*x[n] + a1*x[n-1] + a2*x[n-2) + ... + b1*y[n-1] + b2*y[n-2] + ... 
                for i in 0 to L-1 loop
                    y_buffer <= y_buffer + (((signed(x(i)) * signed(a(i))) + (signed(y(i)) * signed(b(i)))));
                end loop;
                
                y_out <= std_logic_vector(y_buffer(2*data_WIDTH - 1 downto data_WIDTH));              
            
            end if;
       end if;       
   end process Load; 
end Behavioral;
