// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem / Talha Ayyaz
// Date:   14/07/2025

`include "cnn_defs.svh"

module maxpool(
    input  logic clk,
    input  logic reset,
    input  logic en,

    input  logic [DATA_WIDTH-1:0] ifmap [0:CONV_OFMAP_SIZE-1][0:CONV_OFMAP_SIZE-1],
    output logic [DATA_WIDTH-1:0] ofmap [0:(CONV_OFMAP_SIZE/2)-1][0:(CONV_OFMAP_SIZE/2)-1],

    output logic done_pool
);

    localparam int OFMAP_HEIGHT = CONV_OFMAP_SIZE / 2;
    localparam int OFMAP_WIDTH  = CONV_OFMAP_SIZE / 2;

    // FSM state
    pool_state_t state, next_state;

    // Position counters
    logic [POOL_COUNTER_SIZE-1:0] out_row, out_col;

    // Maxpool window and result
    logic [DATA_WIDTH-1:0] window [0:1][0:1];
    logic [DATA_WIDTH-1:0] max_val;
    logic maxpool_done;

    logic processing_valid;

    // FSM logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (en)
                    next_state = PROCESSING;
            end
            PROCESSING: begin
                if (maxpool_done && out_row == OFMAP_HEIGHT - 1 && out_col == OFMAP_WIDTH - 1)
                    next_state = DONE;
                else 
                    next_state = PROCESSING;
            end
            DONE: next_state = DONE;
            default: next_state = IDLE;
        endcase
    end

    // Row/Col counter logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            out_row <= 0;
            out_col <= 0;
        end else if (state == PROCESSING && maxpool_done) begin
            if (out_col == OFMAP_WIDTH - 1) begin
                out_col <= 0;
                out_row <= out_row + 1;
            end else begin
                out_col <= out_col + 1;
            end
        end
    end

    // Load 2x2 window
    always_ff @(posedge clk) begin
        if (state == PROCESSING) begin
            window[0][0] <= ifmap[(out_row << 1)][(out_col << 1)];
            window[0][1] <= ifmap[(out_row << 1)][(out_col << 1) + 1];
            window[1][0] <= ifmap[(out_row << 1) + 1][(out_col << 1)];
            window[1][1] <= ifmap[(out_row << 1) + 1][(out_col << 1) + 1];
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            processing_valid <= 0;
        else
            processing_valid <= (state == PROCESSING);  
    end

    // Comparator instance
    comparator comp_inst (
        .in(window),
        .out(max_val),
        .maxpool_done(maxpool_done)
    );


    always_ff @(posedge clk) begin
        if (processing_valid && maxpool_done)
            ofmap[out_row][out_col] <= max_val;
    end

    // Done signal
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            done_pool <= 0;
        else if (state == DONE)
            done_pool <= 1;
        else
            done_pool <= 0;
    end

endmodule
