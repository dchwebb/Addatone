module top(dac_spi_cs, dac_spi_data, dac_spi_clock, adc_spi_nss, adc_spi_data, adc_spi_clock, rstn, crystal_osc, err_out, debug_out);

	input wire rstn;       // from SW1 pushbutton
	wire reset;
	assign reset = ~rstn;

	//	Initialise 72MHz PLL clock from dev board 12 MHz crystal (dev board pin C8)
	input wire crystal_osc;
	wire fpga_clock;
	OscPll pll(.CLKI(crystal_osc), .CLKOP(fpga_clock));

	// Debug settings
	output wire err_out;
	output reg debug_out;
	reg [31:0] debug_sample;

	// Sample position RAM - memory array to store current position in cycle of each harmonic
	reg [7:0] harmonic = 1'b0;						// Number of harmonic being calculated
	reg next_sample;				// Trigger from top module to say current value has been read and ready for next sample
	wire [15:0] sample_pos;
	reg [15:0] frequency = 16'd1000;
	wire sample_ready;
	SamplePosition sample_position(.reset(reset), .clock(fpga_clock), .frequency(frequency), .harmonic(harmonic), .sample_ready(sample_ready), .next_sample(next_sample),	.sample_position(sample_pos));

	// DAC settings
	output wire dac_spi_cs;
	output wire dac_spi_data;
	output wire dac_spi_clock;
	reg [23:0] dac_data;
	reg dac_send;
	// initialise DAC SPI (Maxim5134)
	DAC_SPI_Out dac(.clock_in(fpga_clock), .reset(reset), .data_in(dac_data), .send(dac_send), .spi_cs_out(dac_spi_cs), .spi_clock_out(dac_spi_clock), .spi_data_out(dac_spi_data));

	// ADC settings
	input wire adc_spi_nss;
	input wire adc_spi_clock;
	input wire adc_spi_data;
	wire [15:0] adc_data0;
	wire [15:0] adc_data1;
	wire adc_data_received;
	// Initialise ADC SPI input microcontroller
	ADC_SPI_In adc(.i_reset(reset), .i_clock(fpga_clock), .i_SPI_CS(adc_spi_nss), .i_SPI_clock(adc_spi_clock), .i_SPI_data(adc_spi_data), .o_data0(adc_data0), .o_data1(adc_data1), .o_data_received(adc_data_received), .CS_stable(err_out));

	// output settings
	reg signed [31:0] output_sample;
	reg [15:0] dac_sample;								// Contains output sample scaled
	parameter SEND_CHANNEL_A = 8'b00110001;		// Write to DAC Channel A

	// Timing and Sine LUT settings
	reg [15:0] sample_timer = 1'b0;					// Counts up to SAMPLEINTERVAL to set sample rate interval
	parameter SAMPLERATE = 16'd48000;
	parameter SAMPLEINTERVAL = 16'd1500;			// Clock frequency / sample rate - eg 88.67Mhz / 44khz = 2015 OR 72MHz / 48kHz = 1500
	// SinLUT settings
	reg [15:0] harmonic_scale;
	reg [10:0] lut_addr = 11'b0;
	wire signed [15:0] lut_value;
	// Initialise Sine LUT
	SineLUT sin_lut (.Address(lut_addr), .OutClock(fpga_clock), .OutClockEn(1'b1), .Reset(reset), .Q(lut_value));


	// Instantiate scaling adder - this scales then accumulates samples for each sine wave
	parameter DIV_BIT = 7;			// Allows fractions from 1/128 to 127/128 (for DIV_BIT = 7)
	reg adder_start, adder_clear;
	wire adder_ready;
	reg [DIV_BIT - 1:0] adder_mult;
	wire signed [31:0] adder_total;
	Fraction #(.DIVISOR_BITS(DIV_BIT)) addSample (.clock(fpga_clock), .reset(reset), .start(adder_start), .clear_accumulator(adder_clear),  .multiple(adder_mult), .in(lut_value), .accumulator(adder_total), .done(adder_ready));

	// State Machine settings - used to control calculation of amplitude of each harmonic sample
	reg [3:0] state_machine;
	localparam sm_idle = 4'd0;
	localparam sm_init = 4'd1;
	localparam sm_sine_lookup = 4'd2;
	localparam sm_next_harm = 4'd3;
	localparam sm_adder_start = 4'd4;
	localparam sm_adder_wait = 4'd5;
	localparam sm_calc_done = 4'd6;
	localparam sm_scale_sample = 4'd7;
	localparam sm_ready_to_send = 4'd8;

	always @(posedge adc_data_received) begin
//		err_out <=  ~err_out;
		frequency <= adc_data0;
		//if (adc_data1 != 16'h5533)
			//debug_out <= ~debug_out;
		//harmonic_scale <= adc_data1;
	end

	always @(posedge fpga_clock) begin
		if (reset) begin
			sample_timer <= 1'b0;
			dac_send <= 1'b0;
			lut_addr <= 1'b0;
			adder_start <= 1'b0;
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
					adder_mult <= 7'd127;
					state_machine <= sm_sine_lookup;
				end

				sm_sine_lookup:
				begin
					adder_start <= 1'b0;
					if (sample_ready) begin
						lut_addr <= sample_pos >> 5;									// offset sample position to generate sine LUT address

						state_machine <= sm_next_harm;
					end
				end

				sm_next_harm:
				begin
					// Load up next sample position
					harmonic <= harmonic + 1'b1;
					next_sample <= 1'b1;

					// decrease harmonic scaler
					if (adder_mult > 5)
						adder_mult <= adder_mult - 5;
					state_machine <= sm_adder_start;
				end

				sm_adder_start:
				begin
					next_sample <= 1'b0;
					if (adder_ready) begin
						// Wait until the adder is free and then start the next calculation
						adder_start <= 1'b1;											// Tell the adder the next sample is ready
						state_machine <= (harmonic > 20) ? sm_adder_wait : sm_sine_lookup;
					end
				end
				
				sm_adder_wait:
				begin
					adder_start <= 1'b0;
					state_machine <= sm_calc_done;								// Pause to let adder clear adder_ready state
				end

				sm_calc_done:
				begin
					if (adder_ready) begin
						// all harmonics calculated - offset output for sending to DAC
						output_sample <= 32'h31000 + adder_total;			// Add extra 2^18 (approx) to cancel divide by 4 on final value
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
						state_machine <= sm_init;
					end				

			endcase

		end
	end

endmodule