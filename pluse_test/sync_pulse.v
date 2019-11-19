/*------------------------------------ 快时钟域到慢时钟域 --------------------------------------------*/
//要将一个信号从快时钟域传递到慢时钟域，首先要在快时钟域展宽脉冲，然后将展宽的脉冲传递到慢时钟域，
//如果在慢时钟域检测到脉冲后就可以给快时钟域一个反馈以阻止脉冲的继续展宽；
/*-----------------------------------------------------------------------------------------------------*/
module sync_pulse(input clka,input b,input rst_n,input pulse_ina,output pulse_outb,output signal_outb);

	reg signal_a;
	reg signal_b;
	reg [1:0]signal_a_r;
	reg [1:0]signal_b_r;

//在clka下，生成展宽信号signal_a;
always@(posedge clka,negedge rst_n)begin
	if(!rst_n)begin
		signal_a <= 'd0;
	end 
	else if(pulse_ina==1'b1) begin
		signal_a <= 1'b1;
	end 
	else if(signal_a_r[1]==1'b1)begin//这个有后面的信号进行反馈
		signal_a <= 1'b0;//停止展宽
	end 
	else begin
		signal_a <= signal_a;//将信号pulse_ina展宽
	end
end

//在clkb下同步signal_a
always@(posedge clkb,negedge rst_n)begin
	if(!rst_n)
		signal_b <= 'd0;
	else 
		signal_b <= signal_a;//将信号进行同步，消除毛刺
end 

//生成clkb下的脉冲信号和输出信号
always@(posedge clkb,negedge rst_n)begin
	if(!rst_n)begin
		signal_b_r <= 'd0;
	end 
	else begin
		signal_b_r <= {signal_b_r[0],signal_b};
	end
end 

//取出上升沿，并输出信号
	assign pulse_outb = ~signal_b_r[1] & signal_b_r[0];//上升沿
	assign signal_b = signal_b_r[1];

//在clka下采集signal_b[1]，生成signal_a_r[1]用于反馈拉低signal_a
always @(posedge clka or negedge rst_n)begin
	if(!rst_n)begin
		signal_a_r <= 'd0;
	end 
	else begin
		signal_a_r <= {signal_a_r[0],signal_b_r[1]};////反馈，防止脉冲继续展宽
	end 
end
endmodule 