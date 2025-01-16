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
end Behavioral;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: SIPO Buffer 
--
-- Description: A serial-in-parallel-out buffer to facilitate crossing from the 
--  sampling clock domain to the VGA pixel clock domain. Data is loaded into the 
--  display buffer at the sampling clock rate and it is loaded out of the 
--  display buffer at the pixel clock rate. The ratio between these two clock 
--  rates will determine the size of the buffer. Data is shifted in at the 
--  sampling clock rate and parallel loaded out at the pixel clock rate. 
--
-- Inputs:
--      clk: Input data clock
--      i_reset: Active-high synchronous reset
--      data_in: Serial input data stream
-- 
-- Outputs:
--      data_out: Parallel output data stream
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity SIPO_BUFFER is
    generic (data_WIDTH : positive; LEN : positive);
    port(
        clk : in std_logic;
        i_reset : in std_logic;
        data_in : in std_logic_vector(data_WIDTH - 1 downto 0);
        data_out : out std_logic_vector(LEN*data_WIDTH - 1 downto 0)
    );
end SIPO_BUFFER;

architecture RTL of SIPO_BUFFER is 
   subtype SLV_data_WIDTH is std_logic_vector(data_WIDTH - 1 downto 0);
   type RAM is array (0 to LEN - 1) of SLV_data_WIDTH;    
   signal buffer_RAM : RAM;
   signal RAM_ptr : integer range 0 to LEN - 1;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if i_reset = '1' then
                buffer_RAM <= (others => (others => '0'));
                RAM_ptr <= 0;
            else
                buffer_RAM(RAM_ptr) <= data_in;   -- Load input data into RAM address
                
                if(RAM_ptr = LEN - 1) then
                    RAM_ptr <= 0;   -- Pointer rolls over to 0
                else
                    RAM_ptr <= RAM_ptr + 1;     -- Increment pointer
                end if;
            end if;    
        end if;
    end process;
    
    -- Parallel output values are read directly from internal RAM
    OUTPUT:for i in 0 to LEN - 1 generate    
        data_out((i+1)*data_WIDTH - 1 downto i*data_WIDTH) <= buffer_RAM(i);
    end generate;
end RTL;
                
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: Volts per division encoder
--
-- Description: Volts per division encoder that converts the input sample value 
--  to a y-coordinate on the VGA display. The y-coordinate of the sample value on
--  the VGA display is determined by the current volts per division setting.
--
-- Inputs:
--      data_in: Input sample value      
--      volts_per_div: Volts per division setting
--
-- Outputs:
--      data_out:
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity VOLTS_PER_DIV_ENCODER is
    generic (data_WIDTH : positive);
    port(
        data_in : in std_logic_vector(data_WIDTH - 1 downto 0);
        volts_per_div : in std_logic_vector(3 downto 0);
        data_out : out std_logic_vector(7 downto 0)
    );
end VOLTS_PER_DIV_ENCODER;

architecture RTL of VOLTS_PER_DIV_ENCODER is 
begin



end RTL;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: Display Buffer
--
-- Description: Display buffer to store the y-coordinates of each sample on the
--  VGA display. 
--
-- Inputs:
--
--
-- Outputs:
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity DISPLAY_BUFFER is
    generic (data_WIDTH : positive);
    port(
        clk : in std_logic;
        i_sample_clk : in std_logic;
        i_address : in std_logic_vector(9 downto 0);
        data_in : std_logic_vector(7 downto 0);
        data_out: std_logic_vector(7 downto 0)
    );
end DISPLAY_BUFFER;


----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: VGA Controller
--
-- Description: 
--
-- Inputs:
--
--
-- Outputs:
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity VGA_CONTROLLER is
    port(

    );
end VGA_CONTROLLER;
