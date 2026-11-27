`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/25 13:00:54
// Design Name: 
// Module Name: alarm
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


module alarm #(
    // 仿真时缩短计数；上板时使用真实参数
    parameter integer CLK_FREQ = 100_000_000,
    parameter integer SIM_MODE = 1
)(
    input  wire clk,
    input  wire rst,       // 高电平同步复位
    input  wire b1,        // 报警触发按键（已同步消抖）
    input  wire b2,        // 报警解除按键（已同步消抖）
    input  wire k1,        // 闪烁速度选择

    output reg  led,
    output reg  [31:0] alarm_count
);

    localparam IDLE = 1'b0;
    localparam ALARM = 1'b1;

    reg state;

    // 本次报警固定使用的速度
    reg speed_sel;

    // 闪烁计数器
    reg [31:0] blink_count;
    reg blink_enable;

    // 仿真计数参数
    localparam integer HALF_1HZ =
        (SIM_MODE == 1) ? 10 : CLK_FREQ / 2;

    localparam integer HALF_2HZ =
        (SIM_MODE == 1) ? 5 : CLK_FREQ / 4;

    wire blink_tick;

    assign blink_tick =
        (speed_sel == 1'b0) ?
        (blink_count >= HALF_1HZ - 1) :
        (blink_count >= HALF_2HZ - 1);

    always @(posedge clk) begin
        if (rst) begin
            state       <= IDLE;
            speed_sel   <= 1'b0;
            blink_count <= 32'd0;
            blink_enable<= 1'b0;
            led         <= 1'b0;
            alarm_count <= 32'd0;
        end
        else begin

            // B2优先：解除报警
            if (b2) begin
                state        <= IDLE;
                led          <= 1'b0;
                blink_count  <= 32'd0;
                blink_enable <= 1'b0;
            end

            // 正常状态下B1触发报警
            else if ((state == IDLE) && b1) begin
                state        <= ALARM;

                // 触发时读取K1，本次报警期间不改变
                speed_sel    <= k1;

                // 每次进入报警先点亮
                led          <= 1'b1;
                blink_count  <= 32'd0;
                blink_enable <= 1'b1;

                alarm_count  <= alarm_count + 1'b1;
            end

            // 报警状态
            else if (state == ALARM) begin
                if (blink_enable) begin
                    if (blink_tick) begin
                        blink_count <= 32'd0;
                        led <= ~led;
                    end
                    else begin
                        blink_count <= blink_count + 1'b1;
                    end
                end
            end

        end
    end

endmodule

