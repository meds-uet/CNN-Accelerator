`include "../rtl/cnn_defs.svh"

module flatten_tb;

    // Parameters from cnn_defs.svh (example values if not defined)
    parameter DATA_WIDTH = 8;
    parameter POOL_OFMAP_SIZE = 2;  // 2x2 pool output
    parameter POOL_PIXEL_COUNT = POOL_OFMAP_SIZE * POOL_OFMAP_SIZE;

    // Testbench signals
    logic [DATA_WIDTH-1:0] feature_array [0:POOL_OFMAP_SIZE-1][0:POOL_OFMAP_SIZE-1];
    logic [DATA_WIDTH-1:0] flattened [0:POOL_PIXEL_COUNT-1];
    
    // Instantiate DUT
    flatten dut (
        .feature(feature_array),
        .flatten_out(flattened)
    );

    // Test stimulus
    initial begin
        $display("Starting flatten module test...");
        
        // Test Case 1: Simple sequential values
        feature_array[0][0] = 8'h01;
        feature_array[0][1] = 8'h02;
        feature_array[1][0] = 8'h03;
        feature_array[1][1] = 8'h04;
        
        #10;
        $display("Test Case 1:");
        $display("Input 2D Array:");
        $display("[ %0d %0d ]", feature_array[0][0], feature_array[0][1]);
        $display("[ %0d %0d ]", feature_array[1][0], feature_array[1][1]);
        $display("Flattened Output:");
        for (int i = 0; i < POOL_PIXEL_COUNT; i++) begin
            $display("flattened[%0d] = %0d", i, flattened[i]);
        end
        
        // Verify outputs
        if (flattened[0] !== 8'h01 || flattened[1] !== 8'h02 || 
            flattened[2] !== 8'h03 || flattened[3] !== 8'h04) begin
            $error("Test Case 1 Failed!");
        end

        // Test Case 2: Random values
        feature_array[0][0] = $random;
        feature_array[0][1] = $random;
        feature_array[1][0] = $random;
        feature_array[1][1] = $random;
        
        #10;
        $display("\nTest Case 2 (Random Values):");
        $display("Input 2D Array:");
        $display("[ %0d %0d ]", feature_array[0][0], feature_array[0][1]);
        $display("[ %0d %0d ]", feature_array[1][0], feature_array[1][1]);
        $display("Flattened Output:");
        for (int i = 0; i < POOL_PIXEL_COUNT; i++) begin
            $display("flattened[%0d] = %0d", i, flattened[i]);
        end
        
        // Verify outputs
        if (flattened[0] !== feature_array[0][0] || 
            flattened[1] !== feature_array[0][1] ||
            flattened[2] !== feature_array[1][0] || 
            flattened[3] !== feature_array[1][1]) begin
            $error("Test Case 2 Failed!");
        end

        $display("\nFlatten module test completed!");
        $finish;
    end

endmodule