`timescale 1ns/1ps
module tb_baud_gen;

    reg clk = 0;
    reg rst = 1;
    wire baud_tick;

    integer cycles = 0;
    integer tick_count = 0;
    integer last_tick_cycle = 0;

    baud_gen #(
        .CLKS_PER_BIT(217)
    ) dut (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    // 25 MHz clock: 40 ns period
    always #20 clk = ~clk;

    initial begin
        $dumpfile("baud_gen.vcd");
        $dumpvars(0, tb_baud_gen);

        repeat (3) @(posedge clk);
        @(negedge clk);
        rst = 0;
    end

    always @(posedge clk) begin
        #1; // Sample after nonblocking assignments update

        if (rst) begin
            cycles = 0;
            tick_count = 0;
            last_tick_cycle = 0;
        end
        else begin
            cycles = cycles + 1;

            if (baud_tick) begin
                if (tick_count == 0) begin
                    if (cycles != 217)
                        $fatal(1, "FAIL: First tick at cycle %0d",
                               cycles);
                end
                else begin
                    if (cycles - last_tick_cycle != 217)
                        $fatal(1, "FAIL: Incorrect tick interval");
                end

                last_tick_cycle = cycles;
                tick_count = tick_count + 1;

                $display("Tick %0d at cycle %0d",
                         tick_count, cycles);

                if (tick_count == 5) begin
                    $display("PASS: Baud generator timing verified!");
                    $finish;
                end
            end
        end
    end

endmodule

