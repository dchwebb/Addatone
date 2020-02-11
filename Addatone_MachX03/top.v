module top(dac_spi_cs, dac_spi_data, dac_spi_clock, adc_spi_nss, adc_spi_data, adc_spi_clock, rstn, crystal_osc, err_out, debug_out);

	input wire rstn;       // from SW1 pushbutton
	wire reset;
	assign reset = ~rstn;

	// Debug settings
	output reg err_out;
	output reg debug_out;
	reg [31:0] debug_sample;

	// SinLUT settings
	reg [10:0] lut_addr = 11'b0;
	wire lut_enable = 1'b1;
	wire signed [15:0] lut_value;

	// Sample position RAM
	reg [7:0] sp_addr;
	reg sp_write;
	wire [15:0] sp_readdata;
	reg [15:0] sp_writedata;
	reg [7:0] harmonic = 0;		// Number of harmonic being calculated

	// DAC settings
	output wire dac_spi_cs;
	output wire dac_spi_data;
	output wire dac_spi_clock;
	reg [23:0] dac_data;
	reg dac_send;

	// ADC settings
	input wire adc_spi_nss;
	input wire adc_spi_clock;
	input wire adc_spi_data;
	wire [15:0] adc_data;
	wire adc_data_received;

	// output settings
	reg signed [31:0] output_sample;
	reg signed [15:0] harmonic_sample;

	// Timing settings
	input wire crystal_osc;
	reg [15:0] sample_pos;
	reg [15:0] sample_timer = 1'b0;
	reg [15:0] freq_increment;						// Sample position offset incrementing by n * freqency for each harmonic
	reg [15:0] frequency = 16'd1000;
	parameter SAMPLERATE = 16'd48000;
	parameter SAMPLEINTERVAL = 16'd1500;			// Clock frequency / sample rate - eg 88.67Mhz / 44khz = 2015 OR 72MHz / 48kHz = 1500
	parameter LUTSIZE = 1500;
	//reg [9:0] lut_pos = 10'b0;


	// Sample settings
	parameter SEND_CHANNEL_A = 8'b00110001;		// Write to DAC Channel A

	//	Initialise 84MHz PLL clock from dev board 12 MHz crystal (dev board pin C8)
	wire fpga_clock;
	OscPll pll(.CLKI(crystal_osc), .CLKOP(fpga_clock));

	// Initialise Sine LUT
	SineLUT sin_lut (.Address(lut_addr), .OutClock(fpga_clock), .OutClockEn(lut_enable), .Reset(reset), .Q(lut_value));

	// Initialise Sample Position RAM
	Sample_Pos_RAM sample_pos_ram(.din(sp_writedata), .addr(harmonic), .write_en(sp_write), .clk(fpga_clock), .dout(sp_readdata));

	// Initialise ADC SPI input microcontroller
	ADC_SPI_In adc(.reset(reset), .clock(fpga_clock), .spi_nss(adc_spi_nss), .spi_clock_in(adc_spi_clock), .spi_data_in(adc_spi_data), .data_out(adc_data), .data_received(adc_data_received));

	// initialise DAC SPI (Maxim5134)
	DAC_SPI_Out dac(.clock_in(fpga_clock), .reset(reset), .data_in(dac_data), .send(dac_send), .spi_cs_out(dac_spi_cs), .spi_clock_out(dac_spi_clock), .spi_data_out(dac_spi_data));

	// Instantiate fractional adder - this scales then accumulates samples for each sine wave
	parameter DIV_BIT = 7;			// Allows fractions from 1/128 to 127/128 (for DIV_BIT = 7)
	reg adder_start, adder_clear;
	wire adder_ready;
	reg [DIV_BIT - 1:0] adder_mult;
	wire signed [31:0] adder_total;
	Fraction #(.DIVISOR_BITS(DIV_BIT)) addSample (.clock(fpga_clock), .reset(reset), .start(adder_start), .clear_accumulator(adder_clear),  .multiple(adder_mult), .in(lut_value), .accumulator(adder_total), .done(adder_ready));

	// State Machine settings
	reg [1:0] state_machine;
	reg [3:0] sm_counter;
	localparam sm_idle = 2'b00;
	localparam sm_init = 2'b01;
	localparam sm_calc_harmonics = 2'b10;
	localparam sm_done = 2'b11;


	always @(posedge adc_data_received) begin
		err_out <=  ~err_out; //(adc_data < 1000)? 1'b0 : 1'b1;
		frequency <= adc_data;
	end

	always @(posedge fpga_clock or posedge reset) begin
		if (reset) begin
			sample_timer <= 1'b0;
			dac_send <= 1'b0;
			//sample_pos <= 1'b0;
			lut_addr <= 1'b0;
			state_machine <= sm_init;
			adder_start <= 1'b0;
			//sp_addr <= 1'b0;
			harmonic <= 8'b0;
		end
		else begin

			case (state_machine)
				sm_init:
				begin
					freq_increment <= frequency;
					//harmonic <= 8'b0;
					state_machine <= sm_calc_harmonics;
					sm_counter <= 1'b0;
					adder_clear <= 1'b0;
					adder_start <= 1'b0;
					adder_mult <= 7'd127;
				end

				sm_calc_harmonics:
				begin
					sm_counter <= sm_counter + 1'b1;

					if (harmonic > 6) begin
						state_machine <= sm_done;
					end
					else if (sm_counter == 0) begin
						// increment next sample position by frequency: number of items in sine LUT is 1500 (32*1500=48000Hz) which means that we can divide by 32 to get correct position
						sample_pos <= (sp_readdata + freq_increment) % SAMPLERATE;

						adder_start <= 1'b0;
					end
					else if (sm_counter == 1) begin
						lut_addr <= sample_pos >> 5;									// pass sine LUT to memory address to be read in two cycles

						//	Write sample position to memory
						sp_writedata <= sample_pos;
						sp_write <= 1'b1;

						//harmonic <= harmonic + 1'b1;
					end
					else if (sm_counter == 2) begin
						freq_increment <= freq_increment + frequency;			// set up next sample position offset

						// Load up next sample position
						sp_write <= 1'b0;
						//sp_addr <= harmonic;
						harmonic <= harmonic + 1'b1;
					end
					else if (adder_ready) begin
						// Wait until the adder is free and then start the next calculation
						adder_mult <= adder_mult - 20;
						adder_start <= 1'b1;												// Tell the adder the next sample is ready
						sm_counter <= 0;
					end
				end

				sm_done:
				begin
					if (adder_ready) begin
						// all harmonics calculated - offset output for sending to DAC
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
				//sp_addr <= 1'b0;
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