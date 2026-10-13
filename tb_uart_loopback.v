
`timescale 1ns/1ps

module tb_uart_loopback;

    reg clk = 0;
    reg rst = 1;
    reg tx_start = 0;
    reg [7:0] tx_data = 0;

    wire tx;
    wire tx_busy;
    wire tx_done;
    wire [7:0] rx_data;
    wire rx_valid;
    wire rx_error;

    integer received = 0;

    always #20 clk = ~clk;

    uart_loopback #(
        .CLKS_PER_BIT(217)
    ) dut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_error(rx_error)
    );

    // Check received data and framing errors.
    always @(posedge clk) begin
        if (!rst && rx_valid) begin
            if (rx_data !== 8'hA6)
                $fatal(1, "FAIL: Expected A6, got %h", rx_data);

            received = received + 1;
            $display("PASS: Loopback received %h at %0t",
                     rx_data, $time);
        end

        if (!rst && rx_error)
            $fatal(1, "FAIL: RX framing error at %0t", $time);
    end

    // Main test.
    initial begin
        $display("Starting UART loopback test...");

        repeat (5) @(negedge clk);
        rst = 0;

        repeat (5) @(negedge clk);

        tx_data  = 8'hA6;
        tx_start = 1'b1;

        // Hold the request until the transmitter accepts it.
        // Check on falling edges to avoid racing the DUT.
        while (tx_busy == 1'b0)
            @(negedge clk);

        tx_start = 1'b0;

        $display("DEBUG: TX accepted A6 at %0t", $time);

        // Wait for the receiver to return the byte.
        wait (received == 1);

        repeat (5) @(negedge clk);

        $display("ALL UART LOOPBACK TESTS PASSED!");
        $finish;
    end

    // Prevent a hung simulation.
    initial begin
        repeat (30000) @(posedge clk);
        $fatal(1, "FAIL: Loopback timeout");
    end

endmodule

