----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: VGA Timing Generator
--
-- Description: A VGA timing generator to generate the horizontal and vertical
--  timing pulses. The pixel clock must be 25MHz and the display must be 640x480.
--
-- Inputs:
--      clk: 25MHz pixel clock
--      i_reset: Active-high synchronous reset
--      i_enable: Active-high enable
--
-- Outputs:
--      H_SYNC: Horizontal SYNC output
--      V_SYNC: Vertical SYNC output
--      o_column: x-coordinate of current pixel during VGA scan 
--      o_row: y-coordinate of current pixel during VGA scan
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity VGA_TIMING_GENERATOR is
    port(
        clk  : in std_logic;
        i_reset  : in std_logic;
        i_enable : in std_logic; 
        o_clk_enable : out std_logic;
        o_column : out std_logic_vector(9 downto 0);
        o_row    : out std_logic_vector(9 downto 0);
        H_SYNC   : out std_logic;
        V_SYNC   : out std_logic
    );
end VGA_TIMING_GENERATOR;

architecture Behavioral of VGA_TIMING_GENERATOR is
    -- Horizontal SYNC Parameters
    constant H_PIXELS : natural := 640;         -- Horizontal visible area length in pixels
    constant H_BACK_PORCH : natural := 48;      -- Horizontal back porch length in pixels
    constant H_FRONT_PORCH : natural := 16;     -- Horizontal front porch length in pixels
    constant H_SYNC_PULSE : natural := 96;      -- Horizontal synch pulse length in pixels
    constant H_LENGTH : natural := 800;         -- Horizontal whole frame length in pixels

    -- Vertical SYNC Parameters
    constant V_PIXELS : natural := 480;         -- Horizontal visible area length in pixels
    constant V_BACK_PORCH : natural := 33;      -- Horizontal back porch length in pixels
    constant V_FRONT_PORCH : natural := 10;     -- Horizontal front porch length in pixels
    constant V_SYNC_PULSE : natural := 2;       -- Horizontal synch pulse length in pixels
    constant V_LENGTH : natural := 525;         -- Horizontal whole frame length in pixels

    -- Clock enable     
    signal clk_counter : integer range 0 to 3;
    signal clk_enable : std_logic;
    
    -- Counter Registers 
    signal h_counter : unsigned(9 downto 0);
    signal v_counter : unsigned(9 downto 0);
    
    -- Output Buffers
    signal h_sync_reg : std_logic;
    signal v_sync_reg : std_logic;
begin
    -- 25MHz VGA Clock enable
    CLOCK_ENABLE:process(clk)
    begin   
        if rising_edge(clk) then
            if i_reset = '1' then
                clk_counter <= 0;
                clk_enable <= '0';                           
            elsif clk_counter = 3 then
                clk_counter <= 0;
                clk_enable <= '1';
            else   
                clk_counter <= clk_counter + 1;           
                clk_enable <= '0';
            end if;                    
        end if;
    end process;
    
    -- Horizontal Counter Logic
    H_TIMER:process(clk)
    begin
        if rising_edge(clk) then
            if i_reset = '1' then
                h_counter <= (others => '0');   -- Reset horizontal counter
            elsif clk_enable = '1' then
                if h_counter = H_LENGTH then
                    h_counter <= (others => '0');   -- Reset horizontal counter
                 else
                    h_counter <= h_counter + 1;     -- Increment horizontal counter
                 end if;
            end if;    
        end if;
    end process;
    
    -- Vertical Counter Logic
    V_TIMER:process(clk)
    begin
        if rising_edge(clk) then
            if i_reset = '1' then
                v_counter <= (others => '0');   -- Reset vertical counter
            elsif clk_enable = '1' then
                -- Only update vertical counter when horizontal scan is complete
                if h_counter = H_LENGTH then
                    if v_counter = V_LENGTH then
                        v_counter <= (others => '0');   -- Resset vertical counter
                    else 
                        v_counter <= v_counter + 1;     --Increment vertical counter
                    end if;
                end if;    
            end if; 
        end if;
    end process;
    
    -- Output Buffer Logic
    h_sync_reg <= '1' when (h_counter <= H_LENGTH - H_SYNC_PULSE - 1) else '0';
    v_sync_reg <= '1' when (v_counter <= V_LENGTH - V_SYNC_PULSE - 1) else '0';
    
    -- Drive output ports
    H_SYNC <= h_sync_reg when i_enable = '1' else '0';  
    V_SYNC <= v_sync_reg when i_enable = '1' else '0';
    
    o_clk_enable <= clk_enable;
    o_column <= std_logic_vector(h_counter) when i_enable = '1' else (others => '0');
    o_row <= std_logic_vector(v_counter) when i_enable = '1' else (others => '0');
end Behavioral;
