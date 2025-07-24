// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem & Talha Ayyaz
// Date:   17/07/2025

`include "cnn_defs.svh"

module flatten(
    input   logic   [DATA_WIDTH-1:0]    feature     [0:POOL_OFMAP_SIZE-1][0:POOL_OFMAP_SIZE-1],
    output  logic   [DATA_WIDTH-1:0]    flatten_out [0:POOL_PIXEL_COUNT-1]
);

    genvar i, j;
    
    generate
        for (i = 0; i < POOL_OFMAP_SIZE; i++) begin 
            for (j = 0; j < POOL_OFMAP_SIZE; j++) begin 
                localparam int FLAT_INDEX = i * POOL_OFMAP_SIZE + j;
                assign flatten_out[FLAT_INDEX] = feature[i][j];
            end
        end
    endgenerate

endmodule
