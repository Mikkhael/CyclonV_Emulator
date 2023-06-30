module Krzeslo (
	input clk,
	input dir,
	input [2:0] in,
	output wire [5:0] out
);

	always @(posedge clk) begin
		if(dir) begin
			out = {out[4:0], out[5]};
		end else begin
			out = {out[0], out[5:1]};
		end
		out[2:0] = in[2:0] ^ out[2:0];
	end

endmodule