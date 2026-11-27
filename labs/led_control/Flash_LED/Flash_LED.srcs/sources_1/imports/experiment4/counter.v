`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/18 15:47:35
// Design Name: 
// Module Name: counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module counter #(
    parameter integer CLK_HZ = 100_000_000
)(
    input wire clk,
    input wire rst,
    input wire [4:0] delta,
    output wire clk_bps
);

    reg [27:0] cnt;
    wire [31:0] period;

    // 流动频率 = |n-6| / 2 次/秒
    // 对应周期 = 2 * CLK_HZ / |n-6|
    assign period = (delta == 0) ? 32'd0 :
                    (2 * CLK_HZ) / delta;

    assign clk_bps = (delta != 0) && (cnt == period - 1'b1);

    always @(posedge clk) begin
        if (rst)
            cnt <= 28'd0;
        else if (delta == 0)
            cnt <= 28'd0;
        else if (cnt >= period - 1'b1)
            cnt <= 28'd0;
        else
            cnt <= cnt + 1'b1;
    end

endmodule

