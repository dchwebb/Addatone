module top(dac_spi_cs, dac_spi_data, dac_spi_clock, adc_spi_nss, adc_spi_data, adc_spi_clock, rstn, crystal_osc, err_out, debug_out);

	input wire rstn;       // from SW1 pushbutton
	wire reset;
	assign reset = ~rstn;

	//	Initialise 84MHz PLL clock from dev board 12 MHz crystal (dev board pin C8)
	input wire crystal_osc;
	wire fpga_clock;
	OscPll pll(.CLKI(crystal_osc), .CLKOP(fpga_clock));

	// Debug settings
	output reg err_out;
	output reg debug_out;
	reg [31:0] debug_sample;

	// SinLUT settings
	reg [10:0] lut_addr = 11'b0;
	//wire lut_enable = 1'b1;
	wire signed [15:0] lut_value;

	// Sample position RAM - memory array to store current position in cycle of each harmonic
	//reg [7:0] sp_addr;
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
	ADC_SPI_In adc(.reset(reset), .clock(fpga_clock), .spi_nss(adc_spi_nss), .spi_clock_in(adc_spi_clock), .spi_data_in(adc_spi_data), .data_out0(adc_data0), .data_out1(adc_data1), .data_received(adc_data_received));

	// output settings
	reg signed [31:0] output_sample;
	parameter SEND_CHANNEL_A = 8'b00110001;		// Write to DAC Channel A

	// Timing and Sine LUT settings
	reg [15:0] sample_pos;								// Temporary register to hold position of current cycle
	reg [15:0] sample_timer = 1'b0;					// Counts up to SAMPLEINTERVAL to set sample rate interval
	reg [15:0] freq_increment;						// Sample position offset incrementing by n * freqency for each harmonic
	reg [15:0] frequency = 16'd1000;
	parameter SAMPLERATE = 16'd48000;
	parameter SAMPLEINTERVAL = 16'd1500;			// Clock frequency / sample rate - eg 88.67Mhz / 44khz = 2015 OR 72MHz / 48kHz = 1500
	parameter LUTSIZE = 1500;
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
	reg [2:0] state_machine;
	localparam sm_idle = 3'b000;
	localparam sm_init = 3'b001;
	localparam sm_harm0 = 3'b010;
	localparam sm_harm1 = 3'b011;
	localparam sm_harm2 = 3'b100;
	localparam sm_harm3 = 3'b101;
	localparam sm_wait_adder = 3'b110;
	localparam sm_done = 3'b111;
	localparam sm_prep = 3'b111;


	always @(posedge adc_data_received) begin
		err_out <=  ~err_out;
		frequency <= adc_data0;
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
					//harmonic <= harmonic + 1'b1;
					state_machine <= sm_harm3;
				end

				sm_harm3:
				begin
					harmonic <= harmonic + 1'b1;									// harmonic incremented here to resolve timing issues through pipelining
					state_machine <= sm_wait_adder;
				end

				sm_wait_adder:
				if (adder_ready) begin
					// Wait until the adder is free and then start the next calculation
					adder_mult <= adder_mult - 20;
					adder_start <= 1'b1;												// Tell the adder the next sample is ready

					state_machine <= (harmonic > 6) ? sm_done : sm_harm0;

				end

				sm_done:
				begin
					if (adder_ready) begin
						// all harmonics calculated - offset output for sending to DAC
						adder_start <= 1'b0;
						output_sample <= 32'h1FFFF + adder_total;					// Add extra 2^17 to cancel divide by two on final value
						state_machine <= sm_idle;
					end
				end

			endcase



			// send DAC data out once sample timer reaches appropriate count
			if (sample_timer == SAMPLEINTERVAL) begin
				debug_sample <= output_sample;
				dac_data <= {SEND_CHANNEL_A, output_sample[17:2]};		// effectively divide output sample by 2 to avoid overflow caused by adding multiple sine waves

				sample_timer <= 1'b0;
				dac_send <= 1'b1;
				state_machine <= sm_init;
				harmonic <= 8'b0;
				sp_write <= 1'b0;
				adder_clear <= 1'b1;
			end
			else begin
				sample_timer <= sample_timer + 1'b1;
				dac_send <= 1'b0;
			end
		end
	end

endmodule