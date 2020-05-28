module MealyFSM_TestBench();

reg a, rst, clk;
wire b;

MealyFSM m1(a, rst, clk, b);

initial
begin
a = 1'b0;
clk = 1'b0;
rst = 1'b0;
end

always
begin
	#2 clk = ~clk;
end
initial
begin
	#1 rst = 1'b1;
	#5 rst = 1'b0; a = 1'b1;
	#5 a = 1'b1;
	#5 a = 1'b0;
	#5 a = 1'b1;
	#5 a = 1'b0;
	#5 a = 1'b1;
	#5 a = 1'b1;
	#5 a = 1'b0;
	#5 a = 1'b1;
	#5 a = 1'b1;
end

initial 
begin
	$dumpfile("MealyFSM_TestBench.vcd");
	$dumpvars(0, MealyFSM_TestBench);
	$monitor($time,"	Input = %b State = %d Output = %d", a, m1.PresentState, b);
	#200 $finish;
end

endmodule