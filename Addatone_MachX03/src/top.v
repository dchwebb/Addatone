module top
	(
		output wire dac_cs,
		output wire dac_bit,
		output wire dac_clock,
		input wire adc_cs,
		input wire adc_data,
		input wire adc_clock,
		input wire rstn,
		input wire crystal_osc,
		output wire err_out,
		output reg debug_out
	);

	parameter NO_OF_HARMONICS = 8'd20;

	wire reset;
	assign reset = ~rstn;

	//	Initialise 72MHz PLL clock from dev board 12 MHz crystal (dev board pin C8)
	wire fpga_clock;
	OscPll pll(.CLKI(crystal_osc), .CLKOP(fpga_clock));

	// Sample position RAM - memory array to store current position in cycle of each harmonic
	reg [7:0] harmonic = 1'b0;						// Number of harmonic being calculated
	reg next_sample;										// Trigger from top module to say current value has been read and ready for next sample
	wire signed [15:0] sample_value;
	reg [15:0] frequency = 16'd1000;
	wire sample_ready;
	SamplePosition sample_position(.i_reset(reset), .i_clock(fpga_clock), .i_frequency(frequency), .i_harmonic(harmonic), .o_sample_ready(sample_ready), .i_next_sample(next_sample),	.o_sample_value(sample_value));

	// initialise DAC SPI (Maxim5134)
	reg [23:0] dac_data;
	reg dac_send;
	DAC_SPI_Out dac(.i_clock(fpga_clock), .i_reset(reset), .i_data(dac_data), .i_send(dac_send), .o_SPI_CS(dac_cs), .o_SPI_clock(dac_clock), .o_SPI_data(dac_bit));

	// Initialise ADC SPI input microcontroller
	wire [15:0] adc_data0;
	wire [15:0] adc_data1;
	wire adc_data_received;
	ADC_SPI_In adc(.i_reset(reset), .i_clock(fpga_clock), .i_SPI_CS(adc_cs), .i_SPI_clock(adc_clock), .i_SPI_data(adc_data), .o_data0(adc_data0), .o_data1(adc_data1), .o_data_received(adc_data_received));

	// Output settings
	reg signed [31:0] output_sample;
	reg [15:0] dac_sample;								// Contains output sample scaled
	parameter SEND_CHANNEL_A = 8'b00110001;		// Write to DAC Channel A

	// Timing and Sine LUT settings
	reg [15:0] sample_timer = 1'b0;					// Counts up to SAMPLEINTERVAL to set sample rate interval
	parameter SAMPLERATE = 16'd48000;
	parameter SAMPLEINTERVAL = 16'd1500;			// Clock frequency / sample rate - eg 88.67Mhz / 44khz = 2015 OR 72MHz / 48kHz = 1500

	// Instantiate scaling adder - this scales then accumulates samples for each sine wave
	parameter DIV_BIT = 8;								// Allows fractions from 1/128 to 127/128 (for DIV_BIT = 7)
	reg adder1_start, adder2_start, adder_clear;
	reg [DIV_BIT - 1:0] harmonic_scale = 1'b0;
	reg [DIV_BIT - 1:0] scale_initial = 255;
	wire adder1_ready, adder2_ready;
	wire [DIV_BIT - 1:0] adder_mult;
	wire signed [31:0] adder1_total;
	wire signed [31:0] adder2_total;
	Adder #(.DIVISOR_BITS(DIV_BIT)) addSample1 (.clock(fpga_clock), .reset(reset), .start(adder1_start), .clear_accumulator(adder_clear),  .multiple(adder_mult), .i_sample(sample_value), .accumulator(adder1_total), .done(adder1_ready));
	Adder #(.DIVISOR_BITS(DIV_BIT)) addSample2 (.clock(fpga_clock), .reset(reset), .start(adder2_start), .clear_accumulator(adder_clear),  .multiple(adder_mult), .i_sample(sample_value), .accumulator(adder2_total), .done(adder2_ready));

	// instantiate multiple scaler - this takes incoming ADC reading and uses it to reduce the level of harmonics scaled by the Adder
	reg start_mult_scaler;
	reg reset_mult_scaler;
	scale_mult #(.DIV_BIT(DIV_BIT)) mult (.i_clock(fpga_clock), .i_start(start_mult_scaler), .i_restart(reset_mult_scaler), .i_scale(harmonic_scale), .i_initial(scale_initial), .o_mult(adder_mult));

	// State Machine settings - used to control calculation of amplitude of each harmonic sample
	reg [3:0] state_machine;
	localparam sm_init = 4'd1;
	localparam sm_adder_mult = 4'd2;
	localparam sm_scale = 4'd9;
	localparam sm_sine_lookup = 4'd3;
	localparam sm_adder_start = 4'd4;
	localparam sm_adder_wait = 4'd5;
	localparam sm_calc_done = 4'd6;
	localparam sm_scale_sample = 4'd7;
	localparam sm_ready_to_send = 4'd8;


	always @(posedge adc_data_received) begin
		frequency <= adc_data0;
		harmonic_scale <= adc_data1[DIV_BIT - 1:0];			// bottom 8 bits are scale value
		scale_initial <= adc_data1[15:DIV_BIT];				// top 8 bits are starting value for scaling (lower if there are more harmonics)
		debug_out <= ~debug_out;
	end

	always @(posedge fpga_clock) begin
		if (reset) begin
			sample_timer <= 1'b0;
			dac_send <= 1'b0;
			adder1_start <= 1'b0;
			adder2_start <= 1'b0;
			harmonic <= 8'b0;
			state_machine <= sm_init;
		end
		else begin
			sample_timer <= sample_timer + 1'b1;

			case (state_machine)
				sm_init:
				begin
					dac_send <= 1'b0;
					next_sample <= 1'b0;
					adder_clear <= 1'b0;
					reset_mult_scaler <= 1'b0;
					state_machine <= sm_adder_start;
				end

				sm_adder_mult:
				begin
					next_sample <= 1'b0;
					adder1_start <= 1'b0;
					adder2_start <= 1'b0;

					// decrease harmonic scaler
					start_mult_scaler <= 1'b1;
					state_machine <= sm_adder_start;
				end

				sm_adder_start:
				begin
					start_mult_scaler <= 1'b0;

					// Wait until the sample value is ready and Adder is free and then start the next calculation
					if (sample_ready && (harmonic[0] == 1'b0 ? adder1_ready : adder2_ready)) begin
						harmonic <= harmonic + 2'b1;								// Load up next sample position
						next_sample <= 1'b1;

						if (harmonic[0] == 1'b0)		// even harmonics
							adder1_start <= 1'b1;											// Tell the adder the next sample is ready
						else
							adder2_start <= 1'b1;
						state_machine <= (harmonic > NO_OF_HARMONICS) ? sm_adder_wait : sm_adder_mult;
					end
				end

				sm_adder_wait:
				begin
					next_sample <= 1'b0;
					adder1_start <= 1'b0;
					adder2_start <= 1'b0;
					state_machine <= sm_calc_done;								// Pause to let adder clear adder_ready state
				end

				sm_calc_done:
				begin
					if (adder1_ready) begin
						// all harmonics calculated - offset output for sending to DAC
						output_sample <= 32'h31000 + adder2_total;			// Add extra 2^18 (approx) to cancel divide by 4 on final value
						state_machine <= sm_scale_sample;
					end
				end

				sm_scale_sample:
				begin
					dac_sample <= output_sample >> 3;							// scale output sample to send to DAC
					state_machine <= sm_ready_to_send;
				end

				sm_ready_to_send:
					if (sample_timer == SAMPLEINTERVAL) begin
						// Send sample value to DAC
						dac_data <= {SEND_CHANNEL_A, dac_sample};
						dac_send <= 1'b1;

						// Clean state ready for next loop
						sample_timer <= 1'b0;
						harmonic <= 8'b0;
						next_sample <= 1'b1;
						adder_clear <= 1'b1;
						reset_mult_scaler <= 1'b1;
						state_machine <= sm_init;
					end

			endcase

		end
	end

endmodule