`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/16 17:23:43
// Design Name: 
// Module Name: flash_led_ctl
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

module flash_led_ctl(
    input wire clk,
    input wire rst,
    input wire dir,
    input wire clk_bps,
    output reg [15:0] led
);

    always @(posedge clk) begin
        if (rst)
            led <= 16'hC000;
        else if (clk_bps) begin
            if (dir == 1'b0) begin
                // 右移：从 LED15、LED16 开始向右侧移动
                if (led == 16'h0003)
                    led <= 16'hC000;
                else
                    led <= led >> 1;
            end
            else begin
                // 左移
                if (led == 16'hC000)
                    led <= 16'h0003;
                else
                    led <= led << 1;
            end
        end
    end

endmodule
