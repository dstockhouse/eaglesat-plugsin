
set curr_wave [current_wave_config]
if { [string length $curr_wave] == 0 } {
  if { [llength [get_objects]] > 0} {
    add_wave /
    set_property needs_save false [current_wave_config]
  } else {
     send_msg_id Add_Wave-1 WARNING "No top level signals found. Simulator will start without a wave window. If you want to open a wave window go to 'File->New Waveform Configuration' or type 'create_wave_config' in the TCL console."
  }
}


# Restart sim
relaunch_sim
restart

# Setup signals
add_force {/interface/D} -radix hex {0 0ns}
add_force {/interface/rst} -radix hex {1 0ns}
add_force {/interface/clk} -radix hex {1 0ns} {0 10000ps} -repeat_every 20000ps
add_force {/interface/pix_clk} -radix hex {0 0ns} {1 100000ps} -repeat_every 200000ps
add_force {/interface/train_en} -radix hex {0 0ns}
add_force {/interface/train} -radix unsigned {85 0ns}

run 1000 ns

add_force {/interface/rst} -radix hex {1 0ns}

run 2000 ns

add_force {/interface/rst} -radix hex {0 0ns}
add_force {/interface/train_en} -radix hex {1 0ns}



# Send training data on serial in line
add_force {/interface/D} -radix hex {1 0ns} {0 10ns} {1 20ns} {0 30ns} {1 40ns} {0 50ns} {1 60ns} {0 70ns} -repeat_every 100ns


# add_bp {/home/eaglesat/Documents/plugsin/plugsin_PL/plugsin_PL.srcs/sources_1/imports/vhdl/interface.vhd} 218
# add_bp {/home/eaglesat/Documents/plugsin/plugsin_PL/plugsin_PL.srcs/sources_1/imports/vhdl/interface.vhd} 224
# add_bp {/home/eaglesat/Documents/plugsin/plugsin_PL/plugsin_PL.srcs/sources_1/imports/vhdl/interface.vhd} 221
# add_bp {/home/eaglesat/Documents/plugsin/plugsin_PL/plugsin_PL.srcs/sources_1/imports/vhdl/interface.vhd} 216

run 500 ns
run 500 ns

