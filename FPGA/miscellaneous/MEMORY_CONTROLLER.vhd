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
-- Name: Memory Controller
--
-- Description: 
--
-- Inputs:
--      clk: System clock
--      i_capture_request: Data capture module memory access request 
--      i_vga_rqst: VGA controller memory access request
--      i_dsp_request: DSP module memory access request 
--
-- Outputs:
--      o_wr_enable: Read/write enable
--      o_address: Memory address pointer 
--      o_clk_enable: Clock for data transfer into memory
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
USE WORK.ALL;

entity MEMORY_CONTROLLER is
    generic (data_WIDTH : positive; addr_WIDTH : positive);
    port(
        clk : in std_logic;
        reset : in std_logic;
        i_capture_rqst : in std_logic;
        o_wr_enable : out std_logic;
        o_address: out std_logic_vector(addr_WIDTH - 1 downto 0);
        o_clk_enable : out std_logic
    );
end MEMORY_CONTROLLER;

architecture FSM of MEMORY_CONTROLLER is
    type state is (IDLE, BURST_TRANSFER);
    signal present_state, next_state : state;

    signal addr_counter, ones_reg: std_logic_vector(addr_WIDTH - 1 downto 0);
    signal rqst_flag, clk_enable : std_logic;
begin
    ones_reg <= (others => '1');   
    
    state_reg: process(clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                present_state <= IDLE;
            else
                present_state <= next_state;
            end if;
        end if;        
    end process;
    
    output: process(clk) is
    begin
        case present_state is
        when IDLE =>
            -- Disable memory port write enable and clock
            clk_enable <= '0';
            o_wr_enable <= '0';
            addr_counter <= (others => '0');        
        when BURST_TRANSFER =>    
            if rising_edge(clk) then 
                addr_counter <= addr_counter + x"1";      
            end if;

            -- Enable memory port write enable and clock                         
            o_clk_enable <= clk;
            o_wr_enable <= '1';
        end case;   
    end process;  
    
    nxt_state: process(i_capture_rqst) is
    begin
        case present_state is
        when IDLE =>
            if (i_capture_rqst'event and i_capture_rqst = '1') then 
                if i_capture_rqst = '1' then
                    next_state <= BURST_TRANSFER;
                else
                    next_state <= IDLE;
                end if;
            end if;          
        when BURST_TRANSFER => 
            if addr_counter = ones_reg then    
                next_state <= IDLE;                        
            else
                next_state <= BURST_TRANSFER;
            end if;
        end case;
    end process;
end FSM;
