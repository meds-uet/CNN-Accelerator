// `timescale 1ns/1ps
`include "../rtl/cnn_defs.svh"

module cnn_tb;
    // DUT Signals
    logic clk = 0;
    logic reset, en;
    logic           [DATA_WIDTH-1:0]    ifmap   [0:IFMAP_SIZE-1][0:IFMAP_SIZE-1];
    logic signed    [DATA_WIDTH-1:0]    weights     [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1];
    logic           [DATA_WIDTH-1:0]    ofmap   [0:POOL_OFMAP_SIZE-1][0:POOL_OFMAP_SIZE-1]; // +1 due to 0 indexing
    logic done;

    // Clock generation
    always #5 clk = ~clk;

    // DUT instantiation
    cnn_accelerator dut (
        .clk(clk),
        .reset(reset),
        .en(en),
        .cnn_ifmap(ifmap),
        .weights(weights),
        .cnn_ofmap(ofmap),
        .done(done)
    );

    // Dump waveform
    initial begin
        $dumpfile("cnn_wave.vcd");
        $dumpvars(0, cnn_tb);
    end

    // ANSI color macros
    `define RED     "\033[1;31m"
    `define GREEN   "\033[1;32m"
    `define YELLOW  "\033[1;33m"
    `define BLUE    "\033[1;34m"
    `define MAGENTA "\033[1;35m"
    `define CYAN    "\033[1;36m"
    `define RESET   "\033[0m"

    // Pool Test Task
    task automatic run_conv_test();
        int fout;

        begin
            $display(`BLUE, "Starting Convolution Test...", `RESET);

            en    = 0;
            reset = 1;
            #10;
            reset = 0;
            en    = 1;

            $display("Running convolution...");

            wait(done);
            #10;

            fout = $fopen("ofmap.txt", "w");
            if (!fout) $fatal("Failed to open ofmap.txt");

            foreach (ofmap[i]) begin
                foreach (ofmap[i][j]) begin
                    $fwrite(fout, "%0d ", ofmap[i][j]);
                end

                // $fwrite(fout, "%0d ", ofmap[i]);
                $fwrite(fout, "\n");
            end

            $fclose(fout);
            $display(`GREEN, "Output feature map saved to ofmap.txt", `RESET);
            $display(`BLUE, "Test Finished.\n", `RESET);
        end
    endtask

    // Stimulus
    initial begin
        int fd_ifmap = $fopen("ifmap.txt", "r");
        int fd_weights = $fopen("test/imgs/weights.txt", "r");
        if (!fd_ifmap) $fatal("Failed to open ifmap.txt");

        foreach (ifmap[i, j]) begin
            int val;
            if ($fscanf(fd_ifmap, "%d", val) != 1)
                $fatal("Read error at ifmap[%0d][%0d]", i, j);
            ifmap[i][j] = val;
        end
        $fclose(fd_ifmap);

        if (!fd_weights) $fatal("Failed to open weights.txt");

        foreach (weights[i, j]) begin
            int val;
            if ($fscanf(fd_weights, "%d", val) != 1)
                $fatal("Read error at weights[%0d][%0d]", i, j);
            weights[i][j] = val;
        end
        $fclose(fd_weights);

        run_conv_test();

        $finish;
    end

endmodule
