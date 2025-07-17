module conv #(
    parameter int IFMAP_HEIGHT  = 6,
    parameter int IFMAP_WIDTH   = 6,
    parameter int KERNEL_HEIGHT = 3,
    parameter int KERNEL_WIDTH  = 3,
    parameter int DATA_WIDTH    = 8,
    parameter int H_STRIDE      = 1,
    parameter int V_STRIDE      = 1,
    parameter int PADDING       = 1
)(
    input  logic clk,
    input  logic reset,
    input  logic en,
    
    input  logic [DATA_WIDTH-1:0] ifmap [0:IFMAP_HEIGHT-1][0:IFMAP_WIDTH-1],  // UNSIGNED
    input  logic signed [DATA_WIDTH-1:0] weights [0:KERNEL_HEIGHT-1][0:KERNEL_WIDTH-1],  // SIGNED
    output logic [DATA_WIDTH-1:0] ofmap [0:(IFMAP_HEIGHT-KERNEL_HEIGHT+2*PADDING)/V_STRIDE][0:(IFMAP_WIDTH-KERNEL_WIDTH+2*PADDING)/H_STRIDE],

    output logic done_conv
);

    localparam int PADDED_HEIGHT = IFMAP_HEIGHT + 2*PADDING;
    localparam int PADDED_WIDTH  = IFMAP_WIDTH + 2*PADDING;
    localparam int OFMAP_HEIGHT  = (PADDED_HEIGHT - KERNEL_HEIGHT) / V_STRIDE + 1;
    localparam int OFMAP_WIDTH   = (PADDED_WIDTH - KERNEL_WIDTH) / H_STRIDE + 1;

    logic [DATA_WIDTH-1:0] window_data [0:KERNEL_HEIGHT-1][0:KERNEL_WIDTH-1];  // UNSIGNED

    logic signed [21:0] mac_result;

    logic [DATA_WIDTH-1:0] relu_out;

    logic [$clog2(OFMAP_HEIGHT)-1:0] out_row;
    logic [$clog2(OFMAP_WIDTH)-1:0]  out_col;

    logic is_last_pixel;

    typedef enum logic [1:0] {
        STATE_IDLE,
        STATE_PROCESS,
        STATE_DONE
    } conv_state_t;

    conv_state_t current_state, next_state;

    // MAC Unit: must cast unsigned input to signed internally
    mac mac_unit (
        .feature(window_data),
        .kernel(weights),
        .result(mac_result)
    );

    // FSM State Register
    always_ff @(posedge clk or posedge reset) begin
        if (reset || ~en)
            current_state <= STATE_IDLE;
        else
            current_state <= next_state;
    end

    // FSM Next State Logic
    always_comb begin
        next_state = current_state;
        case (current_state)
            STATE_IDLE: 
                if (en)
                    next_state = STATE_PROCESS;
            STATE_PROCESS:
                if (is_last_pixel)
                    next_state = STATE_DONE;
                else    
                    next_state = STATE_PROCESS;
            STATE_DONE:
                next_state = current_state;
        endcase
    end

    // Output Row/Column Counter Logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            out_row <= 0;
            out_col <= 0;
        end else if (en && current_state == STATE_PROCESS) begin
            if (out_col == OFMAP_WIDTH-1) begin
                out_col <= 0;
                out_row <= out_row + 1;
            end else begin
                out_col <= out_col + 1;
            end
        end
    end

    // Load KERNELxKERNEL Window
    always_comb begin
        for (int i = 0; i < KERNEL_HEIGHT; i++) begin
            for (int j = 0; j < KERNEL_WIDTH; j++) begin
                int orig_col, orig_row;
                orig_row = out_row * V_STRIDE + i - PADDING;
                orig_col = out_col * H_STRIDE + j - PADDING;

                if (orig_row < 0 || orig_row >= IFMAP_HEIGHT || 
                    orig_col < 0 || orig_col >= IFMAP_WIDTH) begin
                    window_data[i][j] = '0;  // zero padding
                end else begin
                    window_data[i][j] = ifmap[orig_row][orig_col];
                end
            end
        end
    end


    // ReLU Activation and Output Storage
    always_comb begin
        relu_out = mac_result[DATA_WIDTH-1:0];  // Truncate to 8-bit
        ofmap[out_row][out_col] = relu_out[DATA_WIDTH-1] ? '0 : relu_out;  // ReLU
    end

    assign is_last_pixel = (out_row == OFMAP_HEIGHT-1) && (out_col == OFMAP_WIDTH-1);
    assign done_conv = (current_state == STATE_DONE);

endmodule
