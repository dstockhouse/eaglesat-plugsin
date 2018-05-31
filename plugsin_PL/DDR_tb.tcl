relaunch_sim

restart
add_force {/DDRlatch/D} -radix hex {0 0ns}
add_force {/DDRlatch/clk} -radix hex {1 0ns} {0 10000ps} -repeat_every 20000ps
add_force {/DDRlatch/rst} -radix hex {1 0ns}
add_force {/DDRlatch/latch} -radix hex {0 0ns}
run 10 ns
run 10 ns
run 10 ns
run 10 ns
add_force {/DDRlatch/rst} -radix hex {0 0ns}
run 10 ns
run 5 ns
add_force {/DDRlatch/D} -radix hex {1 0ns} {0 10000ps} -repeat_every 20000ps
run 10 ns
run 10 ns
run 10 ns
run 10 ns
run 10 ns
run 10 ns
add_force {/DDRlatch/latch} -radix hex {1 0ns} {0 5000ps} -repeat_every 100000ps
run 300ns
