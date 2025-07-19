library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TRIGGER_MODULE_TB is
end TRIGGER_MODULE_TB;

architecture TB of TRIGGER_MODULE_TB is
    constant CLK_PERIOD     : time := 10 ns;
    constant DATA_WIDTH     : positive := 8;

    signal clk              : std_logic := '0';
    signal i_reset          : std_logic := '0';
    signal i_enable         : std_logic := '0';
    signal i_trigger_type   : std_logic := '0';  -- 0 = rising, 1 = falling
    signal i_trigger_lvl    : signed(DATA_WIDTH-1 downto 0);
    signal i_data           : signed(DATA_WIDTH-1 downto 0);
    signal o_trigger_pulse  : std_logic;

begin

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0'; wait for CLK_PERIOD / 2;
            clk <= '1'; wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- DUT instantiation
    DUT: entity work.TRIGGER_MODULE
        generic map (data_WIDTH => DATA_WIDTH)
        port map (
            clk             => clk,
            i_reset         => i_reset,
            i_enable        => i_enable,
            i_trigger_type  => i_trigger_type,
            i_trigger_lvl   => i_trigger_lvl,
            i_data          => i_data,
            o_trigger_pulse => o_trigger_pulse
        );

    -- Stimulus process (ramp repeatedly from 0 to 255)
    stimulus_process: process
    begin
        -- Initial config
        i_reset <= '1';
        i_enable <= '0';
        i_trigger_lvl <= to_signed(50, DATA_WIDTH);  -- Midpoint trigger level
        wait for 3 * CLK_PERIOD;
        
        i_reset <= '0';
        i_enable <= '1';

        -- Ramp stimulus
        for j in 0 to 5 loop
            i_trigger_type <= '0';  -- Rising edge
            for i in 0 to 127 loop
                i_data <= to_signed(i, DATA_WIDTH);
                wait for 2 * CLK_PERIOD;
            end loop;

            i_trigger_type <= '1';  -- Falling edge            
            for i in 127 downto 0 loop
                i_data <= to_signed(i, DATA_WIDTH);
                wait for 2 * CLK_PERIOD;
            end loop;            
                       
        end loop;

        wait for 10 * CLK_PERIOD;
        assert false report "End of testbench simulation." severity failure;
    end process;

end TB;
