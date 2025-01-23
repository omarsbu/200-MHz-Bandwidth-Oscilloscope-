LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;

entity CIC_TB is
end CIC_TB;

architecture TB of CIC_TB is
    -- Signals for driving inputs and observing outputs
    signal clk      : std_logic := '0';
    signal i_reset  : std_logic := '0';
    signal i_enable : std_logic := '0';
    signal i_data   : signed(15 downto 0) := (others => '0');
    signal o_data : signed(15 downto 0);

    constant clk_period : time := 10 ns;
begin
    UUT: entity CIC_FILTER
	generic map(data_WIDTH => 16, R => 4, N => 3)
	port map(
        clk => clk,
        i_reset => i_reset,
        i_enable => i_enable,
        i_data => i_data,
        o_data => o_data	
	);
    
    -- Clock generation process
    CLOCK: process
    begin
        while TRUE loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    STIMULUS: process
        variable ramp_up : boolean := true;
        variable count   : integer := 0;
    begin
        -- Reset the design
        i_reset <= '1';
        wait for clk_period * 2;
        i_reset <= '0';
        wait for clk_period * 2.5;

        -- Enable and apply ramp signal
        i_enable <= '1';

        while TRUE loop
            i_data <= (to_signed(count, 16));
            wait for clk_period;

            if ramp_up then
                count := count + 32;
                if count >= 512 THEN  -- Example maximum value
                    ramp_up := FALSE;
                end if;
            else
                count := count - 50;
                if count <= -512 then
                    ramp_up := TRUE;
                end if;
            end if;
        end loop;
    
        -- Disable the design (unreachable in this case, simulation must stop externally)
        i_enable <= '0';
        wait for clk_period * 4;

        -- Finish simulation
        wait;
    end process;
end TB;