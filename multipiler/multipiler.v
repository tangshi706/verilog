//---------------------------------------------------------------------------------------------------------------------
//这个是并行乘法器，他可以做到性能上是最快的，他在其中插入流水线的操作；
//这个会有额外的开销，故不会做到面积最优
//---------------------------------------------------------------------------------------------------------------------
module multi_4bits_pipeline(clk,rst_n,mul_a,mul_b,mul_out);
	input clk;
	input rst_n;
	input [3:0]mul_a;
	input [3:0]mul_b;
	output [7:0]mul_out;
	
	reg [7:0]mul_out;
	
	reg [7:0]stroed0;
	reg [7:0]stroed1;
	reg [7:0]stroed2;
	reg [7:0]stroed3;
	
	reg [7:0]add01;
	reg [7:0]add23;
	
	always@(posedge clk,negedge rst_n)
	begin
	if(!rst_n)
	begin
		mul_out <= 'd0;
		stroed0 <= 'd0;
		stroed1 <= 'd0;
		stroed2 <= 'd0;
		stroed3 <= 'd0;
		add01 <= 'd0;
		add23 <= 'd0;
	end 
	else begin
		//第一级流水
		stroed0 <= mul_b[0]? {4'b0,mul_a} : 8'b0;
		stroed1 <= mul_b[1]? {3'b0,mul_a,1'b0} : 8'b0;
		stroed2 <= mul_b[2]? {2'b0,mul_a,2'b0} : 8'b0;
		stroed3 <= mul_b[3]? {1'b0,mul_a,3'b0} : 8'b0;
		//第二级流水
		add01 <= stroed0 + stroed1;
		add23 <= stroed2 + stroed3;
		//第三级流水
		mul_out <= add01 + add23;	
	end 
end 

endmodule 

`ifdef DC
`else
module tb;

	reg clk;
	reg rst_n;
	reg [3:0]mul_a;
	reg [3:0]mul_b;
	wire [7:0]mul_out;

	multi_4bits_pipeline U1(
							.clk(clk),
							.rst_n(rst_n),
							.mul_a(mul_a),
							.mul_b(mul_b),
							.mul_out(mul_out)
							);
							
	initial begin
		clk = 0;
		forever #10 clk = ~clk;
	end 
	
	initial begin
		mul_a = 0;
		mul_b = 0;
		rst_n = 0;
		#100;
		rst_n = 1;
		#20.1;
		mul_a = 3;
		mul_b = 5;
		#20;
		mul_a = 4;
		mul_b = 4;
		#20;
		mul_a = 3;
		mul_b = 4;
		#100 $finish;
	end 

endmodule 
`endif