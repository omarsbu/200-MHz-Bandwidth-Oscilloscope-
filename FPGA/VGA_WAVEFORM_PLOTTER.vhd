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

entity VGA_WAVEFORM_GENERATOR is
    generic (DATA_WIDTH : positive; VGA_ADDR_WIDTH : positive);
    port(
        i_clk     : in std_logic;
        i_clk_enable    : in std_logic;
        i_reset         : in std_logic;
        i_enable        : in std_logic;
        i_data          : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        i_column        : in std_logic_vector(9 downto 0);
        i_row           : in std_logic_vector(9 downto 0);
        o_waveform_on   : out std_logic;
        o_waveform_plotted : out std_logic;
        o_address       : out std_logic_vector(VGA_ADDR_WIDTH - 1 downto 0);
        o_rgb           : out std_logic_vector(11 downto 0)
    );
end VGA_WAVEFORM_GENERATOR;

architecture MIXED of VGA_WAVEFORM_GENERATOR is
    constant GRID_HEIGHT : natural := 400; -- Number of vertical pixels in the waveform
    constant GRID_WIDTH : natural  := 400; -- Number of horizontal pixels in the waveform
    constant V_PER_DIV : natural   := 40;  -- Number of pixels per vertical division (10 divisions)
    constant T_PER_DIV : natural   := 40;  -- Number of pixels per horizontal division (10 divisions)
    
    signal current_sample, previous_sample : std_logic_vector (9 downto 0);
    signal row_compare_0, row_compare_1 : std_logic;
    signal compare_reg : std_logic_vector (1 downto 0);

    signal pixel_color_select : std_logic;
    
    signal vga_address : std_logic_vector(VGA_ADDR_WIDTH - 1 downto 0);
    signal y_pixel : std_logic_vector(9 downto 0);
    signal row : std_logic_vector(9 downto 0);
    signal column : std_logic_vector(9 downto 0);
    signal sample_compare : std_logic;  -- Display sample on current pixel? 
    signal grid_compare : std_logic;    -- Display grid line cloor on current pixel?
    signal rgb, rgb_reg : std_logic_vector(11 downto 0);  -- 12-bit RGB value
begin   
    o_address <= vga_address when to_integer(unsigned(column)) < GRID_WIDTH else (others => '0');        
    vga_address <= std_logic_vector(resize(unsigned(column), VGA_ADDR_WIDTH));
    current_sample <= std_logic_vector(resize(unsigned(i_data), 10));
      
    row <= i_row;
    column <= i_column;
    
    process(i_clk)
    begin  
        if rising_edge(i_clk) then   		      
            if i_clk_enable = '1' then    
                previous_sample <= current_sample;
                compare_reg <= std_logic_vector'(row_compare_0 & row_compare_0);
                rgb_reg <= rgb;
            end if;
        
            if (to_integer(unsigned(column)) > GRID_WIDTH) and (to_integer(unsigned(row)) > GRID_HEIGHT) then    
                o_waveform_plotted <= '1';            
            else    
                o_waveform_plotted <= '0';
            end if;
        end if;
    end process;
    
    -- Compare current and previous sample with current VGA row     
    pixel_color_select <= '1' when 
        ((unsigned(row) >= unsigned(previous_sample)) and (row <= current_sample)) or
        ((unsigned(row) <= unsigned(previous_sample)) and (row >= current_sample))
    else
        '0';
    
    -- Display yellow pixel for sample, white pixel for grid line, and black pixel for background
    with pixel_color_select select
        rgb <= 
            x"FF0" when '1',   -- Yellow pixel (Red and Green = FF, Blue = 0)
            x"000" when others; -- Black pixel  (default case)

    o_waveform_on <= '1' when not (rgb_reg = x"000") else '0';               
    o_rgb <= rgb_reg;
end MIXED;