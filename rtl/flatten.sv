module flatten #(
    parameter int ROW = 6,
    parameter int COL = 6,
    parameter int DATA_WIDTH = 8
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
