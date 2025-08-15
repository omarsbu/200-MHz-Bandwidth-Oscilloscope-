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
        i_capture_rqst : in std_logic;
        o_wr_enable : out std_logic;
        o_address: out std_logic_vector(addr_WIDTH - 1 downto 0);
        o_clk_enable : out std_logic
    );
end MEMORY_CONTROLLER;

architecture RTL of MEMORY_CONTROLLER is
    signal addr_counter, ones_reg: std_logic_vector(addr_WIDTH - 1 downto 0);
    signal rqst_flag, clk_enable : std_logic;
begin
    process(i_capture_rqst, clk)
    begin
        if rising_edge(i_capture_rqst) then
            rqst_flag <= '1';
            clk_enable <= '1';         
            o_wr_enable <= '1';
            addr_counter <= (others => '0');
        elsif rising_edge(clk) then
            if addr_counter = ones_reg then     
                rqst_flag <= '0';
                clk_enable <= '0';         
                o_wr_enable <= '0';
            elsif rqst_flag = '1' then
                addr_counter <= addr_counter + x"1";      
            else
                rqst_flag <= '0';
                clk_enable <= '0';         
                o_wr_enable <= '0';
                addr_counter <= (others => '0');
            end if;
        end if;
                
    end process;
    
    -- Enable clock signal for data transfer
    with clk_enable select
        o_clk_enable <= clk when '1', '0' when others;
    
    o_address <= addr_counter;
    ones_reg <= (others => '1');   
end RTL;
