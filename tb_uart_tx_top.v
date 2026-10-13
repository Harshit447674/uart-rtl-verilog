
`timescale 1ns/1ps

module tb_uart_tx_top;

    reg clk = 0;
    reg rst = 1;
    reg tx_start = 0;
    reg [7:0] tx_data = 0;

    wire tx;
    wire tx_busy;
    wire tx_done;

    integer i;

    uart_tx_top #(
        .CLKS_PER_BIT(217)
    ) dut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );

    always #20 clk = ~clk;

    initial begin
        $display("Starting integrated UART TX test...");

        repeat (3) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // Wait for the first baud tick after reset.
        wait (dut.baud_tick == 1'b1);
        @(negedge clk);

        tx_data = 8'hA6;
        tx_start = 1;

        @(posedge clk);
        @(negedge clk);
        tx_start = 0;

        // Check start bit.
        if (tx !== 1'b0 || tx_busy !== 1'b1) begin
            $display("FAIL: Start bit");
            $fatal;
        end
        $display("PASS: Start bit");

        // Wait one bit period before checking each data bit.
        for (i = 0; i < 8; i = i + 1) begin
            repeat (217) @(posedge clk);
            #1;

            if (tx !== tx_data[i]) begin
                $display("FAIL: Data bit %0d, expected %b, got %b",
                         i, tx_data[i], tx);
                $fatal;
            end

            $display("PASS: Data bit %0d", i);
        end

        // Wait for the stop bit to begin.
        repeat (217) @(posedge clk);
        #1;

        if (tx !== 1'b1 || tx_busy !== 1'b1) begin
            $display("FAIL: Stop bit");
            $fatal;
        end
        $display("PASS: Stop bit");

        // Wait for completion.
        repeat (217) @(posedge clk);
        #1;

        if (tx_done !== 1'b1 || tx_busy !== 1'b0) begin
            $display("FAIL: Completion");
            $fatal;
        end

        $display("PASS: Completion");
        $display("ALL INTEGRATED UART TX TESTS PASSED!");
        $finish;
    end

endmodule

