`include "../rtl/cnn_defs.svh"

module conv_tb1;

    // DUT Signals
    logic clk = 0;
    logic reset, en;
    logic [DATA_WIDTH-1:0] ifmap [0:IFMAP_SIZE-1][0:IFMAP_SIZE-1];
    logic signed [DATA_WIDTH-1:0] kernel [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1];
    logic [DATA_WIDTH-1:0] ofmap [0:CONV_OFMAP_SIZE-1][0:CONV_OFMAP_SIZE-1];
    logic done;

    int error_count = 0, test_count = 0;
    bit verification_complete = 0;

    always #5 clk = ~clk;

    conv dut (
        .clk(clk),
        .reset(reset),
        .en(en),
        .conv_ifmap(ifmap),
        .weights(kernel),
        .conv_ofmap(ofmap),
        .conv_done(done)
    );


    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, dut);
    end

    // Colors
    `define RED     "\033[1;31m"
    `define GREEN   "\033[1;32m"
    `define YELLOW  "\033[1;33m"
    `define BLUE    "\033[1;34m"
    `define MAGENTA "\033[1;35m"
    `define CYAN    "\033[1;36m"
    `define RESET   "\033[0m"

    // Expected Output
    function automatic [7:0] get_expected_pixel(int conv_window_row, int conv_window_col);
        int sum = 0;

        for (int i = 0; i < KERNEL_SIZE; i++) begin
            for (int j = 0; j < KERNEL_SIZE; j++) begin
                int in_row = conv_window_row * STRIDE + i - PADDING;
                int in_col = conv_window_col * STRIDE + j - PADDING;

                int val;
                if (in_row < 0 || in_row >= IFMAP_SIZE || in_col < 0 || in_col >= IFMAP_SIZE)
                    val = 0;  // padding with 0
                else
                    val = ifmap[in_row][in_col];

                sum += val * kernel[i][j];
            end
        end

        if (sum < 0)
            return 8'd0;
        else if (sum > 255)
            return 8'd255;
        else
            return sum[7:0];
    endfunction


    // Verification Logic
    always @(posedge clk) begin
        if (dut.conv_current_state == STATE_PROCESS) begin
            automatic logic [7:0] expected = get_expected_pixel(dut.conv_window_row, dut.conv_window_col);
            automatic logic [7:0] actual   = ofmap[dut.conv_window_row][dut.conv_window_col];
            test_count++;

            #1;
            if (actual !== expected) begin
                error_count++;
                $display(`RED, "Mismatch at [%0d][%0d] - Expected: %0d, Got: %0d", dut.conv_window_row, dut.conv_window_col, expected, actual, `RESET);
            end else begin
                $display(`GREEN, "Match at [%0d][%0d] - %0d", dut.conv_window_row, dut.conv_window_col, actual, `RESET);
            end
        end

        if (done && !verification_complete) begin
            verification_complete = 1;
            #10;
            if (test_count != CONV_OFMAP_SIZE * CONV_OFMAP_SIZE)
                $display(`YELLOW, "Only %0d/%0d outputs verified!", test_count, CONV_OFMAP_SIZE * CONV_OFMAP_SIZE, `RESET);

            if (error_count == 0)
                $display(`CYAN, "\nTEST PASSED: All %0d outputs matched.\n", test_count, `RESET);
            else
                $display(`RED, "\nTEST FAILED: %0d errors out of %0d tests.\n", error_count, test_count, `RESET);

            for (int i = 0; i < CONV_OFMAP_SIZE; i++) begin
                for (int j = 0; j < CONV_OFMAP_SIZE; j++) begin
                    if (ofmap[i][j] == 8'd255)
                        $display(`MAGENTA, "Value clipped to 255 at [%0d][%0d]", i, j, `RESET);
                end
            end
        end
    end

    // Task for test run
    task automatic run_convolution_test();
        begin
            $display(`BLUE, "Starting Convolution Test...", `RESET);

            en    = 0;
            reset = 1;
            #10;
            reset = 0;
            en    = 1;

            $display("Running with %0dx%0d input and %0dx%0d kernel...", IFMAP_SIZE, IFMAP_SIZE, KERNEL_SIZE, KERNEL_SIZE);

            wait(done);
            #10;

            $display(`YELLOW, "\nFinal Output Feature Map:", `RESET);
            for (int i = 0; i < CONV_OFMAP_SIZE; i++) begin
                for (int j = 0; j < CONV_OFMAP_SIZE; j++) begin
                    $write("%4d", ofmap[i][j]);
                end
                $display();
            end

            $display(`BLUE, "Test Finished.\n", `RESET);
        end
    endtask

    // Stimulus
    initial begin
        ifmap = '{
            '{2, 4, 2, 4, 3, 1},
            '{1, 0, 3, 2, 2, 1},
            '{2, 4, 2, 4, 3, 1},
            '{1, 0, 3, 2, 2, 1},
            '{2, 4, 2, 4, 3, 1},
            '{1, 0, 3, 2, 2, 1}
        };
        kernel = '{
            '{8'sd1,  8'sd0, -8'sd1},
            '{8'sd2,  8'sd0, -8'sd2},
            '{8'sd1,  8'sd0, -8'sd1}
        };
        run_convolution_test();

        // Add more tests as needed using same pattern

        $finish;
    end

endmodule
