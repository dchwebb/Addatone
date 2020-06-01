if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2.0} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) 1
set para(prj_dir) "D:/Eurorack/Addatone/ICE40_Tester"
# synthesize IPs
# synthesize VMs
# synthesize top design
file delete -force -- ICE40_Tester_impl_1.vm ICE40_Tester_impl_1.ldc
run_engine_newmsg synthesis -f "ICE40_Tester_impl_1_lattice.synproj"
run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o ICE40_Tester_impl_1_syn.udb ICE40_Tester_impl_1.vm] "D:/Eurorack/Addatone/ICE40_Tester/impl_1/ICE40_Tester_impl_1.ldc"

} out]} {
   runtime_log $out
   exit 1
}
