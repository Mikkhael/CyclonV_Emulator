module EXAMPLE_DUT(
    input  wire       CLK,
    input  wire [9:0] SW,

    input  wire [3:0] KEY,
    output wire [9:0] LED,
    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,
    output wire [6:0] HEX4,
    output wire [6:0] HEX5
);

assign LED = SW ^ {6'd0, {~KEY}};

reg [6:0] val = 0;

assign HEX0 = val + 6'd0;
assign HEX1 = val + 6'd1;
assign HEX2 = val + 6'd2;
assign HEX3 = val + 6'd3;
assign HEX4 = val + 6'd4;
assign HEX5 = val + 6'd5;

always @(posedge CLK) begin
    val <= val + 1'd1;
end


endmodule