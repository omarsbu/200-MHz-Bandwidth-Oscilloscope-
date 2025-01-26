----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: FIR DECIMATOR
--
-- Description: A compensation deciamte-by-2 FIR filter to flatten the passband 
--  response of the CIC decimator and improve stop-band attenuation. The filter
--  coefficients are generated in MATLAB and stored in a .COE file. The entity
--  in this file is a top wrapper for the FIR compiler IP that is generated
--  with a block design.
--
-- Inputs:
--    clk : system clock
--    i_reset : Active-high Synchronous reset
--    i_enable: Active-high Enable
--    i_data : Input data sequence
--
-- Outputs:
--    o_data : Output data sequence
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
USE WORK.ALL;

entity FIR_DECIMATOR is
  port (
    M_AXIS_DATA_0_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXIS_DATA_0_tvalid : out STD_LOGIC;
    S_AXIS_DATA_0_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
    S_AXIS_DATA_0_tready : out STD_LOGIC;
    S_AXIS_DATA_0_tvalid : in STD_LOGIC;
    clk : in STD_LOGIC
  );
end FIR_DECIMATOR;

architecture STRUCTURE of FIR_DECIMATOR is
    component FIR is
    port(
        M_AXIS_DATA_0_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
        M_AXIS_DATA_0_tvalid : out STD_LOGIC;
        S_AXIS_DATA_0_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
        S_AXIS_DATA_0_tready : out STD_LOGIC;
        S_AXIS_DATA_0_tvalid : in STD_LOGIC;
        aclk_0 : in STD_LOGIC        
    );
    end component;
begin
    U0: FIR
    port map(
        M_AXIS_DATA_0_tdata => M_AXIS_DATA_0_tdata,
        M_AXIS_DATA_0_tvalid => M_AXIS_DATA_0_tvalid,
        S_AXIS_DATA_0_tdata => S_AXIS_DATA_0_tdata,
        S_AXIS_DATA_0_tready => S_AXIS_DATA_0_tready,
        S_AXIS_DATA_0_tvalid => S_AXIS_DATA_0_tvalid,
        aclk_0 => clk
    );
end STRUCTURE;
