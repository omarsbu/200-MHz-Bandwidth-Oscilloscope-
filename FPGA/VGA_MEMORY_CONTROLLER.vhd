-- ===========================================================================
-- Title      : VGA Memory Controller (Double Buffer with Clear A/B Names)
-- Author     : [Your Name]
-- Date       : [Date]
-- Description: Manages two separate VGA RAM buffers (A and B) for
--              double-buffered waveform display. Reads triggered waveform
--              data from Acquisition RAM and writes it into the inactive
--              buffer. Swaps buffers after the current buffer is displayed.
-- ===========================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_MEMORY_CONTROLLER is
    generic (
        DATA_WIDTH     : positive;  -- Width of the waveform sample data
        ADDR_WIDTH     : positive;  -- Address width for acquisition RAM
        VGA_ADDR_WIDTH : positive   -- Address width for VGA display buffer
    );
    port(
        -- ======================
        -- Global Signals
        -- ======================
        i_clk   : in  std_logic;  -- System clock
        i_reset : in  std_logic;  -- Synchronous reset, active high

        -- ======================
        -- Trigger Input
        -- ======================
        i_triggered       : in  std_logic;                               -- Trigger signal from Acquisition module
        i_trigger_address : in  std_logic_vector(ADDR_WIDTH-1 downto 0); -- Address of triggered sample

        -- ======================
        -- Acquisition RAM Interface (Read Only)
        -- ======================
        o_acq_rd_enable : out std_logic;                                     -- Read enable for acquisition RAM
        o_acq_rd_addr   : out std_logic_vector(ADDR_WIDTH-1 downto 0);       -- Read address for acquisition RAM
        i_acq_rd_data   : in  std_logic_vector(DATA_WIDTH-1 downto 0);       -- Data read from acquisition RAM
        i_acq_wr_addr   : in std_logic_vector(ADDR_WIDTH-1 downto 0);       -- Write address for acquisition RAM

        -- ======================
        -- VGA RAM Buffer A Interface
        -- ======================
        o_vga_A_rd_enable : out  std_logic;                                    -- Read enable to VGA
--        i_vga_A_rd_addr   : in  std_logic_vector(VGA_ADDR_WIDTH-1 downto 0);   -- Read address from VGA
        i_vga_A_rd_data   : in std_logic_vector(DATA_WIDTH-1 downto 0);        -- Data returned to VGA
--        o_vga_A_rd_data   : out std_logic_vector(DATA_WIDTH-1 downto 0);       -- Data returned to VGA
        o_vga_A_rd_addr   : out  std_logic_vector(VGA_ADDR_WIDTH-1 downto 0);   -- Read address from VGA

        o_vga_A_wr_enable : out std_logic;                                     -- Write enable from controller
        o_vga_A_wr_addr   : out std_logic_vector(VGA_ADDR_WIDTH-1 downto 0);   -- Write address to VGA RAM
        o_vga_A_wr_data   : out std_logic_vector(DATA_WIDTH-1 downto 0);       -- Data written to VGA RAM

        -- ======================
        -- VGA RAM Buffer B Interface
        -- ======================
        o_vga_B_rd_enable : out  std_logic;                                    -- Read enable to VGA
--        i_vga_B_rd_addr   : in  std_logic_vector(VGA_ADDR_WIDTH-1 downto 0);   -- Read address from VGA
        i_vga_B_rd_data   : in std_logic_vector(DATA_WIDTH-1 downto 0);        -- Data returned to VGA
--        o_vga_B_rd_data   : out std_logic_vector(DATA_WIDTH-1 downto 0);       -- Data returned to VGA
        o_vga_B_rd_addr   : out  std_logic_vector(VGA_ADDR_WIDTH-1 downto 0);  -- Read address from VGA
        
        o_vga_B_wr_enable : out std_logic;                                     -- Write enable from controller
        o_vga_B_wr_addr   : out std_logic_vector(VGA_ADDR_WIDTH-1 downto 0);   -- Write address to VGA RAM
        o_vga_B_wr_data   : out std_logic_vector(DATA_WIDTH-1 downto 0);       -- Data written to VGA RAM

        -- ======================
        -- Synchronization / Status
        -- ======================
        i_vga_rd_addr   : in  std_logic_vector(VGA_ADDR_WIDTH-1 downto 0);   -- Read address from VGA
        o_vga_rd_data   : out std_logic_vector(DATA_WIDTH-1 downto 0);       -- Data returned to VGA
        i_waveform_plotted : in std_logic  -- Asserted by VGA driver when current buffer has been fully displayed
    );
end VGA_MEMORY_CONTROLLER;

architecture FSM of VGA_MEMORY_CONTROLLER is
    constant ADDR_RANGE : integer := 2**(ADDR_WIDTH - 1) - 1;   -- Divided by 2 
    constant VGA_ADDR_RANGE : integer := 2**(VGA_ADDR_WIDTH) - 1;

    type state is (IDLE, BURST_TRANSFER, STANDBY, SWAP);
    signal present_state, next_state : state;
    
    -- Internal Signals and Registers
    signal start_addr, end_addr :   unsigned(ADDR_WIDTH - 1 downto 0);
    signal vga_buffer_sel : std_logic;
    signal addr_counter: unsigned(ADDR_WIDTH - 1 downto 0);
begin       
    state_reg: process(i_clk) is
    begin
        if rising_edge(i_clk) then
            if i_reset = '1' then
                present_state <= IDLE;
            else
                present_state <= next_state;
            end if;
        end if;        
    end process;
    
    output: process(i_clk) is
    begin
        if rising_edge(i_clk) then            
            -- Start with VGA Buffer A active
            if i_reset = '1' then
                vga_buffer_sel <= '1';
            end if;
                                    
            -- Output data from Active VGA Buffer
            if vga_buffer_sel = '1' then
                o_vga_B_rd_enable <= '0';   -- VGA Buffer B Inactive  
                o_vga_A_rd_enable <= '1';   -- VGA Buffer A Active           
                o_vga_A_rd_addr <= i_vga_rd_addr;
                o_vga_rd_data <= i_vga_A_rd_data;
--                o_vga_A_rd_addr <= i_vga_A_rd_addr;
--                o_vga_A_rd_data <= i_vga_A_rd_data;                                  
            else
                o_vga_A_rd_enable <= '0';   -- VGA Buffer A Inactive                       
                o_vga_B_rd_enable <= '1';   -- VGA Buffer A Active     
                o_vga_B_rd_addr <= i_vga_rd_addr;
                o_vga_rd_data <= i_vga_B_rd_data;                      
--                o_vga_B_rd_addr <= i_vga_B_rd_addr;
--                o_vga_B_rd_data <= i_vga_B_rd_data;                       
            end if;              
              
            case present_state is
            when IDLE =>
                -- Internal Signals  and Registers
                addr_counter <= (others => '0');
                            
                -- Aquisition Memory Read Port
                o_acq_rd_enable <= '0';            
                o_acq_rd_addr <= (others => '0');
                
                -- VGA Buffer B Write Port
                o_vga_B_wr_enable <= '0';           
                o_vga_B_wr_addr <= (others => '0');
                o_vga_B_wr_data <= (others => '0');      
                
                -- VGA Buffer A Write Port
                o_vga_A_wr_enable <= '0';           
                o_vga_A_wr_addr <= (others => '0');
                o_vga_A_wr_data <= (others => '0');    
                                                
            when BURST_TRANSFER =>
            -- Create window around trigger address so trigger point is center of waveform
                start_addr <= unsigned(i_trigger_address) - to_unsigned((VGA_ADDR_RANGE + 1 )/2, start_addr'length);         
                end_addr <= unsigned(i_trigger_address) + to_unsigned((VGA_ADDR_RANGE + 1)/2, end_addr'length) - 1;
                                           
                -- Aquisition Memory Read Port, make sure not to overtake write address from data aquisition
                if not ( (start_addr + addr_counter) = unsigned(i_acq_wr_addr) ) then

--                if not (to_integer(start_addr + addr_counter) = to_integer(unsigned(i_acq_wr_addr))) then
                    addr_counter <= addr_counter + 1;
                    o_acq_rd_enable <= '1';            
                    o_acq_rd_addr <= std_logic_vector(start_addr + addr_counter);                 
                end if;
                
                -- Transfer data to active VGA Buffer
                if vga_buffer_sel = '1' then
                    o_vga_B_wr_enable <= '0';   -- VGA Buffer B Inactive                           
                    o_vga_A_wr_enable <= '1';   -- VGA Buffer A Active           
                    o_vga_A_wr_addr <= std_logic_vector(resize(unsigned(addr_counter), VGA_ADDR_WIDTH));
                    o_vga_A_wr_data <= i_acq_rd_data;                                  
                else
                    o_vga_A_wr_enable <= '0';   -- VGA Buffer A Inactive           
                    o_vga_B_wr_enable <= '1';   -- VGA Buffer B Active           
                    o_vga_B_wr_addr <= std_logic_vector(resize(unsigned(addr_counter), VGA_ADDR_WIDTH));
                    o_vga_B_wr_data <= i_acq_rd_data;                     
                end if;         
            
            when STANDBY => 
                -- Wait until current waveform is plotted before switching buffers
                o_vga_A_wr_enable <= '0';           
                o_vga_B_wr_enable <= '0';   
            when SWAP =>
                -- Swap VGA Buffers          
                vga_buffer_sel <= not vga_buffer_sel;
            end case;   
        end if;
    end process;  
    
    nxt_state: process(i_clk, i_triggered, i_waveform_plotted) is
    begin
        case present_state is
        when IDLE =>
            if i_triggered = '1' then
                next_state <= BURST_TRANSFER;            
            else
                next_state <= IDLE;            
            end if;
        when BURST_TRANSFER =>                 
            if to_integer(addr_counter) = VGA_ADDR_RANGE then
                next_state <= STANDBY;            
            else
                next_state <= BURST_TRANSFER;            
            end if;
        when STANDBY =>
            if i_waveform_plotted = '1' then
                next_state <= SWAP;            
            else
                next_state <= STANDBY;            
            end if;
        when SWAP =>
            next_state <= IDLE;            
        end case;
    end process;
end FSM;
