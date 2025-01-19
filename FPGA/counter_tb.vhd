library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TESTBENCH is
end TESTBENCH;

architecture Behavioral of TESTBENCH is
    -- Generic parameters for the DUT
    constant WIDTH : positive := 4; -- Address counter width
    constant DATA_WIDTH : positive := 8; -- Data width for FIFO
    constant LEN : positive := 16; -- FIFO length

    -- Signals for CIRCULAR_FIFO
    signal clk : std_logic := '0';
    signal i_write_clk : std_logic := '0';
    signal i_read_clk : std_logic := '0';
    signal i_write_data : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal i_clear : std_logic := '0';
    signal o_read_data : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal i_trigger_clk : std_logic := '0';
    
    constant period : time := 10 ns;
begin

    -- Instantiate CIRCULAR_FIFO
    U_FIFO: entity work.CIRCULAR_FIFO
        generic map(data_WIDTH => DATA_WIDTH, LEN => LEN)
        port map(
            clk => clk,
            i_write_clk => i_write_clk,
            i_write_data => i_write_data,
            i_clear => i_clear,
            i_read_clk => i_read_clk,
            o_read_data => o_read_data,
            i_trigger_clk => i_trigger_clk
        );
        
    -- Test CIRCULAR_FIFO
    i_clear <= '1', '0' after 10*period;
        
    -- Process to generate system clock
	clock: process				
	begin
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
	end process;

    -- Clock generation for i_write_clk
	write_clock: process				
	begin
        i_write_clk <= '0';
        wait for period;
        i_write_clk <= '1';
        wait for period;
	end process;

    -- Clock generation for i_read_clk
	read_clock: process				
	begin
        i_read_clk <= '0';
        wait for 64*period;
        i_read_clk <= '1';
        wait for 64*period;
	end process;
	
    -- Clock generation for i_trigger_clk
	trigger_clock: process				
	begin
        i_trigger_clk <= '0';
        wait for 1704*period;
        i_trigger_clk <= '1';
        wait for 1704*period;
	end process;
	
    -- Stimulus process
    stimulus_process: process
    begin
        wait for period;
        -- Write data to FIFO
        for j in 0 to 10000 loop
            for i in 0 to 255 loop
                i_write_data <= std_logic_vector(to_unsigned(i, DATA_WIDTH));
                wait for 2*period;
            end loop;
        end loop;
    
        wait;
    end process;
end Behavioral;
