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
	reg sp_write;
	wire [15:0] sp_readdata;
	reg [15:0] sp_writedata;
	reg [7:0] harmonic = 1'b0;						// Number of harmonic being calculated
	// Initialise Sample Position RAM
	Sample_Pos_RAM sample_pos_ram(.din(sp_writedata), .addr(harmonic), .write_en(sp_write), .clk(fpga_clock), .dout(sp_readdata));

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
	reg [15:0] sample_pos;								// Temporary register to hold position of current cycle
	reg [15:0] sample_timer = 1'b0;					// Counts up to SAMPLEINTERVAL to set sample rate interval
	reg [15:0] freq_increment;						// Sample position offset incrementing by n * freqency for each harmonic
	reg [15:0] frequency = 16'd1000;
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
	localparam sm_harm0 = 4'd2;
	localparam sm_harm1 = 4'd3;
	localparam sm_harm2 = 4'd4;
	localparam sm_harm3 = 4'd5;
	localparam sm_wait_adder = 4'd6;
	localparam sm_calc_done = 4'd7;
	localparam sm_scale_sample = 4'd8;
	localparam sm_ready_to_send = 4'd9;
	localparam sm_prep = 4'd10;

	always @(posedge adc_data_received) begin
//		err_out <=  ~err_out;
		frequency <= adc_data0;
		if (adc_data1 != 16'h5533)
			debug_out <= ~debug_out;
		//harmonic_scale <= adc_data1;
	end

	always @(posedge fpga_clock or posedge reset) begin
		if (reset) begin
			sample_timer <= 1'b0;
			dac_send <= 1'b0;
			lut_addr <= 1'b0;
			state_machine <= sm_init;
			adder_start <= 1'b0;
			harmonic <= 8'b0;
		end
		else begin
			sample_timer <= sample_timer + 1'b1;


			case (state_machine)
				sm_init:
				begin
					freq_increment <= frequency;
					adder_clear <= 1'b0;
					adder_start <= 1'b0;
					adder_mult <= 7'd127;
					state_machine <= sm_harm0;
				end

				sm_harm0:
				begin
					// increment next sample position by frequency: number of items in sine LUT is 1500 (32*1500=48000Hz) which means that we can divide by 32 to get correct position
					sample_pos <= (sp_readdata + freq_increment) % SAMPLERATE;

					adder_start <= 1'b0;
					state_machine <= sm_harm1;
				end

				sm_harm1:
				begin
					lut_addr <= sample_pos >> 5;									// pass sine LUT to memory address to be read in two cycles

					//	Write sample position to memory
					sp_writedata <= sample_pos;
					sp_write <= 1'b1;

					state_machine <= sm_harm2;
				end

				sm_harm2:
				begin
					freq_increment <= freq_increment + frequency;			// set up next sample position offset

					// Load up next sample position
					sp_write <= 1'b0;
					harmonic <= harmonic + 1'b1;
					//state_machine <= sm_wait_adder;
					state_machine <= sm_harm3;
				end

				
				sm_harm3:
				begin
					//harmonic <= harmonic + 1'b1;								// harmonic incremented here to resolve timing issues through pipelining
					if (adder_mult > 10)
						adder_mult <= adder_mult - 10;
					state_machine <= sm_wait_adder;
				end
				
				sm_wait_adder:
				if (adder_ready) begin
					// Wait until the adder is free and then start the next calculation
					
					adder_start <= 1'b1;												// Tell the adder the next sample is ready
					state_machine <= (harmonic > 10) ? sm_calc_done : sm_harm0;
				end

				sm_calc_done:
				begin
					if (adder_ready) begin
						// all harmonics calculated - offset output for sending to DAC
						adder_start <= 1'b0;
						output_sample <= 32'h1FFFF + adder_total;			// Add extra 2^17 to cancel divide by two on final value
						state_machine <= sm_scale_sample;
					end
				end

				sm_scale_sample:
				begin
					dac_sample <= output_sample >> 2;							// scale output sample to send to DAC
					state_machine <= sm_ready_to_send;
				end
					
				sm_ready_to_send:
					if (sample_timer == SAMPLEINTERVAL) begin
						//debug_sample <= output_sample;
						//dac_data <= {SEND_CHANNEL_A, output_sample[17:2]};	// effectively divide output sample by 2 to avoid overflow caused by adding multiple sine waves
						dac_data <= {SEND_CHANNEL_A, dac_sample};	// effectively divide output sample by 2 to avoid overflow caused by adding multiple sine waves

						sample_timer <= 1'b0;
						dac_send <= 1'b1;
						state_machine <= sm_prep;
					end				

				sm_prep:
				begin
					harmonic <= 8'b0;													// pre main loop preparation phase moved here for timing
					sp_write <= 1'b0;
					adder_clear <= 1'b1;
					dac_send <= 1'b0;
					state_machine <= sm_init;
				end
				
			endcase

		end
	end

endmodule