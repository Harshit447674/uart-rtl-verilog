
`timescale 1ns/1ps

module tb_uart_rx;

    localparam CLKS_PER_BIT = 217;

    reg clk = 0;
    reg rst = 1;
    reg rx = 1;

    wire [7:0] rx_data;
    wire rx_valid;
    wire rx_error;

    integer i;

    // Device under test
    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) dut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_error(rx_error)
    );

    // 10 ns clock period
    always #20 clk = ~clk;

    // Send one serial bit for one complete bit period
    task send_bit;
        input bit_value;
        begin
            @(negedge clk);
            rx = bit_value;
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
    endtask
    task send_frame;
    input [7:0] data;
    input       stop_value;

    integer j;
    integer timeout;
    reg seen_valid;
    reg seen_error;

    begin
        send_bit(1'b0);       // Start bit

        for (j = 0; j < 8; j = j + 1)
            send_bit(data[j]); // LSB first

        @(negedge clk);
        rx = stop_value;

        seen_valid = 0;
        seen_error = 0;

        // Monitor every clock so we don't miss the pulse.
        for (timeout = 0; timeout < 120; timeout = timeout + 1) begin
            @(posedge clk);
            #1;

            if (rx_valid) begin
                seen_valid = 1;

                if (rx_data !== data)
                    $fatal(1, "FAIL: Expected %h, got %h",
                           data, rx_data);
            end

            if (rx_error)
                seen_error = 1;
        end

        if (stop_value == 1'b1) begin
            if (!seen_valid)
                $fatal(1, "FAIL: rx_valid was never asserted");

            $display("PASS: Received data %h", data);
        end
        else begin
            if (!seen_error)
                $fatal(1, "FAIL: Invalid stop bit not detected");

            $display("PASS: Invalid stop bit detected");
        end

        // Finish the stop-bit period.
        repeat (97) @(posedge clk);
        #1;
    end
endtask

    // Send start bit, 8 data bits (LSB first),
    // and stop bit. Check the result near the stop-bit midpoint.
    
    initial begin
        $display("Starting UART RX test...");

        // Reset
        repeat (3) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // Test 1: Receive A6
        send_frame(8'hA6, 1'b1);

        // Test 2: Receive 3C
        send_frame(8'h3C, 1'b1);

        // Test 3: Invalid stop bit
        send_frame(8'h55, 1'b0);

        $display("ALL UART RX TESTS PASSED!");
        $finish;
    end

endmodule

