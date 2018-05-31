onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xil_defaultlib -L xpm -L xlconcat_v2_1_1 -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.PLL_phase xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {PLL_phase.udo}

run -all

quit -force
