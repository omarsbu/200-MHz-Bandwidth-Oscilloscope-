----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: ADDRESS_COUNTER
--
-- Description: An address counter to generate the read and write pointer signals
--  to index the FIFO RAM. 
--
-- Inputs:
--      clk: Counter clock
--      reset: Active-high Asynchronous reset
--      enable: Active-high enable
--
-- Outputs:
--      count : Output address value
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ADDRESS_COUNTER is
    generic(WIDTH : positive);
    port( 
        clk: in std_logic;
        reset: in std_logic;
        enable : in std_logic;
        count: out std_logic_vector(WIDTH - 1 downto 0)
     );
end ADDRESS_COUNTER;

architecture behavioral of ADDRESS_COUNTER is
    signal counter: std_logic_vector(WIDTH - 1 downto 0);
begin
    process(clk, reset)
    begin
    if reset = '1' then 
        counter <= (others => '0');
    elsif rising_edge(clk) then
        if enable = '1' then
            counter <= counter + x"1";
        end if;
     end if;
    end process;
     count <= counter;
end behavioral;

-----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: Capture FIFO
--
-- Description: Capture FIFO buffer to continuously read samples from the JESD204B
--  reciever. Following a trigger event, the buffer captures a set of samples that
--  correspond to a waveform with the trigger point in the center. The FIFO has 
--  separate READ and WRITE buses to allow clock-domain crossing from the fast 
--  sampling clock domain to the slower VGA pixel clock domain. 
--
-- Inputs:
--      clk: System clock
--      i_trigger_clk: Trigger clock, rising edge indicates trigger event
--      i_write_clk: Input clock to load data
--      i_write_data: Input sample data
--      i_clear: Synchronous clear
--      i_read_clk: Input clock to read data
--
-- Outputs:
--      o_read_data: Output sample data read from circular FIFO 
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
USE WORK.ALL;

entity CAPTURE_FIFO is
    generic (data_WIDTH : positive; LEN : positive);
    port(
        clk : in std_logic;
        i_trigger_clk : in std_logic;
        i_write_clk : in std_logic;
        i_write_data : in std_logic_vector(data_WIDTH - 1 downto 0);
        i_clear : in std_logic;
        i_read_clk : in std_logic;
        o_read_data : out std_logic_vector(data_WIDTH - 1 downto 0)
    );
end CAPTURE_FIFO;

architecture FSM of CAPTURE_FIFO is
    -- Compute the number of address bits required for LEN addresses
    constant ADDR_WIDTH : integer := integer(ceil(log2(real(LEN))));
    
    type state is (CLEAR, SAMPLE, TRIGGER, CAPTURE, READ);
    signal present_state, next_state : state;
    subtype SLV_data_WIDTH is std_logic_vector(data_WIDTH - 1 downto 0);
    type RAM is array (0 to LEN - 1) of SLV_data_WIDTH;
    signal FIFO_RAM : RAM;      
    signal write_ptr, read_ptr, read_offset_ptr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal write_ptr_reg, read_ptr_reg : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal waveform_start, waveform_end : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal write_enable, read_enable, write_ptr_reset, read_ptr_reset : std_logic;    
begin
    
    state_reg: process(clk, i_clear) is
    begin
        if rising_edge(clk) then
            if i_clear = '1' then
                present_state <= CLEAR;
            else
                present_state <= next_state;
            end if;
        end if;        
    end process;
    
    output: process(present_state, i_write_clk, i_read_clk) is
    begin
        case present_state is
            when CLEAR => 
            -- Initialize internal registers to all 0's 
                FIFO_RAM <= (others => (others => '0')); 
                waveform_start <= (others => '0');
                waveform_end <= (others => '0');
                read_ptr <= (others => '0');
                o_read_data <= (others => '0');
                write_ptr_reg <= (others => '0');
                read_ptr_reg <= (others => '0');
                write_ptr_reset <= '1'; -- Reset write address counter
                read_ptr_reset <= '1';  -- Reset read address counter
                write_enable <= '0';    -- Disable write address counter
                read_enable <= '0';     -- Disable read address counter
            when SAMPLE =>         
            -- Enable write address counter and read input sample into FIFO_RAM
                write_ptr_reset <= '0'; 
                read_ptr_reset <= '1';  
                write_enable <= '1';    -- Enable write address counter
                read_enable <= '0';     -- Disable read address counter 
                if rising_edge(i_write_clk) then
                    write_ptr_reg <= write_ptr;
                    FIFO_RAM(to_integer(unsigned(write_ptr))) <= i_write_data;                
                end if;
            when TRIGGER =>
            -- Calculate addresses of first and last samples in waveform so trigger sample is always in the center
                waveform_start <= write_ptr_reg - std_logic_vector(to_unsigned(LEN/2, waveform_end'length));         
                waveform_end <= write_ptr_reg + std_logic_vector(to_unsigned(LEN/2, waveform_end'length)) - x"1";                
                -- Continue reading samples into FIFO_RAM to not miss any data, only in this state for 1 clk
                write_ptr_reset <= '0'; 
                read_ptr_reset <= '1';  
                write_enable <= '1';    -- Enable write address counter
                read_enable <= '0';     -- Disable read address counter  
                if rising_edge(i_write_clk) then
                    write_ptr_reg <= write_ptr;
                    FIFO_RAM(to_integer(unsigned(write_ptr))) <= i_write_data;                
                end if;    
            when CAPTURE =>
            -- Enable write address counter and read input sample into FIFO_RAM until full waveform is captured
                write_ptr_reset <= '0'; 
                read_ptr_reset <= '1';  
                write_enable <= '1';    -- Enable write address counter
                read_enable <= '0';     -- Disable read address counter  
                if rising_edge(i_write_clk) then
                    write_ptr_reg <= write_ptr;
                    FIFO_RAM(to_integer(unsigned(write_ptr))) <= i_write_data;                
                end if;            
            when READ =>
            -- Enable read address counter and read wavefom samples out of FIFO_RAM
                write_ptr_reset <= '0'; 
                read_ptr_reset <= '0';  
                write_enable <= '0';    -- Disable write address counter
                read_enable <= '1';     -- Enable read address counter 
                read_ptr <= waveform_start + read_offset_ptr + 1;
                if rising_edge(i_read_clk) then
                    -- Read pointer is an offset from the start address of a waveform 
                    read_ptr_reg <= read_ptr;
                    o_read_data <= FIFO_RAM(to_integer(unsigned(read_ptr)));                
                end if;    
        end case;   
    end process;  
    
    nxt_state: process(present_state, clk, i_trigger_clk, write_ptr, read_ptr) is
    begin
        case present_state is
        when CLEAR =>
            if i_clear = '1' then
                next_state <= CLEAR;
            else
                next_state <= SAMPLE;
            end if;  
        when SAMPLE =>
            if (i_trigger_clk'event and i_trigger_clk = '1') then 
                if i_trigger_clk = '1' then
                    next_state <= TRIGGER;
                else
                    next_state <= SAMPLE;
                end if;
            end if; 
        when TRIGGER =>
            next_state <= CAPTURE;
        when CAPTURE =>
            if write_ptr_reg = waveform_end + x"1" then
                next_state <= READ;
            else
                next_state <= CAPTURE;
            end if;
        when READ => 
            if read_ptr_reg = waveform_end + x"1" then
                next_state <= SAMPLE;
            else
                next_state <= READ;
            end if; 
        end case;
    end process;

    -- Write pointer address counter
    U0: entity ADDRESS_COUNTER
    generic map(WIDTH => ADDR_WIDTH)
    port map(
        clk => i_write_clk,
        reset => write_ptr_reset,
        enable => write_enable,
        count => write_ptr
    ); 
    -- Read pointer address counter
    U1: entity ADDRESS_COUNTER
    generic map(WIDTH => ADDR_WIDTH)
    port map(
        clk => i_read_clk,
        reset => read_ptr_reset,
        enable => read_enable,
        count => read_offset_ptr
    );  
end FSM;
