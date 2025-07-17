// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem / Talha Ayyaz
// Date:   16/07/2025


module cnn_accelerator #(
    parameter int IFMAP_HEIGHT    = 128,
    parameter int IFMAP_WIDTH     = 128,
    parameter int KERNEL_HEIGHT   = 3,
    parameter int KERNEL_WIDTH    = 3,
    parameter int DATA_WIDTH      = 8,
    parameter int H_STRIDE        = 1,
    parameter int V_STRIDE        = 1,
    parameter int PADDING         = 1
)(
    input  logic clk,
    input  logic reset,
    input  logic en,

    input  logic [DATA_WIDTH-1:0] ifmap_in [0:IFMAP_HEIGHT-1][0:IFMAP_WIDTH-1],                        // Unsigned
    input  logic signed [DATA_WIDTH-1:0] weights [0:KERNEL_HEIGHT-1][0:KERNEL_WIDTH-1],               // Signed

    output logic [DATA_WIDTH-1:0] out_feature [0:(IFMAP_HEIGHT-KERNEL_HEIGHT+2*PADDING)/V_STRIDE/2]
                                                  [0:(IFMAP_WIDTH-KERNEL_WIDTH+2*PADDING)/H_STRIDE/2],  // Final Output

    output logic done
);

    localparam int CONV_OUT_HEIGHT = (IFMAP_HEIGHT  - KERNEL_HEIGHT + 2 * PADDING) / V_STRIDE;
    localparam int CONV_OUT_WIDTH  = (IFMAP_WIDTH   - KERNEL_WIDTH  + 2 * PADDING) / H_STRIDE;

    // Intermediate signal from conv to maxpool
    logic [DATA_WIDTH-1:0] conv_out [0:CONV_OUT_HEIGHT][0:CONV_OUT_WIDTH];
    logic done_conv, done_pool;

    // Conv Layer
    conv #(
        .IFMAP_HEIGHT   (IFMAP_HEIGHT),
        .IFMAP_WIDTH    (IFMAP_WIDTH),
        .KERNEL_HEIGHT  (KERNEL_HEIGHT),
        .KERNEL_WIDTH   (KERNEL_WIDTH),
        .DATA_WIDTH     (DATA_WIDTH),
        .H_STRIDE       (H_STRIDE),
        .V_STRIDE       (V_STRIDE),
        .PADDING        (PADDING)
    ) conv_inst (
        .clk        (clk),
        .reset      (reset),
        .en         (en),
        .ifmap      (ifmap_in),
        .weights    (weights),
        .ofmap      (conv_out),
        .done_conv  (done_conv)
    );

    // MaxPool Layer
    maxpool #(
        .IFMAP_HEIGHT (CONV_OUT_HEIGHT + 1), // +1 to match SV indexing
        .IFMAP_WIDTH  (CONV_OUT_WIDTH + 1),
        .DATA_WIDTH   (DATA_WIDTH)
    ) maxpool_inst (
        .clk        (clk),
        .reset      (reset),
        .en         (done_conv),
        .ifmap      (conv_out),
        .ofmap      (out_feature),
        .done_pool  (done_pool)
    );

    assign done = done_pool;

endmodule
