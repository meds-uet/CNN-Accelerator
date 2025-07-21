// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem / Talha Ayyaz
// Date:   17/07/2025

`include "cnn_defs.svh"

module flatten #(
    parameter int ROW = OFMAP_WIDTH,
    parameter int COL = OFMAP_HEIGHT,
    parameter int DATA_WIDTH = DATA_WIDTH
)(
    input  logic [DATA_WIDTH-1:0] feature [0:ROW-1][0:COL-1],
    output logic [DATA_WIDTH-1:0] flatten [0:ROW*COL-1]
);

    genvar i, j;
    generate
        for (i = 0; i < ROW; i++) begin 
            for (j = 0; j < COL; j++) begin 
                localparam int FLAT_INDEX = i * COL + j;
                assign flatten[FLAT_INDEX] = feature[i][j];
            end
        end
    endgenerate

endmodule
