// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem / Talha Ayyaz
// Date:   17/07/2025


`ifndef CNN_DEFS_SVH
`define CNN_DEFS_SVH

// -----------------------------------------------------------------------------
// Global CNN Parameters
// -----------------------------------------------------------------------------
parameter int DATA_WIDTH      = 8;
parameter int IFMAP_HEIGHT    = 128;
parameter int IFMAP_WIDTH     = 128;
parameter int KERNEL_HEIGHT   = 3;
parameter int KERNEL_WIDTH    = 3;
parameter int KERNEL_SIZE     = 3;
parameter int H_STRIDE        = 2;
parameter int V_STRIDE        = 2;
parameter int PADDING         = 1;


// -----------------------------------------------------------------------------
// Derived CNN Parameters
// -----------------------------------------------------------------------------

parameter int OFMAP_HEIGHT    = (IFMAP_HEIGHT-KERNEL_HEIGHT+2*PADDING)/V_STRIDE;
parameter int OFMAP_WIDTH     = (IFMAP_WIDTH-KERNEL_WIDTH+2*PADDING)/H_STRIDE;


`endif
