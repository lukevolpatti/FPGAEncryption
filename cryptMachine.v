`timescale 1ns / 1ns // `timescale time_unit/time_precision
module cryptMachine (
input [9:0] SW,
input [2:0] KEY,
input CLOCK_50,
inout PS2_CLK, PS2_DAT, 
output [6:0] HEX0,
HEX1, HEX2, HEX3, HEX4, HEX5,
output [9:0] LEDR
);

	wire [31:0] finalResult;
	wire [7:0] received_data;
	wire received_data_en;
	wire load, displayV0, displayV1,
	ld_enc_sum, ld_enc_results_1, ld_enc_results_2, ld_enc_v0, ld_enc_v1,
	ld_dec_sum, ld_dec_results_1, ld_dec_results_2, ld_dec_v0, ld_dec_v1,
	setSum, resetFlag;
	wire [3:0] ld_counter;

	PS2_Controller k0 (
		.CLOCK_50(CLOCK_50),
		.reset(~KEY[0]),
		.PS2_CLK(PS2_CLK),					
		.PS2_DAT(PS2_DAT),					
		.received_data(received_data),
		.received_data_en(received_data_en) // If 1 - new data (NOTE: DOES NOT MEAN DIFFERENT DATA) has been received
	);
	
	datapath d0 (
		.clk(CLOCK_50), 		
      .load(load), .displayV0(displayV0), .displayV1(displayV1),
		
		.ld_enc_sum(ld_enc_sum), .ld_enc_results_1(ld_enc_results_1),
		.ld_enc_results_2(ld_enc_results_2), .ld_enc_v0(ld_enc_v0), .ld_enc_v1(ld_enc_v1),
		
		.ld_dec_sum(ld_dec_sum), .ld_dec_results_1(ld_dec_results_1),
		.ld_dec_results_2(ld_dec_results_2), .ld_dec_v0(ld_dec_v0), .ld_dec_v1(ld_dec_v1),
		
		.finalResult(finalResult),
		.resetFlag(resetFlag),
		.received_data(received_data),
		.setSum(setSum),
		.ld_counter(ld_counter)
	);
	
	control c0 (
		 .clk(CLOCK_50),
       .load(load), .displayV0(displayV0), .displayV1(displayV1),
		 
		 .ld_enc_sum(ld_enc_sum), .ld_enc_results_1(ld_enc_results_1),
		 .ld_enc_results_2(ld_enc_results_2), .ld_enc_v0(ld_enc_v0), .ld_enc_v1(ld_enc_v1),
		 
		 .ld_dec_sum(ld_dec_sum), .ld_dec_results_1(ld_dec_results_1),
		 .ld_dec_results_2(ld_dec_results_2), .ld_dec_v0(ld_dec_v0), .ld_dec_v1(ld_dec_v1),
		 
		 .resetFlag(resetFlag),
		 .setSum(setSum),
		 
	    .received_data(received_data),
		 .ld_counter(ld_counter),
		 .received_data_en(received_data_en)
	);
	
	hex_decoder H0(finalResult[3:0],HEX0); 
	hex_decoder H1(finalResult[7:4],HEX1);
	hex_decoder H2(finalResult[11:8],HEX2);
	
	hex_decoder H3(finalResult[19:16],HEX3);
	hex_decoder H4(finalResult[23:20],HEX4);
	hex_decoder H5(finalResult[27:24],HEX5);
	
	// assign LEDR[3:0] = finalResult[15:12];
	// assign LEDR[7:4] = finalResult[31:28];
	
	assign LEDR = ld_counter;
	
endmodule


module datapath (
		 input clk, resetn,		
		 input [9:0] data_in,
		 input ld_v0, ld_v1, ld_k0, ld_k1, 
		 ld_k2, ld_k3, displayV0, displayV1,
		 ld_enc_sum, ld_enc_results_1,
		 ld_enc_results_2, ld_enc_v0, ld_enc_v1,
		 ld_dec_sum, ld_dec_results_1,
		 ld_dec_results_2, ld_dec_v0, ld_dec_v1, load,
		 input [3:0] ld_counter,
		 resetFlag, setSum, go,
		 input [7:0] received_data,
		 output reg [31:0] finalResult
);

reg [31:0] sum = 32'd0;
reg [31:0] result1, result2, 
result3, result4, 
result5, result6,
k0, k1, k2, k3, v0, v1;

localparam delta = 32'h9e3779b9;

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
		  
				if (resetFlag) begin
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

endmodule

module control (
	 input clk,
    input resetn,
	 input [7:0] received_data,
	 input received_data_en,
	 output reg  load, displayV0, displayV1,
	 ld_enc_sum, ld_enc_results_1,
	 ld_enc_results_2, ld_enc_v0, ld_enc_v1,
	 ld_dec_sum, ld_dec_results_1,
	 ld_dec_results_2, ld_dec_v0, ld_dec_v1,
	 resetFlag, setSum,
	 output reg [3:0] ld_counter
);

    reg [5:0] current_state, next_state; 
     reg [5:0] counter = 6'd0;
	  	reg ldcountFlag = 1'b0;
		reg spcpressed = 1'b0;

	  
    localparam  LOAD              = 5'd0,
					 LOAD_WAIT         = 5'd1,
		          WAIT_FOR_ENCRYPT  = 5'd2,
					 E_SUM             = 5'd3,
					 E_RESULTS_1       = 5'd4,
					 E_V0              = 5'd5,
					 E_RESULTS_2       = 5'd6,
					 E_V1              = 5'd7,
					 E_DISPLAY_V0      = 5'd8,
					 E_DISPLAY_V1      = 5'd9,
					 WAIT_FOR_DECRYPT  = 5'd10,
					 D_RESULTS_1       = 5'd11,
					 D_V1              = 5'd12,
					 D_RESULTS_2       = 5'd13,
					 D_V0              = 5'd14,
					 D_SUM             = 5'd15,
					 D_DISPLAY_V0      = 5'd16,
					 D_DISPLAY_V1      = 5'd17,
					 FINAL             = 5'd18;
    
	
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
					 	 
					 E_DISPLAY_V0: next_state = E_DISPLAY_V1;
					 
					 E_DISPLAY_V1: next_state = WAIT_FOR_DECRYPT;
					 
					 WAIT_FOR_DECRYPT: next_state = (received_data == 8'h23) ? D_RESULTS_1: WAIT_FOR_DECRYPT;
					 
					 D_RESULTS_1: next_state = D_V1;
					 
					 D_V1: next_state = D_RESULTS_2; 
					 
					 D_RESULTS_2: next_state = D_V0;
					 
					 D_V0: next_state = D_SUM;
					 
					 D_SUM: next_state = (counter == 6'd32) ? D_DISPLAY_V0: D_RESULTS_1;
					 
					 D_DISPLAY_V0: next_state = D_DISPLAY_V1;
					 
					 D_DISPLAY_V1: next_state = FINAL;
					 
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
				
				E_DISPLAY_V1: begin
					 displayV1 = 1'b1;
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
				
				D_DISPLAY_V1: begin
					 displayV1 = 1'b1;
					 end
				
				FINAL: begin
					resetFlag = 1'b1;
					end
           
        // default: don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
	
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(received_data == 8'h76)
            current_state <= FINAL;
        else begin
            current_state <= next_state;
				
				if (current_state == LOAD)
		      begin
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
				
				if (current_state == WAIT_FOR_ENCRYPT)
		      begin
				  counter <= 6'd0;
			   end
				
				if (current_state == WAIT_FOR_DECRYPT)
		      begin
				  counter <= 6'd0;
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

