`timescale 1ns / 1ns // `timescale time_unit/time_precision
module cryptMachine (
input [1:0] KEY,
input CLOCK_50,
inout PS2_CLK, PS2_DAT, 
output [6:0] HEX0,
HEX1, HEX2, HEX3, HEX4, HEX5,
output [7:0] LEDR,
// The ports below are for the VGA output.  Do not change.
output VGA_CLK,   					//	VGA Clock
		 VGA_HS,							//	VGA H_SYNC
		 VGA_VS,							//	VGA V_SYNC
		 VGA_BLANK_N,					//	VGA BLANK
		 VGA_SYNC_N,					//	VGA SYNC
output [9:0]
		 VGA_R,   						//	VGA Red[9:0]
		 VGA_G,	 						//	VGA Green[9:0]
		 VGA_B   						//	VGA Blue[9:0]
);

	wire [31:0] finalResult;
	wire [3:0] frameOutput;
	wire [7:0] received_data;
	wire [3:0] ld_counter;
	wire [3:0] indexcounter;
	wire received_data_en;
	wire load, displayV0, displayV1, skip,
	ld_enc_sum, ld_enc_results_1, ld_enc_results_2, ld_enc_v0, ld_enc_v1,
	ld_dec_sum, ld_dec_results_1, ld_dec_results_2, ld_dec_v0, ld_dec_v1,
	setSum, resetFlag, drawV0, eraseV0, drawV0E, eraseV0E, drawV1E, eraseV1E, 
	eraseV1, enableRateDivider, drawV1, donedrawv0, doneerasev0, doneerasev1, 
	donedrawv1, draw, v0flag, v0erase, v1erase, v1flag;
	wire writeEn, indexv0, indexv1, drawLetter;
	wire [2:0] romColourOutput; // what goes to vga
	wire [2:0] romColourOutput1; // for drawing numbers
	wire [2:0] romColourOutput2; // for drawing letters
   wire [12:0] addressCounter;
	wire [12:0] addressCounterLetters;
   wire [12:0] startAddress;
	wire [5:0] xcounter;
	wire [5:0] ycounter;
	wire [7:0] startX;
	wire [6:0] startY;
	wire [7:0] startXWire;
	wire [6:0] startYWire;
	
	wire donedrawv0L, doneerasev0L, doneerasev1L, donedrawv1L;
		wire [5:0] xcounterL;
	wire [5:0] ycounterL;
	wire [7:0] startXL;
	wire [6:0] startYL;
	
		wire [5:0] xcounterF;
	wire [5:0] ycounterF;
			wire [7:0] startXF;
		wire [6:0] startYF;
		wire selectCounters;
		 
	//wire [6:0] current_state; //
	
	wire [1:0] selectRom;
	
	PS2_Controller k0 (
		.CLOCK_50(CLOCK_50),
		.reset(~KEY[0]),
		.PS2_CLK(PS2_CLK),					
		.PS2_DAT(PS2_DAT),					
		.received_data(received_data),
		.received_data_en(received_data_en) 
		// If 1: new data (NOTE: DOES NOT MEAN DIFFERENT DATA) has been received
	);
	
	
	letters l0 (
	 .address(addressCounterLetters),
	 .clock(CLOCK_50),
	 .q(romColourOutput2)	
	);

	
	numbers n0 (
	 .address(addressCounter),
	 .clock(CLOCK_50),
	 .q(romColourOutput1)
	);
	
	
	selectRomOutput s (
		.romColourOutput1(romColourOutput1),
		.romColourOutput2(romColourOutput2),
		.selectRom(selectRom),
		.romColourOutput(romColourOutput)
	);
	
	selectCounter C0 (
	.selectCounters(selectCounters),
		.xcounter(xcounter),
      .ycounter(ycounter),
		.startX(startX),
		.startY(startY),	
				.xcounterL(xcounterL),
      .ycounterL(ycounterL),
		.startXL(startXL),
		.startYL(startYL),

	.xcounterF(xcounterF),
	.ycounterF(ycounterF),
	.startXF(startXF),
	.startYF(startYF)
	);
	
drawNumberOutput o (
		 .clk(CLOCK_50),
		 .draw(draw),
		 .startXWire(startXWire),
		 .startYWire(startYWire),
		 .startAddress(startAddress),
		.xcounter(xcounter),
      .ycounter(ycounter),
		.startX(startX),
		.startY(startY),		
		.addressCounter(addressCounter),
		.donedrawv0(donedrawv0),
		.doneerasev0(doneerasev0),
		.doneerasev1(doneerasev1),
		.donedrawv1(donedrawv1),
		.v0flag(v0flag),
		.v1flag(v1flag),
		.v0erase(v0erase),
		.v1erase(v1erase)
);

drawLetterOutput L0 (
		 .clk(CLOCK_50),
		 .drawLetter(drawLetter),
		 .startXWire(startXWire),
		 .startYWire(startYWire),
		 .startAddress(startAddress),
		.xcounterL(xcounterL),
      .ycounterL(ycounterL),
		.startXL(startXL),
		.startYL(startYL),		
		.addressCounterLetters(addressCounterLetters),
		.donedrawv0L(donedrawv0L),
		.doneerasev0L(doneerasev0L),
		.doneerasev1L(doneerasev1L),
		.donedrawv1L(donedrawv1L),
		.v0flag(v0flag),
		.v1flag(v1flag),
		.v0erase(v0erase),
		.v1erase(v1erase)
);


	datapath d0 (
		.clk(CLOCK_50), .resetn(KEY[0]),
		
      .resetFlag(resetFlag), .load(load), .drawV0(drawV0), .drawV1(drawV1),
		.displayV0(displayV0), .displayV1(displayV1),
		.setSum(setSum),
		.eraseV0(eraseV0),  .eraseV1(eraseV1),
		
		.ld_enc_sum(ld_enc_sum), .ld_enc_results_1(ld_enc_results_1),
		.ld_enc_results_2(ld_enc_results_2), .ld_enc_v0(ld_enc_v0), .ld_enc_v1(ld_enc_v1),
		
		.ld_dec_sum(ld_dec_sum), .ld_dec_results_1(ld_dec_results_1),
		.ld_dec_results_2(ld_dec_results_2), .ld_dec_v0(ld_dec_v0), .ld_dec_v1(ld_dec_v1),
		
		.ld_counter(ld_counter),
		.received_data(received_data),
                .draw(draw),
					 .drawLetter(drawLetter),
					 .v0flag(v0flag),
					 .v1flag(v1flag),
					 .indexv0(indexv0),
					 .indexv1(indexv1),
					 .indexcounter(indexcounter),
					 
					 .drawV0E(drawV0E),
					 .eraseV0E(eraseV0E),
					 					 
					 .drawV1E(drawV1E),
					 .eraseV1E(eraseV1E),
		.finalResult(finalResult),
		.startXWire(startXWire),
		.startYWire(startYWire),		
		.startAddress(startAddress),
		.selectRom(selectRom),
		.selectCounters(selectCounters),
		.v0erase(v0erase),
		.v1erase(v1erase),
		.enableRateDivider(enableRateDivider),
		.frameOutput(frameOutput),
		.skip(skip)
	);
	
	
	control c0 (
		 .clk(CLOCK_50),
		 
       .resetFlag(resetFlag), .load(load), .drawV0(drawV0), .drawV1(drawV1),
		 .displayV0(displayV0), .displayV1(displayV1),
		 .setSum(setSum),
		 
		 .ld_enc_sum(ld_enc_sum), .ld_enc_results_1(ld_enc_results_1),
		 .ld_enc_results_2(ld_enc_results_2), .ld_enc_v0(ld_enc_v0), .ld_enc_v1(ld_enc_v1),
		 
		 .ld_dec_sum(ld_dec_sum), .ld_dec_results_1(ld_dec_results_1),
		 .ld_dec_results_2(ld_dec_results_2), .ld_dec_v0(ld_dec_v0), .ld_dec_v1(ld_dec_v1),
		 
		 					 .drawV0E(drawV0E),
					 .eraseV0E(eraseV0E),
					 		 					 .drawV1E(drawV1E),
					 .eraseV1E(eraseV1E),
		 .ld_counter(ld_counter),
		 .received_data(received_data),
		 .received_data_en(received_data_en),
		 .enableRateDivider(enableRateDivider),
		 .plotOutput(writeEn),
		 .donedrawv0(donedrawv0),
		 .doneerasev0(doneerasev0),
		 .doneerasev1(doneerasev1),
		 .eraseV0(eraseV0),
		 .eraseV1(eraseV1),
		 .frameOutput(frameOutput),
		 .indexv0(indexv0),
		 .indexv1(indexv1),
		 .indexcounter(indexcounter),
		 .skip(skip),
		 .donedrawv1(donedrawv1),
		 		.donedrawv0L(donedrawv0L),
		.doneerasev0L(doneerasev0L),
		.doneerasev1L(doneerasev1L),
		.donedrawv1L(donedrawv1L)//,
		 //.current_state(current_state)
	);
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(romColourOutput),
			.x(startXF + xcounterF),
			.y(startYF + ycounterF),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK)
			);
			
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "background.mif";
	
	hex_decoder H0(finalResult[3:0],HEX0); 
	hex_decoder H1(finalResult[7:4],HEX1);
	hex_decoder H2(finalResult[11:8],HEX2);
	
	hex_decoder H3(finalResult[19:16],HEX3);
	hex_decoder H4(finalResult[23:20],HEX4);
	hex_decoder H5(finalResult[27:24],HEX5);
	
	assign LEDR[3:0] = finalResult[15:12];
	assign LEDR[7:4] = finalResult[31:28];
	// assign LEDR = current_state;
	// assign LEDR = ld_counter;
	
endmodule

module selectRomOutput (
		input [2:0] romColourOutput1,
		input [2:0] romColourOutput2,
		input [1:0] selectRom,
		output reg [2:0] romColourOutput
	);
	
	always @(*)
	begin
		case (selectRom)
			2'd0: romColourOutput = 3'b000;
			2'd1: romColourOutput = romColourOutput1;
			2'd2: romColourOutput = romColourOutput2;
			default: romColourOutput = 3'b000;
		endcase
	end
	
endmodule

module selectCounter (
	    input selectCounters,
		 input [5:0] xcounter,
		 input [5:0] ycounter,
		 input [7:0] startX,
		 input [6:0] startY,
		 input [5:0] xcounterL,
		 input [5:0] ycounterL,
		 input [7:0] startXL,
		 input [6:0] startYL,
	output reg [5:0] xcounterF,
	output reg [5:0] ycounterF,
			 output reg [7:0] startXF,
		 output reg [6:0] startYF
	
	);
	
		always @(*)
	begin
		case (selectCounters)
			1'd0: begin
			xcounterF = xcounter;
			ycounterF = ycounter;
			startXF = startX;
			startYF = startY;
			end
			1'd1: begin
			xcounterF = xcounterL;
			ycounterF = ycounterL;
			startXF = startXL;
			startYF = startYL;
			end
			
			default: begin
			
			xcounterF = xcounter;
			ycounterF = ycounter;
			startXF = startX;
			startYF = startY;
			
			
			end
		endcase
	end
	
endmodule

module drawNumberOutput (
		 input clk,
		 input draw,
		 input v0flag, v1flag, v0erase, v1erase,
		 input [7:0] startXWire,
		 input [6:0] startYWire,
		 input [12:0] startAddress,
		 output reg [5:0] xcounter,
		 output reg [5:0] ycounter,
		 output reg [7:0] startX,
		 output reg [6:0] startY,
		 output reg [12:0] addressCounter,
		 output reg donedrawv0,
		  output reg donedrawv1,
		  output reg doneerasev0,
		  output reg doneerasev1
);

reg firstrow = 1'b1;

always@(posedge clk) begin

	if (draw) begin

		startX <= startXWire;
		startY <= startYWire;

		if (xcounter != 6'd15) begin 
		
			if (firstrow) begin
				if (!v0erase && !v1erase) addressCounter <=  startAddress;
				xcounter <= 6'd0;
				ycounter <= 6'd0;
				firstrow <= 1'b0;
				donedrawv0 <= 1'b0;
				doneerasev0 <= 1'b0;
				doneerasev1 <= 1'b0;
				donedrawv1 <= 1'b0;
			end
			else begin
				xcounter <= xcounter + 6'd1;
				if (!v0erase && !v1erase) addressCounter <= addressCounter + 13'd1;
				donedrawv0 <= 1'b0;
				doneerasev0 <= 1'b0;
				doneerasev1 <= 1'b0;
				donedrawv1 <= 1'b0;
			end
			
		end

		else begin						
							
				if(ycounter != 6'd30) begin
					xcounter <= 6'd0;
					if (!v0erase && !v1erase) addressCounter <= addressCounter + 13'd135;
					ycounter <= ycounter + 6'd1;
					donedrawv0 <= 1'b0;
					doneerasev0 <= 1'b0;
					doneerasev1 <= 1'b0;
					donedrawv1 <= 1'b0;
				end
				else begin
					firstrow <= 1'b1;
					if (v0flag) donedrawv0 <= 1'b1;	
					if (v0erase) doneerasev0 <= 1'b1;
					if (v1erase) doneerasev1 <= 1'b1;
					if (v1flag) donedrawv1 <= 1'b1;
				end		
				
		end
			
	end
	else begin // draw = 1'b0; 
				firstrow <= 1'b1;
				xcounter <= 6'd0;
				donedrawv0 <= 1'b0;
				doneerasev0 <= 1'b0;
				doneerasev1 <= 1'b0;
				donedrawv1 <= 1'b0;
				ycounter <= 6'd0;
	
	end
	
	
		
end

endmodule

module drawLetterOutput (
		 input clk,
		 input drawLetter,
		 input v0flag, v1flag, v0erase, v1erase,
		 input [7:0] startXWire,
		 input [6:0] startYWire,
		 input [12:0] startAddress,
		 output reg [5:0] xcounterL,
		 output reg [5:0] ycounterL,
		 output reg [7:0] startXL,
		 output reg [6:0] startYL,
		 output reg [12:0] addressCounterLetters,
		 output reg donedrawv0L,
		  output reg donedrawv1L,
		  output reg doneerasev0L,
		  output reg doneerasev1L
);

reg firstrow = 1'b1;

always@(posedge clk) begin

	if (drawLetter) begin

		startXL <= startXWire;
		startYL <= startYWire;

		if (xcounterL != 6'd15) begin 
		
			if (firstrow) begin
				if (!v0erase && !v1erase) addressCounterLetters <=  startAddress;
				xcounterL <= 6'd0;
				ycounterL <= 6'd0;
				firstrow <= 1'b0;
				donedrawv0L <= 1'b0;
				doneerasev0L <= 1'b0;
				doneerasev1L <= 1'b0;
				donedrawv1L <= 1'b0;
			end
			else begin
				xcounterL <= xcounterL + 6'd1;
				if (!v0erase && !v1erase) addressCounterLetters <= addressCounterLetters + 13'd1;
				donedrawv0L <= 1'b0;
				doneerasev0L <= 1'b0;
				doneerasev1L <= 1'b0;
				donedrawv1L <= 1'b0;
			end
			
		end

		else begin						
							
				if(ycounterL != 6'd30) begin
					xcounterL <= 6'd0;
					if (!v0erase && !v1erase) addressCounterLetters <= addressCounterLetters + 13'd75;
					ycounterL <= ycounterL + 6'd1;
					donedrawv0L <= 1'b0;
					doneerasev0L <= 1'b0;
					doneerasev1L <= 1'b0;
					donedrawv1L <= 1'b0;
				end
				else begin
					firstrow <= 1'b1;
					if (v0flag) donedrawv0L <= 1'b1;	
					if (v0erase) doneerasev0L <= 1'b1;
					if (v1erase) doneerasev1L <= 1'b1;
					if (v1flag) donedrawv1L <= 1'b1;
				end		
				
		end
			
	end
	else begin // draw = 1'b0; 
				firstrow <= 1'b1;
				xcounterL <= 6'd0;
				donedrawv0L <= 1'b0;
				doneerasev0L <= 1'b0;
				doneerasev1L <= 1'b0;
				donedrawv1L <= 1'b0;
				ycounterL <= 6'd0;
	
	end
	
	
		
end

endmodule


module datapath (
		 input clk, resetn,
		 input resetFlag, load, displayV0, 
		 displayV1, drawV0, eraseV0, drawV0E, eraseV0E, drawV1E, eraseV1E, eraseV1, drawV1, setSum, 
		 ld_enc_sum, ld_enc_results_1,
		 ld_enc_results_2, ld_enc_v0, ld_enc_v1,
		 ld_dec_sum, ld_dec_results_1,
		 ld_dec_results_2, ld_dec_v0, ld_dec_v1, enableRateDivider,
		 indexv0, indexv1,
		 input [3:0] indexcounter,
		 input [3:0] ld_counter,
		 input [7:0] received_data,
		 output reg [31:0] finalResult,
       output reg draw, drawLetter, v0flag, v0erase, v1erase, v1flag, skip, selectCounters,
		 output reg [1:0] selectRom,
		 output reg [7:0] startXWire,
		 output reg [6:0] startYWire,
		 output reg [12:0] startAddress,
		 output [3:0] frameOutput
);

reg [31:0] sum = 32'd0;
reg [31:0] result1, result2, 
result3, result4, 
result5, result6,
k0, k1, k2, k3, v0, v1;
reg [3:0] v0_encrypted_data; 
reg [3:0] v1_encrypted_data; 

localparam delta = 32'h9e3779b9;
 wire enableWire;
 wire [25:0] rateDividerOutput;

    // Registers 
    always@(posedge clk) begin
	 
        if(received_data == 8'h76) begin
            v0 <= 32'd0;
				v1 <= 32'd0;
				k0 <= 32'd0;
				k1 <= 32'd0;
				k2 <= 32'd0;
				k3 <= 32'd0;
            sum <= 32'd0; 
            result1 <= 32'd0; 
            result2 <= 32'd0;
				result3 <= 32'd0;
				result4 <= 32'd0;
				result5 <= 32'd0;
				result6 <= 32'd0;
				finalResult <= 32'd0; 
        end
		  
        else begin
		  
					draw <= 1'b0;
					drawLetter <= 1'b0;
					v0flag <= 1'b0;
					v1flag <= 1'b0;
					v0erase <= 1'b0;
					v1erase <= 1'b0;
					skip <= 1'b0;
					
				if (resetFlag) begin
					v0 <= 32'd0;
					draw <= 1'b0;
					v1 <= 32'd0;
					k0 <= 32'd0;
					k1 <= 32'd0;
					k2 <= 32'd0;
					k3 <= 32'd0;
					sum <= 32'd0; 
					result1 <= 32'd0; 
					result2 <= 32'd0;
					result3 <= 32'd0;
					result4 <= 32'd0;
					result5 <= 32'd0;
					result6 <= 32'd0;
				end
				
				if (load) begin

				    if (ld_counter == 4'd0) begin
					// loading V0
					
					if (received_data == 8'h45) begin
					// 0
						v0 <= 32'd0;
					end
					else if (received_data == 8'h16) begin
					// 1
						v0 <= 32'd1;
					end
					else if (received_data == 8'h1E) begin
					// 2
						v0 <= 32'd2;
					end
					else if (received_data == 8'h26) begin
					// 3
						v0 <= 32'd3;
					end
					else if (received_data == 8'h25) begin
					// 4
						v0 <= 32'd4;
					end
					else if (received_data == 8'h2E) begin
					// 5
						v0 <= 32'd5;
					end
					else if (received_data == 8'h36) begin
					// 6
						v0 <= 32'd6;
					end
					else if (received_data == 8'h3D) begin
					// 7
						v0 <= 32'd7;
					end
					else if (received_data == 8'h3E) begin
					// 8
						v0 <= 32'd8;
					end
					else if (received_data == 8'h46) begin
					// 9
						v0 <= 32'd9;
					end
 
     				    end

				    else if (ld_counter == 4'd1) begin
					// loading V1
					
					if (received_data == 8'h45) begin
					// 0
						v1 <= 32'd0;
					end
					else if (received_data == 8'h16) begin
					// 1
						v1 <= 32'd1;
					end
					else if (received_data == 8'h1E) begin
					// 2
						v1 <= 32'd2;
					end
					else if (received_data == 8'h26) begin
					// 3
						v1 <= 32'd3;
					end
					else if (received_data == 8'h25) begin
					// 4
						v1 <= 32'd4;
					end
					else if (received_data == 8'h2E) begin
					// 5
						v1 <= 32'd5;
					end
					else if (received_data == 8'h36) begin
					// 6
						v1 <= 32'd6;
					end
					else if (received_data == 8'h3D) begin
					// 7
						v1 <= 32'd7;
					end
					else if (received_data == 8'h3E) begin
					// 8
						v1 <= 32'd8;
					end
					else if (received_data == 8'h46) begin
					// 9
						v1 <= 32'd9;
					end
     				    end
				    
				    else if (ld_counter == 4'd2) begin
					// loading K0

					if (received_data == 8'h45) begin
					// 0
						k0 <= 32'd0;
					end
					else if (received_data == 8'h16) begin
					// 1
						k0 <= 32'd1;
					end
					else if (received_data == 8'h1E) begin
					// 2
						k0 <= 32'd2;
					end
					else if (received_data == 8'h26) begin
					// 3
						k0 <= 32'd3;
					end
					else if (received_data == 8'h25) begin
					// 4
						k0 <= 32'd4;
					end
					else if (received_data == 8'h2E) begin
					// 5
						k0 <= 32'd5;
					end
					else if (received_data == 8'h36) begin
					// 6
						k0 <= 32'd6;
					end
					else if (received_data == 8'h3D) begin
					// 7
						k0 <= 32'd7;
					end
					else if (received_data == 8'h3E) begin
					// 8
						k0 <= 32'd8;
					end
					else if (received_data == 8'h46) begin
					// 9
						k0 <= 32'd9;
					end
     				    end

				    else if (ld_counter == 4'd3) begin
					// loading K1


					if (received_data == 8'h45) begin
					// 0
						k1 <= 32'd0;
					end
					else if (received_data == 8'h16) begin
					// 1
						k1 <= 32'd1;
					end
					else if (received_data == 8'h1E) begin
					// 2
						k1 <= 32'd2;
					end
					else if (received_data == 8'h26) begin
					// 3
						k1 <= 32'd3;
					end
					else if (received_data == 8'h25) begin
					// 4
						k1 <= 32'd4;
					end
					else if (received_data == 8'h2E) begin
					// 5
						k1 <= 32'd5;
					end
					else if (received_data == 8'h36) begin
					// 6
						k1 <= 32'd6;
					end
					else if (received_data == 8'h3D) begin
					// 7
						k1 <= 32'd7;
					end
					else if (received_data == 8'h3E) begin
					// 8
						k1 <= 32'd8;
					end
					else if (received_data == 8'h46) begin
					// 9
						k1 <= 32'd9;
					end
     				    end

				    else if (ld_counter == 4'd4) begin
					// loading K2


					if (received_data == 8'h45) begin
					// 0
						k2 <= 32'd0;
					end
					else if (received_data == 8'h16) begin
					// 1
						k2 <= 32'd1;
					end
					else if (received_data == 8'h1E) begin
					// 2
						k2 <= 32'd2;
					end
					else if (received_data == 8'h26) begin
					// 3
						k2 <= 32'd3;
					end
					else if (received_data == 8'h25) begin
					// 4
						k2 <= 32'd4;
					end
					else if (received_data == 8'h2E) begin
					// 5
						k2 <= 32'd5;
					end
					else if (received_data == 8'h36) begin
					// 6
						k2 <= 32'd6;
					end
					else if (received_data == 8'h3D) begin
					// 7
						k2 <= 32'd7;
					end
					else if (received_data == 8'h3E) begin
					// 8
						k2 <= 32'd8;
					end
					else if (received_data == 8'h46) begin
					// 9
						k2 <= 32'd9;
					end
     				    end

				    else if (ld_counter == 4'd5) begin
					// loading K3


					if (received_data == 8'h45) begin
					// 0
						k3 <= 32'd0;
					end
					else if (received_data == 8'h16) begin
					// 1
						k3 <= 32'd1;
					end
					else if (received_data == 8'h1E) begin
					// 2
						k3 <= 32'd2;
					end
					else if (received_data == 8'h26) begin
					// 3
						k3 <= 32'd3;
					end
					else if (received_data == 8'h25) begin
					// 4
						k3 <= 32'd4;
					end
					else if (received_data == 8'h2E) begin
					// 5
						k3 <= 32'd5;
					end
					else if (received_data == 8'h36) begin
					// 6
						k3 <= 32'd6;
					end
					else if (received_data == 8'h3D) begin
					// 7
						k3 <= 32'd7;
					end
					else if (received_data == 8'h3E) begin
					// 8
						k3 <= 32'd8;
					end
					else if (received_data == 8'h46) begin
					// 9
						k3 <= 32'd9;
					end

     				    end

				end
				
				if (displayV0) finalResult[15:0] <= v0[15:0];
			
				if (displayV1) finalResult[31:16] <= v1[15:0];
				// for encrypted data
				// we need if (drawV0E || eraseV0E) 
				// need temp register of 4 bits to store the section of v0 
				// we are analyze and do that in a state before,
				// so have a counter in the fsm that you increment from 0 to 1 to 2 to 3 
				// in this state before and if counter is 0, you set ldflag0 to datapath
				// --> to set temp reg <= v0[16:12] 
				// if v0 == number --> same code as decrypted data
				// if v0 == letter --> need new draw signal so draw of letter 
				// doesnt happen, new start address, start x and start y wires
			
				if (indexv0) begin
									
					if (indexcounter == 4'd0) v0_encrypted_data <= v0[31:28];
					if (indexcounter == 4'd1) v0_encrypted_data <= v0[27:24];
					if (indexcounter == 4'd2) v0_encrypted_data <= v0[23:20];
					if (indexcounter == 4'd3) v0_encrypted_data <= v0[19:16];
				
				
				
					if (indexcounter == 4'd4) v0_encrypted_data <= v0[15:12];
					if (indexcounter == 4'd5) v0_encrypted_data <= v0[11:8];
					if (indexcounter == 4'd6) v0_encrypted_data <= v0[7:4];
					if (indexcounter == 4'd7) v0_encrypted_data <= v0[3:0];
				end
				
				if (drawV0E || eraseV0E) begin
						// draw <= 1'b1; 
						// draw changes based on whether it is a letter or number
						startYWire <= 7'd25;
						// startYWire changes based on whether it is a letter or number
						// for now we can keep because only testing numbers 
						if (drawV0E) begin
							//selectRom <= 2'b1; 
							// select rom will be different based on whether it was a letter or number
							v0flag <= 1'b1;
						end
						if (eraseV0E) begin
							selectRom <= 2'b0; 
							// select rom will be 0 when erasing whether it was a number of letter
							v0erase <= 1'b1;
						end
						
					if (v0_encrypted_data == 32'd0) begin
						if (!eraseV0E) selectRom <= 2'b1; 
						draw <= 1'b1; // draw will be for numbers module
						startAddress <=  13'd0;
						selectCounters <= 1'b0;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end
					
					else if (v0_encrypted_data == 32'd1) begin
						if (!eraseV0E) selectRom <= 2'b1; 
						draw <= 1'b1;
						startAddress <=  13'd15;
						selectCounters <= 1'b0;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end

					else if (v0_encrypted_data == 32'd2) begin
					   if (!eraseV0E) selectRom <= 2'b1; 
						draw <= 1'b1;
						startAddress <=  13'd30;
						selectCounters <= 1'b0;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end

					else if (v0_encrypted_data == 32'd3) begin
					   if (!eraseV0E) selectRom <= 2'b1; 
						draw <= 1'b1;
						startAddress <=  13'd45;
						selectCounters <= 1'b0;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end

					else if (v0_encrypted_data == 32'd4) begin
					   if (!eraseV0E) selectRom <= 2'b1; 
						draw <= 1'b1;
						startAddress <=  13'd60;
						selectCounters <= 1'b0;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end

					else if (v0_encrypted_data == 32'd5) begin
						if (!eraseV0E) selectRom <= 2'b1; 
						draw <= 1'b1;
						startAddress <=  13'd75;
						selectCounters <= 1'b0;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end

					else if (v0_encrypted_data == 32'd6) begin
						if (!eraseV0E) selectRom <= 2'b1; 
						draw <= 1'b1;
						startAddress <=  13'd90;
					selectCounters <= 1'b0;	
						startXWire <= 8'd15;
						skip <= 1'b0;
					end

					else if (v0_encrypted_data == 32'd7) begin
						if (!eraseV0E) selectRom <= 2'b1; 
						draw <= 1'b1;
						startAddress <=  13'd105;
					selectCounters <= 1'b0;	
						startXWire <= 8'd15;
						skip <= 1'b0;
					end

					else if (v0_encrypted_data == 32'd8) begin
						if (!eraseV0E) selectRom <= 2'b1; 
						draw <= 1'b1;
						startAddress <=  13'd120;
						selectCounters <= 1'b0;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end

					else if (v0_encrypted_data == 32'd9) begin
						if (!eraseV0E) selectRom <= 2'b1; 
						draw <= 1'b1;
						startAddress <=  13'd135;
						selectCounters <= 1'b0;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end	
					
					else if (v0_encrypted_data == 4'hA) begin
						if (!eraseV0E) selectRom <= 2'd2; 
						drawLetter <= 1'b1;
						startAddress <=  13'd0;
						selectCounters <= 1'b1;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end
					
					else if (v0_encrypted_data == 4'hB) begin
						if (!eraseV0E) selectRom <= 2'd2; 
						drawLetter <= 1'b1;
						startAddress <=  13'd15;
						selectCounters <= 1'b1;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end
					
					else if (v0_encrypted_data == 4'hC) begin
						if (!eraseV0E) selectRom <= 2'd2; 
						drawLetter <= 1'b1;
						startAddress <=  13'd30;
						selectCounters <= 1'b1;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end
					
					else if (v0_encrypted_data == 4'hD) begin
						if (!eraseV0E) selectRom <= 2'd2; 
						drawLetter <= 1'b1;
						startAddress <=  13'd45;
						selectCounters <= 1'b1;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end
					
					else if (v0_encrypted_data == 4'hE) begin
						if (!eraseV0E) selectRom <= 2'd2; 
						drawLetter <= 1'b1;
						startAddress <=  13'd60;
						selectCounters <= 1'b1;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end
					
					else if (v0_encrypted_data == 4'hF) begin
						if (!eraseV0E) selectRom <= 2'd2; 
						drawLetter <= 1'b1;
						startAddress <=  13'd75;
						selectCounters <= 1'b1;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end
					
					// else will be the letters that we will have to add later
					else skip <= 1'b1;
					
				end
	
				
				if (drawV0 || eraseV0) begin
						selectCounters <= 1'b0;
						draw <= 1'b1;
						startYWire <= 7'd25;
						if (drawV0) begin
							selectRom <= 2'b1;
							v0flag <= 1'b1;
						end
						if (eraseV0) begin
							selectRom <= 2'b0;
							v0erase <= 1'b1;
						end
						
					if (v0 == 32'd0) begin
						startAddress <=  13'd0;
						startXWire <= 8'd105;
					end
					
					if (v0 == 32'd1) begin
						startAddress <=  13'd15;
						startXWire <= 8'd105;
					end

					if (v0 == 32'd2) begin
						startAddress <=  13'd30;
						startXWire <= 8'd105;
					end

					if (v0 == 32'd3) begin
						startAddress <=  13'd45;
						startXWire <= 8'd105;
					end

					if (v0 == 32'd4) begin
						startAddress <=  13'd60;
						startXWire <= 8'd105;
					end

					if (v0 == 32'd5) begin
						startAddress <=  13'd75;
						startXWire <= 8'd105;
					end

					if (v0 == 32'd6) begin
						startAddress <=  13'd90; 
						startXWire <= 8'd105;
					end

					if (v0 == 32'd7) begin
						startAddress <=  13'd105; 
						startXWire <= 8'd105;
					end

					if (v0 == 32'd8) begin
						startAddress <=  13'd120;
						startXWire <= 8'd105;
					end

					if (v0 == 32'd9) begin
						startAddress <=  13'd135;
						startXWire <= 8'd105;
					end	
					
				end
				
				
				if (indexv1) begin
				
				
					if (indexcounter == 4'd0) v1_encrypted_data <= v0[31:28];
					if (indexcounter == 4'd1) v1_encrypted_data <= v0[27:24];
					if (indexcounter == 4'd2) v1_encrypted_data <= v0[23:20];
					if (indexcounter == 4'd3) v1_encrypted_data <= v0[19:16];
					
					if (indexcounter == 4'd4) v1_encrypted_data <= v1[15:12];
					if (indexcounter == 4'd5) v1_encrypted_data <= v1[11:8];
					if (indexcounter == 4'd6) v1_encrypted_data <= v1[7:4];
					if (indexcounter == 4'd7) v1_encrypted_data <= v1[3:0];
				end
				
				if (drawV1E || eraseV1E) begin
						// draw <= 1'b1; 
						// draw changes based on whether it is a letter or number
						startYWire <= 7'd25;
						// startYWire changes based on whether it is a letter or number
						// for now we can keep because only testing numbers 
						if (drawV1E) begin
							selectRom <= 2'b1; 
							// select rom will be different based on whether it was a letter or number
							v1flag <= 1'b1;
						end
						if (eraseV1E) begin
							selectRom <= 2'b0; 
							// select rom will be 0 when erasing whether it was a number of letter
							v1erase <= 1'b1;
						end
						
					if (v1_encrypted_data == 32'd0) begin
						draw <= 1'b1; // draw will be for numbers module
						startAddress <=  13'd0;
						startXWire <= 8'd15;
						selectCounters <= 1'b0;
						skip <= 1'b0;
					end
					
					else if (v1_encrypted_data == 32'd1) begin
						draw <= 1'b1;
						selectCounters <= 1'b0;
						startAddress <=  13'd15;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end

					else if (v1_encrypted_data == 32'd2) begin
						draw <= 1'b1;
						startAddress <=  13'd30;
						startXWire <= 8'd15;
						selectCounters <= 1'b0;
						skip <= 1'b0;
					end

					else if (v1_encrypted_data == 32'd3) begin
						draw <= 1'b1;
						startAddress <=  13'd45;
						startXWire <= 8'd15;
						selectCounters <= 1'b0;
						skip <= 1'b0;
					end

					else if (v1_encrypted_data == 32'd4) begin
						draw <= 1'b1;
						startAddress <=  13'd60;
						startXWire <= 8'd15;
						skip <= 1'b0;
						selectCounters <= 1'b0;
					end

					else if (v1_encrypted_data == 32'd5) begin
						draw <= 1'b1;
						startAddress <=  13'd75;
						selectCounters <= 1'b0;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end

					else if (v1_encrypted_data == 32'd6) begin
						draw <= 1'b1;
						startAddress <=  13'd90; 
						selectCounters <= 1'b0;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end

					else if (v1_encrypted_data == 32'd7) begin
						draw <= 1'b1;
						startAddress <=  13'd105;
					selectCounters <= 1'b0;	
						startXWire <= 8'd15;
						skip <= 1'b0;
					end

					else if (v1_encrypted_data == 32'd8) begin
						draw <= 1'b1;
						startAddress <=  13'd120;
						startXWire <= 8'd15;
						selectCounters <= 1'b0;
						skip <= 1'b0;
					end

					else if (v1_encrypted_data == 32'd9) begin
						draw <= 1'b1;
						startAddress <=  13'd135;
						selectCounters <= 1'b0;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end	
					
					else if (v1_encrypted_data == 4'hA) begin
						if (!eraseV0E) selectRom <= 2'd2; 
						drawLetter <= 1'b1;
						startAddress <=  13'd0;
						selectCounters <= 1'b1;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end
					
					else if (v1_encrypted_data == 4'hB) begin
						if (!eraseV0E) selectRom <= 2'd2; 
						drawLetter <= 1'b1;
						startAddress <=  13'd15;
						selectCounters <= 1'b1;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end
					
					else if (v1_encrypted_data == 4'hC) begin
						if (!eraseV0E) selectRom <= 2'd2; 
						drawLetter <= 1'b1;
						startAddress <=  13'd30;
						selectCounters <= 1'b1;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end
					
					else if (v1_encrypted_data == 4'hD) begin
						if (!eraseV0E) selectRom <= 2'd2; 
						drawLetter <= 1'b1;
						startAddress <=  13'd45;
						selectCounters <= 1'b1;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end
					
					else if (v1_encrypted_data == 4'hE) begin
						if (!eraseV0E) selectRom <= 2'd2; 
						drawLetter <= 1'b1;
						startAddress <=  13'd60;
						selectCounters <= 1'b1;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end
					
					else if (v1_encrypted_data == 4'hF) begin
						if (!eraseV0E) selectRom <= 2'd2; 
						drawLetter <= 1'b1;
						startAddress <=  13'd75;
						selectCounters <= 1'b1;
						startXWire <= 8'd15;
						skip <= 1'b0;
					end
					
					// else will be the letters that we will have to add later
					else skip <= 1'b1;
					
				end
				
				
				
				if (drawV1 || eraseV1) begin
				selectCounters <= 1'b0;
						draw <= 1'b1;
						startYWire <= 7'd25;
						
						if (drawV1) begin
							selectRom <= 2'b1;
							v1flag <= 1'b1;
						end
						if (eraseV1) begin
							selectRom <= 2'b0;
							v1erase <= 1'b1;
						end
						
					if (v1 == 32'd0) begin
						startAddress <=  13'd0;
						startXWire <= 8'd105;
					end
					
					if (v1 == 32'd1) begin
						startAddress <=  13'd15;
						startXWire <= 8'd105;
					end

					if (v1 == 32'd2) begin
						startAddress <=  13'd30;
						startXWire <= 8'd105;
					end

					if (v1 == 32'd3) begin
						startAddress <=  13'd45;
						startXWire <= 8'd105;
					end

					if (v1 == 32'd4) begin
						startAddress <=  13'd60;
						startXWire <= 8'd105;
					end

					if (v1 == 32'd5) begin
						startAddress <=  13'd75;
						startXWire <= 8'd105;
					end

					if (v1 == 32'd6) begin
						startAddress <=  13'd90;
						startXWire <= 8'd105;
					end

					if (v1 == 32'd7) begin
						startAddress <=  13'd105;
						startXWire <= 8'd105;
					end

					if (v1 == 32'd8) begin
						startAddress <=  13'd120;
						startXWire <= 8'd105;
					end

					if (v1 == 32'd9) begin
						startAddress <=  13'd135;
						startXWire <= 8'd105;
					end	
					
				end
				
				if(ld_enc_sum)
                sum <= sum + delta; 
	
            if(ld_enc_results_1)  begin
                result1 <= (v1 << 4) + k0;
					 result2 <= v1 + sum;
					 result3 <= (v1 >> 5) + k1;
					 end 
					 
			   if(ld_enc_results_2)  begin
                result4 <= (v0 << 4) + k2;
					 result5 <= v0 + sum;
					 result6 <= (v0 >> 5) + k3; 
					 end 
					 					 
            if(ld_enc_v0) begin
                v0 <= v0 + (result1 ^ result2 ^ result3);
					 end
										
				if(ld_enc_v1) begin
                v1 <= v1 + (result4 ^ result5 ^ result6);
					 end		 
					  
				if (setSum) sum <= 32'hC6EF3720;	 
				
				if (ld_dec_sum) begin
					 sum <= sum - delta;
					 end
					 
				if(ld_dec_results_1) begin
                result1 <= (v0 << 4) + k2;
					 result2 <= v0 + sum;
					 result3 <= (v0 >> 5) + k3; 	 
					end 
					
				if(ld_dec_results_2)  begin
                result4 <= (v1 << 4) + k0;
					 result5 <= v1 + sum;
					 result6 <= (v1 >> 5) + k1;
					 end 
					 
				if(ld_dec_v1) begin
                v1 <= v1 - (result1 ^ result2 ^ result3);
					 end	
					 
				if(ld_dec_v0) begin
                v0 <= v0 - (result4 ^ result5 ^ result6);
					 end			
			end
    end
	 
	 RateDivider r0 (enableRateDivider, clk, 26'd833334, rateDividerOutput, resetn);
	 
	 assign enableWire = (rateDividerOutput == 26'd0)? 1'b1:1'b0;
	  
	 DisplayCounter d0 (enableWire, clk, frameOutput, resetn);

endmodule

module RateDivider (input enable, input Clock, input [25:0] D, output reg [25:0] Q, input reset);
	
	always @ (posedge Clock, negedge reset)
		begin
				
			if (reset == 0)
				Q <= 26'd0;
				
			else if (enable == 1'b0 || (Q == 26'd0)) 
				Q <= D; 
				
			else 
			
				Q <= Q - 26'd1; 		
		end
			
endmodule 

module DisplayCounter (input Enable, Clock, output reg [3:0] Q, input reset);
	
	always @ (posedge Clock)
		begin
			
			if (reset == 0) Q <= 4'd0; 
			
			else if (Q == 4'd15) Q <= 4'd0;
			
			else if (Enable == 1'b1) Q <= Q + 4'b0001;
				
		end
	
endmodule 

module control (
	 input clk, skip, 		donedrawv0L,
		 donedrawv1L,
		  doneerasev0L,
		  doneerasev1L, input [3:0] frameOutput,
	 
	 output reg resetFlag, load, drawV0, eraseV0, eraseV1, drawV1,
	 drawV0E, eraseV0E, drawV1E, eraseV1E,
	 displayV0, displayV1, 
	 setSum,
	  
	 ld_enc_sum, ld_enc_results_1,
	 ld_enc_results_2, ld_enc_v0, ld_enc_v1,
	 
	 ld_dec_sum, ld_dec_results_1,
	 ld_dec_results_2, ld_dec_v0, ld_dec_v1,
	 plotOutput, enableRateDivider, indexv0, indexv1,
	 
	 output reg [3:0] ld_counter,	 
	 input [7:0] received_data,
	 input received_data_en, donedrawv0, doneerasev0, doneerasev1, donedrawv1,
	 output reg [3:0] /*[2:0]*/indexcounter//,
	// output reg [6:0] current_state
);

    reg [6:0] current_state, next_state; 
    reg [5:0] counter = 6'd0;
	 
	 reg ldcountFlag = 1'b0;
	 reg spcpressed = 1'b0;

	  
    localparam  LOAD              = 7'd0,
					 LOAD_WAIT         = 7'd1,
		          WAIT_FOR_ENCRYPT  = 7'd2,
					 E_SUM             = 7'd3,
					 E_RESULTS_1       = 7'd4,
					 E_V0              = 7'd5,
					 E_RESULTS_2       = 7'd6,
					 E_V1              = 7'd7,
					 E_DISPLAY_V0      = 7'd8,
					 E_INDEX_V0        = 7'd25,
					 E_DRAW_V0         = 7'd26,
					 E_DRAW_V0_WAIT    = 7'd27,
					 E_ERASE_V0        = 7'd28,
					 E_DISPLAY_V1      = 7'd9,
					 E_INDEX_V1        = 7'd29,
					 E_DRAW_V1         = 7'd30,
					 E_DRAW_V1_WAIT    = 7'd31,
					 E_ERASE_V1        = 7'd32,
					 WAIT_FOR_DECRYPT  = 7'd10,
					 D_RESULTS_1       = 7'd11,
					 D_V1              = 7'd12,
					 D_RESULTS_2       = 7'd13,
					 D_V0              = 7'd14,
					 D_SUM             = 7'd15,
					 D_DISPLAY_V0      = 7'd16,
					 D_DRAW_V0         = 7'd17,
					 D_DRAW_V0_WAIT    = 7'd18,
					 D_ERASE_V0        = 7'd19,
					 D_DISPLAY_V1      = 7'd20,
					 D_DRAW_V1         = 7'd21,
					 D_DRAW_V1_WAIT    = 7'd22,
					 D_ERASE_V1        = 7'd23,
					 FINAL             = 7'd24;
    
	
	    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
								 
					 LOAD: next_state = (received_data == 8'h5A) ? LOAD_WAIT : LOAD;
						
					 LOAD_WAIT: next_state = (received_data == 8'h5A) ? LOAD_WAIT : WAIT_FOR_ENCRYPT;

					 WAIT_FOR_ENCRYPT: next_state  = (received_data == 8'h24) ? E_SUM: WAIT_FOR_ENCRYPT;
					 
					 E_SUM: next_state = E_RESULTS_1;
					 
					 E_RESULTS_1: next_state = E_V0;
					 
					 E_V0: next_state = E_RESULTS_2; 
					 
					 E_RESULTS_2: next_state = E_V1;
					 
					 E_V1: next_state = (counter == 6'd32) ? E_DISPLAY_V0: E_SUM;
					 	 
					 E_DISPLAY_V0: next_state = E_INDEX_V0;	 
					 
					 E_INDEX_V0: next_state = (indexcounter == 4'd8/*indexcounter == 3'd4*/) ? E_DISPLAY_V1 : E_DRAW_V0;
					 
					 E_DRAW_V0: begin
							if (!skip) next_state = (donedrawv0 || donedrawv0L) ? E_DRAW_V0_WAIT : E_DRAW_V0;
							else next_state = E_INDEX_V0;
					 end
					 
					 E_DRAW_V0_WAIT: next_state = (frameOutput == 4'd15) ? E_ERASE_V0 : E_DRAW_V0_WAIT;
					  
					 E_ERASE_V0: next_state = (doneerasev0 || doneerasev0L) ? E_INDEX_V0 : E_ERASE_V0;
						 
					 E_DISPLAY_V1: next_state = (received_data == 8'h21) ?  E_INDEX_V1 : E_DISPLAY_V1; // it was just next_state = E_INDEX_V1;, now only if they press C it will continue 
					 
					 E_INDEX_V1: next_state = (indexcounter == 4'd8 /*indexcounter == 3'd4*/) ?  WAIT_FOR_DECRYPT : E_DRAW_V1;
					 
					 E_DRAW_V1:  begin
							if (!skip) next_state = (donedrawv1 || donedrawv1L) ? E_DRAW_V1_WAIT : E_DRAW_V1;
							else next_state = E_INDEX_V1;
					 end
					 
					 E_DRAW_V1_WAIT: next_state = (frameOutput == 4'd15) ? E_ERASE_V1 : E_DRAW_V1_WAIT;
					 
					 E_ERASE_V1: next_state = (doneerasev1 || doneerasev1L) ? E_INDEX_V1 : E_ERASE_V1;
					 
					 WAIT_FOR_DECRYPT: next_state = (received_data == 8'h23) ? D_RESULTS_1: WAIT_FOR_DECRYPT;
					 
					 D_RESULTS_1: next_state = D_V1;
					 
					 D_V1: next_state = D_RESULTS_2; 
					 
					 D_RESULTS_2: next_state = D_V0;
					 
					 D_V0: next_state = D_SUM;
					 
					 D_SUM: next_state = (counter == 6'd32) ? D_DISPLAY_V0: D_RESULTS_1;
					 
					 D_DISPLAY_V0: next_state = D_DRAW_V0/*D_DISPLAY_V1*/;
					 
					 D_DRAW_V0: next_state = (donedrawv0) ? D_DRAW_V0_WAIT/*D_DISPLAY_V1*/ : D_DRAW_V0;
					 
					 D_DRAW_V0_WAIT: next_state = (frameOutput == 4'd15) ? D_ERASE_V0 : D_DRAW_V0_WAIT;
					  
					 D_ERASE_V0: next_state = (doneerasev0) ? D_DISPLAY_V1 : D_ERASE_V0;
					 
					 D_DISPLAY_V1: next_state = (received_data == 8'h21) ? D_DRAW_V1 : D_DISPLAY_V1; // it was just next_state = D_DRAW_V1;, now only if they press C it will continue 
					 
					 D_DRAW_V1: next_state = (donedrawv1) ? D_DRAW_V1_WAIT : D_DRAW_V1;
					 
					 D_DRAW_V1_WAIT: next_state = (frameOutput == 4'd15) ? D_ERASE_V1 : D_DRAW_V1_WAIT;
					 
					 D_ERASE_V1: next_state = (doneerasev1) ? FINAL : D_ERASE_V1;
					 
					 FINAL: next_state = LOAD;

            default: next_state = LOAD;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0

		  load = 1'b0;
		  displayV0 = 1'b0;
		  displayV1 = 1'b0;
		  
		  drawV0 = 1'b0;
		  eraseV0 = 1'b0;
		  eraseV1 = 1'b0;
		  drawV1 = 1'b0;
		  
		  drawV0E = 1'b0;
		  eraseV0E = 1'b0;
		  drawV1E = 1'b0;
		  eraseV1E = 1'b0;
		  
		  plotOutput = 1'b0;
		  enableRateDivider = 1'b0;
		  
		  ld_enc_sum = 1'b0;
		  ld_enc_results_1 = 1'b0;
		  ld_enc_results_2 = 1'b0;
		  ld_enc_v0 = 1'b0;
		  ld_enc_v1 = 1'b0;
		  
		  ld_dec_sum = 1'b0;
		  ld_dec_results_1 = 1'b0;
		  ld_dec_results_2 = 1'b0;
		  ld_dec_v0 = 1'b0;
		  ld_dec_v1 = 1'b0;

		  resetFlag = 1'b0;
		  setSum = 1'b0;
		  
		   indexv0 = 1'b0;
			indexv1 = 1'b0;

        case (current_state)
		
				LOAD: begin
					 load = 1'b1;
					 end
	 
				E_SUM: begin
				    ld_enc_sum = 1'b1;					 
					 end
					 
				E_RESULTS_1: begin
					 ld_enc_results_1 = 1'b1;
					 end
					 
				E_V0: begin
					 ld_enc_v0 = 1'b1;
					 end
					 
				E_RESULTS_2: begin
					 ld_enc_results_2 = 1'b1;
					 end
					 
				E_V1: begin
					 ld_enc_v1 = 1'b1;
					 end
					 
				E_DISPLAY_V0: begin
					 displayV0 = 1'b1;
					 end
					 
				E_INDEX_V0: begin
					indexv0 = 1'b1;				
					end
				
				E_DRAW_V0: begin
					 drawV0E = 1'b1;
					 plotOutput = 1'b1;
					 end
					 
			   E_DRAW_V0_WAIT: begin
					enableRateDivider = 1'b1;
					end
				
				E_ERASE_V0: begin
					eraseV0E = 1'b1;
					plotOutput = 1'b1;
					end
					
					
					
					
					
				E_DISPLAY_V1: begin
					 displayV1 = 1'b1;
					 end
					 
				E_INDEX_V1: begin
					indexv1 = 1'b1;				
					end
				
				E_DRAW_V1: begin
					 drawV1E = 1'b1;
					 plotOutput = 1'b1;
					 end
					 
			   E_DRAW_V1_WAIT: begin
					enableRateDivider = 1'b1;
					end
				
				E_ERASE_V1: begin
					eraseV1E = 1'b1;
					plotOutput = 1'b1;
					end
					 
					 
					 
					 
					 
					 
					 
					 
					 
			   WAIT_FOR_DECRYPT: begin
					 setSum = 1'b1;
					 displayV0 = 1'b1;
					 displayV1 = 1'b1;
					 end	 
	 
				D_RESULTS_1: begin
					 ld_dec_results_1 = 1'b1;
					 end
					 
				D_V1: begin
					 ld_dec_v1 = 1'b1;
					 end
					 
			   D_RESULTS_2: begin
					 ld_dec_results_2 = 1'b1;
					 end
				
				D_V0: begin
					 ld_dec_v0 = 1'b1;
					 end
				
				D_SUM: begin
				    ld_dec_sum = 1'b1;					 
					 end	 
					 
				D_DISPLAY_V0: begin
					 displayV0 = 1'b1;
					 end
				
				D_DRAW_V0: begin
					 drawV0 = 1'b1;
					 plotOutput = 1'b1;
					 end
					 
				D_DRAW_V0_WAIT: begin
					enableRateDivider = 1'b1;
					end
				
				D_ERASE_V0: begin
					eraseV0 = 1'b1;
					plotOutput = 1'b1;
					end
				
				D_DISPLAY_V1: begin
					 displayV1 = 1'b1;
					 end
					 
				D_DRAW_V1: begin
					 drawV1 = 1'b1;
					 plotOutput = 1'b1;
					 end
					 
				D_DRAW_V1_WAIT: begin
					enableRateDivider = 1'b1;
					end
					
				D_ERASE_V1: begin
					eraseV1 = 1'b1;
					plotOutput = 1'b1;
					end
				
				FINAL: begin
					resetFlag = 1'b1;
					// plotOutput = 1'b1;
					end
           
        // default: don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
	
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(received_data == 8'h76)
            //current_state <= FINAL;
				current_state <= LOAD;
        else begin
            current_state <= next_state;
				
				if (current_state == LOAD)
		      begin
				 indexcounter <= /*3*/4'd0;
				 if (received_data_en && received_data == 8'h29 && ldcountFlag == 1'b0 && spcpressed == 1'b0) begin
					ld_counter <= ld_counter + 4'd1;
					ldcountFlag <= 1'b1;
					spcpressed = 1'b1;
					end
				 else if (received_data_en && received_data == 8'h29 && ldcountFlag == 1'b1) ldcountFlag <= 1'b0; 
				 // for the break code ending with space comes again, you reset ldcountflag
				 
				 else if (received_data_en && received_data != 8'h29 && received_data != 8'hF0) spcpressed <= 1'b0; 
				 // for when some other code other than break code and space code comes, you reset spcpressed
				 
			   end

				if (current_state == E_SUM)
		      begin
				  counter <= counter + 6'd1;
			   end
				
				if (current_state == D_RESULTS_1)
		      begin
				  counter <= counter + 6'd1;
			   end
				
				if (current_state == E_INDEX_V0)
		      begin
				  indexcounter <= indexcounter + /*3*/4'd1;
			   end
				
				if (current_state == E_INDEX_V1)
		      begin
				  indexcounter <= indexcounter + /*3*/4'd1;
			   end
				
				if (current_state == E_DISPLAY_V0 || current_state == E_DISPLAY_V1)
		      begin
				  indexcounter <= /*3*/4'd0;
			   end
				
				if (current_state == WAIT_FOR_ENCRYPT)
		      begin
				  counter <= 6'd0;
				  indexcounter <= /*3*/4'd0;
			   end
				
				if (current_state == WAIT_FOR_DECRYPT)
		      begin
				  counter <= 6'd0;
				  indexcounter <= /*3*/4'd0;
			   end
				
				if (current_state == FINAL)
		      begin
				  ld_counter <= 4'd0;
			   end
		  end
    end // state_FFS

endmodule



module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule