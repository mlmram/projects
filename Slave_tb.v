`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/24/2021 01:20:26 AM
// Design Name: 
// Module Name: Slave_tb
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


module Slave_tb(

    );
    
    reg PCLK, PRESETn, PSEL, PENABLE, PWRITE;
    reg [31:0] PADDR, PWDATA;
    reg [3:0] PSTRB;
    wire [31:0] PRDATA;
    wire PREADY, PSLVERR;
    
    always #5 PCLK = ~PCLK;
    
    initial
    begin
        PCLK = 1'b0;
        PRESETn = 1'b0;
        PADDR = 0;
        #4;
        PRESETn = 1'b1;
        @ (negedge PCLK);
        PSEL <= 1'b1;
        PWRITE <= 1'b1;
        PENABLE <= 1'b1;
        PADDR[11:0] <= $random;
        PWDATA <= $random;
        PSTRB <= 4'b1011;
        while (PREADY !== 1'b1)
        begin
            @ (negedge PCLK);
        end
        PENABLE <= 1'b0;
        PWRITE <= 1'b0;
        @ (negedge PCLK);
        PENABLE <= 1'b1;
        while (PREADY !== 1'b1)
        begin
            @ (negedge PCLK);
        end
        #20;
        $finish;
    end
    
    Slave #(.ADDR_SIZE (32), .DATA_SIZE (32), .END_ADDR (4095)) Slave_inst (
        .PCLK           (PCLK),
        .PRESETn        (PRESETn),
        .PADDR          (PADDR),
        .PPROT          (),
        .PSEL           (PSEL),
        .PENABLE        (PENABLE),
        .PWRITE         (PWRITE),
        .PWDATA         (PWDATA),
        .PSTRB          (PSTRB),
        .PRDATA         (PRDATA),
        .PREADY         (PREADY),
        .PSLVERR        (PSLVERR)
        );
    
endmodule
