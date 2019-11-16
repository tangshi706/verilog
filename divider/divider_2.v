/*--------------------------------------------------------------------------------------------------------------------
说明：第二中设计思路是基于通用的半整数分频器进行实现，其设计思路是利用模N器从0计数到N，当计数到N的时候输出为1，但是为了实现N+0.5个周期，
则输出的1持续的时间为半个周期，这样的话就需要将输入时钟的下降沿变成上升沿，这样就可以实现输出半个周期长度的1。将输入时钟的上升沿变成
下降沿通过二分频的输出和输入时钟异或实现的。
---------------------------------------------------------------------------------------------------------------------*/

module half_div #(parameter N=5)(
input clk_in,
input rst_n,
output clk_out);

reg [3:0]cnt;
reg div1;
reg div2;
wire clk_half;

//形成半个时钟，因为只有系统时钟在会有0.5个时钟周期
assign clk_half = clk_in ^ div2;

//造一个时钟
always@(posedge clk_half,negedge rst_n)begin
if(!rst_n)begin
	cnt <= 'd0;
	div1 <= 'd0;
end 
else if(cnt == N)begin
	cnt <= 'd0;
	div1 <= 1'b1;
end 
else begin
	cnt <= cnt + 1'b1;
	div1 <='d0;
end 
end 
always@(posedge div1,negedge rst_n)begin
if(!rst_n)
	div2 <= 'd0;
else 
	div2 <= ~div2;
end 

//时钟输出
assign clk_out = div1;

endmodule 

`ifdef DC
`else 
`timescale 1ns/1ns
module half_div_tb;

	reg clk_in;
	reg rst_n;
	wire clk_out;

	half_div #(.N(5)) inst0(
								.clk_in(clk_in),
								.rst_n(rst_n),
								.clk_out(clk_out));
								
	initial begin
		rst_n = 1;
		#100;
		rst_n = 0;
		#100;
		rst_n = 1;
		#1000;
		$finish;
	end 
	
	initial begin
		clk_in = 0;
		forever #10 clk_in = ~clk_in;
	end 

endmodule 
`endif