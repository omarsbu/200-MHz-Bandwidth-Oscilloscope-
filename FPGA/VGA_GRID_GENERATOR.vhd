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

entity VGA_GRID_GENERATOR is
    port(
        i_clk : in std_logic;
        i_clk_enable : in std_logic;
        i_reset  : in std_logic;
        i_enable : in std_logic;        
        i_column  : in std_logic_vector(9 downto 0);
        i_row     : in std_logic_vector(9 downto 0);       
        o_grid_on : out std_logic;         
        o_rgb     : out std_logic_vector(11 downto 0)      
    );
end VGA_GRID_GENERATOR;

architecture MIXED of VGA_GRID_GENERATOR is
    constant GRID_HEIGHT : natural := 250; -- Number of vertical pixels in the waveform
    constant GRID_WIDTH : natural  := 400; -- Number of horizontal pixels in the waveform
    constant V_PER_DIV : natural   := 25;  -- Number of pixels per vertical division (10 divisions)
    constant T_PER_DIV : natural   := 40;  -- Number of pixels per horizontal division (10 divisions)
    
    type grid_lut is array (0 to 10) of integer range 0 to 512;
    
    -- VGA rows where grid lines should be displayed
    constant grid_rows : grid_lut := (
        (0  * V_PER_DIV),
        (1  * V_PER_DIV) - 1,
        (2  * V_PER_DIV) - 1,
        (3  * V_PER_DIV) - 1,
        (4  * V_PER_DIV) - 1,
        (5  * V_PER_DIV) - 1,
        (6  * V_PER_DIV) - 1,
        (7  * V_PER_DIV) - 1,
        (8  * V_PER_DIV) - 1,
        (9  * V_PER_DIV) - 1,
        (10 * V_PER_DIV) - 1
    );
    
    -- VGA columns where grid lines should be displayed
    constant grid_cols : grid_lut := (
        (0  * T_PER_DIV),
        (1  * T_PER_DIV) - 1,
        (2  * T_PER_DIV) - 1,
        (3  * T_PER_DIV) - 1,
        (4  * T_PER_DIV) - 1,
        (5  * T_PER_DIV) - 1,
        (6  * T_PER_DIV) - 1,
        (7  * T_PER_DIV) - 1,
        (8  * T_PER_DIV) - 1,
        (9  * T_PER_DIV) - 1,
        (10 * T_PER_DIV) - 1
    );
   
    -- Function to check membership in LUT
    function in_lut(val : integer; lut : grid_lut) return boolean is
    begin
        for i in lut'range loop
            if val = lut(i) then
                return true;
            end if;
        end loop;
        return false;
    end function;
    
    signal row : std_logic_vector(9 downto 0);
    signal column : std_logic_vector(9 downto 0);
    signal grid_compare, grid_region, grid_on : std_logic;    
    signal rgb, rgb_reg : std_logic_vector(11 downto 0); 
begin   
    process(i_clk)
    begin
    if rising_edge(i_clk) then   		      
        if i_clk_enable = '1' then
            rgb_reg <= rgb;
        end if;
    end if;
    end process;

    row <= i_row;
    column <= i_column;
        
    grid_compare <= '1' when in_lut(to_integer(unsigned(row)), grid_rows) or
                               in_lut(to_integer(unsigned(column)), grid_cols)
                    else '0';
    grid_region <= '1' when to_integer(unsigned(row)) < GRID_HEIGHT and
                            to_integer(unsigned(column)) < GRID_WIDTH
                    else '0';
    
    grid_on <= grid_compare and grid_region;
               
    -- Display yellow pixel for sample, white pixel for grid line, and black pixel for background
    with grid_on select
        rgb <= 
            x"555" when '1',   -- White pixel
            x"000" when others; -- Black pixel  (default case)
    
    o_grid_on <= grid_on;
    o_rgb <= rgb_reg;
end MIXED;