`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/29 19:07:22
// Design Name: 
// Module Name: top
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
//======================================================
// 2位全加器
// A、B：两个2位加数
// Cin：输入进位
// Sum：2位和
// Cout：输出进位
//======================================================
module TwoBitAdder (
    input  [1:0] A,
    input  [1:0] B,
    input        Cin,

    output [1:0] Sum,
    output       Cout
);

    wire c1;

    // 第0位全加器
    assign Sum[0] = A[0] ^ B[0] ^ Cin;
    assign c1      = (A[0] & B[0]) |
                     (A[0] & Cin)  |
                     (B[0] & Cin);

    // 第1位全加器
    assign Sum[1] = A[1] ^ B[1] ^ c1;
    assign Cout   = (A[1] & B[1]) |
                    (A[1] & c1)   |
                    (B[1] & c1);

endmodule


//======================================================
// 七段数码管译码模块
// 沿用实验1.22的译码表
// 输入data：4位二进制数
// pos：数码管位选
// seg：数码管段码
//======================================================
module segMsg (
    input  key1,
    input  key2,
    input  key3,
    input  key4,

    output reg [3:0] pos,
    output reg [7:0] seg
);

    wire [3:0] data;

    assign data = {key4, key3, key2, key1};

    always @(*) begin

        // 选择一个数码管位置
        pos = 4'b0010;

        case (data)

            4'b0000: seg = 8'b0011_1111;  // 0
            4'b0001: seg = 8'b0000_0110;  // 1
            4'b0010: seg = 8'b0101_1011;  // 2
            4'b0011: seg = 8'b0100_1111;  // 3
            4'b0100: seg = 8'b0110_0110;  // 4
            4'b0101: seg = 8'b0110_1101;  // 5
            4'b0110: seg = 8'b0111_1101;  // 6
            4'b0111: seg = 8'b0000_0111;  // 7
            4'b1000: seg = 8'b0111_1111;  // 8
            4'b1001: seg = 8'b0110_1111;  // 9

            default: seg = 8'b0000_1000;

        endcase

    end

endmodule


//======================================================
// 顶层模块
// EGO1拨码开关输入 + 2位全加器 + 数码管显示
//======================================================
module top (
    input  [7:0] sw_pin,

    output [7:0] seg_cs_pin,
    output [7:0] seg_data_0_pin,
    output [7:0] seg_data_1_pin
);

    // 两个2位加数
    wire [1:0] A;
    wire [1:0] B;

    // 输入进位
    wire Cin;

    // 加法器输出
    wire [1:0] Sum;
    wire Cout;

    // 3位实际加法结果
    wire [2:0] result;

    // 数码管译码输入
    wire [3:0] display_data;

    // 数码管位选与段码
    wire [3:0] pos;
    wire [7:0] seg;


    //==================================================
    // 拨码开关分配
    //==================================================

    assign A   = {sw_pin[1], sw_pin[0]};
    assign B   = {sw_pin[3], sw_pin[2]};
    assign Cin = sw_pin[4];


    //==================================================
    // 实例化2位全加器
    //==================================================

    TwoBitAdder u_adder (
        .A    (A),
        .B    (B),
        .Cin  (Cin),
        .Sum  (Sum),
        .Cout (Cout)
    );


    //==================================================
    // 将加法结果转换为4位数码管输入
    //==================================================

    assign result       = {Cout, Sum};
    assign display_data = {1'b0, result};


    //==================================================
    // 实例化数码管译码模块
    //==================================================

    segMsg u_segMsg (
        .key1 (display_data[0]),
        .key2 (display_data[1]),
        .key3 (display_data[2]),
        .key4 (display_data[3]),
        .pos  (pos),
        .seg  (seg)
    );


    //==================================================
    // EGO1数码管输出连接
    //
    // 这里先将pos映射到seg_cs_pin低4位，
    // 段码接到seg_data_0_pin，
    // seg_data_1_pin暂时关闭。
    //==================================================

    assign seg_cs_pin     = {4'b0000, pos};
    assign seg_data_0_pin = seg;
    assign seg_data_1_pin = 8'b0000_0000;

endmodule