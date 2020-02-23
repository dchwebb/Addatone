setenv SIM_WORKING_FOLDER .
set newDesign 0
if {![file exists "D:/Eurorack/Addatone/Addatone_MachX03/addatone_sim/addatone_sim.adf"]} { 
	design create addatone_sim "D:/Eurorack/Addatone/Addatone_MachX03"
  set newDesign 1
}
design open "D:/Eurorack/Addatone/Addatone_MachX03/addatone_sim"
cd "D:/Eurorack/Addatone/Addatone_MachX03"
designverincludedir -clear
designverlibrarysim -PL -clear
designverlibrarysim -L -clear
designverlibrarysim -PL pmi_work
designverlibrarysim ovi_machxo3l
designverdefinemacro -clear
if {$newDesign == 0} { 
  removefile -Y -D *
}
addfile "D:/Eurorack/Addatone/Addatone_MachX03/src/TestBench_Top.v"
addfile "D:/Eurorack/Addatone/Addatone_MachX03/SineLUT.v"
addfile "D:/Eurorack/Addatone/Addatone_MachX03/OscPll.v"
addfile "D:/Eurorack/Addatone/Addatone_MachX03/src/top.v"
addfile "D:/Eurorack/Addatone/Addatone_MachX03/src/ADC_SPI_In.v"
addfile "D:/Eurorack/Addatone/Addatone_MachX03/src/DAC_SPI_Out.v"
addfile "D:/Eurorack/Addatone/Addatone_MachX03/src/Fraction.v"
addfile "D:/Eurorack/Addatone/Addatone_MachX03/src/sample_pos_RAM.v"
vlib "D:/Eurorack/Addatone/Addatone_MachX03/addatone_sim/work"
set worklib work
adel -all
vlog -dbg -work work "D:/Eurorack/Addatone/Addatone_MachX03/src/TestBench_Top.v"
vlog -dbg -work work "D:/Eurorack/Addatone/Addatone_MachX03/SineLUT.v"
vlog -dbg -work work "D:/Eurorack/Addatone/Addatone_MachX03/OscPll.v"
vlog -dbg -work work "D:/Eurorack/Addatone/Addatone_MachX03/src/top.v"
vlog -dbg -work work "D:/Eurorack/Addatone/Addatone_MachX03/src/ADC_SPI_In.v"
vlog -dbg -work work "D:/Eurorack/Addatone/Addatone_MachX03/src/DAC_SPI_Out.v"
vlog -dbg -work work "D:/Eurorack/Addatone/Addatone_MachX03/src/Fraction.v"
vlog -dbg -work work "D:/Eurorack/Addatone/Addatone_MachX03/src/sample_pos_RAM.v"
module TestBench_Top
vsim  +access +r TestBench_Top   -PL pmi_work -L ovi_machxo3l
add wave *
run 1000ns
