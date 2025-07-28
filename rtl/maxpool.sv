`include "cnn_defs.svh"

module maxpool(
    input  logic clk,
    input  logic reset,
    input  logic en,

    input  logic [DATA_WIDTH-1:0] ifmap [0:IFMAP_HEIGHT-1][0:IFMAP_WIDTH-1],
    output logic [DATA_WIDTH-1:0] ofmap [0:(IFMAP_HEIGHT/POOL_STRIDE)-1][0:(IFMAP_WIDTH/POOL_STRIDE)-1],

    output logic done_pool
);

    localparam int OFMAP_HEIGHT = IFMAP_HEIGHT / POOL_STRIDE;
    localparam int OFMAP_WIDTH  = IFMAP_WIDTH / POOL_STRIDE;

    // FSM state
    pool_state_t state, next_state;

    // Position counters
    logic [POOL_COUNTER_SIZE-1:0] out_row, out_col;

    // Maxpool window and result
    logic [DATA_WIDTH-1:0] window [0:1][0:1];
    logic [DATA_WIDTH-1:0] max_val;
    logic maxpool_done;

    // FSM logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (en)
                    next_state = PROCESSING;
            end
            PROCESSING: begin
                if (maxpool_done && out_row == OFMAP_HEIGHT - 1 && out_col == OFMAP_WIDTH - 1)
                    next_state = DONE;
            end
            DONE: next_state = DONE;
            default: next_state = IDLE;
        endcase
    end

    // Row/Col counter logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            out_row <= 0;
            out_col <= 0;
        end else if (state == PROCESSING && maxpool_done) begin
            if (out_col == OFMAP_WIDTH - 1) begin
                out_col <= 0;
                out_row <= out_row + 1;
            end else begin
                out_col <= out_col + 1;
            end
        end
    end

    // Load 2x2 window
    always_ff @(posedge clk) begin
        if (state == PROCESSING) begin
            window[0][0] <= ifmap[(out_row << 1)][(out_col << 1)];
            window[0][1] <= ifmap[(out_row << 1)][(out_col << 1) + 1];
            window[1][0] <= ifmap[(out_row << 1) + 1][(out_col << 1)];
            window[1][1] <= ifmap[(out_row << 1) + 1][(out_col << 1) + 1];
        end
    end

    // Use comparator
    comparator comp_inst (
        .in(window),
        .out(max_val),
        .maxpool_done(maxpool_done)
    );

    // Write result to ofmap
    always_ff @(posedge clk) begin
        if (state == PROCESSING && maxpool_done)
            ofmap[out_row][out_col] <= max_val;
    end

    // Done signal
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            done_pool <= 0;
        else if (state == DONE)
            done_pool <= 1;
        else
            done_pool <= 0;
    end

endmodule
