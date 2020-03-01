onerror { resume }
transcript off
add wave -noreg -decimal -literal {/TestBench_Top/dut/sample_timer}
add wave -noreg -decimal -literal -unsigned {/TestBench_Top/dut/dac_sample}
add wave -noreg -logic {/TestBench_Top/dut/next_sample}
add wave -noreg -logic {/TestBench_Top/dut/adder_start}
add wave -noreg -decimal -literal {/TestBench_Top/dut/state_machine}
cursor "Cursor 1" 923483.28ps  
transcript on
