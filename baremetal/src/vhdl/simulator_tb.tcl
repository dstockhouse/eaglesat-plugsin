# Simulator signals (clk and rst and trigger)

restart

add_force {/cmv_simulator/frame_req} -radix hex {0 0ns}
add_force {/cmv_simulator/clk} -radix hex {1 0ns} {0 5000ps} -repeat_every 10000ps
add_force {/cmv_simulator/pix_clk} -radix hex {1 0ns} {0 100000ps} -repeat_every 200000ps
add_force {/cmv_simulator/rst} -radix hex {0 0ns}

run 50 ns

add_force {/cmv_simulator/rst} -radix hex {1 0ns}

run 1 ms

add_force {/cmv_simulator/frame_req} -radix hex {1 0ns}

run 1000 ns

add_force {/cmv_simulator/frame_req} -radix hex {0 0ns}

run 502 ms

