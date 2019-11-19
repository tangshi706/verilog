module bin_to_gray(b_in,g_out);
	input [4:0]b_in;
	output [4:0]g_out;
	
	//格雷码的转换
	assign g_out[4]=b_in[4];
	assign g_out[3]=b_in[3];
	assign g_out[2]=b_in[3]^b_in[2];
	assign g_out[1]=b_in[2]^b_in[1];
	assign g_out[0]=b_in[1]^b_in[0];

endmodule 

module async_fifo(wclk,rclk,rst,wr_en,rd_en,data_in,data_out,empty,full);
	input wclk;
	input rclk;
	input rst;
	input wr_en;
	input rd_en;
	input [7:0]data_in;
	output [7:0]data_out;
	output empty;
	output full;
	
	reg [7:0]mem[15:0];
	
	reg [4:0]w_addr_a,r_addr_a;//binary address
	wire [4:0]w_addr_b,r_addr_b;//gray address
	reg [4:0]w_addr_r,r_addr_w;//采样地址，用在空满信号
	
	//写端的地址控制
	bin_to_gray(.b_in(w_addr_a),.g_out(w_addr_b));
	
	//读端的地址控制
	bin_to_gray(.b_in(r_addr_a),.g_out(r_addr_b));
	
	assign w_addr=w_addr_b[3:0];
	assign r_addr=r_addr_b[3:0];
	
	always@(posedge rclk,negedge rst)
	begin : read_control
	if(!rst)begin
		r_addr_a <= 'd0;
		r_addr_w <= 'd0;
	end 
	else begin
		r_addr_w <= w_addr_b;//将格雷码出来的地址给采样下来
		if(rd_en && empty)
		begin
			data_out <= mem[r_addr];
			r_addr_a <= r_addr_a + 1'b1;
		end 
	end 
	end 
	
	always@(posedge wclk,negedge rst)
	begin : write_control
		if(!rst)
		begin
			w_addr_a <= 'd0;
			w_addr_r <= 'd0;
		end 
		else begin
			w_addr_r <= r_addr_b;
			if(wr_en && full)
			begin
				mem[w_addr] <= data_in;
				w_addr_a <= w_addr_a + 1'b1;
			end 
		end 
	end 
	
	assign empty = (r_addr_b == r_addr_w)? 1 : 0;
	assign full = (w_addr_b[4] != w_addr_r[4])&&(w_addr_b[3:0] == w_addr_r[3:0])? 1:0;
	
endmodule 