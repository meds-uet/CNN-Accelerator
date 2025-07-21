// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem / Talha Ayyaz
// Date:   14/07/2025

/**
 * MAC (Multiply-Accumulate) Module for CNN Kernels
 * -----------------------------------------------
 * - Supports fixed kernel sizes: 3x3 or 5x5
 * - Fully combinational (no pipelining)
 * - Optimized adder tree for minimal delay
 * - Unrolled multiplications for better synthesis
 * - Signed kernel & unsigned feature map inputs
 * 
 * Algorithm:
 * 1. Multiply each kernel weight with corresponding feature map pixel (parallel).
 * 2. Sum all products using a balanced adder tree (logarithmic depth).
 * 3. Output final accumulated result (combinational).
 */

`include "cnn_defs.svh"

module mac #(
    parameter int KERNEL_SIZE = KERNEL_SIZE,   // Supported: 3 or 5
    parameter int DATA_WIDTH = DATA_WIDTH      // Bit-width of input data
)(
    // Inputs
    input  logic [DATA_WIDTH-1:0] feature [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1],  // Feature map (unsigned)
    input  logic signed [DATA_WIDTH-1:0] kernel [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1],  // Kernel weights (signed)
    
    // Output
    output logic signed [DATA_WIDTH*2 + $clog2(KERNEL_SIZE*KERNEL_SIZE)-1:0] result  // Accumulated result (signed)
);

    // ==========================================================================
    // Parameters & Internal Signals
    // ==========================================================================
    localparam int NUM_PRODUCTS = KERNEL_SIZE * KERNEL_SIZE;  // Total multiplications
    localparam int PRODUCT_WIDTH = DATA_WIDTH * 2;            // Multiplier output width
    localparam int RESULT_WIDTH = PRODUCT_WIDTH + $clog2(NUM_PRODUCTS);  // Final result width (prevents overflow)

    // Array to store all multiplication results
    logic signed [PRODUCT_WIDTH-1:0] products [0:NUM_PRODUCTS-1];

    // ==========================================================================
    // Stage 1: Parallel Multiplications (Unrolled for Optimization)
    // ==========================================================================
    generate
        if (KERNEL_SIZE == 3) begin
            // 3x3 Kernel: Unroll all 9 multiplications explicitly
            always_comb begin
                // Row 0
                products[0] = $signed({1'b0, feature[0][0]}) * kernel[0][0];  // feature[0][0] * kernel[0][0]
                products[1] = $signed({1'b0, feature[0][1]}) * kernel[0][1];
                products[2] = $signed({1'b0, feature[0][2]}) * kernel[0][2];
                // Row 1
                products[3] = $signed({1'b0, feature[1][0]}) * kernel[1][0];
                products[4] = $signed({1'b0, feature[1][1]}) * kernel[1][1];
                products[5] = $signed({1'b0, feature[1][2]}) * kernel[1][2];
                // Row 2
                products[6] = $signed({1'b0, feature[2][0]}) * kernel[2][0];
                products[7] = $signed({1'b0, feature[2][1]}) * kernel[2][1];
                products[8] = $signed({1'b0, feature[2][2]}) * kernel[2][2];
            end
        end else if (KERNEL_SIZE == 5) begin
            // 5x5 Kernel: Unroll all 25 multiplications explicitly
            always_comb begin
                // Row 0
                products[0] = $signed({1'b0, feature[0][0]}) * kernel[0][0];
                products[1] = $signed({1'b0, feature[0][1]}) * kernel[0][1];
                products[2] = $signed({1'b0, feature[0][2]}) * kernel[0][2];
                products[3] = $signed({1'b0, feature[0][3]}) * kernel[0][3];
                products[4] = $signed({1'b0, feature[0][4]}) * kernel[0][4];
                // Row 1
                products[5] = $signed({1'b0, feature[1][0]}) * kernel[1][0];
                products[6] = $signed({1'b0, feature[1][1]}) * kernel[1][1];
                products[7] = $signed({1'b0, feature[1][2]}) * kernel[1][2];
                products[8] = $signed({1'b0, feature[1][3]}) * kernel[1][3];
                products[9] = $signed({1'b0, feature[1][4]}) * kernel[1][4];
                // Row 2
                products[10] = $signed({1'b0, feature[2][0]}) * kernel[2][0];
                products[11] = $signed({1'b0, feature[2][1]}) * kernel[2][1];
                products[12] = $signed({1'b0, feature[2][2]}) * kernel[2][2];
                products[13] = $signed({1'b0, feature[2][3]}) * kernel[2][3];
                products[14] = $signed({1'b0, feature[2][4]}) * kernel[2][4];
                // Row 3
                products[15] = $signed({1'b0, feature[3][0]}) * kernel[3][0];
                products[16] = $signed({1'b0, feature[3][1]}) * kernel[3][1];
                products[17] = $signed({1'b0, feature[3][2]}) * kernel[3][2];
                products[18] = $signed({1'b0, feature[3][3]}) * kernel[3][3];
                products[19] = $signed({1'b0, feature[3][4]}) * kernel[3][4];
                // Row 4
                products[20] = $signed({1'b0, feature[4][0]}) * kernel[4][0];
                products[21] = $signed({1'b0, feature[4][1]}) * kernel[4][1];
                products[22] = $signed({1'b0, feature[4][2]}) * kernel[4][2];
                products[23] = $signed({1'b0, feature[4][3]}) * kernel[4][3];
                products[24] = $signed({1'b0, feature[4][4]}) * kernel[4][4];
            end
        end
    endgenerate

    // ==========================================================================
    // Stage 2: Balanced Adder Tree (Combinational Summation)
    // ==========================================================================
    logic signed [RESULT_WIDTH-1:0] sum;  // Final accumulated result

    generate
        if (KERNEL_SIZE == 3) begin
            // 3x3 Kernel: 9 multiplications → 4+2+1 additions (3 levels)
            logic signed [RESULT_WIDTH-1:0] stage1 [0:3];  // Level 1 adders
            logic signed [RESULT_WIDTH-1:0] stage2 [0:1];  // Level 2 adders

            always_comb begin
                // Level 1: Pairwise additions (4 operations)
                stage1[0] = products[0] + products[1];  // P0 + P1
                stage1[1] = products[2] + products[3];  // P2 + P3
                stage1[2] = products[4] + products[5];  // P4 + P5
                stage1[3] = products[6] + products[7];  // P6 + P7

                // Level 2: Further reduce (2 operations)
                stage2[0] = stage1[0] + stage1[1];  // (P0+P1) + (P2+P3)
                stage2[1] = stage1[2] + stage1[3];  // (P4+P5) + (P6+P7)

                // Final: Sum all + remaining product
                sum = stage2[0] + stage2[1] + products[8];  // (P0+P1+P2+P3) + (P4+P5+P6+P7) + P8
            end
        end else if (KERNEL_SIZE == 5) begin
            // 5x5 Kernel: 25 multiplications → 12+6+3+1 additions (4 levels)
            logic signed [RESULT_WIDTH-1:0] stage1 [0:11];  // Level 1 adders (12 ops)
            logic signed [RESULT_WIDTH-1:0] stage2 [0:5];   // Level 2 adders (6 ops)
            logic signed [RESULT_WIDTH-1:0] stage3 [0:2];   // Level 3 adders (3 ops)

            always_comb begin
                // Level 1: First reduction (12 additions)
                for (int i = 0; i < 12; i++) begin
                    stage1[i] = products[2*i] + products[2*i+1];  // P0+P1, P2+P3, ..., P22+P23
                end

                // Level 2: Second reduction (6 additions)
                for (int i = 0; i < 6; i++) begin
                    stage2[i] = stage1[2*i] + stage1[2*i+1];  // (P0+P1)+(P2+P3), ..., (P20+P21)+(P22+P23)
                end

                // Level 3: Third reduction (3 additions)
                for (int i = 0; i < 3; i++) begin
                    stage3[i] = stage2[2*i] + stage2[2*i+1];  // (P0+...+P3)+(P4+...+P7), etc.
                end

                // Final: Sum all + remaining product (P24)
                sum = stage3[0] + stage3[1] + stage3[2] + products[24];  // P0+...+P23 + P24
            end
        end
    endgenerate

    // Output Assignment
    assign result = sum;

endmodule