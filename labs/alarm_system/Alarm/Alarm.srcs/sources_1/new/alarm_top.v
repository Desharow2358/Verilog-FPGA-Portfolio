
`timescale 1ns / 1ps

module alarm_top (
    input  wire        sys_clk_in,
    input  wire        sys_rst_n,

    input  wire [4:0]  btn_pin,
    input  wire [7:0]  sw_pin,

    output wire [15:0] led_pin,

    output wire [7:0]  seg_cs_pin,
    output wire [7:0]  seg_data_0_pin,
    output wire [7:0]  seg_data_1_pin
);

    //==================================================
    // 1. 复位信号
    // 板上复位低有效，内部模块高有效
    //==================================================

    wire rst;

    assign rst = ~sys_rst_n;


    //==================================================
    // 2. 按键输入
    // 假设按键按下为低电平
    //==================================================

    wire b1_raw;
    wire b2_raw;

    assign b1_raw = ~btn_pin[0];
    assign b2_raw = ~btn_pin[1];


    //==================================================
    // 3. 按键消抖
    //==================================================

    wire b1_level;
    wire b1_pulse;

    wire b2_level;
    wire b2_pulse;

    key_debounce #(
        .CLK_FREQ(100_000_000),
        .SIM_MODE(0)
    ) debounce_b1 (
        .clk       (sys_clk_in),
        .rst       (rst),
        .key_in    (b1_raw),
        .key_level (b1_level),
        .key_pulse (b1_pulse)
    );

    key_debounce #(
        .CLK_FREQ(100_000_000),
        .SIM_MODE(0)
    ) debounce_b2 (
        .clk       (sys_clk_in),
        .rst       (rst),
        .key_in    (b2_raw),
        .key_level (b2_level),
        .key_pulse (b2_pulse)
    );


    //==================================================
    // 4. K1拨码开关同步
    //==================================================

    reg k1_sync1;
    reg k1_sync2;

    always @(posedge sys_clk_in) begin
        if (rst) begin
            k1_sync1 <= 1'b0;
            k1_sync2 <= 1'b0;
        end
        else begin
            k1_sync1 <= sw_pin[0];
            k1_sync2 <= k1_sync1;
        end
    end


    //==================================================
    // 5. 报警核心
    //==================================================

    wire alarm_led;
    wire [31:0] alarm_count;

    alarm #(
        .CLK_FREQ(100_000_000),
        .SIM_MODE(0)
    ) alarm_core (
        .clk         (sys_clk_in),
        .rst         (rst),
        .b1          (b1_pulse),
        .b2          (b2_pulse),
        .k1          (k1_sync2),
        .led         (alarm_led),
        .alarm_count (alarm_count)
    );


    //==================================================
    // 6. LED输出
    //==================================================

    assign led_pin = {
        14'b0,
        alarm_led,
        1'b0
    };


    //==================================================
    // 7. 数码管扫描
    //==================================================

    wire [6:0] seg0;
    wire dp0;
    wire [3:0] sel0;

    wire [6:0] seg1;
    wire dp1;
    wire [3:0] sel1;

    sevenseg8_scan display_core (
        .clk   (sys_clk_in),
        .rst   (rst),
        .value (alarm_count),

        .seg0  (seg0),
        .dp0   (dp0),
        .sel0  (sel0),

        .seg1  (seg1),
        .dp1   (dp1),
        .sel1  (sel1)
    );


    //==================================================
    // 8. 连接EGO1数码管引脚
    // bit[0]=A, bit[1]=B, ... bit[6]=G, bit[7]=DP
    //==================================================

    assign seg_data_0_pin = {dp0, seg0};
    assign seg_data_1_pin = {dp1, seg1};

    assign seg_cs_pin = {sel1, sel0};

endmodule
