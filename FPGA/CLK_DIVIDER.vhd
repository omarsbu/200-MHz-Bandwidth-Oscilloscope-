library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CLK_DIVIDER is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           timebase : in  STD_LOGIC_VECTOR (4 downto 0);
           clk_out : out  STD_LOGIC);
end CLK_DIVIDER;

architecture BEHAVIORAL of CLK_DIVIDER is
    signal counter : integer range 0 to 99999999;
    signal counter_maxcnt : integer range 0 to 199999999;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                counter <= 0;
                clk_out <= '1'; 
            elsif counter = counter_maxcnt then
                counter <= 0;
                clk_out <= '1';
                case to_integer(unsigned(timebase (4 downto 0))) is
                    when 0 | 1 | 31 =>
                        counter_maxcnt <= 0;	       -- 4 ns sampling period
                    when 2 =>
                        counter_maxcnt <= 1;	       -- 8 ns
                    when 3 =>
                        counter_maxcnt <= 4;	       -- 20 ns
                    when 4 =>
                        counter_maxcnt <= 9;	       -- 40 ns
                    when 5 =>
                        counter_maxcnt <= 19;	       -- 80 ns					
                    when 6 =>
                        counter_maxcnt <= 49;	       -- 200 ns					
                    when 7 =>
                        counter_maxcnt <= 99;           -- 400 ns				
                    when 8 =>
                        counter_maxcnt <= 199;          -- 800 ns				
                    when 9 =>
                        counter_maxcnt <= 499;          -- 2 us				
                    when 10 =>
                        counter_maxcnt <= 999;          -- 4 us					
                    when 11 =>
                        counter_maxcnt <= 1999;         -- 8 us				
                    when 12 =>
                        counter_maxcnt <= 4999;         -- 20 us					
                    when 13 =>
                        counter_maxcnt <= 9999;         -- 40 us
                    when 14 =>
                        counter_maxcnt <= 19999;        -- 80 us			
                    when 15 =>
                        counter_maxcnt <= 49999;        -- 200 us					
                    when 16 =>
                        counter_maxcnt <= 99999;        -- 400 us		
                    when 17 =>
                        counter_maxcnt <= 199999;       -- 800 us
                    when 18 =>
                        counter_maxcnt <= 499999;       -- 2 ms		
                    when 19 =>
                        counter_maxcnt <= 999999;       -- 4 ms				
                    when 20 =>
                        counter_maxcnt <= 1999999;      -- 8 ms			
                    when 21 =>
                        counter_maxcnt <= 4999999;      -- 20 ms			
                    when others =>
                        null;				
                end case;		
            else
                -- else: keep counting
                counter <= counter + 1;
                clk_out <= '0';			
            end if;
        end if;		
    end process;
end BEHAVIORAL;
