`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/25 13:03:21
// Design Name: 
// Module Name: key_debounce
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
module key_debounce #(
    // FPGA主时钟频率：100MHz
    parameter integer CLK_FREQ = 100_000_000,

    // 1：仿真模式，缩短消抖时间
    // 0：实际硬件模式，使用20ms消抖
    parameter integer SIM_MODE = 1
)(
    input  wire clk,
    input  wire rst,       // 高电平同步复位
    input  wire key_in,    // 原始按键输入

    output reg  key_level, // 消抖后的稳定电平
    output reg  key_pulse  // 按下时产生一个周期脉冲
);

    //================================================
    // 1. 两级同步寄存器
    //================================================
    reg sync_1;
    reg sync_2;

    always @(posedge clk) begin
        if (rst) begin
            sync_1 <= 1'b0;
            sync_2 <= 1'b0;
        end
        else begin
            sync_1 <= key_in;
            sync_2 <= sync_1;
        end
    end

    //================================================
    // 2. 消抖计数器
    //================================================
    reg [31:0] debounce_count;

    // 仿真时缩短为几个时钟周期
    // 实际硬件：100MHz下20ms = 2,000,000个周期
    localparam integer DEBOUNCE_MAX =
        (SIM_MODE == 1) ? 5 : CLK_FREQ / 50;

    //================================================
    // 3. 消抖与单次按下检测
    //================================================
    always @(posedge clk) begin
        if (rst) begin
            debounce_count <= 32'd0;
            key_level      <= 1'b0;
            key_pulse      <= 1'b0;
        end
        else begin
            // 默认每个周期清除脉冲
            key_pulse <= 1'b0;

            // 同步后的输入与稳定电平不同
            if (sync_2 != key_level) begin

                // 连续变化达到消抖时间
                if (debounce_count >= DEBOUNCE_MAX - 1) begin
                    debounce_count <= 32'd0;

                    // 更新稳定电平
                    key_level <= sync_2;

                    // 仅在稳定按下时产生一次脉冲
                    if (sync_2 == 1'b1)
                        key_pulse <= 1'b1;
                end
                else begin
                    debounce_count <= debounce_count + 1'b1;
                end
            end
            else begin
                // 输入恢复稳定，计数清零
                debounce_count <= 32'd0;
            end
        end
    end

endmodule

