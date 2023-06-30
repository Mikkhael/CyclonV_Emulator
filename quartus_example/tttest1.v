`timescale 1ns/1ns

module tttest1 ();

reg [3:0] KEY = 0;
reg [9:0] SW  = 0;

wire [9:0] LED;
wire [6:0] HEX;


mammamia dut (
    .KEY(KEY),
    .SW9(SW[9]),
    .SW2(SW[2]),
    .SW1(SW[1]),
    .SW0(SW[0]),
    .LED(LED),
    .HEX(HEX)
);

initial begin
    #10;
    SW  = 10'b1111111111;
    #20;
    KEY = 4'b1111;
    #10
    $display("%b %b", LED, HEX);
    $stop;
end

endmodule