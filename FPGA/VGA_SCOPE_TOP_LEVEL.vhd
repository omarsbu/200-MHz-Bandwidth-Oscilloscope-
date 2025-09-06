-- ============================================================
-- Top-Level Wrapper for Oscilloscope VGA
-- Basys3 FPGA
-- ============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity top_wrapper is
    port(
        -- Clock and Reset
        clk    : in  std_logic;
        i_reset : in  std_logic;   -- active low reset button

        -- Switches
        i_timebase : in std_logic_vector(4 downto 0);

        -- VGA outputs
        RED  : out std_logic_vector(3 downto 0);
        GREEN  : out std_logic_vector(3 downto 0);
        BLUE  : out std_logic_vector(3 downto 0);
        H_SYNC : out std_logic;
        V_SYNC : out std_logic
    );
end entity;

architecture RTL of top_wrapper is
    ----------------------------------------------------------------
    -- Text String Signals (16 chars * 7 bits = 112 bits each)
    ----------------------------------------------------------------
    signal horizontal_scale_str : std_logic_vector(111 downto 0);
    signal vertical_scale_str   : std_logic_vector(111 downto 0);
    signal delay_str            : std_logic_vector(111 downto 0);
    signal trigger_level_str    : std_logic_vector(111 downto 0);
    signal trigger_mode_str     : std_logic_vector(111 downto 0);
    signal sample_rate_str      : std_logic_vector(111 downto 0);
    signal frequency_str        : std_logic_vector(111 downto 0);
    signal voltage_pp_str       : std_logic_vector(111 downto 0);
    signal voltage_avg_str      : std_logic_vector(111 downto 0);
    signal voltage_max_str      : std_logic_vector(111 downto 0);
    signal voltage_min_str      : std_logic_vector(111 downto 0);
    signal x1_cursor_str        : std_logic_vector(111 downto 0);
    signal x2_cursor_str        : std_logic_vector(111 downto 0);
    signal x_cursor_delta_str   : std_logic_vector(111 downto 0);
    signal y1_cursor_str        : std_logic_vector(111 downto 0);
    signal y2_cursor_str        : std_logic_vector(111 downto 0);
    signal y_cursor_delta_str   : std_logic_vector(111 downto 0);

    ----------------------------------------------------------------
    -- Constant Strings (must be 16 characters)
    ----------------------------------------------------------------
    constant str1  : string := "100mV/DIV       ";
    constant str2  : string := "100us/DIV       ";
    constant str3  : string := "Delay: 100us    ";
    constant str4  : string := "TRG LVL: 100mV  ";
    constant str5  : string := "(RISING)        ";
    constant str6  : string := "100MSa/s        ";
    constant str7  : string := "Freq: 100MHz    ";
    constant str8  : string := "V(max): 100mV   ";
    constant str9  : string := "V(min): 100mV   ";
    constant str10 : string := "V(avg): 100mV   ";
    constant str11 : string := "V(p-p): 100mV   ";
    constant str12 : string := "X1: 100us       ";
    constant str13 : string := "X2: 100us       ";
    constant str14 : string := "Y1: 100mV       ";
    constant str15 : string := "Y2: 100mV       ";
    constant str16 : string := "(X2-X1): 100us  ";
    constant str17 : string := "(Y2-Y1): 100mV  ";

    ----------------------------------------------------------------
    -- Reset handling
    ----------------------------------------------------------------
    signal reset : std_logic;

    -- VGA internal bus
    signal vga_rgb : std_logic_vector(11 downto 0);

    -- function to convert character to slv
    function char_to_slv(c : character) return std_logic_vector is
        variable temp : std_logic_vector(6 downto 0);
    begin
        temp := std_logic_vector(to_unsigned(character'pos(c), 7));
        return temp;
    end function;

begin
    ----------------------------------------------------------------
    -- Generate constant text strings
    ----------------------------------------------------------------
    gen_text_init : for i in 0 to 15 generate
    begin
        vertical_scale_str(7*(i+1)-1 downto 7*i)   <= char_to_slv(str1(i+1));
        horizontal_scale_str(7*(i+1)-1 downto 7*i) <= char_to_slv(str2(i+1));
        delay_str(7*(i+1)-1 downto 7*i)            <= char_to_slv(str3(i+1));
        trigger_level_str(7*(i+1)-1 downto 7*i)    <= char_to_slv(str4(i+1));
        trigger_mode_str(7*(i+1)-1 downto 7*i)     <= char_to_slv(str5(i+1));
        sample_rate_str(7*(i+1)-1 downto 7*i)      <= char_to_slv(str6(i+1));
        frequency_str(7*(i+1)-1 downto 7*i)        <= char_to_slv(str7(i+1));

        voltage_max_str(7*(i+1)-1 downto 7*i)      <= char_to_slv(str8(i+1));
        voltage_min_str(7*(i+1)-1 downto 7*i)      <= char_to_slv(str9(i+1));
        voltage_avg_str(7*(i+1)-1 downto 7*i)      <= char_to_slv(str10(i+1));
        voltage_pp_str(7*(i+1)-1 downto 7*i)       <= char_to_slv(str11(i+1));

        x1_cursor_str(7*(i+1)-1 downto 7*i)        <= char_to_slv(str12(i+1));
        x2_cursor_str(7*(i+1)-1 downto 7*i)        <= char_to_slv(str13(i+1));
        y1_cursor_str(7*(i+1)-1 downto 7*i)        <= char_to_slv(str14(i+1));
        y2_cursor_str(7*(i+1)-1 downto 7*i)        <= char_to_slv(str15(i+1));
        x_cursor_delta_str(7*(i+1)-1 downto 7*i)   <= char_to_slv(str16(i+1));
        y_cursor_delta_str(7*(i+1)-1 downto 7*i)   <= char_to_slv(str17(i+1));
    end generate;

U_DESIGN_1 : entity work.design_1
    port map (
        -- Clocks and control
        clk                  => clk,
        i_enable             => '1',          
        i_reset              => i_reset,        
        i_timebase_0         => i_timebase,      
        i_trigger_lvl_0      => (others => '0'),
        i_trigger_type_0     => '0',          
        video_on_0           => '1',         

        -- VGA output
        H_SYNC_0             => H_SYNC,
        V_SYNC_0             => V_SYNC,
        o_rgb_0              => vga_rgb,

        -- Text overlay strings
        horizontal_scale_str_0 => horizontal_scale_str,
        vertical_scale_str_0   => vertical_scale_str,
        delay_str_0            => delay_str,
        trigger_level_str_0    => trigger_level_str,
        trigger_mode_str_0     => trigger_mode_str,
        sample_rate_str_0      => sample_rate_str,
        frequency_str_0        => frequency_str,
        voltage_pp_str_0       => voltage_pp_str,
        voltage_avg_str_0      => voltage_avg_str,
        voltage_max_str_0      => voltage_max_str,
        voltage_min_str_0      => voltage_min_str,
        x1_cursor_str_0        => x1_cursor_str,
        x2_cursor_str_0        => x2_cursor_str,
        x_cursor_delta_str_0   => x_cursor_delta_str,
        y1_cursor_str_0        => y1_cursor_str,
        y2_cursor_str_0        => y2_cursor_str,
        y_cursor_delta_str_0   => y_cursor_delta_str
    );

    -- Split RGB 12-bit -> 4-4-4
    RED <= vga_rgb(11 downto 8);
    GREEN <= vga_rgb(7 downto 4);
    BLUE <= vga_rgb(3 downto 0);

end RTL;
