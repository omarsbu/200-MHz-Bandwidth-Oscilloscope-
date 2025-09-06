library ieee;
use ieee.std_logic_1164.all ;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity SIGNED_TO_ROW is
generic (i_data_WIDTH : integer; o_data_WIDTH : integer);
port (
    i_data: in std_logic_vector(i_data_WIDTH - 1 downto 0);
    o_data: out std_logic_vector(o_data_WIDTH - 1 downto 0)
);
end SIGNED_TO_ROW;

architecture RTL of SIGNED_TO_ROW is
    signal shift_buffer : signed(i_data_WIDTH - 1 downto 0);
    signal i_buffer : std_logic_vector(o_data_WIDTH - 1 downto 0);
    signal o_buffer : std_logic_vector(o_data_WIDTH - 1 downto 0);
begin
    shift_buffer <= signed(shift_right(signed(i_data),1));
    i_buffer <= std_logic_vector(resize(signed(shift_buffer),o_data_WIDTH));    
    o_buffer(o_data_WIDTH - 1) <= '0';
    o_buffer(o_data_WIDTH - 2) <= not i_buffer(o_data_WIDTH - 1);
    o_buffer(o_data_WIDTH - 3 downto 0) <= i_buffer(o_data_WIDTH - 3 downto 0);    
    o_data <= o_buffer - x"40"; -- Waveform top y-boarder
end RTL;
