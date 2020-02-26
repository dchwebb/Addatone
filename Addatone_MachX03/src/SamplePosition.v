module SamplePosition
	(
		input wire reset,
		input wire clock,
		input wire [15:0] frequency,
		input wire [7:0] harmonic,
		output reg sample_ready,				// Tells top module that sample position has been loaded
		input wire next_sample,					// Trigger from top module to say current value has been read and ready for next sample
		output reg [15:0] sample_position
	);

	reg sp_write;
	wire [15:0] sp_readdata;
	// Initialise Sample Position RAM (inferred)
	//Sample_Pos_RAM sample_pos_ram(.din(sample_position), .addr(harmonic), .write_en(sp_write), .clk(clock), .dout(sp_readdata));
	// Initialise Sample Position RAM (IP)
	SamplePos_RAM sample_pos_ram(.Clock(clock), .ClockEn(1'b1), .Reset(reset), .WE(sp_write), .Address(harmonic), .Data(sample_position), .Q(sp_readdata));
	
	reg [16:0] accumulated_frequency;
	reg [2:0] state_machine;
	localparam [2:0] sm_init = 3'd0;
	localparam [2:0] sm_write = 3'd1;
	localparam [2:0] sm_ready = 3'd2;
	localparam [2:0] sm_next = 3'd3;
	
	always @(posedge clock) begin
		if (reset) begin
			sp_write <= 1'b0;
			sample_ready <= 1'b0;
			state_machine <= sm_init;
		end
		else begin
			case (state_machine)
				sm_init:
					begin
						accumulated_frequency <= frequency;
						sample_ready <= 1'b0;
						sp_write <= 1'b0;
						state_machine <= sm_write;
					end
					
				sm_write:
					begin
						// increment next sample position by frequency: number of items in sine LUT is 2048 (32*2048=65536) which means that we can divide by 32 to get correct position
						sample_position <= sp_readdata + accumulated_frequency;
						sp_write <= 1'b1;
						sample_ready <= 1'b1;
						state_machine <= sm_ready;
					end

				sm_ready:
					begin
						sp_write <= 1'b0;
						if (next_sample) begin
							sample_ready <= 1'b0;
							state_machine <= (harmonic == 1'b0) ? sm_init : sm_next;
						end
					end
				
				sm_next:
					begin
						
						accumulated_frequency <= accumulated_frequency + frequency;
						state_machine <= sm_write;
					end
			endcase
		end
		
	end

endmodule