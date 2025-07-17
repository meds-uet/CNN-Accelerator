module cnn_tb;

    // CONFIGURABLE PARAMETERS
    localparam int IFMAP_HEIGHT  = 128;
    localparam int IFMAP_WIDTH   = 128;
    localparam int KERNEL_HEIGHT = 3;
    localparam int KERNEL_WIDTH  = 3;
    localparam int DATA_WIDTH    = 8;
    localparam int H_STRIDE      = 1;
    localparam int V_STRIDE      = 1;
    localparam int PADDING       = 1;

    localparam int OFMAP_HEIGHT = (IFMAP_HEIGHT - KERNEL_HEIGHT + 2 * PADDING) / V_STRIDE;
    localparam int OFMAP_WIDTH  = (IFMAP_WIDTH  - KERNEL_WIDTH  + 2 * PADDING) / H_STRIDE;

    // DUT Signals
    logic clk = 0;
    logic reset, en;
    logic [DATA_WIDTH-1:0] ifmap   [0:IFMAP_HEIGHT-1][0:IFMAP_WIDTH-1];
    logic signed [DATA_WIDTH-1:0] weights [0:KERNEL_HEIGHT-1][0:KERNEL_WIDTH-1];
    logic [DATA_WIDTH-1:0] ofmap  [0:OFMAP_HEIGHT][0:OFMAP_WIDTH]; // +1 due to 0 indexing
    logic done;

    // Clock generation
    always #5 clk = ~clk;

    // DUT instantiation
    conv #(
        .IFMAP_HEIGHT(IFMAP_HEIGHT),
        .IFMAP_WIDTH(IFMAP_WIDTH),
        .KERNEL_HEIGHT(KERNEL_HEIGHT),
        .KERNEL_WIDTH(KERNEL_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .H_STRIDE(H_STRIDE),
        .V_STRIDE(V_STRIDE),
        .PADDING(PADDING)
    ) dut (
        .clk(clk),
        .reset(reset),
        .en(en),
        .ifmap(ifmap),
        .weights(weights),
        .ofmap(ofmap),
        .done_conv(done)
    );

    // Dump waveform
    initial begin
        $dumpfile("conv_wave.vcd");
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
        int fd_weights = $fopen("imgs/weights.txt", "r");
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
