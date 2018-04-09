//
//  FIFO.v
//  Top level Verilog code for FIFO Memory
//
//  Created by Óscar Julian Umaña, Juan Diego Ocampo and Raúl Morales on 03/05/2018.
//  Copyright © 2018 Juan Diego Ocampo. All rights reserved.
//

/*
Specifications:
- Designed for Nexys4 Development Kit (FPGA: Artix7 - Device: XC7A100T-3CSG324)
- 256 stages.
- 8-bit data width 
- Status signals: 
  * Full: LED 13 turns on.
  * Empty: LED 15 turns on.
  * Data saved: LED 14 turns on.
  * No need for button-controlled R/W Enable Processes.
  * Button-controlled RCLK/WCLK Enable Signals.
*/

// FIFO Test
module FIFO
	#(
		parameter DATO_WIDTH = 8,
		parameter FIFO_LENGTH = 7
	)(
		input wclk,
		input [DATO_WIDTH-1:0] datin,
		input rclk,
		input rst,
		output reg [DATO_WIDTH-1:0] datout,
		output reg full,
		output reg empy,
		output reg dato
	);
	parameter fifo_depth = (1 << FIFO_LENGTH);

// Registers	
	reg [DATO_WIDTH-1:0] f [0:(fifo_depth-1)];
	reg orwr;
	reg [fifo_depth-1:0] cont = 0;
	reg [fifo_depth-1:0] contw = 0;
	reg [fifo_depth-1:0] contr = 0;
	
	always @(posedge orwr) begin
		if(rst) begin
			datout = 1'b0;
			cont = 1'b0;
			contw = 1'b0;
			contr = 1'b0;
		end else begin
			case({rclk,wclk})
				2'b01:
					if(~full) begin
						f[contw] = datin;
						contw = contw + 1'b1;	
						if(contw >= fifo_depth) contw = 1'b0;
						cont = cont + 1'b1;
					end
				2'b10:
					if(~empy) begin
						datout = f[contr];
						//f[contr] = 0;
						contr = contr + 1'b1;
						if(contr >= fifo_depth) contr = 1'b0;
						cont = cont - 1'b1;
					end
				2'b11:
					if(full) begin
						datout = f[contr];
						//f[contr] = 0;
						contr = contr + 1'b1;
						if(contr >= fifo_depth) contr = 1'b0;
						f[contw] = datin;
						contw = contw + 1'b1;	
						if(contw >= fifo_depth) contw = 1'b0;
					end else if(empy) begin
						datout = datin;
					end else begin
						if(~full) begin
							f[contw] = datin;
							contw = contw + 1'b1;	
							if(contw >= fifo_depth) contw = 1'b0;
						end
							if(~empy) begin
							datout = f[contr];
							//f[contr] = 0;
							contr = contr + 1'b1;
							if(contr >= fifo_depth) contr = 1'b0;
						end
					end
			endcase
		end
	end
	
	always @(*) begin
		orwr = wclk | rclk | rst;
		if(cont == 0) begin
			empy = 1;
			dato = 0;
			full = 0;
		end
		if(cont == fifo_depth) begin
			empy = 0;
			dato = 0;
			full = 1;
		end 
		if(cont > 0 && cont < fifo_depth) begin
			empy = 0;
			dato = 1;
			full = 0;
		end
	end

endmodule