// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem / Talha Ayyaz
// Date:   15/07/2025

`include "cnn_defs.svh"

module maxpool (
        input   logic   clk,
        input   logic   reset,
        input   logic   en,
        input   logic   [DATA_WIDTH-1:0]    pool_ifmap   [0:CONV_OFMAP_SIZE-1][0:CONV_OFMAP_SIZE-1],

        output  logic   [DATA_WIDTH-1:0]    pool_ofmap   [0:POOL_OFMAP_SIZE-1][0:POOL_OFMAP_SIZE-1],

        output  logic   pool_done
    );

    pool_state_t pool_current_state, pool_next_state;

    // Address counters
    logic [POOL_COUNTER_SIZE-1:0] pool_window_row;
    logic [POOL_COUNTER_SIZE-1:0] pool_window_col;
    logic [$clog2(POOL_PIXEL_COUNT):0] window_count;

    // Pipeline registers for 2x2 window
    logic [DATA_WIDTH-1:0] pool_window [0:3];
    logic [DATA_WIDTH-1:0] max_result;
    logic result_valid;

    // Address tracking for pipeline
    logic [POOL_COUNTER_SIZE-1:0] result_row;
    logic [POOL_COUNTER_SIZE-1:0] result_col;

    // State machine
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pool_current_state <= IDLE;
        end else begin
            pool_current_state <= pool_next_state;
        end
    end

    always_comb begin
        pool_next_state = pool_current_state;
        case (pool_current_state)
            IDLE: begin
                if (en) begin
                    pool_next_state = PROCESSING;
                end
            end
            PROCESSING: begin
                if (window_count >= POOL_PIXEL_COUNT) begin
                    pool_next_state = DONE;
                end else if (!en) begin
                    pool_next_state = IDLE;
                end
            end
            DONE: begin
                if (!en) begin
                    pool_next_state = IDLE;
                end
            end
            default: pool_next_state = IDLE;
        endcase
    end

    // Address generation and control
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pool_window_row <= 0;
            pool_window_col <= 0;
            window_count <= 0;
            pool_done <= 0;
        end else begin
            case (pool_current_state)
                IDLE: begin
                    pool_window_row <= 0;
                    pool_window_col <= 0;
                    window_count <= 0;
                    pool_done <= 0;
                end
                PROCESSING: begin
                    if (window_count < POOL_PIXEL_COUNT) begin
                        window_count <= window_count + 1;
                        
                        // Generate next address
                        if (pool_window_col == POOL_OFMAP_SIZE - 1) begin
                            pool_window_col <= 0;
                            if (pool_window_row == POOL_OFMAP_SIZE - 1) begin
                                pool_window_row <= 0;
                            end else begin
                                pool_window_row <= pool_window_row + 1;
                            end
                        end else begin
                            pool_window_col <= pool_window_col + 1;
                        end
                    end
                end
                DONE: begin
                    pool_done <= 1;
                end
            endcase
        end
    end

    // Pipeline Stage 1: Load 2x2 window and find max in one cycle
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pool_window[0] <= 0;
            pool_window[1] <= 0;
            pool_window[2] <= 0;
            pool_window[3] <= 0;
            result_valid <= 0;
            result_row <= 0;
            result_col <= 0;
            max_result <= 0;
        end else if (pool_current_state == PROCESSING && 32'(window_count) < POOL_PIXEL_COUNT) begin
            // Load 2x2 window with bounds checking
            pool_window[0] <= pool_ifmap[pool_window_row * 2][pool_window_col * 2];
            
            if (pool_window_col * 2 + 1 < CONV_OFMAP_SIZE) begin
                pool_window[1] <= pool_ifmap[pool_window_row * 2][pool_window_col * 2 + 1];
            end else begin
                pool_window[1] <= 0;
            end
            
            if (pool_window_row * 2 + 1 < CONV_OFMAP_SIZE) begin
                pool_window[2] <= pool_ifmap[pool_window_row * 2 + 1][pool_window_col * 2];
            end else begin
                pool_window[2] <= 0;
            end
            
            if (pool_window_row * 2 + 1 < CONV_OFMAP_SIZE && pool_window_col * 2 + 1 < CONV_OFMAP_SIZE) begin
                pool_window[3] <= pool_ifmap[pool_window_row * 2 + 1][pool_window_col * 2 + 1];
            end else begin
                pool_window[3] <= 0;
            end
            
            // Store address for this window
            result_row <= pool_window_row;
            result_col <= pool_window_col;
            result_valid <= 1;
        end else begin
            result_valid <= 0;
        end
    end

    // Pipeline Stage 2: Find maximum (combinational for this cycle, registered next cycle)
    logic [DATA_WIDTH-1:0] max_01, max_23, final_max;
    logic [DATA_WIDTH-1:0] delayed_max;
    logic [$clog2(POOL_OFMAP_SIZE)-1:0] delayed_row;
    logic [$clog2(POOL_OFMAP_SIZE)-1:0] delayed_col;
    logic delayed_valid;

    comparator #(.DATA_WIDTH(DATA_WIDTH)) comparator (
        .input1(pool_window[0]),
        .input2(pool_window[1]),
        .input3(pool_window[2]),
        .input4(pool_window[3]),
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
    if (delayed_valid && 32'(delayed_row) < POOL_OFMAP_SIZE && 32'(delayed_col) < POOL_OFMAP_SIZE) begin
            pool_ofmap[delayed_row][delayed_col] <= delayed_max;
        end
    end

endmodule
