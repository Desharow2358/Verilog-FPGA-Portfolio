`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/25 13:27:35
// Design Name: 
// Module Name: alarm_tb
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

module alarm_tb;

    reg clk;
    reg rst;
    reg b1_raw;
    reg b2_raw;
    reg k1;

    wire b1_pulse;
    wire b2_pulse;
    wire b1_level;
    wire b2_level;

    wire led;
    wire [31:0] alarm_count;

    //========================================
    // 100MHz仿真时钟
    //========================================
    initial clk = 1'b0;
    always #5 clk = ~clk;

    //========================================
    // B1按键同步消抖
    //========================================
    key_debounce #(
        .CLK_FREQ(100_000_000),
        .SIM_MODE(1)
    ) debounce_b1 (
        .clk(clk),
        .rst(rst),
        .key_in(b1_raw),
        .key_level(b1_level),
        .key_pulse(b1_pulse)
    );

    //========================================
    // B2按键同步消抖
    //========================================
    key_debounce #(
        .CLK_FREQ(100_000_000),
        .SIM_MODE(1)
    ) debounce_b2 (
        .clk(clk),
        .rst(rst),
        .key_in(b2_raw),
        .key_level(b2_level),
        .key_pulse(b2_pulse)
    );

    //========================================
    // 报警器模块
    //========================================
    alarm #(
        .CLK_FREQ(100_000_000),
        .SIM_MODE(1)
    ) uut (
        .clk(clk),
        .rst(rst),
        .b1(b1_pulse),
        .b2(b2_pulse),
        .k1(k1),
        .led(led),
        .alarm_count(alarm_count)
    );

    //========================================
    // 按下B1
    //========================================
    task press_b1;
        begin
            @(negedge clk);
            b1_raw = 1'b1;

            // 保持足够时间完成同步和消抖
            repeat (12) @(negedge clk);

            b1_raw = 1'b0;

            // 等待松开消抖完成
            repeat (12) @(negedge clk);
        end
    endtask

    //========================================
    // 按下B2
    //========================================
    task press_b2;
        begin
            @(negedge clk);
            b2_raw = 1'b1;

            repeat (12) @(negedge clk);

            b2_raw = 1'b0;

            repeat (12) @(negedge clk);
        end
    endtask

    //========================================
    // 测试流程
    //========================================
    initial begin

        rst    = 1'b1;
        b1_raw = 1'b0;
        b2_raw = 1'b0;
        k1     = 1'b0;

        // 复位
        repeat (5) @(negedge clk);
        rst = 1'b0;

        //------------------------------------
        // TEST 1：B1触发报警
        //------------------------------------
        $display("TEST 1: B1触发报警");

        press_b1();

        if (alarm_count == 1)
            $display("PASS: 报警触发，次数为1");
        else
            $display("FAIL: 报警次数错误");

        //------------------------------------
        // TEST 2：报警期间再次按B1
        //------------------------------------
        $display("TEST 2: 报警期间再次按B1");

        press_b1();

        if (alarm_count == 1)
            $display("PASS: 报警期间不重复计数");
        else
            $display("FAIL: 报警期间重复计数");

        //------------------------------------
        // TEST 3：B2解除报警
        //------------------------------------
        $display("TEST 3: B2解除报警");

        press_b2();

        if (led == 1'b0 && alarm_count == 1)
            $display("PASS: 报警解除，次数保持");
        else
            $display("FAIL: 报警解除异常");

        //------------------------------------
        // TEST 4：再次触发，次数增加
        //------------------------------------
        $display("TEST 4: 再次触发报警");

        press_b1();

        if (alarm_count == 2)
            $display("PASS: 报警次数增加到2");
        else
            $display("FAIL: 报警次数错误");

        //------------------------------------
        // TEST 5：B1和B2同时按下
        //------------------------------------
        $display("TEST 5: B1和B2同时按下");

        @(negedge clk);
        b1_raw = 1'b1;
        b2_raw = 1'b1;

        repeat (12) @(negedge clk);

        b1_raw = 1'b0;
        b2_raw = 1'b0;

        repeat (12) @(negedge clk);

        if (led == 1'b0)
            $display("PASS: B2优先解除报警");
        else
            $display("FAIL: B2优先级异常");

        //------------------------------------
        // TEST 6：复位清零
        //------------------------------------
        $display("TEST 6: 复位");

        rst = 1'b1;
        repeat (3) @(negedge clk);
        rst = 1'b0;

        repeat (2) @(negedge clk);

        if (alarm_count == 0 && led == 1'b0)
            $display("PASS: 复位成功");
        else
            $display("FAIL: 复位异常");

        //------------------------------------
        // 结束
        //------------------------------------
        $display("--------------------------------");
        $display("报警器核心功能测试结束");

        $finish;
    end

endmodule
