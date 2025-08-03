
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
    
    -- Counter Registers 
    signal h_counter : unsigned(9 downto 0);
    signal v_counter : unsigned(9 downto 0);
    
    -- Output Buffers
    signal h_sync_reg : std_logic;
    signal v_sync_reg : std_logic;
begin
    -- Horizontal Counter Logic
    H_TIMER:process(clk)
    begin
        if rising_edge(clk) then
            if i_reset = '1' then
                h_counter <= (others => '0');   -- Reset horizontal counter
            else
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
            else
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
    
    o_column <= std_logic_vector(h_counter) when i_enable = '1' else (others => '0');
    o_row <= std_logic_vector(v_counter) when i_enable = '1' else (others => '0');
end Behavioral;
                                                

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: VGA Controller
--
-- Description: 
--
--
-- Inputs:
--      i_pixel_clk : 25MHz pixel clock 
--      i_reset : Active-high, synchronous reset
--      i_enable : Active-high enable to load samples into the display_buffer
--      i_data : Input sample read from VGA buffer RAM
--
-- Outputs:
--      o_address : Address bus to index VGA buffer RAM
--      o_RED : 4-bit red RGB pixel value
--      o_GREEN : 4-bit green RGB pixel value
--      o_BLUE : 4-bit blue RGB value
--      H_SYNC: Horizontal SYNC output
--      V_SYNC: Vertical SYNC output
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;

entity VGA_CONTROLLER is
    generic (data_WIDTH : positive; LEN : positive);
    port(
        i_pixel_clk : in std_logic;
        i_reset  : in std_logic;
        i_enable : in std_logic;
        i_data  : in std_logic_vector(9 downto 0);
        o_address : out std_logic_vector(9 downto 0);
        o_RED    : out std_logic_vector(3 downto 0);
        o_GREEN  : out std_logic_vector(3 downto 0);
        o_BLUE   : out std_logic_vector(3 downto 0);
        H_SYNC   : out std_logic;
        V_SYNC   : out std_logic
    );
end VGA_CONTROLLER;

architecture MIXED of VGA_CONTROLLER is
    constant GRID_HEIGHT : natural := 400; -- Number of vertical pixels in the waveform
    constant GRID_WIDTH : natural  := 400; -- Number of horizontal pixels in the waveform
    constant V_PER_DIV : natural   := 40;  -- Number of pixels per vertical division (10 divisions)
    constant T_PER_DIV : natural   := 40;  -- Number of pixels per horizontal division (10 divisions)
    
    signal current_sample, previous_sample : std_logic_vector (9 downto 0);
    signal row_compare_0, row_compare_1 : std_logic;
    signal compare_reg : std_logic_vector (1 downto 0);

    signal pixel_color_select : std_logic;
    
    signal y_pixel : std_logic_vector(9 downto 0);
    signal row : std_logic_vector(9 downto 0);
    signal column : std_logic_vector(9 downto 0);
    signal sample_compare : std_logic;  -- Display sample on current pixel? 
    signal grid_compare : std_logic;    -- Display grid line cloor on current pixel?
    signal rgb : std_logic_vector(11 downto 0);  -- 12-bit RGB value
begin   
    -- VGA timing generator provides SYNC pulses and current pixel coordinates (counter values)
    U0: entity VGA_TIMING_GENERATOR 
    port map(
        clk => i_pixel_clk,
        i_reset => i_reset,
        i_enable => i_enable,
        o_column => column,
        o_row => row,
        H_SYNC => H_SYNC,
        V_SYNC => V_SYNC
    );
        
    o_address <= column when to_integer(unsigned(column)) < GRID_WIDTH else (others => '0');        
    current_sample <= i_data;
    
    process(i_pixel_clk)
    begin
    if rising_edge(i_pixel_clk) then   		      
        previous_sample <= current_sample;
        compare_reg <= std_logic_vector'(row_compare_0 & row_compare_0);
    end if;
    end process;
    
    -- Compare current and previous sample with current VGA row     
    pixel_color_select <= '1' when 
        ((unsigned(row) >= unsigned(previous_sample)) and (row < current_sample)) or
        ((unsigned(row) <= unsigned(previous_sample)) and (row > current_sample))
    else
        '0';
    
    -- Display yellow pixel for sample, white pixel for grid line, and black pixel for background
    with pixel_color_select select
        rgb <= 
            x"FF0" when '1',   -- Yellow pixel (Red and Green = FF, Blue = 0)
            x"000" when others; -- Black pixel  (default case)
            
    o_RED   <= rgb(11 downto 8);
    o_GREEN <= rgb(7 downto 4);
    o_BLUE  <= rgb(3 downto 0);
end MIXED;
