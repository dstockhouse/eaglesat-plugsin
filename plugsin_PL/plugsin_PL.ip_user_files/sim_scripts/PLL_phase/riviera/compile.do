vlib work
vlib riviera

vlib riviera/xil_defaultlib
vlib riviera/xpm
vlib riviera/xlconcat_v2_1_1

vmap xil_defaultlib riviera/xil_defaultlib
vmap xpm riviera/xpm
vmap xlconcat_v2_1_1 riviera/xlconcat_v2_1_1

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/4868" "+incdir+../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/4868" \
"/home/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93 \
"/home/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/4868" "+incdir+../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/4868" \
"../../../bd/PLL_phase/ip/PLL_phase_clk_wiz_0_0/PLL_phase_clk_wiz_0_0_clk_wiz.v" \
"../../../bd/PLL_phase/ip/PLL_phase_clk_wiz_0_0/PLL_phase_clk_wiz_0_0.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/PLL_phase/sim/PLL_phase.vhd" \

vlog -work xlconcat_v2_1_1  -v2k5 "+incdir+../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/4868" "+incdir+../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/4868" \
"../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/2f66/hdl/xlconcat_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/4868" "+incdir+../../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ipshared/4868" \
"../../../bd/PLL_phase/ip/PLL_phase_xlconcat_0_0/sim/PLL_phase_xlconcat_0_0.v" \

vlog -work xil_defaultlib \
"glbl.v"

