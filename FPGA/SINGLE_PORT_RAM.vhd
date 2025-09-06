library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DUAL_PORT_RAM is
  generic (
        RAM_WIDTH : natural := 8; 
        ADDR_WIDTH : natural := 10; 
        RAM_DEPTH : natural := 1024
  );    
  port(
        clk : in std_logic;
        
        -- Write Port
        i_wr_enable : in std_logic;
        i_wr_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        i_wr_data : in std_logic_vector(RAM_WIDTH - 1 downto 0);
       
        -- Read Port
        i_rd_enable : in std_logic;
        i_rd_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        o_rd_data : out std_logic_vector(RAM_WIDTH - 1 downto 0)
    );
end DUAL_PORT_RAM;

architecture RTL of DUAL_PORT_RAM is
    type RAM_TYPE is array (RAM_DEPTH - 1 downto 0) of std_logic_vector(RAM_WIDTH - 1 downto 0);
    signal RAM : RAM_TYPE;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if i_wr_enable = '1' then
                RAM(to_integer(unsigned(i_wr_addr))) <= i_wr_data;
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if i_rd_enable = '1' then
                o_rd_data <= RAM(to_integer(unsigned(i_rd_addr)));
            end if;
        end if;
    end process;    
end RTL;