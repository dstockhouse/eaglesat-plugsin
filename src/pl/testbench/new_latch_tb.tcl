# Initialization
relaunch_sim
restart
add_force {/new_latch/d1} -radix hex {0 0ns}
add_force {/new_latch/d2} -radix hex {0 0ns}
add_force {/new_latch/d_ctl} -radix hex {0 0ns}
add_force {/new_latch/train_en} -radix hex {0 0ns}
add_force {/new_latch/pix_clk} -radix hex {0 0ns}
add_force {/new_latch/clk} -radix hex {0 0ns}
add_force {/new_latch/rst} -radix hex {1 0ns}
run 10 ns

# rst off
add_force {/new_latch/rst} -radix hex {0 0ns}
run 10 ns
add_force {/new_latch/train_en} -radix hex {1 0ns}
run 10 ns

#### First bit is manual, then use loops

# Bit 0
add_force {/new_latch/d1} -radix hex {1 0ns}
add_force {/new_latch/d2} -radix hex {1 0ns}
run 25 ns
add_force {/new_latch/clk} -radix hex {1 0ns} {0 50000ps} -repeat_every 100000ps
add_force {/new_latch/pix_clk} -radix hex {1 0ns} {0 250000ps} -repeat_every 500000ps
add_force {/new_latch/d1} -radix hex {1 0ns}
add_force {/new_latch/d2} -radix hex {1 0ns}
add_force {/new_latch/d_ctl} -radix hex {0 0ns}
run 25 ns

# Bit 1
add_force {/new_latch/d1} -radix hex {0 0ns}
add_force {/new_latch/d2} -radix hex {0 0ns}
run 50 ns

# Bit 2
add_force {/new_latch/d1} -radix hex {1 0ns}
add_force {/new_latch/d2} -radix hex {1 0ns}
run 50 ns

# Bit 3
add_force {/new_latch/d2} -radix hex {0 0ns}
add_force {/new_latch/d1} -radix hex {0 0ns}
run 50 ns

# Bit 4
add_force {/new_latch/d1} -radix hex {1 0ns}
add_force {/new_latch/d2} -radix hex {1 0ns}
run 50 ns

# Bit 5
add_force {/new_latch/d1} -radix hex {0 0ns}
add_force {/new_latch/d2} -radix hex {0 0ns}
run 50 ns

# Bit 6
add_force {/new_latch/d1} -radix hex {1 0ns}
add_force {/new_latch/d2} -radix hex {1 0ns}
run 50 ns

# Bit 7
add_force {/new_latch/d1} -radix hex {0 0ns}
add_force {/new_latch/d2} -radix hex {0 0ns}
run 50 ns

# Bit 8
run 50 ns

# Bit 9
add_force {/new_latch/d_ctl} -radix hex {1 0ns}
run 50 ns


#### Now for some more advance Tcl scripting

# Maybe later

set train_data [expr {0x55}]
set train_ctl [expr {0x200}]

for {set j 0} {$j < 10} {incr j} {
	for {set i 0} {$i < 10} {incr i} {

		set bit_data [expr {[expr {$train_data >> $i}] & 1}]
		set bit_ctl [expr {[expr {$train_ctl >> $i}] & 1}]

		if {$bit_data} {
			add_force {/new_latch/d1} -radix hex {1 0ns}
			add_force {/new_latch/d2} -radix hex {1 0ns}
		} else {
			add_force {/new_latch/d1} -radix hex {0 0ns}
			add_force {/new_latch/d2} -radix hex {0 0ns}
		}

		if {$bit_ctl} {
			add_force {/new_latch/d_ctl} -radix hex {1 0ns}
		} else {
			add_force {/new_latch/d_ctl} -radix hex {0 0ns}
		}

		run 50 ns

	} ;# Loop through bits

	if {$j == 6} {
		# Signal to end training prematurely
		add_force {/new_latch/train_en} -radix hex {0 0ns}
	}

} ;# Loop through words


#### Stop Training, Start Actual Data

# set ldata [list [expr {0x63 << 2}] [expr {0x44 << 2}] [expr {0x38 << 2}] [expr {0x9a << 2}] [expr {0xea << 2}] [expr {0xf3 << 2}]]
set ctl [expr {0x207}]

for {set data 0} {$data < 256} {incr data} {
# foreach data $ldata

	# set data [lindex ldata $j]
	set datasamp [expr {$data << 2}]

	for {set i 0} {$i < 10} {incr i} {

		set bit_data [expr {[expr {$datasamp >> $i}] & 1}]
		set bit_ctl [expr {[expr {$ctl >> $i}] & 1}]

		if {$bit_data} {
			add_force {/new_latch/d1} -radix hex {1 0ns}
			add_force {/new_latch/d2} -radix hex {1 0ns}
		} else {
			add_force {/new_latch/d1} -radix hex {0 0ns}
			add_force {/new_latch/d2} -radix hex {0 0ns}
		}

		if {$bit_ctl} {
			add_force {/new_latch/d_ctl} -radix hex {1 0ns}
		} else {
			add_force {/new_latch/d_ctl} -radix hex {0 0ns}
		}

		run 50 ns

	} ;# Loop through bits

} ;# Loop through words


#### Clear buffers

add_force {/new_latch/d1} -radix hex {0 0ns}
add_force {/new_latch/d2} -radix hex {0 0ns}
add_force {/new_latch/d_ctl} -radix hex {0 0ns}

run 1500 ns

