module pipeline_testbench();

reg clk1,clk2;
reg [3:0] ra1,ra2,func,rwa;
reg [7:0] ma;

wire [15:0] C;
integer i;

pipeline p1(C,ra1,ra2,rwa,ma,func,clk1,clk2);

initial
begin
	clk1 = 1'b0; clk2 = 1'b0;

	repeat(30)			/*Generating two phase clock*/
	begin
		clk1 = #5 1'b1; clk1 = #5 1'b0;
		clk2 = #5 1'b1; clk2 = #5 1'b0;
	end
end

initial
begin
	for(i=0;i<15;i=i+1)			/*Initializing regbank*/
		p1.regbank[i] = i*i;
end

initial
begin
	#5 ra1 = 2; ra2 = 7; func = 0; rwa =12; ma = 145;
	#20 ra1 = 1; ra2 = 4; func = 4; rwa =13; ma = 169;
	#20 ra1 = 9; ra2 = 5; func = 3; rwa =11; ma = 132;
	#20 ra1 = 6; ra2 = 2; func = 7; rwa =14; ma = 140;

	#50
	for(i=132; i<170; i = i+1)
		$display("Memory[%3d] = %d", i, p1.mem[i]);
end

initial
begin
	$dumpfile("pipeline.vcd");
	$dumpvars(0,pipeline_testbench);
	$monitor($time,"Output = %d",C);
	#200 $finish;
end

endmodule