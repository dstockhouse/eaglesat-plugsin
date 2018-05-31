vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/xlconcat_v2_1_1

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap xpm modelsim_lib/msim/xpm
vmap xlconcat_v2_1_1 modelsim_lib/msim/xlconcat_v2_1_1

vlog -work xil_defaultlib -64 -incr -sv "+incdir+../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/4868" "+incdir+../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/4868" \
"/home/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -64 -93 \
"/home/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/4868" "+incdir+../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/4868" \
"../../../bd/PLL_phase/ip/PLL_phase_clk_wiz_0_0/PLL_phase_clk_wiz_0_0_clk_wiz.v" \
"../../../bd/PLL_phase/ip/PLL_phase_clk_wiz_0_0/PLL_phase_clk_wiz_0_0.v" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/PLL_phase/sim/PLL_phase.vhd" \

vlog -work xlconcat_v2_1_1 -64 -incr "+incdir+../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/4868" "+incdir+../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/4868" \
"../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/2f66/hdl/xlconcat_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/4868" "+incdir+../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/4868" \
"../../../bd/PLL_phase/ip/PLL_phase_xlconcat_0_0/sim/PLL_phase_xlconcat_0_0.v" \

vlog -work xil_defaultlib \
"glbl.v"

