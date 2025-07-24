// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem & Talha Ayyaz
// Date:   16/07/2025

`include "cnn_defs.svh"

module cnn_accelerator (
    input  logic clk,
    input  logic reset,
    input  logic en,

    input  logic        [DATA_WIDTH-1:0]    cnn_ifmap   [0:IFMAP_SIZE-1][0:IFMAP_SIZE-1],                   // Unsigned
    input  logic signed [DATA_WIDTH-1:0]    weights     [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1],                 // Signed

    output logic        [DATA_WIDTH-1:0]    cnn_ofmap   [0:POOL_OFMAP_SIZE-1][0:POOL_OFMAP_SIZE-1],         // Final Output

    output logic done
);

    // Intermediate signal from conv to maxpool
    logic [DATA_WIDTH-1:0] conv_ofmap [0:CONV_OFMAP_SIZE-1][0:CONV_OFMAP_SIZE-1];
    logic conv_done, done_pool;

    // Conv Layer
    conv conv_inst (
        .clk        (clk),
        .reset      (reset),
        .en         (en),
        .conv_ifmap (cnn_ifmap),
        .weights    (weights),
        .conv_ofmap (conv_ofmap),
        .conv_done  (conv_done)
    );

    // MaxPool Layer
    maxpool maxpool_inst (
        .clk        (clk),
        .reset      (reset),
        .en         (conv_done),
        .pool_ifmap (conv_ofmap),
        .pool_ofmap (cnn_ofmap),
        .pool_done  (done_pool)
    );

    assign done = done_pool;

endmodule
