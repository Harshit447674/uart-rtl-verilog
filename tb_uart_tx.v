
`timescale 1ns/1ps

module tb_uart_tx;

    reg clk = 0;
    reg rst = 1;
    reg baud_tick = 0;
    reg tx_start = 0;
    reg [7:0] tx_data = 0;

    wire tx;
    wire tx_busy;
    wire tx_done;

    integer i;

    // Device Under Test (your actual UART transmitter)
    uart_tx dut (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );

    // Generate a clock with a 10 ns period
    always #20 clk = ~clk;

    // Generate one baud tick and let the DUT process it
    task pulse_tick;
        begin
            @(negedge clk);
            baud_tick = 1;

            @(posedge clk);
            #1 baud_tick = 0;
        end
    endtask

    initial begin
        $display("Starting UART TX test...");

        // 1. Reset the transmitter
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 0;

        if (tx !== 1'b1 || tx_busy !== 1'b0) begin
            $display("FAIL: Incorrect idle/reset outputs");
            $fatal;
        end

        // 2. Request transmission of 8'hA6
        tx_data = 8'hA6;
        tx_start = 1;

        pulse_tick;

        tx_start = 0;

        if (tx !== 1'b0 || tx_busy !== 1'b1) begin
            $display("FAIL: Start bit or busy signal incorrect");
            $fatal;
        end

        $display("PASS: Start bit");

        // 3. Check all eight data bits, LSB first
        for (i = 0; i < 8; i = i + 1) begin
            pulse_tick;

            if (tx !== tx_data[i]) begin
                $display("FAIL: Data bit %0d, expected %b, got %b",
                         i, tx_data[i], tx);
                $fatal;
            end

            $display("PASS: Data bit %0d = %b", i, tx);
        end

        if (tx_busy !== 1'b1) begin
            $display("FAIL: Busy dropped before stop bit");
            $fatal;
        end

        // 4. Start the stop bit
        pulse_tick;

        if (tx !== 1'b1 || tx_busy !== 1'b1 || tx_done !== 1'b0) begin
            $display("FAIL: Stop bit timing/signals incorrect");
            $fatal;
        end

        $display("PASS: Stop bit begins");

        // 5. Complete the stop bit and report completion
        pulse_tick;

        if (tx_done !== 1'b1 || tx_busy !== 1'b0 || tx !== 1'b1) begin
            $display("FAIL: Completion signals incorrect");
            $fatal;
        end

        $display("PASS: Transmission complete");

        // 6. Check that tx_done is only a one-clock pulse
        @(posedge clk);
        #1;

        if (tx_done !== 1'b0) begin
            $display("FAIL: tx_done did not clear");
            $fatal;
        end

        $display("PASS: tx_done pulse width");
        $display("ALL UART TX TESTS PASSED!");

        $finish;
    end

endmodule



