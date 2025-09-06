----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: Dual-port RAM
--
-- Description: A dual-port RAM with synchronous read. It has one write port and 
--  two read ports.
--
-- Inputs:
--      clk: Counter clock
--      reset: Active-high Asynchronous reset
--      write_enable: Active-high write enable for a bus
--      addr_a: a ADDRESS bus
--      addr_b: b ADDRESS bus
--      din_a: a WRITE data bus
--
-- Outputs:
--      dout_a: a READ data bus
--      dout_b: b READ data bus
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

entity DUAL_PORT_RAM is
generic (addr_WIDTH : integer; data_WIDTH : integer);
port (
    clk: in std_logic;
    reset : in std_logic;
    write_enable: in std_logic;
    addr_a: in std_logic_vector(addr_WIDTH - 1 downto 0);
    addr_b: in std_logic_vector(addr_WIDTH - 1 downto 0);
    din_a: in std_logic_vector(data_WIDTH - 1 downto 0);
    dout_a: out std_logic_vector(data_WIDTH - 1 downto 0);
    dout_b: out std_logic_vector(data_WIDTH - 1 downto 0)
);
end DUAL_PORT_RAM;

architecture behavioral of DUAL_PORT_RAM is
    type RAM_TYPE is array (0 to 2**addr_WIDTH - 1) of std_logic_vector(data_WIDTH - 1 downto 0);
    signal RAM : RAM_TYPE;
    signal addr_a_reg , addr_b_reg : std_logic_vector(addr_WIDTH - 1 downto 0);
begin
    process(clk)
    begin
        if reset = '1' then 
            RAM <= (others => (others => '0'));
            addr_a_reg <= (others => '0');
            addr_b_reg <= (others => '0');
        elsif rising_edge(clk) then
            if write_enable = '1' then
                RAM(to_integer(unsigned(addr_a))) <= din_a;
            end if;
            addr_a_reg <= addr_a;
            addr_b_reg <= addr_b;
        end if;
    end process;
    
    dout_a <= RAM(to_integer(unsigned(addr_a_reg)));
    dout_b <= RAM(to_integer(unsigned(addr_b_reg)));
end behavioral;
