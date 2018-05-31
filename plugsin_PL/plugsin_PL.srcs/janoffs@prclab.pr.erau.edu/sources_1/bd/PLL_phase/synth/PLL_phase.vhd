--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
--Date        : Sun Mar  4 21:37:34 2018
--Host        : eaglesat-p6-2020t running 64-bit Ubuntu 16.04.4 LTS
--Command     : generate_target PLL_phase.bd
--Design      : PLL_phase
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity PLL_phase is
  port (
    clk_in : in STD_LOGIC;
    clk_out : out STD_LOGIC_VECTOR ( 5 downto 0 );
    locked : out STD_LOGIC;
    rst : in STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of PLL_phase : entity is "PLL_phase,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=PLL_phase,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=2,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_board_cnt=2,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of PLL_phase : entity is "PLL_phase.hwdef";
end PLL_phase;

architecture STRUCTURE of PLL_phase is
  component PLL_phase_clk_wiz_0_0 is
  port (
    reset : in STD_LOGIC;
    clk_in1 : in STD_LOGIC;
    clk_out1 : out STD_LOGIC;
    clk_out2 : out STD_LOGIC;
    clk_out3 : out STD_LOGIC;
    clk_out4 : out STD_LOGIC;
    clk_out5 : out STD_LOGIC;
    clk_out6 : out STD_LOGIC;
    locked : out STD_LOGIC
  );
  end component PLL_phase_clk_wiz_0_0;
  component PLL_phase_xlconcat_0_0 is
  port (
    In0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    In1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    In2 : in STD_LOGIC_VECTOR ( 0 to 0 );
    In3 : in STD_LOGIC_VECTOR ( 0 to 0 );
    In4 : in STD_LOGIC_VECTOR ( 0 to 0 );
    In5 : in STD_LOGIC_VECTOR ( 0 to 0 );
    dout : out STD_LOGIC_VECTOR ( 5 downto 0 )
  );
  end component PLL_phase_xlconcat_0_0;
  signal clk_in_1 : STD_LOGIC;
  signal clk_wiz_0_clk_out1 : STD_LOGIC;
  signal clk_wiz_0_clk_out2 : STD_LOGIC;
  signal clk_wiz_0_clk_out3 : STD_LOGIC;
  signal clk_wiz_0_clk_out4 : STD_LOGIC;
  signal clk_wiz_0_clk_out5 : STD_LOGIC;
  signal clk_wiz_0_clk_out6 : STD_LOGIC;
  signal clk_wiz_0_locked : STD_LOGIC;
  signal rst_1 : STD_LOGIC;
  signal xlconcat_0_dout : STD_LOGIC_VECTOR ( 5 downto 0 );
begin
  clk_in_1 <= clk_in;
  clk_out(5 downto 0) <= xlconcat_0_dout(5 downto 0);
  locked <= clk_wiz_0_locked;
  rst_1 <= rst;
clk_wiz_0: component PLL_phase_clk_wiz_0_0
     port map (
      clk_in1 => clk_in_1,
      clk_out1 => clk_wiz_0_clk_out1,
      clk_out2 => clk_wiz_0_clk_out2,
      clk_out3 => clk_wiz_0_clk_out3,
      clk_out4 => clk_wiz_0_clk_out4,
      clk_out5 => clk_wiz_0_clk_out5,
      clk_out6 => clk_wiz_0_clk_out6,
      locked => clk_wiz_0_locked,
      reset => rst_1
    );
xlconcat_0: component PLL_phase_xlconcat_0_0
     port map (
      In0(0) => clk_wiz_0_clk_out1,
      In1(0) => clk_wiz_0_clk_out2,
      In2(0) => clk_wiz_0_clk_out3,
      In3(0) => clk_wiz_0_clk_out4,
      In4(0) => clk_wiz_0_clk_out5,
      In5(0) => clk_wiz_0_clk_out6,
      dout(5 downto 0) => xlconcat_0_dout(5 downto 0)
    );
end STRUCTURE;
