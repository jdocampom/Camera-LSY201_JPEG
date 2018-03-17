//
//  FIFO.v
//  Verilog Source Code for FIFO Memory
//
//  Created by Óscar Julián Umaña, Juan Diego Ocampo and Raúl Morales on 03/05/2018.
//  Copyright © 2018 Juan Diego Ocampo. All rights reserved.
//

module FIFO
	#(
		parameter DATO_WIDTH = 8,
		parameter FIFO_LENGTH = 53
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

// Registers	
	reg [DATO_WIDTH-1:0] f [0:(FIFO_LENGTH-1)];
	reg orwr;
	reg [5:0] cont = 0;
	reg [5:0] contw = 0;
	reg [5:0] contr = 0;
	
	always @(posedge orwr) begin
		if(rst) begin
			f[0] <= 3'b000;
			f[1] <= 3'b000;
			f[2] <= 3'b000;
			f[3] <= 3'b000;
			f[4] <= 3'b000;
			cont <= 0;
			contw <= 0;
			contr <= 0;
			datout <= 0;
		end else begin
			case({rclk,wclk})
				2'b01:
					if(~full) begin
						f[contw] <= datin;
						contw <= contw + 3'b001;	
						if(contw >= (FIFO_LENGTH - 1)) contw <= 3'b000;
						cont <= cont + 3'b001;
					end
				2'b10:
					if(~empy) begin
						datout <= f[contr];
						f[contr] <= 0;
						contr <= contr + 3'b001;
						if(contr >= (FIFO_LENGTH - 1)) contr <= 3'b000;
						cont <= cont - 3'b001;
					end
				2'b11:
					if(full) begin
						datout <= f[contr];
						f[contr] <= 0;
						contr <= contr + 3'b001;
						if(contr >= (FIFO_LENGTH - 1)) contr <= 3'b000;
						f[contw] <= datin;
						contw <= contw + 3'b001;	
						if(contw >= (FIFO_LENGTH - 1)) contw <= 3'b000;
					end else if(empy) begin
						datout <= datin;
					end else begin
						if(~full) begin
							f[contw] <= datin;
							contw <= contw + 3'b001;	
							if(contw >= (FIFO_LENGTH - 1)) contw <= 3'b000;
						end
						if(~empy) begin
							datout <= f[contr];
							f[contr] <= 0;
							contr <= contr + 3'b001;
							if(contr >= (FIFO_LENGTH - 1)) contr <= 3'b000;
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
		if(cont > 0) begin
			empy = 0;
			dato = 1;
			full = 0;
		end
		if(cont == FIFO_LENGTH) begin
			empy = 0;
			dato = 0;
			full = 1;
		end
	end

endmodule