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
    // input  logic signed [DATA_WIDTH-1:0]    fc_weights     [0:NUM_CLASSES-1][0:POOL_PIXEL_COUNT-1],
    // input  logic signed [FC_BIAS_WIDTH-1:0] fc_bias        [0:NUM_CLASSES-1],

    output logic [DATA_WIDTH-1:0]  cnn_ofmap  [0:POOL_OFMAP_SIZE-1][0:POOL_OFMAP_SIZE-1],         // Final Output


    // output logic        [DATA_WIDTH-1:0]    cnn_ofmap   [0:POOL_PIXEL_COUNT-1],
    // output logic signed [FC_MAC_WIDTH-1:0]  fc_out   [0:NUM_CLASSES-1],

    output logic done
);

    // Intermediate signal from conv to maxpool
    logic [DATA_WIDTH-1:0]  conv_ofmap  [0:CONV_OFMAP_SIZE-1][0:CONV_OFMAP_SIZE-1];
    // logic [DATA_WIDTH-1:0]  pool_ofmap  [0:POOL_OFMAP_SIZE-1][0:POOL_OFMAP_SIZE-1];         // Final Output
    logic conv_done, pool_done;

    // Conv Layer
    conv conv_inst (
        .clk        (clk),
        .reset      (reset),
        .en         (en && !conv_done),
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
        .pool_done  (done)
    );

    // flatten flatten_inst(
    //     .flatten_in(pool_ofmap),
    //     .flatten_out(cnn_ofmap)
    // );

    // fc_layer fc_inst(
    //     .clk(clk),
    //     .reset(reset),
    //     .en(pool_done),
    //     .fc_in(cnn_ofmap),
    //     .fc_bias(fc_bias),
    //     .fc_weights(fc_weights),
    //     .fc_out(fc_out),
    //     .done(done)

    // );

    // assign done = pool_done;

endmodule
