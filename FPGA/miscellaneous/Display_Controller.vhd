-- VGA Display Controller

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std;
use ieee.std_logic_unsigned.all;

entity VGA_controller is
    port(clk, rst : in std_logic;   -- clk and reset signal
         rgb : in std_logic_vector(11 downto 0);    -- input pixel color   
         video_on : out std_logic;  -- within desiplay area flag
         pixel_clk : out std_logic; -- pixel rate signal
         hsync, vsync : out std_logic;  -- horizontal and veritcal sync 
         x, y : out std_logic_vector (9 downto 0));  -- pixel coordinates
end;

architecture behavioral of VGA_controller is
-- Horizontal Sync Parameters
    constant H_DISPLAY : natural := 640;    -- display horizontal width
    constant H_L_BORDER : natural := 48;    -- horizontal left border
    constant H_R_BORDER : natural := 16;    -- horizontal right border
    constant H_RETRACE : natural := 96;     -- horizontal retrace
    constant H_MAX : natural := 799;   -- horizontal scan row width

-- Vertical sync parameters
    constant V_DISPLAY : natural := 480;    -- display vertical height
    constant V_T_BORDER : natural := 10;    -- vertical top border
    constant V_B_BORDER : natural := 33;    -- vertical bottom border
    constant V_RETRACE : natural := 2;     -- vertical retrace
    constant V_MAX : natural := 524;   -- vertical scan column height

-- Counter Registers, two each for buffering to avoid glitches
    signal h_count_reg, h_count_next : std_logic_vector(9 downto 0);
    signal v_count_reg, v_count_next : std_logic_vector(9 downto 0);

-- Output Buffers
    signal v_sync_reg, h_sync_reg : std_logic;
    signal v_sync_next, h_sync_next : std_logic;      

begin
-- Horizontal Counter Logic
    process(clk, rst)
    begin
        if rst = '1' then
            h_count_reg <= (others => '0');
        elsif rising_edge(clk) then
            if h_count_reg = H_MAX then
                h_count_next <= (others => '0');
            else
                h_count_next <= h_count_reg + 1;
            end if;
        end if;
    end process;

-- Vertical Counter Logic
    process(clk, rst)
    begin
        if rst = '1' then
            v_count_reg <= (others => '0');
        elsif rising_edge(clk) then
            if h_count_reg = H_MAX then
                if v_count_reg = V_MAX then
                    v_count_next <= (others => '0');
                else
                    v_count_next <= v_count_reg + 1;
                end if;
            end if;
        end if;
    end process;

-- h_sync_next asserted within the horizontal retrace area
    h_sync_next <= '1' when (h_count_reg >= (H_DISPLAY + H_R_BORDER) and h_count_reg <= (H_DISPLAY + H_R_BORDER + H_RETRACE - 1)) else '0';

-- v_sync_next asserted within the vertical retrace area
    v_sync_next <= '1' when (v_count_reg >= (V_DISPLAY + V_B_BORDER) and v_count_reg <= (V_DISPLAY + V_B_BORDER + V_RETRACE - 1)) else '0';

-- Video ON/OFF - only ON while pixel counts are within the display area
    video_on <= '1' when (h_count_reg < H_DISPLAY) and (v_count_reg < V_DISPLAY) else '0';

-- Outputs
    hsync <= h_sync_reg;
    vsync <= v_sync_reg;
    x <= h_count_reg;
    y <= v_count_reg;
    
end behavioral;
