module EXAMPLE_DUT(
    input  wire       CLK,
    input  wire [9:0] SW,

    input  wire [3:0] KEY,
    output wire [9:0] LED,
    output reg  [6:0] HEX0 = 7'b1111110,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,
    output wire [6:0] HEX4,
    output wire [6:0] HEX5
);

assign LED = SW ^ {6'd0, {~KEY}};

// HEXY powinny chodzić w wężyk
assign HEX1 = {HEX0[5:0], HEX0[6]};
assign HEX2 = {HEX1[5:0], HEX1[6]};
assign HEX3 = {HEX2[5:0], HEX2[6]};
assign HEX4 = {HEX3[5:0], HEX3[6]};
assign HEX5 = {HEX4[5:0], HEX4[6]};

always @(posedge CLK) begin
    HEX0 <= HEX1;
end


endmodule