// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem & Talha Ayyaz
// Date:   14/07/2025

`include "cnn_defs.svh"

module maxpool (
    input  logic clk,
    input  logic reset,
    input  logic en,
    
    input  logic [DATA_WIDTH-1:0] ifmap  [0:CONV_OFMAP_SIZE-1][0:CONV_OFMAP_SIZE-1],
    
    output logic [DATA_WIDTH-1:0] ofmap  [0:(CONV_OFMAP_SIZE/2)-1][0:(CONV_OFMAP_SIZE/2)-1],
    
    output logic done_pool
);

    localparam int OFMAP_HEIGHT = CONV_OFMAP_SIZE / 2;
    localparam int OFMAP_WIDTH  = CONV_OFMAP_SIZE / 2;

    logic [DATA_WIDTH-1:0]        window           [0:1][0:1];
    logic [DATA_WIDTH-1:0]        max_val;
    
    logic [POOL_COUNTER_SIZE-1:0] out_row;
    logic [POOL_COUNTER_SIZE-1:0] out_col;
    
    logic                         maxpool_done;
    logic                         processing_valid;
    
    pool_state_t                  state, next_state;


    // Comparator Unit
    comparator comp_inst (
        .in(window),
        .out(max_val),
        .maxpool_done(maxpool_done)
    );


    // FSM State Register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pool_current_state <= POOL_IDLE;
        end else begin
            pool_current_state <= pool_next_state;
        end
    end

    always_comb begin
        pool_next_state = pool_current_state;
        case (pool_current_state)
            POOL_IDLE: begin
                if (en) begin
                    pool_next_state = POOL_PROCESS;
                end
            end
            POOL_PROCESS: begin
                if (window_count >= POOL_PIXEL_COUNT) begin
                    pool_next_state = POOL_DONE;
                end else if (!en) begin
                    pool_next_state = POOL_IDLE;
                end
            end
            POOL_DONE: begin
                if (!en) begin
                    pool_next_state = POOL_IDLE;
                end
            end
            default: pool_next_state = POOL_IDLE;
        endcase
    end


    // Output Row/Column Counter Logic
    always_ff @(posedge clk or posedge reset) begin
        
        if (reset) begin
            pool_window_row <= 0;
            pool_window_col <= 0;
            window_count <= 0;
            pool_done <= 0;
        end else begin
            case (pool_current_state)
                POOL_IDLE: begin
                    pool_window_row <= 0;
                    pool_window_col <= 0;
                    window_count <= 0;
                    pool_done <= 0;
                end
                POOL_PROCESS: begin
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
                POOL_DONE: begin
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
        end else if (pool_current_state == POOL_PROCESS && 32'(window_count) < POOL_PIXEL_COUNT) begin
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

    comparator comparator (
        .input1(pool_window[0]),
        .input2(pool_window[1]),
        .input3(pool_window[2]),
        .input4(pool_window[3]),
        .max_val(final_max)
    );


    // Register the result for output
    always_ff @(posedge clk or posedge reset) begin
        
        if (reset)
            processing_valid <= 0;
        
        else
            processing_valid <= (state == PROCESSING);
    end


    // Output Storage
    always_ff @(posedge clk) begin
        
        if (processing_valid && maxpool_done)
            ofmap[out_row][out_col] <= max_val;
    end


    // Done Signal
    always_ff @(posedge clk or posedge reset) begin
        
        if (reset)
            done_pool <= 0;
        
        else if (state == DONE)
            done_pool <= 1;
        
        else
            done_pool <= 0;
    end

endmodule