// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem & Talha Ayyaz
// Date:   17/07/2025


`ifndef CNN_DEFS_SVH
`define CNN_DEFS_SVH

// -----------------------------------------------------------------------------
// Global CNN Parameters
// -----------------------------------------------------------------------------
parameter int DATA_WIDTH      = 8;
parameter int IFMAP_SIZE      = 256;
parameter int KERNEL_SIZE     = 3;
parameter int STRIDE          = 1;
parameter int PADDING         = 1;

// -----------------------------------------------------------------------------
// Derived CONV Parameters
// -----------------------------------------------------------------------------

parameter int CONV_OFMAP_SIZE       = (IFMAP_SIZE - KERNEL_SIZE + 2 * PADDING) / STRIDE + 1;
// parameter int MAC_WIDTH             = (DATA_WIDTH * 2) + $clog2(KERNEL_SIZE << 2);               <-- Made for any kernel size -->
parameter int CONV_COUNTER_SIZE     = $clog2(CONV_OFMAP_SIZE);

typedef enum logic [1:0] {
    STATE_IDLE,
    STATE_PROCESS,
    STATE_DONE
} conv_state_t;

// -----------------------------------------------------------------------------
// Derived MAC Parameters
// -----------------------------------------------------------------------------

// parameter int MAC_PRODUCT_COUNT     = KERNEL_SIZE * KERNEL_SIZE;
parameter int MAC_PRODUCT_COUNT     = (KERNEL_SIZE == 3) ? 9 : 25;
parameter int MAC_PRODUCT_WIDTH     = DATA_WIDTH << 1;
parameter int MAC_RESULT_WIDTH      = MAC_PRODUCT_WIDTH + $clog2(MAC_PRODUCT_COUNT);

// -----------------------------------------------------------------------------
// Derived POOL Parameters
// -----------------------------------------------------------------------------

parameter int POOL_OFMAP_SIZE       = CONV_OFMAP_SIZE >> 1;
parameter int POOL_PIXEL_COUNT      = POOL_OFMAP_SIZE * POOL_OFMAP_SIZE;
parameter int POOL_COUNTER_SIZE     = $clog2(POOL_OFMAP_SIZE);            
// parameter int POOL_COUNTER_SIZE     = $clog2(4);

typedef enum logic [1:0] {
    IDLE,
    PROCESSING,
    DONE
} pool_state_t;


`endif