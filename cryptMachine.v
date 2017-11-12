module cryptMachine (
input [9:0] SW,
input [1:0] KEY,
input CLOCK_50,
output [6:0] HEX0,
HEX1, HEX2, HEX3, HEX4, HEX5,
output [9:0] LEDR
);

	wire [31:0] finalResult;
	wire ld_sum_enc, ld_results, ld_v_enc_results, setSum, ld_v_dec_results,
	ld_v0, ld_v1, ld_k0, ld_k1, ld_k2, ld_k3, displayV0, displayV1, ld_sum_dec,
	resultFlag, modSum;
	
	datapath d0 (
		.clk(CLOCK_50), 
		.resetn(KEY[0]),
		.ld_sum_enc(ld_sum_enc), .ld_sum_dec(ld_sum_dec),
		.ld_results(ld_results),
		.ld_v_enc_results(ld_v_enc_results), .ld_v_dec_results(ld_v_dec_results),
		.ld_v0(ld_v0), .ld_v1(ld_v1), .ld_k0(ld_k0), .ld_k1(ld_k1), 
		.ld_k2(ld_k2), .ld_k3(ld_k3), 
		.displayV0(displayV0), .displayV1(displayV1),
		.data_in(SW[9:0]),
		.finalResult(finalResult),
		.resetFlag(resultFlag),
		.setSum(setSum),
		.modSum(modSum)
	);
	
	control c0 (
	
		 .clk(CLOCK_50),
       .resetn(KEY[0]),
       .go(~KEY[1]),
		 .ld_sum_enc(ld_sum_enc), .ld_sum_dec(ld_sum_dec), .ld_results(ld_results),
		 .ld_v_enc_results(ld_v_enc_results), .ld_v_dec_results(ld_v_dec_results), 
		 .displayV0(displayV0), .displayV1(displayV1),
	 	 .ld_v0(ld_v0), .ld_v1(ld_v1), .ld_k0(ld_k0), .ld_k1(ld_k1), 
		 .ld_k2(ld_k2), .ld_k3(ld_k3),
	    .resetFlag(resultFlag), .setSum(setSum), .modSum(modSum)
	);
	
	hex_decoder H0(finalResult[3:0],HEX0); 
	hex_decoder H1(finalResult[7:4],HEX1);
	hex_decoder H2(finalResult[11:8],HEX2);
	hex_decoder H3(finalResult[19:16],HEX3);
	hex_decoder H4(finalResult[23:20],HEX4);
	hex_decoder H5(finalResult[27:24],HEX5);
	
	//assign LEDR = finalResult [31:24];
	assign LEDR[3:0] = finalResult[15:12];
	assign LEDR[7:4] = finalResult[31:28];
	
	
endmodule


module datapath (
input clk, resetn,
input ld_sum_enc, ld_sum_dec, ld_results,
ld_v_enc_results, ld_v_dec_results,
ld_v0, ld_v1, ld_k0, ld_k1, ld_k2, ld_k3,
displayV0, displayV1, resetFlag, setSum, modSum,
input [9:0] data_in,
output reg [31:0] finalResult
);

reg [31:0] sum = 32'd0;
reg [31:0] result1, result2, 
result3, result4, 
result5, result6,
k0, k1, k2, k3, v0, v1;

localparam delta = 32'h9e3779b9,
			  // max_u_int = 32'd4294967296;
			  max_u_int = 33'd4294967296;
			  /*k1 = 32'd32;
			  k2 = 32'd324;
			  k3 = 32'd1232;
			  k4 = 32'd54;*/

    // Registers 
    always@(posedge clk) begin
	 
        if(!resetn) begin
            v0 <= 32'd0;
				v1 <= 32'd0;
            sum <= 32'd0; 
            result1 <= 32'd0; 
            result2 <= 32'd0;
				result3 <= 32'd0;
				result4 <= 32'd0;
				result5 <= 32'd0;
				result6 <= 32'd0;
        end
        else begin
		  
				if (resetFlag) begin
					v0 <= 32'd0;
					v1 <= 32'd0;
					sum <= 32'd0; 
					result1 <= 32'd0; 
					result2 <= 32'd0;
					result3 <= 32'd0;
					result4 <= 32'd0;
					result5 <= 32'd0;
					result6 <= 32'd0;
				end
				
				if (setSum) sum <= 32'hC6EF3720;
				
				if (modSum) begin 
				
					if (sum[31] == 1'b1) sum[31] <= 1'b0;
				
				end
				
            if(ld_sum_enc)
                sum <= sum + delta; 
	
            if(ld_results)  begin
                result1 <= (v1 << 4) + k0;
					 result2 <= v1 + sum;
					 result3 <= (v1 >> 5) + k1;
					 result4 <= (v0 << 4) + k2;
					 result5 <= v0 + sum;
					 result6 <= (v0 >> 5) + k3; 
					 end 
					 
            if(ld_v_enc_results) begin
                v0 <= v0 + result1 ^ result2 ^ result3;
					 v1 <= v1 + result4 ^ result5 ^ result6;	  
					 end
			
				if (ld_sum_dec) begin
				
					 sum <= sum - delta;
					 				 
					 end
					 
				if(ld_v_dec_results) begin
                v1 <= v1 - result4 ^ result5 ^ result6;
					 v0 <= v0 - result1 ^ result2 ^ result3;	 
					end 
			
				if (ld_v0) begin
					v0 <= data_in[9:0];
					end
				
				if (ld_v1) begin 
					v1 <= data_in[9:0];
					end
				
				if (ld_k0) k0 <= data_in[9:0];
				
				if (ld_k1) k1 <= data_in[9:0];
				
				if (ld_k2) k2 <= data_in[9:0];
				
				if (ld_k3) k3 <= data_in[9:0];
				
				if (displayV0) finalResult[15:0] <= v0[15:0];
			
				if (displayV1) finalResult[31:16] <= v1[15:0];
						
			end
    end


endmodule


module control (

	 input clk,
    input resetn,
    input go,
    output reg  ld_sum_enc, ld_sum_dec,ld_results,
	 ld_v_enc_results, ld_v_dec_results, displayV0, displayV1,
	 ld_v0, ld_v1, ld_k0, ld_k1, ld_k2, ld_k3, // encrypt, decrypt,
	 resetFlag, setSum, modSum
);

    reg [5:0] current_state, next_state; 
	 // reg [4:0] counter = 5'd0;
     reg [5:0] counter = 6'd0;
	  
    localparam  LOAD_V0        = 5'd0,
                LOAD_V0_WAIT   = 5'd1,
                LOAD_V1        = 5'd2,
                LOAD_V1_WAIT   = 5'd3,
                LOAD_K0        = 5'd4,
                LOAD_K0_WAIT   = 5'd5,
                LOAD_K1        = 5'd6,
                LOAD_K1_WAIT   = 5'd7,
                LOAD_K2        = 5'd8,
                LOAD_K2_WAIT   = 5'd9,
                LOAD_K3        = 5'd10,
					 LOAD_K3_WAIT   = 5'd11,
		          WAIT_FOR_ENCRYPT = 5'd12,
					 E_SUM           = 5'd13,
					 E_RESULTS       = 5'd14,
					 E_V             = 5'd15,
					 E_DISPLAY_V0     = 5'd16,
					 E_DISPLAY_V1     = 5'd17,
					 WAIT_FOR_DECRYPT = 5'd18,
					 D_SUM           = 5'd19,
					 D_RESULTS       = 5'd20,
					 D_V             = 5'd21,
					 D_DISPLAY_V0     = 5'd22,
					 D_DISPLAY_V1     = 5'd23,
					 FINAL            = 5'd24,
					 D_MOD_SUM        = 5'd25;
    
	
	    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
				
                LOAD_V0: next_state = go ? LOAD_V0_WAIT : LOAD_V0; 
					 // Loop in current state until value is input
					 
                LOAD_V0_WAIT: next_state = go ? LOAD_V0_WAIT : LOAD_V1; 
					 // Loop in current state until go signal goes low
                
					 LOAD_V1: next_state = go ? LOAD_V1_WAIT : LOAD_V1; 
					 // Loop in current state until value is input
					 
                LOAD_V1_WAIT: next_state = go ? LOAD_V1_WAIT : LOAD_K0; 
					 // Loop in current state until go signal goes low
                
					 LOAD_K0: next_state = go ? LOAD_K0_WAIT : LOAD_K0; 
					 // Loop in current state until value is input
					 
                LOAD_K0_WAIT: next_state = go ? LOAD_K0_WAIT : LOAD_K1; 
					 // Loop in current state until go signal goes low
                
					 LOAD_K1: next_state = go ? LOAD_K1_WAIT : LOAD_K1; 
					 // Loop in current state until value is input
					 
                LOAD_K1_WAIT: next_state = go ? LOAD_K1_WAIT : LOAD_K2; 
					 // Loop in current state until go signal goes low
                
					 LOAD_K2: next_state = go ? LOAD_K2_WAIT : LOAD_K2; 
					 // Loop in current state until value is input
					 
                LOAD_K2_WAIT: next_state = go ? LOAD_K2_WAIT : LOAD_K3; 
					 // Loop in current state until go signal goes low
					 
					 LOAD_K3: next_state = go ? LOAD_K3_WAIT : LOAD_K3; 
					 // Loop in current state until value is input
					 
                LOAD_K3_WAIT: next_state = go ? LOAD_K3_WAIT : WAIT_FOR_ENCRYPT; 
					 // Loop in current state until go signal goes low
					 
					 WAIT_FOR_ENCRYPT: next_state  = go ? E_SUM: WAIT_FOR_ENCRYPT;
					 
					 E_SUM: next_state = E_RESULTS;
					 
					 E_RESULTS: next_state = E_V;
					 
					 E_V: next_state = (counter == 6'd32/*counter == 5'd32*/) ? E_DISPLAY_V0: E_SUM;
					 
					 E_DISPLAY_V0: next_state = E_DISPLAY_V1;
					 
					 E_DISPLAY_V1: next_state = WAIT_FOR_DECRYPT;
					 
					 WAIT_FOR_DECRYPT: next_state = go ? D_RESULTS: WAIT_FOR_DECRYPT;
					 
					 D_RESULTS: next_state = D_V;
					 
					 D_V: next_state = D_SUM;
					 
					 D_SUM: next_state = /*(counter == 6'd32 counter == 5'd32) ? D_DISPLAY_V0: D_RESULTS;*/D_MOD_SUM;
	
					 D_MOD_SUM: next_state = (counter == 6'd32/*counter == 5'd32*/) ? D_DISPLAY_V0: D_RESULTS;
					 
					 D_DISPLAY_V0: next_state = D_DISPLAY_V1;
					 
					 D_DISPLAY_V1: next_state = FINAL;
					 
					 FINAL: next_state = LOAD_V0;

            default: next_state = LOAD_V0;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
    
        ld_v0 = 1'b0;
        ld_v1 = 1'b0;
        ld_k0 = 1'b0;
        ld_k1 = 1'b0;
        ld_k2 = 1'b0;
		  ld_k3 = 1'b0;
		  ld_sum_enc = 1'b0;
		  ld_sum_dec = 1'b0;
		  ld_results = 1'b0;
        ld_v_enc_results = 1'b0;
		  ld_v_dec_results = 1'b0;
		  displayV0 = 1'b0;
		  displayV1 = 1'b0;
		  resetFlag = 1'b0;
		  setSum = 1'b0;
		  modSum = 1'b0;
		   

        case (current_state)
		  
            LOAD_V0: begin
                ld_v0 = 1'b1;
                end
					 
            LOAD_V1: begin
                ld_v1 = 1'b1;
                end
					 
            LOAD_K0: begin
                ld_k0 = 1'b1;
                end
					 
				LOAD_K1: begin
                ld_k1 = 1'b1;
                end 
					 
				LOAD_K2: begin
                ld_k2 = 1'b1;
                end
					 
			   LOAD_K3: begin
                ld_k3 = 1'b1;
                end
					 
				E_SUM: begin
				    ld_sum_enc = 1'b1;					 
					 end
					 
				E_RESULTS: begin
					 ld_results = 1'b1;
					 end
					 
				E_V: begin
					 ld_v_enc_results = 1'b1;
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
					 
			   D_SUM: begin
				    ld_sum_dec = 1'b1;					 
					 end
					 
				D_MOD_SUM: begin
					 modSum = 1'b1;
					 end
					 
				D_RESULTS: begin
					 ld_results = 1'b1;
					 end
					 
				D_V: begin
					 ld_v_dec_results = 1'b1;
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
           
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= LOAD_V0;
        else begin
            current_state <= next_state;
				
				if (current_state == E_SUM)
		      begin
              // counter <= counter + 5'd1;
				  counter <= counter + 6'd1;
			   end
				
				if (current_state == /*D_MOD_SUM*/D_SUM)
		      begin
              // counter <= counter + 5'd1;
				  counter <= counter + 6'd1;
			   end
				
				if (current_state == WAIT_FOR_ENCRYPT)
		      begin
              // counter <= 5'd0;
				  counter <= 6'd0;
			   end
				
				if (current_state == WAIT_FOR_DECRYPT)
		      begin
              // counter <= 5'd0;
				  counter <= 6'd0;
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