module baud_gen #(
    parameter CLKS_PER_BIT = 217)(
    input  wire clk,
    input  wire rst,
    output reg  baud_tick
);

    reg [$clog2(CLKS_PER_BIT)-1:0] count;

    always @(posedge clk) begin
        if (rst) begin
            count     <= 0;
            baud_tick <= 0;
        end
        else begin
            if (count == CLKS_PER_BIT - 1) begin
                count     <= 0;
                baud_tick <= 1;
            end
            else begin
                count     <= count + 1'b1;
                baud_tick <= 0;
            end
        end
    end

endmodule

