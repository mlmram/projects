`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2021 01:22:04 AM
// Design Name: 
// Module Name: Slave_memory_m
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


module Slave_memory_m# (
    parameter integer ADDR_SIZE = 32,
    parameter integer DATA_SIZE = 32,
    parameter integer END_ADDR = 4095
    )
    (
    input PCLK,
    input PRESETn,
    input [ADDR_SIZE-1:0] PADDR,
    input [DATA_SIZE-1:0] PWDATA,
    input [(DATA_SIZE/8)-1:0] PSTRB,
    output [DATA_SIZE-1:0] PRDATA,
    input write_init,
    output write_finished,
    input read_init,
    output read_finished
    );
    
    reg [7:0] memory[END_ADDR:0];
    
    reg [$clog2(DATA_SIZE)-1:0] data_counter;
    wire [$clog2(DATA_SIZE)-1:0] next_data_counter;
    reg [ADDR_SIZE-1:0] present_addr;
    wire [ADDR_SIZE-1:0] next_addr;
    reg write_ongoing, read_ongoing, adder_valid;
    reg [DATA_SIZE-1:0] PWDATA_reg, PRDATA_reg, PRDATA_r;
    reg [(DATA_SIZE/8)-1:0] PSTRB_reg;
    reg [7:0] temp_mem;
    
    assign PRDATA = PRDATA_r;
    always @ (posedge PCLK or negedge PRESETn)
    begin
        if (!PRESETn)
        begin
            data_counter = 0;
            adder_valid = 0;
            write_ongoing = 0;
            read_ongoing = 0;
        end
        else
        begin
            if ((write_init === 1'b1) && (write_ongoing === 1'b0) && (read_ongoing === 1'b0))
            begin
                write_ongoing <= 1'b1;
                data_counter <= 0;
                present_addr <= PADDR;
                PWDATA_reg <= PWDATA;
                PSTRB_reg <= PSTRB;
                adder_valid <= 1'b1;
            end
            else if ((read_init === 1'b1) && (write_ongoing === 1'b0) && (read_ongoing === 1'b0))
            begin
                read_ongoing <= 1'b1;
                data_counter <= 0;
                present_addr <= PADDR;
                PRDATA_reg <= 0;
                adder_valid <= 1'b1;
            end
            else if (write_ongoing === 1'b1)
            begin
                present_addr <= next_addr;
                if (data_counter === (DATA_SIZE / 8))
                begin
                    adder_valid <= 1'b0;
                    write_ongoing <= 1'b0;
                    data_counter <= 0;
                end
                else
                begin
                    data_counter <= next_data_counter;
                    if (PSTRB_reg[0] === 1'b1)
                    begin
                        memory[present_addr] <= PWDATA_reg[7:0];
                    end
                    PSTRB_reg <= PSTRB_reg >> 1;
                    PWDATA_reg <= PWDATA_reg >> 8;
                end
            end
            else if (read_ongoing === 1'b1)
            begin
                present_addr <= next_addr;
                if (data_counter === (DATA_SIZE / 8))
                begin
                    adder_valid <= 1'b0;
                    write_ongoing <= 1'b0;
                    data_counter <= 0;
                    PRDATA_r <= PRDATA_reg;
                end
                else
                begin
                    data_counter <= next_data_counter;
                    PRDATA_reg[DATA_SIZE-1:DATA_SIZE-8] <= memory[present_addr];
                    PRDATA_reg[DATA_SIZE-9:0] <= PRDATA_reg[DATA_SIZE-1:8];
                    temp_mem <= memory[present_addr];
                end
            end
        end
    end
    
    reg write_finished_r, read_finished_r;
    assign write_finished = write_finished_r;
    assign read_finished = read_finished_r;
    
    always @ (posedge PCLK or negedge PRESETn)
    begin
        if (!PRESETn)
        begin
           write_finished_r = 1'b0; 
        end
        else
        begin
            if (data_counter === (DATA_SIZE / 8))
            begin
                write_finished_r <= write_ongoing;
                read_finished_r <= read_ongoing;
            end
            else
            begin
                write_finished_r <= 1'b0;
                read_finished_r <= 1'b0;
            end
        end
    end
    
    Incrementer #(.SIZE ($clog2(DATA_SIZE))) counter_incr_inst (
        .PCLK       (PCLK),
        .PRESETn    (PRESETn),
        .in         (data_counter),
        .valid      (adder_valid),
        .out        (next_data_counter)
    );
    
    Incrementer #(.SIZE (ADDR_SIZE)) addr_incr_inst (
        .PCLK       (PCLK),
        .PRESETn    (PRESETn),
        .in         (present_addr),
        .valid      (adder_valid),
        .out        (next_addr)
    );
    
endmodule
