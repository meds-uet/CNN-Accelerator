// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem & Talha Ayyaz
// Date:   13/07/2025


// Comparator 2x2 Module
// Takes a 2x2 matrix of 8-bit unsigned inputs and outputs the maximum value

`include "cnn_defs.svh"

module comparator (
        input   logic   [DATA_WIDTH-1:0] input1, input2, input3, input4,
        output  logic   [DATA_WIDTH-1:0] max_val
    );

    // Intermediate signals
    logic [DATA_WIDTH-1:0] max_top, max_bottom;

    always_comb begin

        if (input1 > input2) 
            max_top = input1; 
        else 
            max_top = input2;
        

        if (input3 > input4) 
            max_bottom = input3; 
        else 
            max_bottom = input4;
        
        if (max_top > max_bottom) 
            max_val = max_top;
        else 
            max_val = max_bottom;

    end

endmodule
