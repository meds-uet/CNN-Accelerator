// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem & Talha Ayyaz
// Date:   03/07/2025

`include "cnn_defs.svh"

module conv (
    input  logic clk,
    input  logic reset,
    input  logic en,
    
    input  logic        [DATA_WIDTH-1:0] conv_ifmap     [0:IFMAP_SIZE-1][0:IFMAP_SIZE-1],           // UNSIGNED
    input  logic signed [DATA_WIDTH-1:0] weights        [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1],         // SIGNED

    output logic        [DATA_WIDTH-1:0] conv_ofmap     [0:CONV_OFMAP_SIZE-1][0:CONV_OFMAP_SIZE-1],

    output logic conv_done
);


    logic           [DATA_WIDTH-1:0]            conv_window     [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1];  // UNSIGNED

    logic signed    [MAC_RESULT_WIDTH-1:0]      mac_result;

    logic           [DATA_WIDTH-1:0]            relu_out;

    logic           [CONV_COUNTER_SIZE-1:0]     conv_window_row;
    logic           [CONV_COUNTER_SIZE-1:0]     conv_window_col;

    logic           is_last_pixel;

    conv_state_t    conv_current_state, conv_next_state;
    logic           is_process, is_done;

    int targeted_col, targeted_row;



    // MAC Unit: must cast unsigned input to signed internally
    mac mac_unit (
        .feature(conv_window),
        .kernel(weights),
        .result(mac_result)
    );

    // always @(clk) $display("Window @[%0d][%0d] [%0d][%0d]: \n%0d %0d %0d\n%0d %0d %0d\n%0d %0d %0d", 
    // conv_window_row, conv_window_col, targeted_row, targeted_col,
    // conv_window[0][0], conv_window[0][1], conv_window[0][2],
    // conv_window[1][0], conv_window[1][1], conv_window[1][2],
    // conv_window[2][0], conv_window[2][1], conv_window[2][2]);


    // FSM State Register
    always_ff @(posedge clk or posedge reset) begin

        if (reset)
            conv_current_state <= STATE_IDLE;

        else
            conv_current_state <= conv_next_state;
    end


    // FSM Next State Logic
    always_comb begin

        case (conv_current_state)
            STATE_IDLE: 
                if (en)
                    conv_next_state = STATE_PROCESS;

            STATE_PROCESS:
                if (is_last_pixel)
                    conv_next_state = STATE_DONE;
                else    
                    conv_next_state = STATE_PROCESS;

            STATE_DONE:
                conv_next_state = conv_current_state;
                
            default:
                conv_next_state = conv_current_state;

        endcase
    end


    // State Output Logic
    always_comb begin
        
        case (conv_current_state)
            STATE_PROCESS: begin
                is_process  = 1;
                is_done     = 0;
            end

            STATE_DONE: begin
                is_process  = 0;
                is_done     = 1; 
            end

            default: begin
                is_process  = 0;
                is_done     = 0;
            end
        endcase
    end


    // Output Row/Column Counter Logic
    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            conv_window_row <= 0;
            conv_window_col <= 0;
        end 
        
        else if (en && is_process) begin

            if ( 32'(conv_window_col) == CONV_OFMAP_SIZE-1) begin
                conv_window_col <= 0;
                conv_window_row <= conv_window_row + 1;
            end
            
            else
                conv_window_col <= conv_window_col + 1;
            
        end
    end


    // Load KERNELxKERNEL Window
    always_comb begin

        for (int i = 0; i < KERNEL_SIZE; i++) begin
            for (int j = 0; j < KERNEL_SIZE; j++) begin

                if (STRIDE == 2) begin
                    targeted_row =  (32'(conv_window_row) << 1) + i - PADDING;
                    targeted_col =  (32'(conv_window_col) << 1) + j - PADDING;
                end
                
                else begin
                    targeted_row =  32'(conv_window_row) + i - PADDING;
                    targeted_col =  32'(conv_window_col) + j - PADDING;
                end

                if (targeted_row < 0 || targeted_row >= IFMAP_SIZE || targeted_col < 0 || targeted_col >= IFMAP_SIZE)
                    conv_window[i][j] = '0;  // zero padding
                
                
                else 
                    conv_window[i][j] = conv_ifmap[targeted_row][targeted_col];

            end
        end
    end


    // ReLU Activation and Output Storage
    always_comb begin

        relu_out = mac_result[DATA_WIDTH-1:0];  // Truncate to 8-bit

        if (relu_out[DATA_WIDTH-1])
            conv_ofmap[conv_window_row][conv_window_col] = 0;

        else
            conv_ofmap[conv_window_row][conv_window_col] = relu_out;

    end

    assign is_last_pixel    = ( 32'(conv_window_row) == CONV_OFMAP_SIZE-1) && ( 32'(conv_window_col) == CONV_OFMAP_SIZE-1);
    assign conv_done        = is_done;

endmodule
