// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem / Talha Ayyaz
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


    logic           [DATA_WIDTH-1:0]    window_data     [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1];  // UNSIGNED

    logic signed    [MAC_WIDTH-1:0]     mac_result;

    logic           [DATA_WIDTH-1:0]    relu_out;

    logic           [CONV_COUNTER_SIZE-1:0]     out_row;
    logic           [CONV_COUNTER_SIZE-1:0]     out_col;

    logic           is_last_pixel;

    conv_state_t    current_state, next_state;
    logic           is_process, is_done;


    // MAC Unit: must cast unsigned input to signed internally
    mac mac_unit (
        .feature(window_data),
        .kernel(weights),
        .result(mac_result)
    );


    // FSM State Register
    always_ff @(posedge clk or posedge reset) begin

        if (reset)
            current_state <= STATE_IDLE;

        else
            current_state <= next_state;
    end


    // FSM Next State Logic
    always_comb begin

        case (current_state)
            STATE_IDLE: 
                if (en)
                    next_state = STATE_PROCESS;

            STATE_PROCESS:
                if (is_last_pixel)
                    next_state = STATE_DONE;
                else    
                    next_state = STATE_PROCESS;

            STATE_DONE:
                next_state = current_state;
                
            default:
                next_state = current_state;

        endcase
    end


    // State Output Logic
    always_comb begin
        
        case (current_state)
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
            out_row <= 0;
            out_col <= 0;
        end 
        
        else if (en && is_process) begin

            if ( 32'(out_col) == CONV_OFMAP_SIZE-1) begin
                out_col <= 0;
                out_row <= out_row + 1;
            end
            
            else
                out_col <= out_col + 1;
            
        end
    end


    // Load KERNELxKERNEL Window
    always_comb begin

        for (int i = 0; i < KERNEL_SIZE; i++) begin
            for (int j = 0; j < KERNEL_SIZE; j++) begin

                int targeted_col, targeted_row;

                if (STRIDE == 2) begin
                    targeted_row =  32'(out_row) << 1 + i - PADDING;
                    targeted_col =  32'(out_col) << 1 + j - PADDING;
                end
                
                else begin
                    targeted_row =  32'(out_row) + i - PADDING;
                    targeted_col =  32'(out_col) + j - PADDING;
                end

                if (targeted_row < 0 || targeted_row >= IFMAP_SIZE || targeted_col < 0 || targeted_col >= IFMAP_SIZE)
                    window_data[i][j] = '0;  // zero padding
                
                
                else 
                    window_data[i][j] = conv_ifmap[targeted_row][targeted_col];

            end
        end
    end


    // ReLU Activation and Output Storage
    always_comb begin

        relu_out = mac_result[DATA_WIDTH-1:0];  // Truncate to 8-bit

        if (relu_out[DATA_WIDTH-1])
            conv_ofmap[out_row][out_col] = 0;

        else
            conv_ofmap[out_row][out_col] = relu_out;

    end

    assign is_last_pixel    = ( 32'(out_row) == CONV_OFMAP_SIZE-1) && ( 32'(out_col) == CONV_OFMAP_SIZE-1);
    assign conv_done        = is_done;

endmodule
