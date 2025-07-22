// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem / Talha Ayyaz
// Date:   14/07/2025

// Multiply-Accumulate Unit
// Performs element-wise multiplication and summation
// of feature window and kernel

`include "cnn_defs.svh"

module mac (
    input  logic         [DATA_WIDTH-1:0]       feature [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1],
    input  logic signed  [DATA_WIDTH-1:0]       kernel  [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1],
    output logic signed  [MAC_RESULT_WIDTH-1:0] result
);

    logic signed    [MAC_PRODUCT_WIDTH-1:0]     products    [0:MAC_PRODUCT_COUNT-1];
    logic signed    [MAC_RESULT_WIDTH-1:0]      temp_sum;

    // Multiplication Stage
    always_comb begin

        int idx = 0;
        for (int i = 0; i < KERNEL_SIZE; i++) 
            for (int j = 0; j < KERNEL_SIZE; j++) 
                products[idx] = feature[i][j] * kernel[i][j];

        idx++;

    end
    

    // Adder Tree
    always_comb begin

        temp_sum = '0;

        for (int i = 0; i < MAC_PRODUCT_COUNT; i++)
            temp_sum = temp_sum + MAC_RESULT_WIDTH'(products[i]);
        
    end

    assign result = temp_sum;

endmodule