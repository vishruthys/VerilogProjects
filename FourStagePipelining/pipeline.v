module pipeline(
	output [15:0] C, 
	output reg [15:0] mem_array [0:255], /*256x16 Memory*/ /*Wont show in trace*/
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
	// reg [15:0] mem_array [0:255];

	assign C = L34_C;

	always @ (posedge clk1)			/*Stage 1*/
	begin
		L12_A 		<= regbank[ra1];
		L12_B 		<= regbank[ra2];
		L12_rwa 	<= rwa;
		L12_func 	<= func;
		L12_ma 		<= ma;
	end

	always @ (negedge clk2)			/*Stage 2*/
	begin
		case(L12_func)
			4'b0000: L23_C <= L12_A + L12_B;
			4'b0001: L23_C <= L12_A - L12_B;
			4'b0010: L23_C <= L12_A * L12_B;
			4'b0011: L23_C <= L12_A; 		/*Select A*/
			4'b0100: L23_C <= L12_B; 		/*Select B*/
			4'b0101: L23_C <= L12_A & L12_B;
			4'b0110: L23_C <= L12_A | L12_B;
			4'b0111: L23_C <= L12_A ^ L12_B;
			4'b1000: L23_C <= L12_A ~^ L12_B;
			4'b1001: L23_C <= ~L12_A;
			4'b1010: L23_C <= ~L12_B;
			4'b1011: L23_C <= L12_A >> 1;
			4'b1100: L23_C <= L12_A << 1;
			default: L23_C <= 16'hxxxx;
		endcase
		L23_ma <= L12_ma;
		L23_rwa <= L12_rwa;
	end

	always @ (posedge clk1)			/*Stage 3*/
	begin
		regbank[L23_rwa] 	<= L23_C;
		L34_ma 				<= L23_ma;
		L34_C 				<= L23_C;
	end

	always @ (negedge clk2)			/*Stage 4*/
	begin
		mem_array[L34_ma] <= L34_C; 
	end

endmodule