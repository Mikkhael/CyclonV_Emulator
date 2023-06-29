`timescale 1ns/1ns

module EMULATOR();


reg CLK = 0;
wire [9:0] SW;
wire [3:0] KEY;
wire [9:0] LED;
wire [6:0] HEX0;
wire [6:0] HEX1;
wire [6:0] HEX2;
wire [6:0] HEX3;
wire [6:0] HEX4;
wire [6:0] HEX5;

///////// TU WSTAW TESTOWANY MODUŁ ////////////

always #15 CLK = !CLK; // Genrator Zegara

EXAMPLE_DUT dut(
    .CLK(CLK),
    .SW(SW),
    .KEY(KEY),
    .LED(LED),
    .HEX0(HEX0),
    .HEX1(HEX1),
    .HEX2(HEX2),
    .HEX3(HEX3),
    .HEX4(HEX4),
    .HEX5(HEX5)
);

always @(*) begin
    $display("LED: %b | KEY: %b", LED, KEY);
end

/////////////////////////////////////////////

parameter INPUTS_STATE_LEN  = 14;
parameter OUTPUTS_STATE_LEN = 52;


wire [OUTPUTS_STATE_LEN-1 : 0] outputs_state;
reg  [INPUTS_STATE_LEN-1  : 0] inputs_state  = 0;

assign SW  = inputs_state[9:0];
assign KEY = inputs_state[13:10];
assign outputs_state[9:0]   = LED;
assign outputs_state[16:10] = HEX0;
assign outputs_state[23:17] = HEX1;
assign outputs_state[30:24] = HEX2;
assign outputs_state[37:31] = HEX3;
assign outputs_state[44:38] = HEX4;
assign outputs_state[51:45] = HEX5;

function [OUTPUTS_STATE_LEN-1:0] update_state(input [INPUTS_STATE_LEN-1:0] new_inputs_state);
begin
    inputs_state = new_inputs_state;
    update_state = outputs_state;
end
endfunction


endmodule