library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity VGA_MUX_3_1 is
    port(
        i_obj1_rgb   : in  std_logic_vector(11 downto 0);
        i_obj1_on    : in  std_logic;  

        i_obj2_rgb   : in  std_logic_vector(11 downto 0);
        i_obj2_on    : in  std_logic;

        i_obj3_rgb   : in  std_logic_vector(11 downto 0);
        i_obj3_on    : in  std_logic;                 

        o_rgb        : out std_logic_vector(11 downto 0)
    );
end VGA_MUX_3_1;

architecture RTL of VGA_MUX_3_1 is
    signal rgb     : std_logic_vector(11 downto 0);
    signal rgb_sel : std_logic_vector(2 downto 0);     
begin

    rgb_sel <= i_obj1_on & i_obj2_on & i_obj3_on;

    with rgb_sel select
        o_rgb <= i_obj1_rgb when "100",                 
                 i_obj2_rgb when "010",
                 i_obj3_rgb when others;
end RTL;
