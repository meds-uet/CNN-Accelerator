// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem / Talha Ayyaz
// Date:   15/07/2025

`include "cnn_defs.svh"

module maxpool #(
        parameter int IFMAP_HEIGHT = IFMAP_HEIGHT,
        parameter int IFMAP_WIDTH = IFMAP_WIDTH,
        parameter int DATA_WIDTH = DATA_WIDTH
    )(
        input logic clk,
        input logic reset,
        input logic en,
        input logic [DATA_WIDTH-1:0] ifmap [0:IFMAP_HEIGHT-1][0:IFMAP_WIDTH-1],
        output logic [DATA_WIDTH-1:0] ofmap [0:(IFMAP_HEIGHT/2)-1][0:(IFMAP_WIDTH/2)-1],
        output logic done_pool
    );

    localparam int OFMAP_HEIGHT = IFMAP_HEIGHT / 2;
    localparam int OFMAP_WIDTH = IFMAP_WIDTH / 2;
    localparam int TOTAL_WINDOWS = OFMAP_HEIGHT * OFMAP_WIDTH;

    // State machine
    typedef enum logic [1:0] {
        IDLE,
        PROCESSING,
        DONE
    } state_t;

    state_t state, next_state;

    // Address counters
    logic [$clog2(OFMAP_HEIGHT)-1:0] row_addr;
    logic [$clog2(OFMAP_WIDTH)-1:0] col_addr;
    logic [$clog2(TOTAL_WINDOWS):0] window_count;

    // Pipeline registers for 2x2 window
    logic [DATA_WIDTH-1:0] window_data [0:3];
    logic [DATA_WIDTH-1:0] max_result;
    logic result_valid;

    // Address tracking for pipeline
    logic [$clog2(OFMAP_HEIGHT)-1:0] result_row;
    logic [$clog2(OFMAP_WIDTH)-1:0] result_col;

    // State machine
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (en) begin
                    next_state = PROCESSING;
                end
            end
            PROCESSING: begin
                if (window_count >= TOTAL_WINDOWS) begin
                    next_state = DONE;
                end else if (!en) begin
                    next_state = IDLE;
                end
            end
            DONE: begin
                if (!en) begin
                    next_state = IDLE;
                end
            end
        endcase
    end

    // Address generation and control
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            row_addr <= 0;
            col_addr <= 0;
            window_count <= 0;
            done_pool <= 0;
        end else begin
            case (state)
                IDLE: begin
                    row_addr <= 0;
                    col_addr <= 0;
                    window_count <= 0;
                    done_pool <= 0;
                end
                PROCESSING: begin
                    if (window_count < TOTAL_WINDOWS) begin
                        window_count <= window_count + 1;
                        
                        // Generate next address
                        if (col_addr == OFMAP_WIDTH - 1) begin
                            col_addr <= 0;
                            if (row_addr == OFMAP_HEIGHT - 1) begin
                                row_addr <= 0;
                            end else begin
                                row_addr <= row_addr + 1;
                            end
                        end else begin
                            col_addr <= col_addr + 1;
                        end
                    end
                end
                DONE: begin
                    done_pool <= 1;
                end
            endcase
        end
    end

    // Pipeline Stage 1: Load 2x2 window and find max in one cycle
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            window_data[0] <= 0;
            window_data[1] <= 0;
            window_data[2] <= 0;
            window_data[3] <= 0;
            result_valid <= 0;
            result_row <= 0;
            result_col <= 0;
            max_result <= 0;
        end else if (state == PROCESSING && window_count < TOTAL_WINDOWS) begin
            // Load 2x2 window with bounds checking
            window_data[0] <= ifmap[row_addr * 2][col_addr * 2];
            
            if (col_addr * 2 + 1 < IFMAP_WIDTH) begin
                window_data[1] <= ifmap[row_addr * 2][col_addr * 2 + 1];
            end else begin
                window_data[1] <= 0;
            end
            
            if (row_addr * 2 + 1 < IFMAP_HEIGHT) begin
                window_data[2] <= ifmap[row_addr * 2 + 1][col_addr * 2];
            end else begin
                window_data[2] <= 0;
            end
            
            if (row_addr * 2 + 1 < IFMAP_HEIGHT && col_addr * 2 + 1 < IFMAP_WIDTH) begin
                window_data[3] <= ifmap[row_addr * 2 + 1][col_addr * 2 + 1];
            end else begin
                window_data[3] <= 0;
            end
            
            // Store address for this window
            result_row <= row_addr;
            result_col <= col_addr;
            result_valid <= 1;
        end else begin
            result_valid <= 0;
        end
    end

    // Pipeline Stage 2: Find maximum (combinational for this cycle, registered next cycle)
    logic [DATA_WIDTH-1:0] max_01, max_23, final_max;
    logic [DATA_WIDTH-1:0] delayed_max;
    logic [$clog2(OFMAP_HEIGHT)-1:0] delayed_row;
    logic [$clog2(OFMAP_WIDTH)-1:0] delayed_col;
    logic delayed_valid;

    comparator #(.DATA_WIDTH(DATA_WIDTH)) comparator (
        .input1(window_data[0]),
        .input2(window_data[1]),
        .input3(window_data[2]),
        .input4(window_data[3]),
        .max_val(final_max)
    );


    // Register the result for output
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            delayed_max <= 0;
            delayed_row <= 0;
            delayed_col <= 0;
            delayed_valid <= 0;
        end else begin
            delayed_max <= final_max;
            delayed_row <= result_row;
            delayed_col <= result_col;
            delayed_valid <= result_valid;
        end
    end

    // Output assignment
    always_ff @(posedge clk or posedge reset) begin
    if (delayed_valid && delayed_row < OFMAP_HEIGHT && delayed_col < OFMAP_WIDTH) begin
            ofmap[delayed_row][delayed_col] <= delayed_max;
        end
    end

endmodule
