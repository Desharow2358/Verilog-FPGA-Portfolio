
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/25 14:10:26
// Design Name: 
// Module Name: sevenseg8_scan
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

`timescale 1ns / 1ps

module sevenseg8_scan (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] value,

    output reg  [6:0]  seg0,
    output reg         dp0,
    output reg  [3:0]  sel0,

    output reg  [6:0]  seg1,
    output reg         dp1,
    output reg  [3:0]  sel1
);

    //==================================================
    // 1. 二进制转十进制BCD
    //==================================================

    reg [39:0] bcd;

    integer i;
    integer j;

    always @(*) begin
        bcd = 40'd0;

        // Double Dabble算法
        for (i = 31; i >= 0; i = i - 1) begin

            for (j = 0; j < 10; j = j + 1) begin
                if (bcd[j*4 +: 4] >= 4'd5)
                    bcd[j*4 +: 4] =
                        bcd[j*4 +: 4] + 4'd3;
            end

            bcd = bcd << 1;
            bcd[0] = value[i];

        end
    end


    //==================================================
    // 2. 动态扫描计数器
    //==================================================

    reg [13:0] scan_counter;
    reg [2:0]  scan_index;

    // 每12500个100MHz时钟切换一位
    // 8位完整刷新频率约为1kHz
    always @(posedge clk) begin
        if (rst) begin
            scan_counter <= 14'd0;
            scan_index   <= 3'd0;
        end
        else begin
            if (scan_counter >= 14'd12499) begin
                scan_counter <= 14'd0;
                scan_index   <= scan_index + 1'b1;
            end
            else begin
                scan_counter <= scan_counter + 1'b1;
            end
        end
    end


    //==================================================
    // 3. 判断最高有效位
    //==================================================

    reg [3:0] highest_digit;
    integer k;

    always @(*) begin
        highest_digit = 4'd0;

        for (k = 0; k < 8; k = k + 1) begin
            if (bcd[k*4 +: 4] != 4'd0)
                highest_digit = k;
        end
    end


    //==================================================
    // 4. 当前扫描位对应的数字
    //==================================================

    reg [3:0] current_digit;
    reg       digit_enable;

    always @(*) begin

        current_digit = 4'd0;
        digit_enable  = 1'b0;

        if (scan_index <= highest_digit) begin
            current_digit = bcd[scan_index*4 +: 4];
            digit_enable  = 1'b1;
        end

        // 数值为0时，只显示最低位的0
        if (value == 32'd0) begin
            if (scan_index == 3'd0) begin
                current_digit = 4'd0;
                digit_enable  = 1'b1;
            end
            else begin
                digit_enable = 1'b0;
            end
        end

    end


    //==================================================
    // 5. 七段数码管译码
    // seg[0]=A, seg[1]=B, ... seg[6]=G
    // 共阴极：高电平点亮
    //==================================================

    reg [6:0] seg_code;

    always @(*) begin
        case (current_digit)

            4'd0: seg_code = 7'b0111111;
            4'd1: seg_code = 7'b0000110;
            4'd2: seg_code = 7'b1011011;
            4'd3: seg_code = 7'b1001111;
            4'd4: seg_code = 7'b1100110;
            4'd5: seg_code = 7'b1101101;
            4'd6: seg_code = 7'b1111101;
            4'd7: seg_code = 7'b0000111;
            4'd8: seg_code = 7'b1111111;
            4'd9: seg_code = 7'b1101111;

            default: seg_code = 7'b0000000;

        endcase
    end


    //==================================================
    // 6. 输出位选和段选
    //==================================================

    always @(*) begin

        // 默认全部关闭
        seg0 = 7'b0000000;
        seg1 = 7'b0000000;

        dp0 = 1'b0;
        dp1 = 1'b0;

        sel0 = 4'b0000;
        sel1 = 4'b0000;

        if (digit_enable) begin

            if (scan_index < 4) begin

                seg0 = seg_code;
                sel0 = 4'b0001 << scan_index;

            end
            else begin

                seg1 = seg_code;
                sel1 = 4'b0001 << (scan_index - 4);

            end

        end

    end

endmodule

