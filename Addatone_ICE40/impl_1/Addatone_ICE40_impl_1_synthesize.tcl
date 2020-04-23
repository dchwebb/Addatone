if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2.0} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) 1
set para(prj_dir) "D:/Eurorack/Addatone/Addatone_ICE40"
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- Addatone_ICE40_impl_1_cpe.ldc
run_engine_newmsg cpe -f "Addatone_ICE40_impl_1.cprj" "Sine_LUT.cprj" "SamplePos_RAM.cprj" "Ring_Mod_Mult.cprj" -a "iCE40UP" -o Addatone_ICE40_impl_1_cpe.ldc
# synthesize top design
file delete -force -- Addatone_ICE40_impl_1.vm Addatone_ICE40_impl_1.ldc
run_engine_newmsg synthesis -f "Addatone_ICE40_impl_1_lattice.synproj"
run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o Addatone_ICE40_impl_1_syn.udb Addatone_ICE40_impl_1.vm] "D:/Eurorack/Addatone/Addatone_ICE40/impl_1/Addatone_ICE40_impl_1.ldc"

} out]} {
   runtime_log $out
   exit 1
}
