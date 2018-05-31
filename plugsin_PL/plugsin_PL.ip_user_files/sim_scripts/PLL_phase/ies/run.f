-makelib ies_lib/xil_defaultlib -sv \
  "/home/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib ies_lib/xpm \
  "/home/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/PLL_phase/ip/PLL_phase_clk_wiz_0_0/PLL_phase_clk_wiz_0_0_clk_wiz.v" \
  "../../../bd/PLL_phase/ip/PLL_phase_clk_wiz_0_0/PLL_phase_clk_wiz_0_0.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/PLL_phase/sim/PLL_phase.vhd" \
-endlib
-makelib ies_lib/xlconcat_v2_1_1 \
  "../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/2f66/hdl/xlconcat_v2_1_vl_rfs.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/PLL_phase/ip/PLL_phase_xlconcat_0_0/sim/PLL_phase_xlconcat_0_0.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

