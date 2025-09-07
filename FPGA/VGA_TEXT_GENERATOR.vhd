library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.all;

entity VGA_TEXT_GENERATOR is
    generic(ADDR_WIDTH : positive);
    port(
        clk          : in std_logic;
        i_clk_enable : in std_logic;
        i_column     : in std_logic_vector(9 downto 0);
        i_row        : in std_logic_vector(9 downto 0);
        i_ascii_code : in std_logic_vector(6 downto 0);
        o_rd_address : out std_logic_vector(ADDR_WIDTH - 1 downto 0);  
        o_rd_enable  : out std_logic;
        text_on      : out std_logic;
        rgb_text     : out std_logic_vector(11 downto 0)
    );
end VGA_TEXT_GENERATOR;

architecture MIXED of VGA_TEXT_GENERATOR is     
    constant H_START : natural := 0;     -- Horizontal front porch length in pixels
    constant V_START : natural := 2;     -- Horizontal front porch length in pixels

    signal rom_addr : std_logic_vector(10 downto 0);    -- Font ROM address
    signal ascii_code : std_logic_vector(6 downto 0);   -- 7-bit ASCII code
    signal row_addr : std_logic_vector(3 downto 0);     -- Row of font character
    signal bit_addr : std_logic_vector(2 downto 0);     -- Column of font character
    signal font_word : std_logic_vector(7 downto 0);    -- Row of pixels for a character
    signal font_bit : std_logic;                        -- on/off for character pixel                 
    signal text_x : unsigned(6 downto 0);       -- Character tile x-coordinate
    signal text_y : unsigned(5 downto 0);       -- Character tile y-coordinate
    
    signal ram_base_addr   : unsigned(ADDR_WIDTH - 1 downto 0); -- Base address of string in character RAM 
    signal ram_offset_addr, ram_offset_addr_reg : unsigned(ADDR_WIDTH - 1 downto 0); -- Index of char in string
    signal o_rd_addr_reg : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal s1,s2,s3,s4,s5,s6,s7 : std_logic_vector(ADDR_WIDTH - 1 downto 0);
        
    signal text_on_reg : std_logic;    
begin
    -- Instantiate Font ROM
    FONT_UNIT: entity font_rom
    port map(
      clock => clk,
      addr => rom_addr,
      data => font_word
    );
    
      -- Font ROM interface:
      -- Convert 1x1 pixel to 8x16 character tile, new coordinate system
      text_x <= unsigned(i_column(9 downto 3)) - to_unsigned(6, 7); -- Mod-8 
      text_y <= unsigned(i_row(9 downto 4));    -- Mod-16 
          
      -- Process to generate ascii codes to index font ROM
      ASCII_GEN:process(clk, text_x, text_y)
        variable txt_x : integer range 0 to 80; -- 80 horizontal character tiles
        variable txt_y : integer range 0 to 30; -- 30 vertical character tiles
      begin
         txt_x := to_integer(text_x);
         txt_y := to_integer(text_y);
                               
        case txt_y is        
            -- Text Region 1
            when V_START + 1 =>         
                if txt_x >= H_START + 0 and txt_x < H_START + 16 then 
                    -- Vertical Scale String Base Address
                    ram_base_addr <= to_unsigned(0, ADDR_WIDTH);                                
                elsif txt_x >= H_START + 16 and txt_x < H_START + 32 then    
                    -- Horizontal Scale String Base Address
                    ram_base_addr <= to_unsigned(16, ADDR_WIDTH);            
                elsif txt_x >= H_START + 32 and txt_x < H_START + 48 then
                    -- Delay String Base Address
                    ram_base_addr <= to_unsigned(32, ADDR_WIDTH);            
                elsif txt_x >= H_START + 48 and txt_x < H_START + 64 then
                    -- Trigger Level String Base Address
                    ram_base_addr <= to_unsigned(48, ADDR_WIDTH);            
                elsif txt_x >= H_START + 64 and txt_x < H_START + 80 then   
                    -- Trigger Mode String Base Address
                    ram_base_addr <= to_unsigned(64, ADDR_WIDTH);            
                end if;
                text_on_reg <= '1';
        
            -- Text region 2
            when V_START + 5 => 
                if txt_x >= 64 and txt_x < 80 then           
                    -- Sample Rate String Base Address
                    ram_base_addr <= to_unsigned(80, ADDR_WIDTH);            
                    text_on_reg <= '1';         
                else
                    text_on_reg <= '0';
                end if;
        
            when V_START + 7 => 
                if txt_x >= 64 and txt_x < 80 then           
                    -- Frequency String Base Address                        
                    ram_base_addr <= to_unsigned(96, ADDR_WIDTH);            
                    text_on_reg <= '1';         
                else
                    text_on_reg <= '0';
                end if;           
        
            when V_START + 9 => 
                -- Voltage Max String Base Address                                           
                if txt_x >= 64 and txt_x < 80 then           
                    ram_base_addr <= to_unsigned(112, ADDR_WIDTH);            
                    text_on_reg <= '1';         
                else
                    text_on_reg <= '0';
                end if;
        
            when V_START + 11 =>
                -- Voltage Min String Base Address                                           
                if txt_x >= 64 and txt_x < 80 then           
                    ram_base_addr <= to_unsigned(128, ADDR_WIDTH);            
                    text_on_reg <= '1';         
                else
                    text_on_reg <= '0';
                end if; 
        
            when V_START + 13 =>
                -- Voltage Average String Base Address                                           
                if txt_x >= 64 and txt_x < 80 then           
                    ram_base_addr <= to_unsigned(144, ADDR_WIDTH);            
                    text_on_reg <= '1';         
                else
                    text_on_reg <= '0';
                end if;
        
            when V_START + 15 =>
                -- Voltage Pk-Pk String Base Address                                           
                if txt_x >= 64 and txt_x < 80 then           
                    ram_base_addr <= to_unsigned(160, ADDR_WIDTH);            
                    text_on_reg <= '1';         
                else
                    text_on_reg <= '0';
                end if;
        
            -- Text Region 3
            when V_START + 26 => 
                if txt_x >= H_START + 0 and txt_x < H_START + 16 then 
                    -- X1 Cursor String Base Address                                           
                    ram_base_addr <= to_unsigned(176, ADDR_WIDTH);            
                    text_on_reg <= '1';         
                elsif txt_x >= H_START + 16 and txt_x < H_START + 32 then   
                    -- Y1 Cursor String Base Address                                           
                    ram_base_addr <= to_unsigned(192, ADDR_WIDTH);            
                    text_on_reg <= '1';         
                else
                    text_on_reg <= '0';         
                end if;            
        
            when V_START + 27 => 
                if txt_x >= H_START + 0 and txt_x < H_START + 16 then 
                    -- X2 Cursor String Base Address                                           
                    ram_base_addr <= to_unsigned(208, ADDR_WIDTH);            
                    text_on_reg <= '1';         
                elsif txt_x >= H_START + 16 and txt_x < H_START + 32 then   
                    -- Y2 Cursor String Base Address                                           
                    ram_base_addr <= to_unsigned(224, ADDR_WIDTH);            
                    text_on_reg <= '1';         
                else
                    text_on_reg <= '0';         
                end if;            
        
            when V_START + 28 => 
                if txt_x >= H_START + 0 and txt_x < H_START + 16 then 
                    -- X Cursor Delta String Base Address                                           
                    ram_base_addr <= to_unsigned(240, ADDR_WIDTH);            
                    text_on_reg <= '1';                         
                elsif txt_x >= H_START + 16 and txt_x < H_START + 32 then   
                    -- Y Cursor Delta String Base Address                                           
                    ram_base_addr <= to_unsigned(256, ADDR_WIDTH);            
                    text_on_reg <= '1';         
                else
                    text_on_reg <= '0';         
                end if;              
        
            -- No text                                   
            when others => 
                text_on_reg <= '0';         
        end case;
          
        if rising_edge(clk) then    
           if i_clk_enable = '1' then                            
               o_rd_addr_reg <= std_logic_vector(ram_base_addr + ram_offset_addr); 
               s1 <= o_rd_addr_reg;
               s2 <= s1;
               s3 <= s2;
               s4 <= s3;
               s5 <= s4;
               s6 <= s5;
               s7 <= s6;              
           end if;
        end if;
      end process;
     
    ram_offset_addr <= resize(unsigned(text_x(3 downto 0)), ADDR_WIDTH);                           
    ascii_code <= i_ascii_code;
    o_rd_address <= s7;
         
    rom_addr <= ascii_code & row_addr;
    row_addr <= i_row (3 downto 0);
    bit_addr <= i_column (2 downto 0);     
    font_bit <= font_word(to_integer(unsigned(not bit_addr)));
    text_on <= text_on_reg;
    o_rd_enable <= '1';
    
    rgb_text <= x"0BF" when font_bit = '1' and text_on_reg = '1' else x"000";
end MIXED;
