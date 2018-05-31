onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+PLL_phase -L xil_defaultlib -L xpm -L xlconcat_v2_1_1 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.PLL_phase xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {PLL_phase.udo}

run -all

endsim

quit -force
