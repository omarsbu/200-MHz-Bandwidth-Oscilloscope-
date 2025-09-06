library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CLK_DIVIDER is
    Port ( clk : in  STD_LOGIC;
           i_reset : in  STD_LOGIC;
           i_timebase : in  STD_LOGIC_VECTOR (4 downto 0);
           o_clk_en : out  STD_LOGIC);
end CLK_DIVIDER;

architecture BEHAVIORAL of CLK_DIVIDER is
    signal counter_reg, max_cnt : unsigned(31 downto 0);
begin
    process(clk)
        variable mask : unsigned(31 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            if i_reset = '1' then
                counter_reg <= (others => '0');
                o_clk_en <= '1';
            elsif counter_reg >= max_cnt - 1 then  
                mask := (others => '0');
                mask(to_integer(unsigned(i_timebase))) := '1';
                max_cnt <= mask;              
                counter_reg <= (others => '0');    
                o_clk_en <= '1';
            else
                mask := (others => '0');
                mask(to_integer(unsigned(i_timebase))) := '1';
                max_cnt <= mask;                
                o_clk_en <= '0';
                counter_reg <= counter_reg + 1;
            end if;
        end if;		
    end process;
 
end BEHAVIORAL;