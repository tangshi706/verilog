module Arbitrary_divider #(parameter N=3)(input clk_in,input rst_n,output clk_out);
reg [9:0]count1;
reg [9:0]count2;
reg clk_out1;
reg clk_out2;

//计数器在上升沿进行计数
always@(posedge clk_in,negedge rst_n)begin
  if(!rst_n)begin
    count1 <= 'd0;
    clk_out1 <= 'd0;
  end 
  else begin
    if(N==2)
      clk_out1 <= ~clk_out1;
    else if(count1 <= ((N-1)/2)-1)begin
      clk_out1 <= 1'b1;
      count1 <= count1 + 1'b1;
    end 
    else if(count1 <= (N-2))begin
      count1 <= count1 + 1'b1;
      clk_out1 <= 1'b0;
    end 
    else begin
      count1 <= 'd0;
      clk_out1 <= 'd0;
    end 
  end 
end 

//计数器在下降沿进行计数
always@(negedge clk_in,negedge rst_n)begin
  if(~rst_n)begin
    count2 <= 'd0;
    clk_out2 <= 'd0;
  end 
  else begin
    if(N==2)
      clk_out2 <= 'd0;
    else if(count2 <= ((N-1)/2)-1)begin
      count2 <= count2 + 1'b1;
      clk_out <= 1'b1;
    end 
    else if(count2 <= (N-2))begin
      count2 <= count2 + 1'b1;
      clk_out2 <= 1'b0;
    end 
    else begin
      count2 <= 'd0;
      clk_out2 <= 'd0;
    end 
  end
end 

assign clk_out = clk_out1 | clk_out2;

endmodule 
