/*-----------------------------------------------------------------------------------
#本设计为N+0.5分频器的实现
#本设计以5.5分频为例进行说明。对于N+0.5分频，没有办法实占空比为50%，因此我们实现
#占空比为1/(N+0.5)的分频器，即在0.5个周期实现高电平即可。
#通过两个分频时钟的与操作实现。两个分频时钟的占空比均为（N+1）/(2*N+1),对于5.5分频电路来讲，
#其占空比为6/11，不过这两个分频时钟一个是基于时钟上升沿触发一个是基于时钟下降沿触发，
#并且时钟的初始化值相反，这样将这两个时钟相与就可以得到5.5分频的电路了。
------------------------------------------------------------------------------------*/
module half_div#(parameter N = 5)(
input clk_in,
input rst_n,
output clk_out);

reg [3:0]cnt1;
reg [3:0]cnt2;
reg div1;
reg div2;

always@(posedge clk_in,negedge rst_n)
begin
	if(!rst_n)begin
		cnt1 <= 3'b0;
		div1 <= 'd0;
	end 
	else begin
		cnt1 <= cnt1 + 1'b1;
		if(cnt1 == 2*N)begin
			cnt1 <= 'd0;
		end 
		else if(cnt1 == N+1 || cnt1 == 0)begin
			div1 <= ~div1;
		end 
	end 
end 

always@(negedge clk_in,negedge rst_n)
begin
	if(!rst_n)begin
		cnt2 <= 'd0;
		div2 <= 'd0;
	end 
	else begin
		cnt2 <= cnt2 + 1'b1;
		if(cnt2 == 2*N)begin
			cnt2 <= 'd0;
		end 
		else if(cnt2 == N+1 || cnt2 == 1)begin
			div2 <= ~div2;
		end 
	end 
end 

assign clk_out = div1 & div2;

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