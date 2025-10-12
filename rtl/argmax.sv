`include "cnn_defs.svh"

module argmax(
    input  logic [DATA_WIDTH-1:0] data_in [CHANNELS],
    output logic [INDEX_WIDTH-1:0] max_index,
    output logic [DATA_WIDTH-1:0]  max_value
);

    // Internal registers
    int idx;
    logic [DATA_WIDTH-1:0] current_max;
    logic [INDEX_WIDTH-1:0] current_index;

    always_comb begin
        current_max   = data_in[0];
        current_index = 0;

        for (idx = 1; idx < CHANNELS; idx++) begin
            if (data_in[idx] > current_max) begin
                current_max   = data_in[idx];
                current_index = idx;
            end
        end

        max_index = current_index;
        max_value = current_max;
    end

endmodule
