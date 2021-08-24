`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2021 01:55:46 AM
// Design Name: 
// Module Name: Incrementer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Incrementer # (
    parameter integer SIZE = 32
    )
    (
    input PCLK,
    input PRESETn,
    input [SIZE-1:0] in,
    input valid,
    output [SIZE-1:0] out
    );
    
    assign out = (valid === 1'b1) ? (in + 1) : in;
    
endmodule
