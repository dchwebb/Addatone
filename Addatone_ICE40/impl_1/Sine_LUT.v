// Verilog netlist produced by program LSE 
// Netlist written on Mon Apr 06 12:08:01 2020
// Source file index table: 
// Object locations will have the form @<file_index>(<first_ line>[<left_column>],<last_line>[<right_column>])
// file 0 "c:/lscc/radiant/2.0/ip/common/adder/rtl/lscc_adder.v"
// file 1 "c:/lscc/radiant/2.0/ip/common/adder_subtractor/rtl/lscc_add_sub.v"
// file 2 "c:/lscc/radiant/2.0/ip/common/complex_mult/rtl/lscc_complex_mult.v"
// file 3 "c:/lscc/radiant/2.0/ip/common/counter/rtl/lscc_cntr.v"
// file 4 "c:/lscc/radiant/2.0/ip/common/fifo/rtl/lscc_fifo.v"
// file 5 "c:/lscc/radiant/2.0/ip/common/fifo_dc/rtl/lscc_fifo_dc.v"
// file 6 "c:/lscc/radiant/2.0/ip/common/mult_accumulate/rtl/lscc_mult_accumulate.v"
// file 7 "c:/lscc/radiant/2.0/ip/common/mult_add_sub/rtl/lscc_mult_add_sub.v"
// file 8 "c:/lscc/radiant/2.0/ip/common/mult_add_sub_sum/rtl/lscc_mult_add_sub_sum.v"
// file 9 "c:/lscc/radiant/2.0/ip/common/multiplier/rtl/lscc_multiplier.v"
// file 10 "c:/lscc/radiant/2.0/ip/common/ram_dp/rtl/lscc_ram_dp.v"
// file 11 "c:/lscc/radiant/2.0/ip/common/ram_dq/rtl/lscc_ram_dq.v"
// file 12 "c:/lscc/radiant/2.0/ip/common/rom/rtl/lscc_rom.v"
// file 13 "c:/lscc/radiant/2.0/ip/common/subtractor/rtl/lscc_subtractor.v"
// file 14 "c:/lscc/radiant/2.0/ip/pmi/pmi_add.v"
// file 15 "c:/lscc/radiant/2.0/ip/pmi/pmi_addsub.v"
// file 16 "c:/lscc/radiant/2.0/ip/pmi/pmi_complex_mult.v"
// file 17 "c:/lscc/radiant/2.0/ip/pmi/pmi_counter.v"
// file 18 "c:/lscc/radiant/2.0/ip/pmi/pmi_dsp.v"
// file 19 "c:/lscc/radiant/2.0/ip/pmi/pmi_fifo.v"
// file 20 "c:/lscc/radiant/2.0/ip/pmi/pmi_fifo_dc.v"
// file 21 "c:/lscc/radiant/2.0/ip/pmi/pmi_mac.v"
// file 22 "c:/lscc/radiant/2.0/ip/pmi/pmi_mult.v"
// file 23 "c:/lscc/radiant/2.0/ip/pmi/pmi_multaddsub.v"
// file 24 "c:/lscc/radiant/2.0/ip/pmi/pmi_multaddsubsum.v"
// file 25 "c:/lscc/radiant/2.0/ip/pmi/pmi_ram_dp.v"
// file 26 "c:/lscc/radiant/2.0/ip/pmi/pmi_ram_dp_be.v"
// file 27 "c:/lscc/radiant/2.0/ip/pmi/pmi_ram_dq.v"
// file 28 "c:/lscc/radiant/2.0/ip/pmi/pmi_ram_dq_be.v"
// file 29 "c:/lscc/radiant/2.0/ip/pmi/pmi_rom.v"
// file 30 "c:/lscc/radiant/2.0/ip/pmi/pmi_sub.v"
// file 31 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/ccu2_b.v"
// file 32 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/fd1p3bz.v"
// file 33 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/fd1p3dz.v"
// file 34 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/fd1p3iz.v"
// file 35 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/fd1p3jz.v"
// file 36 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/hsosc.v"
// file 37 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/hsosc1p8v.v"
// file 38 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/ib.v"
// file 39 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/ifd1p3az.v"
// file 40 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/lsosc.v"
// file 41 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/lsosc1p8v.v"
// file 42 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/ob.v"
// file 43 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/obz_b.v"
// file 44 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/ofd1p3az.v"
// file 45 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/pdp4k.v"
// file 46 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/rgb.v"
// file 47 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/rgb1p8v.v"
// file 48 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/sp256k.v"
// file 49 "c:/lscc/radiant/2.0/cae_library/simulation/verilog/ice40up/legacy.v"

//
// Verilog Description of module Sine_LUT
//

module Sine_LUT (rd_clk_i, rst_i, rd_en_i, rd_clk_en_i, rd_addr_i, 
            rd_data_o);
    input rd_clk_i;
    input rst_i;
    input rd_en_i;
    input rd_clk_en_i;
    input [10:0]rd_addr_i;
    output [15:0]rd_data_o;
    
    
    
endmodule
