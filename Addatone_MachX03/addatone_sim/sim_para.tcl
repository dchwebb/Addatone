lappend auto_path "C:/lscc/diamond/3.11_x64/data/script"
package require simulation_generation
set ::bali::simulation::Para(PROJECT) {addatone_sim}
set ::bali::simulation::Para(PROJECTPATH) {D:/Eurorack/Addatone/Addatone_MachX03}
set ::bali::simulation::Para(FILELIST) {"D:/Eurorack/Addatone/Addatone_MachX03/src/TestBench_Top.v" "D:/Eurorack/Addatone/Addatone_MachX03/SineLUT.v" "D:/Eurorack/Addatone/Addatone_MachX03/OscPll.v" "D:/Eurorack/Addatone/Addatone_MachX03/src/top.v" "D:/Eurorack/Addatone/Addatone_MachX03/src/ADC_SPI_In.v" "D:/Eurorack/Addatone/Addatone_MachX03/src/DAC_SPI_Out.v" "D:/Eurorack/Addatone/Addatone_MachX03/src/Fraction.v" "D:/Eurorack/Addatone/Addatone_MachX03/src/sample_pos_RAM.v" }
set ::bali::simulation::Para(GLBINCLIST) {}
set ::bali::simulation::Para(INCLIST) {"none" "none" "none" "none" "none" "none" "none" "none"}
set ::bali::simulation::Para(WORKLIBLIST) {"work" "work" "work" "work" "work" "work" "work" "work" }
set ::bali::simulation::Para(COMPLIST) {"VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" }
set ::bali::simulation::Para(SIMLIBLIST) {pmi_work ovi_machxo3l}
set ::bali::simulation::Para(MACROLIST) {}
set ::bali::simulation::Para(SIMULATIONTOPMODULE) {TestBench_Top}
set ::bali::simulation::Para(SIMULATIONINSTANCE) {}
set ::bali::simulation::Para(LANGUAGE) {VERILOG}
set ::bali::simulation::Para(SDFPATH)  {}
set ::bali::simulation::Para(ADDTOPLEVELSIGNALSTOWAVEFORM)  {1}
set ::bali::simulation::Para(RUNSIMULATION)  {1}
set ::bali::simulation::Para(HDLPARAMETERS) {}
set ::bali::simulation::Para(POJO2LIBREFRESH)    {}
set ::bali::simulation::Para(POJO2MODELSIMLIB)   {}
::bali::simulation::ActiveHDL_Run
