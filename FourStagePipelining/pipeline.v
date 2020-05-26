module pipeline(
	output [15:0] C, 
	input [3:0] ra1,	/*Register read address 1*/
	input [3:0] ra2,	/*Register read address 2*/
	input [3:0] rwa,	/*Register write address*/
	input [7:0] ma,		/*Memory write address*/
	input [3:0] func,	/*Operation to be executed*/
	input clk1,			/*Two phase clock*/
	input clk2);

	reg [15:0] L12_A, L12_B, L23_C, L34_C;
	reg [3:0] L12_rwa, L12_func, L23_rwa;
	reg [7:0] L12_ma, L23_ma, L34_ma;

	reg [15:0] regbank [0:15]; /*16x16 Register Bank*/
	reg [15:0] mem [0:255]; /*256x16 Memory*/

	assign C = L34_C;

	always @ (posedge clk1)			/*Stage 1*/
	begin
		L12_A 		<= #2 regbank[ra1];
		L12_B 		<= #2 regbank[ra2];
		L12_rwa 	<= #2 rwa;
		L12_func 	<= #2 func;
		L12_ma 		<= #2 ma;
	end

	always @ (negedge clk2)			/*Stage 2*/
	begin
		case(L12_func)
			4'b0000: #2 L23_C <= L12_A + L12_B;
			4'b0001: #2 L23_C <= L12_A - L12_B;
			4'b0010: #2 L23_C <= L12_A * L12_B;
			4'b0011: #2 L23_C <= L12_A; 		/*Select A*/
			4'b0100: #2 L23_C <= L12_B; 		/*Select B*/
			4'b0101: #2 L23_C <= L12_A & L12_B;
			4'b0110: #2 L23_C <= L12_A | L12_B;
			4'b0111: #2 L23_C <= L12_A ^ L12_B;
			4'b1000: #2 L23_C <= L12_A ~^ L12_B;
			4'b1001: #2 L23_C <= ~L12_A;
			4'b1010: #2 L23_C <= ~L12_B;
			4'b1011: #2 L23_C <= L12_A >> 1;
			4'b1100: #2 L23_C <= L12_A << 1;
			default: #2 L23_C <= 16'hxxxx;
		endcase
		L23_ma <= #2 L12_ma;
		L23_rwa <= #2 L12_rwa;
	end

	always @ (posedge clk1)			/*Stage 3*/
	begin
		regbank[L23_rwa] 	<= #2 L23_C;
		L34_ma 				<= #2 L23_ma;
		L34_C 				<= #2 L23_C;
	end

	always @ (negedge clk2)			/*Stage 4*/
	begin
		mem[L34_ma] <= #2 L34_C; 
	end

endmodule