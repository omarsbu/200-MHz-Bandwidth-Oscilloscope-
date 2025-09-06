LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;

entity DATA_ACQUISITION_MODULE is
    generic (DATA_WIDTH : positive := 8; ADDR_WIDTH : positive := 10);
    port(
        clk : in std_logic;
        i_clk_enable : in std_logic; 
        i_enable : std_logic;       
        i_reset : in std_logic;
        i_trigger_enable : in std_logic;
        i_adc_data : in std_logic_vector(DATA_WIDTH - 1 downto 0);                
        o_trigger_address : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
        o_triggered : out std_logic;
        -- RAM Interface
        o_wr_data : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        o_wr_address : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
        o_wr_enable : out std_logic
    );
end DATA_ACQUISITION_MODULE;

architecture FSM of DATA_ACQUISITION_MODULE is        
    constant ADDR_RANGE : integer := 2**(ADDR_WIDTH - 1) - 1;
    
    type state is (RESET, IDLE, AQUIRE, TRIGGERED);
    signal present_state, next_state : state;
        
    -- Internal Signals and Registers
    signal trigger_timer : unsigned(ADDR_WIDTH - 1 downto 0);
    signal trigger_timer_en : std_logic;
    
    -- Output Buffers    
    signal o_trigger_addr_reg : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal o_data_reg : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal o_addr_reg : unsigned(ADDR_WIDTH - 1 downto 0);
    signal o_enable_reg : std_logic;
    signal o_triggered_reg : std_logic;
begin
    o_wr_data <= o_data_reg;
    o_wr_address <= std_logic_vector(o_addr_reg);
    o_wr_enable <= o_enable_reg;
    o_trigger_address <= o_trigger_addr_reg;
    o_triggered <= o_triggered_reg;
       
    state_reg: process(clk) is
    begin
        if rising_edge(clk) then
            if i_reset = '1' then
                present_state <= RESET;
            else 
                present_state <= next_state;
            end if;
        
        end if;        
    end process;
    
    output: process(present_state, clk) is
    begin
    if rising_edge (clk) then
        case present_state is
            when RESET => 
            -- Initialize internal registers to all 0's 
                if i_clk_enable = '1' then
                    trigger_timer <= (others => '0');
                    o_trigger_addr_reg <= (others => '0');
                    o_triggered_reg <= '0';
                    o_data_reg <= (others => '0');
                    o_addr_reg <= (others => '0');
                    o_enable_reg <= '0';
                end if;
            
            when IDLE =>
                o_enable_reg <= '0';
            
            when AQUIRE =>
                if i_trigger_enable = '1' then
                    o_trigger_addr_reg <= std_logic_vector(o_addr_reg);
                    o_triggered_reg <= '1';                                                                        
                else
                    o_trigger_addr_reg <= (others => '0');
                    o_triggered_reg <= '0';  
                end if;            
            
                if i_clk_enable = '1' then                    
                    trigger_timer <= (others => '0');                                               
                    o_addr_reg <= o_addr_reg + 1;
                    o_data_reg <= i_adc_data;        
                    o_enable_reg <= '1';
                end if;
            
            when TRIGGERED =>
                if i_clk_enable = '1' then
                    trigger_timer <= trigger_timer + 1;                                               
                    o_triggered_reg <= '1';                                                                        
                    o_addr_reg <= o_addr_reg + 1;
                    o_data_reg <= i_adc_data;        
                    o_enable_reg <= '1';
                end if;                
        end case;   
    end if;
    end process;  
    
    nxt_state: process(present_state, i_reset, clk) is
    begin
        case present_state is
        when RESET =>
            if i_reset = '1' then
                next_state <= RESET;
            else
                next_state <= AQUIRE;
            end if;  
        when IDLE =>
            if i_enable = '0' then
                next_state <= IDLE;
            else
                next_state <= AQUIRE;
            end if;      
        when AQUIRE =>            
            if i_enable = '0' then
                next_state <= IDLE;
            elsif i_trigger_enable = '1' then
                next_state <= TRIGGERED;
            else
                next_state <= AQUIRE;
            end if;  
        when TRIGGERED =>
            if i_enable = '0' then
                next_state <= IDLE;
            elsif trigger_timer = to_unsigned(ADDR_RANGE, ADDR_WIDTH) then
                next_state <= AQUIRE;
            else
                next_state <= TRIGGERED;
            end if;          
        end case;
    end process;        
end FSM;