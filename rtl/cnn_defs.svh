`ifndef CNN_DEFS_SVH
`define CNN_DEFS_SVH

// -----------------------------------------------------------------------------
// Global CNN Parameters (can be overridden in top-level module)
// -----------------------------------------------------------------------------
parameter int DATA_WIDTH      = 8;
parameter int IFMAP_HEIGHT    = 128;
parameter int IFMAP_WIDTH     = 128;
parameter int KERNEL_HEIGHT   = 3;
parameter int KERNEL_WIDTH    = 3;
parameter int H_STRIDE        = 1;
parameter int V_STRIDE        = 1;
parameter int PADDING         = 1;

// -----------------------------------------------------------------------------
// Derived Parameters
// -----------------------------------------------------------------------------
parameter int PADDED_HEIGHT   = IFMAP_HEIGHT + 2 * PADDING;
parameter int PADDED_WIDTH    = IFMAP_WIDTH  + 2 * PADDING;

parameter int CONV_OUT_HEIGHT = (PADDED_HEIGHT - KERNEL_HEIGHT) / V_STRIDE + 1;
parameter int CONV_OUT_WIDTH  = (PADDED_WIDTH  - KERNEL_WIDTH)  / H_STRIDE + 1;

parameter int POOL_SIZE       = 2;
parameter int POOL_STRIDE     = 2;

parameter int POOL_OUT_HEIGHT = CONV_OUT_HEIGHT / POOL_SIZE;
parameter int POOL_OUT_WIDTH  = CONV_OUT_WIDTH  / POOL_SIZE;

// Width for MAC output: DATA_WIDTH * 2 + log2(KERNEL_HEIGHT * KERNEL_WIDTH)
parameter int MAC_RESULT_WIDTH = (DATA_WIDTH * 2) + $clog2(KERNEL_HEIGHT * KERNEL_WIDTH);

// -----------------------------------------------------------------------------
// Typedefs
// -----------------------------------------------------------------------------
typedef logic [DATA_WIDTH-1:0]           data_t;
typedef logic signed [DATA_WIDTH-1:0]    sdata_t;

typedef data_t ifmap_t       [0:IFMAP_HEIGHT-1][0:IFMAP_WIDTH-1];
typedef sdata_t kernel_t     [0:KERNEL_HEIGHT-1][0:KERNEL_WIDTH-1];
typedef data_t conv_out_t    [0:CONV_OUT_HEIGHT-1][0:CONV_OUT_WIDTH-1];
typedef data_t pool_out_t    [0:POOL_OUT_HEIGHT-1][0:POOL_OUT_WIDTH-1];
typedef data_t flat_out_t    [0:POOL_OUT_HEIGHT * POOL_OUT_WIDTH - 1];

`endif // CNN_DEFS_SVH
