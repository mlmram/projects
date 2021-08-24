`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2021 12:57:10 AM
// Design Name: 
// Module Name: Slave
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


module Slave #(
    parameter integer ADDR_SIZE = 32,
    parameter integer DATA_SIZE = 32,
    parameter integer END_ADDR = 4095
    )
    (
    input PCLK,
    input PRESETn,
    input [ADDR_SIZE-1:0] PADDR,
    input PPROT,
    input PSEL,
    input PENABLE,
    input PWRITE,
    input [DATA_SIZE-1:0] PWDATA,
    input [(DATA_SIZE/8)-1:0] PSTRB,
    output PREADY,
    output [DATA_SIZE-1:0] PRDATA,
    output PSLVERR
    );
    
    reg write_initiated, prev_write_initiated, read_initiated, prev_read_initiated;
    wire write_finished, read_finished, busy;
    assign busy = (write_initiated & ~write_finished) | (read_initiated & ~read_finished);
    always @ (posedge PCLK or negedge PRESETn)
    begin
        if (!PRESETn)
        begin
            write_initiated = 1'b0;
            prev_write_initiated = 1'b0;
            read_initiated = 1'b0;
            prev_read_initiated = 1'b0;
        end
        else
        begin
            prev_write_initiated <= write_initiated;
            prev_read_initiated <= read_initiated;
            if (PSEL === 1'b1)
            begin
                if ((PWRITE === 1'b1) && (busy === 1'b0) && (write_initiated === 1'b0))
                begin
                    write_initiated <= 1'b1;
                end
                else if ((PWRITE === 1'b1) && (write_initiated === 1'b1) && (write_finished === 1'b1))
                begin
                    write_initiated <= 1'b0;
                end
                else if ((PWRITE === 1'b0) && (busy === 1'b0) && (read_initiated === 1'b0))
                begin
                    read_initiated <= 1'b1;
                end
                else if ((PWRITE === 1'b0) && (read_initiated === 1'b1) && (read_finished === 1'b1))
                begin
                    read_initiated <= 1'b0;
                end
            end
        end
    end
    
    reg PREADY_r;
    assign PREADY = PREADY_r;
    always @ (posedge PCLK or negedge PRESETn)
    begin
        if (!PRESETn)
        begin
            PREADY_r <= 1'b0;
        end
        else
        begin
            if (((write_initiated === 1'b1) && (write_finished === 1'b1)) || ((read_initiated === 1'b1) && (read_finished === 1'b1)))
            begin
                PREADY_r <= 1'b1;
            end
            else
            begin
                PREADY_r <= 1'b0;
            end
        end
    end
    
    wire write_initiated_valid, read_initiated_valid;
    assign write_initiated_valid = ~prev_write_initiated & write_initiated;
    assign read_initiated_valid = ~prev_read_initiated & read_initiated;
    Slave_memory_m #(.ADDR_SIZE (ADDR_SIZE), .DATA_SIZE (DATA_SIZE), .END_ADDR (END_ADDR)) Slave_memory_inst (
        .PCLK           (PCLK),
        .PRESETn        (PRESETn),
        .PADDR          (PADDR),
        .PWDATA         (PWDATA),
        .PSTRB          (PSTRB),
        .PRDATA         (PRDATA),
        .write_init     (write_initiated_valid),
        .write_finished (write_finished),
        .read_init      (read_initiated_valid),
        .read_finished  (read_finished)
        );
    
endmodule
