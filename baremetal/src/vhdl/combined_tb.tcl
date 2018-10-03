# Simulator signals (clk and rst and trigger)

restart

add_force {/design_1_wrapper/rst} -radix hex {0 0ns}
add_force {/design_1_wrapper/M_AXIS_tready} -radix hex {1 0ns}
add_force {/design_1_wrapper/PS_TO_PL} -radix hex {0 0ns}
add_force {/design_1_wrapper/train_en} -radix hex {0 0ns}
add_force {/design_1_wrapper/frame_req} -radix hex {0 0ns}
add_force {/design_1_wrapper/clk} -radix hex {1 0ns} {0 5000ps} -repeat_every 10000ps
add_force {/design_1_wrapper/pix_clk} -radix hex {1 0ns} {0 100000ps} -repeat_every 200000ps

run 50 ns

add_force {/design_1_wrapper/rst} -radix hex {1 0ns}

run 50000 ns

add_force {/design_1_wrapper/train_en} -radix hex {1 0ns}

run 100 ns

# run 10000000 ns
# 
# add_force {/design_1_wrapper/frame_req} -radix hex {1 0ns}
# add_force {/design_1_wrapper/train_en} -radix hex {0 0ns}
# 
# run 1000 ns
# 
# add_force {/design_1_wrapper/frame_req} -radix hex {0 0ns}
# 
# run 5 ms
# run 502 ms

