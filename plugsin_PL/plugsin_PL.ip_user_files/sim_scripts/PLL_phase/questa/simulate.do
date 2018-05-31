onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib PLL_phase_opt

do {wave.do}

view wave
view structure
view signals

do {PLL_phase.udo}

run -all

quit -force
