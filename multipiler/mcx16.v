//要是面积最小，一定是“移位-相加”的串行乘法器
//  b
//x a
//-----------
module mcx16(clk,rst_n,start,ain,bin,yout,done);
	input clk;
	input rst_n;
	input start;
	input [15:0]ain;
	input [15:0]bin;
	output [31:0]yout;
	output done;
	
	reg [15:0]areg;
	reg [15:0]breg;
	reg [31:0]yout_r;
	reg done_r;
	reg [4:0]i;
	
	assign done = done_r;
	assign yout = yout_r;
	
	//数据位控制
	always@(posedge clk,negedge rst_n)
	begin
	if(!rst_n)
		i <= 'd0;
	else if((start == 1'b1) && (i < 5'd17))
		i <= i + 1'b1;
	else if(start == 1'b0)
		i <= 5'd0;
	end 
	
	//乘法完成标志信号
	always@(posedge clk,negedge rst_n)
	begin
	if(!rst_n)
		done_r <= 1'b0;
	else if(i == 5'd16)
		done_r <= 1'b1;
	else if(i == 5'd17)
		done_r <= 1'b0;
	end 
	
	//专用寄存器进行移位累加操作
	always@(posedge clk,negedge rst_n)
	begin
	if(!rst_n)
	begin
		areg <= 'd0;
		breg <= 'd0;
		yout_r <= 'd0;
	end 
	else if(start == 1'b1) begin
		if(i == 5'd0)begin
			areg <= ain;
			breg <= bin;
		end 
		else if(i > 5'd0 && i < 5'd17)begin
			if(areg[i-1] == 1'b1)
				yout_r <= yout_r + ({16'b0,breg}<<(i-1));
		end 
	end 
	end 

endmodule 

`ifdef DC
`else
`timescale 1ns/1ps

module mcx_tb;

	reg clk;
	reg rst_n;
	reg start;
	reg [15:0]ain;
	reg [15:0]bin;
	wire [31:0]yout;
	wire done;

	mcx16 U2(.clk(clk),.rst_n(rst_n),.start(start),.ain(ain),.bin(bin),.yout(yout),.done(done));
	
	initial begin
		clk = 0;
		forever #10 clk = ~clk;
	end 
	
	initial begin
		ain = 0;
		bin = 0;
		start = 0;
		rst_n = 0;
		#20.1
		rst_n = 1;
		start = 1;
		ain = 4;
		bin = 3;
		#100;
		$finish;
	end 

endmodule 
`endif