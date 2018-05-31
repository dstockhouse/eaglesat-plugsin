-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
-- Date        : Sun Mar  4 18:28:48 2018
-- Host        : eaglesat-p6-2020t running 64-bit Ubuntu 16.04.4 LTS
-- Command     : write_vhdl -force -mode funcsim
--               /home/eaglesat/Documents/plugsin/plugsin_PL/plugsin_PL.srcs/sources_1/bd/PLL_phase/ip/PLL_phase_clk_wiz_0_0/PLL_phase_clk_wiz_0_0_sim_netlist.vhdl
-- Design      : PLL_phase_clk_wiz_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity PLL_phase_clk_wiz_0_0_PLL_phase_clk_wiz_0_0_clk_wiz is
  port (
    clk_out1 : out STD_LOGIC;
    clk_out2 : out STD_LOGIC;
    clk_out3 : out STD_LOGIC;
    clk_out4 : out STD_LOGIC;
    clk_out5 : out STD_LOGIC;
    clk_out6 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of PLL_phase_clk_wiz_0_0_PLL_phase_clk_wiz_0_0_clk_wiz : entity is "PLL_phase_clk_wiz_0_0_clk_wiz";
end PLL_phase_clk_wiz_0_0_PLL_phase_clk_wiz_0_0_clk_wiz;

architecture STRUCTURE of PLL_phase_clk_wiz_0_0_PLL_phase_clk_wiz_0_0_clk_wiz is
  signal clk_in1_PLL_phase_clk_wiz_0_0 : STD_LOGIC;
  signal clk_out1_PLL_phase_clk_wiz_0_0 : STD_LOGIC;
  signal clk_out2_PLL_phase_clk_wiz_0_0 : STD_LOGIC;
  signal clk_out3_PLL_phase_clk_wiz_0_0 : STD_LOGIC;
  signal clk_out4_PLL_phase_clk_wiz_0_0 : STD_LOGIC;
  signal clk_out5_PLL_phase_clk_wiz_0_0 : STD_LOGIC;
  signal clk_out6_PLL_phase_clk_wiz_0_0 : STD_LOGIC;
  signal clkfbout_PLL_phase_clk_wiz_0_0 : STD_LOGIC;
  signal clkfbout_buf_PLL_phase_clk_wiz_0_0 : STD_LOGIC;
  signal NLW_plle2_adv_inst_DRDY_UNCONNECTED : STD_LOGIC;
  signal NLW_plle2_adv_inst_DO_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  attribute BOX_TYPE : string;
  attribute BOX_TYPE of clkf_buf : label is "PRIMITIVE";
  attribute BOX_TYPE of clkin1_ibufg : label is "PRIMITIVE";
  attribute CAPACITANCE : string;
  attribute CAPACITANCE of clkin1_ibufg : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE : string;
  attribute IBUF_DELAY_VALUE of clkin1_ibufg : label is "0";
  attribute IFD_DELAY_VALUE : string;
  attribute IFD_DELAY_VALUE of clkin1_ibufg : label is "AUTO";
  attribute BOX_TYPE of clkout1_buf : label is "PRIMITIVE";
  attribute BOX_TYPE of clkout2_buf : label is "PRIMITIVE";
  attribute BOX_TYPE of clkout3_buf : label is "PRIMITIVE";
  attribute BOX_TYPE of clkout4_buf : label is "PRIMITIVE";
  attribute BOX_TYPE of clkout5_buf : label is "PRIMITIVE";
  attribute BOX_TYPE of clkout6_buf : label is "PRIMITIVE";
  attribute BOX_TYPE of plle2_adv_inst : label is "PRIMITIVE";
begin
clkf_buf: unisim.vcomponents.BUFG
     port map (
      I => clkfbout_PLL_phase_clk_wiz_0_0,
      O => clkfbout_buf_PLL_phase_clk_wiz_0_0
    );
clkin1_ibufg: unisim.vcomponents.IBUF
    generic map(
      IOSTANDARD => "DEFAULT"
    )
        port map (
      I => clk_in1,
      O => clk_in1_PLL_phase_clk_wiz_0_0
    );
clkout1_buf: unisim.vcomponents.BUFG
     port map (
      I => clk_out1_PLL_phase_clk_wiz_0_0,
      O => clk_out1
    );
clkout2_buf: unisim.vcomponents.BUFG
     port map (
      I => clk_out2_PLL_phase_clk_wiz_0_0,
      O => clk_out2
    );
clkout3_buf: unisim.vcomponents.BUFG
     port map (
      I => clk_out3_PLL_phase_clk_wiz_0_0,
      O => clk_out3
    );
clkout4_buf: unisim.vcomponents.BUFG
     port map (
      I => clk_out4_PLL_phase_clk_wiz_0_0,
      O => clk_out4
    );
clkout5_buf: unisim.vcomponents.BUFG
     port map (
      I => clk_out5_PLL_phase_clk_wiz_0_0,
      O => clk_out5
    );
clkout6_buf: unisim.vcomponents.BUFG
     port map (
      I => clk_out6_PLL_phase_clk_wiz_0_0,
      O => clk_out6
    );
plle2_adv_inst: unisim.vcomponents.PLLE2_ADV
    generic map(
      BANDWIDTH => "OPTIMIZED",
      CLKFBOUT_MULT => 9,
      CLKFBOUT_PHASE => 0.000000,
      CLKIN1_PERIOD => 10.000000,
      CLKIN2_PERIOD => 0.000000,
      CLKOUT0_DIVIDE => 18,
      CLKOUT0_DUTY_CYCLE => 0.500000,
      CLKOUT0_PHASE => 0.000000,
      CLKOUT1_DIVIDE => 18,
      CLKOUT1_DUTY_CYCLE => 0.500000,
      CLKOUT1_PHASE => 60.000000,
      CLKOUT2_DIVIDE => 18,
      CLKOUT2_DUTY_CYCLE => 0.500000,
      CLKOUT2_PHASE => 120.000000,
      CLKOUT3_DIVIDE => 18,
      CLKOUT3_DUTY_CYCLE => 0.500000,
      CLKOUT3_PHASE => 180.000000,
      CLKOUT4_DIVIDE => 18,
      CLKOUT4_DUTY_CYCLE => 0.500000,
      CLKOUT4_PHASE => 240.000000,
      CLKOUT5_DIVIDE => 18,
      CLKOUT5_DUTY_CYCLE => 0.500000,
      CLKOUT5_PHASE => 300.000000,
      COMPENSATION => "ZHOLD",
      DIVCLK_DIVIDE => 1,
      IS_CLKINSEL_INVERTED => '0',
      IS_PWRDWN_INVERTED => '0',
      IS_RST_INVERTED => '0',
      REF_JITTER1 => 0.010000,
      REF_JITTER2 => 0.010000,
      STARTUP_WAIT => "FALSE"
    )
        port map (
      CLKFBIN => clkfbout_buf_PLL_phase_clk_wiz_0_0,
      CLKFBOUT => clkfbout_PLL_phase_clk_wiz_0_0,
      CLKIN1 => clk_in1_PLL_phase_clk_wiz_0_0,
      CLKIN2 => '0',
      CLKINSEL => '1',
      CLKOUT0 => clk_out1_PLL_phase_clk_wiz_0_0,
      CLKOUT1 => clk_out2_PLL_phase_clk_wiz_0_0,
      CLKOUT2 => clk_out3_PLL_phase_clk_wiz_0_0,
      CLKOUT3 => clk_out4_PLL_phase_clk_wiz_0_0,
      CLKOUT4 => clk_out5_PLL_phase_clk_wiz_0_0,
      CLKOUT5 => clk_out6_PLL_phase_clk_wiz_0_0,
      DADDR(6 downto 0) => B"0000000",
      DCLK => '0',
      DEN => '0',
      DI(15 downto 0) => B"0000000000000000",
      DO(15 downto 0) => NLW_plle2_adv_inst_DO_UNCONNECTED(15 downto 0),
      DRDY => NLW_plle2_adv_inst_DRDY_UNCONNECTED,
      DWE => '0',
      LOCKED => locked,
      PWRDWN => '0',
      RST => reset
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity PLL_phase_clk_wiz_0_0 is
  port (
    clk_out1 : out STD_LOGIC;
    clk_out2 : out STD_LOGIC;
    clk_out3 : out STD_LOGIC;
    clk_out4 : out STD_LOGIC;
    clk_out5 : out STD_LOGIC;
    clk_out6 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of PLL_phase_clk_wiz_0_0 : entity is true;
end PLL_phase_clk_wiz_0_0;

architecture STRUCTURE of PLL_phase_clk_wiz_0_0 is
begin
inst: entity work.PLL_phase_clk_wiz_0_0_PLL_phase_clk_wiz_0_0_clk_wiz
     port map (
      clk_in1 => clk_in1,
      clk_out1 => clk_out1,
      clk_out2 => clk_out2,
      clk_out3 => clk_out3,
      clk_out4 => clk_out4,
      clk_out5 => clk_out5,
      clk_out6 => clk_out6,
      locked => locked,
      reset => reset
    );
end STRUCTURE;
