onerror { resume }
transcript off
add wave -noreg -decimal -literal {/TestBench_Top/dut/Frequency}
add wave -noreg -decimal -literal {/TestBench_Top/dut/Freq_Scale}
add wave -noreg -logic {/TestBench_Top/dut/Freq_Too_High}
add wave -noreg -logic -unsigned {/TestBench_Top/dut/dac_cs}
add wave -noreg -logic {/TestBench_Top/dut/dac_bit}
add wave -noreg -logic {/TestBench_Top/dut/dac_clock}
add wave -noreg -logic {/TestBench_Top/dut/crystal_osc}
add wave -noreg -logic {/TestBench_Top/dut/err_out}
add wave -noreg -logic {/TestBench_Top/dut/debug_out}
add wave -noreg -decimal -literal {/TestBench_Top/dut/sample_position/Accumulated_Frequency}
add wave -noreg -logic {/TestBench_Top/dut/sample_position/o_Sample_Ready}
add wave -noreg -hexadecimal -literal {/TestBench_Top/dut/Adder_Start}
add wave -noreg -decimal -literal {/TestBench_Top/dut/SM_Top}
add wave -noreg -hexadecimal -literal {/TestBench_Top/dut/Comb_Interval}
add wave -noreg -logic {/TestBench_Top/dut/mult/o_Mult_Ready}
add wave -noreg -logic {/TestBench_Top/dut/mult/i_Start}
add wave -noreg -hexadecimal -literal -signed2 {/TestBench_Top/dut/Adder_Ready}
add wave -noreg -logic {/TestBench_Top/dut/Sample_Ready}
add wave -noreg -logic {/TestBench_Top/dut/Mult_Ready}
add wave -noreg -hexadecimal -literal {/TestBench_Top/dut/mult/SM_Scale_Mult}
add wave -noreg -decimal -literal {/TestBench_Top/dut/Harmonic}
add wave -noreg -hexadecimal -literal {/TestBench_Top/dut/Adder_Start}
add wave -noreg -decimal -literal {/TestBench_Top/dut/Adder_Mult}
add wave -noreg -logic {/TestBench_Top/dut/Active_Adder}
cursor "Cursor 1" 14362233.28ps  
bookmark add 3340.75723ns
bookmark add 14.171292us
bookmark add 14.329099us
bookmark add 14.78294us
transcript on
