/*This FSM is detects the pattern 11011*/

module MealyFSM(
	input a, 
	input rst,
	input clk,
	output reg b);

	parameter s0 = 3'b000, s1 = 3'b001, s2 = 3'b010, s3 = 3'b011, s4 = 3'b100;

	reg [2:0] PresentState;
	reg [2:0] NextState;

	always @ (posedge clk)
	begin
		if (rst)
			PresentState <= s0;
		else
			PresentState <= NextState;
	end

	always @ (PresentState,a)
	begin
		case(PresentState)
			s0: if(a) 
				begin
					NextState = s1;
					b = 1'b0;
				end
				else
				begin
					NextState = s0;
					b = 1'b0;
				end		
			s1: if(a) 
				begin
					NextState = s2;
					b = 1'b0;
				end
				else
				begin
					NextState = s0;
					b = 1'b0;
				end		
			s2: if(a) 
					begin
						NextState = s2;
						b = 1'b0;
					end
				else
				begin
					NextState = s3;
					b = 1'b0;
				end		
			s3: if(a) 
				begin
					NextState = s4;
					b = 1'b0;
				end
				else
				begin
					NextState = s0;
					b = 1'b0;
				end		
			s4: if(a) 
				begin
					NextState = s2;
					b = 1'b1;
				end
				else
				begin
					NextState = s0;
					b = 1'b0;
				end		
			default: PresentState = s0;
		endcase
	end
endmodule