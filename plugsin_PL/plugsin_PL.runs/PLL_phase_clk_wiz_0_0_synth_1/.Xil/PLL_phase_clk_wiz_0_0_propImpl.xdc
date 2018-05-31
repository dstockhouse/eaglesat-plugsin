set_property SRC_FILE_INFO {cfile:/home/eaglesat/Documents/plugsin/plugsin_PL/plugsin_PL.srcs/sources_1/bd/PLL_phase/ip/PLL_phase_clk_wiz_0_0/PLL_phase_clk_wiz_0_0.xdc rfile:../../../plugsin_PL.srcs/sources_1/bd/PLL_phase/ip/PLL_phase_clk_wiz_0_0/PLL_phase_clk_wiz_0_0.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.2
