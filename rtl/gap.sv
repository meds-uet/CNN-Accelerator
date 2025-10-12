`include "cnn_defs.svh"

module gap(
    input logic clk,
    input logic rst,
    input logic start,

    input logic [DATA_WIDTH-1:0] input_fm [CHANNELS-1:0][POOL_OFMAP_SIZE-1:0][POOL_OFMAP_SIZE-1:0],
    output logic done,
    output logic [DATA_WIDTH-1:0] output_fm [CHANNELS-1:0]
);

    // Internal types
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [$clog2(POOL_OFMAP_SIZE*POOL_OFMAP_SIZE+1)-1:0] counter_t;

    // Accumulators (with more bits to avoid overflow)
    logic [DATA_WIDTH+7:0] sum [CHANNELS-1:0];

    // Index counters
    logic [$clog2(POOL_OFMAP_SIZE)-1:0] h, w;
    logic [$clog2(CHANNELS)-1:0] c;

    gap_state_t state,

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= GAP_IDLE;
            done <= 0;
        end else begin
            case (state)
                GAP_IDLE: begin
                    if (start) begin
                        for (int i = 0; i < CHANNELS; i++) begin
                            sum[i] <= 0;
                        end
                        c <= 0;
                        h <= 0;
                        w <= 0;
                        done <= 0;
                        state <= GAP_ACCUMULATE;
                    end
                end

                GAP_ACCUMULATE: begin
                    sum[c] <= sum[c] + input_fm[c][h][w];

                    if (w == POOL_OFMAP_SIZE - 1) begin
                        w <= 0;
                        if (h == POOL_OFMAP_SIZE - 1) begin
                            h <= 0;
                            if (c == CHANNELS - 1) begin
                                state <= GAP_DONE;
                            end else begin
                                c <= c + 1;
                            end
                        end else begin
                            h <= h + 1;
                        end
                    end else begin
                        w <= w + 1;
                    end
                end

                GAP_DONE: begin
                    for (int i = 0; i < CHANNELS; i++) begin
                        output_fm[i] <= sum[i] / (POOL_OFMAP_SIZE * POOL_OFMAP_SIZE);  // Integer division
                    end
                    done <= 1;
                    state <= GAP_IDLE;
                end
            endcase
        end
    end

endmodule
