--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
--Date        : Sun Mar  4 21:37:34 2018
--Host        : eaglesat-p6-2020t running 64-bit Ubuntu 16.04.4 LTS
--Command     : generate_target PLL_phase_wrapper.bd
--Design      : PLL_phase_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity PLL_phase_wrapper is
  port (
    clk_in : in STD_LOGIC;
    clk_out : out STD_LOGIC_VECTOR ( 5 downto 0 );
    locked : out STD_LOGIC;
    rst : in STD_LOGIC
  );
end PLL_phase_wrapper;

architecture STRUCTURE of PLL_phase_wrapper is
  component PLL_phase is
  port (
    rst : in STD_LOGIC;
    clk_in : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_out : out STD_LOGIC_VECTOR ( 5 downto 0 )
  );
  end component PLL_phase;
begin
PLL_phase_i: component PLL_phase
     port map (
      clk_in => clk_in,
      clk_out(5 downto 0) => clk_out(5 downto 0),
      locked => locked,
      rst => rst
    );
end STRUCTURE;
