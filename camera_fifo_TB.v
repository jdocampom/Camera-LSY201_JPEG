//
//  camera_fifo_TB.v
//  TestBench for LS-Y201 JPEG Camera Driver
//
//  Created by Óscar Julián Umaña, Juan Diego Ocampo and Raúl Morales on 03/05/2018.
//  Copyright © 2018 Juan Diego Ocampo. All rights reserved.
//

module camera_fifo_TB; 
reg reset, clk, send, rdx;
reg [7:0] Tx;  
reg rclk = 0;
wire txd;

camera_fifo  uut(
.clk(clk),
.reset(reset),
.rx(rdx),
.tx(txd),
.rclk(rclk)
);

reg [5:0] cont = 0;
	
initial begin 
	clk <= 0;
	rdx <= 1;
	reset=1;
	#10; reset=0;
end
	
always #1 clk <= ~clk;

always begin
	for(cont = 0; cont < 15; cont = cont + 1) begin
		#2700;
		rdx <= ~rdx;
	end
	rclk <= 1;
	#2;
	rclk <= 0;
	#2;
	rclk <= 1;
	#2;
	rclk <= 0;
	#2;
end 

initial begin//: TEST_CASE
  $dumpfile("camera_fifo_TB.vcd");
  $dumpvars(-1, uut);
  #80000 $finish;
end

endmodule