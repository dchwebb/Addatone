setenv SIM_WORKING_FOLDER .
set newDesign 0
if {![file exists "D:/docs/FPGA/Oscillator/osc_sim/osc_sim.adf"]} { 
	design create osc_sim "D:/docs/FPGA/Oscillator"
  set newDesign 1
}
design open "D:/docs/FPGA/Oscillator/osc_sim"
cd "D:/docs/FPGA/Oscillator"
designverincludedir -clear
designverlibrarysim -PL -clear
designverlibrarysim -L -clear
designverlibrarysim -PL pmi_work
designverlibrarysim ovi_machxo3l
designverdefinemacro -clear
if {$newDesign == 0} { 
  removefile -Y -D *
}
addfile "D:/docs/FPGA/Oscillator/DAC_SPI_Out.v"
addfile "D:/docs/FPGA/Oscillator/ADC_SPI_In.v"
addfile "D:/docs/FPGA/Oscillator/SineLUT.v"
addfile "D:/docs/FPGA/Oscillator/OscPll.v"
addfile "D:/docs/FPGA/Oscillator/top.v"
addfile "D:/docs/FPGA/Oscillator/TestBench_Top.v"
vlib "D:/docs/FPGA/Oscillator/osc_sim/work"
set worklib work
adel -all
vlog -dbg -work work "D:/docs/FPGA/Oscillator/DAC_SPI_Out.v"
vlog -dbg -work work "D:/docs/FPGA/Oscillator/ADC_SPI_In.v"
vlog -dbg -work work "D:/docs/FPGA/Oscillator/SineLUT.v"
vlog -dbg -work work "D:/docs/FPGA/Oscillator/OscPll.v"
vlog -dbg -work work "D:/docs/FPGA/Oscillator/top.v"
vlog -dbg -work work "D:/docs/FPGA/Oscillator/TestBench_Top.v"
module TestBench_Top
vsim  +access +r TestBench_Top   -PL pmi_work -L ovi_machxo3l
add wave *
run 1000ns
