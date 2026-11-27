
`timescale 1ns / 1ps

module Flash_led_top_tb;

    reg clk;
    reg rst_n;
    reg [7:0] sw_pin;
    reg [7:0] dip_pin;

    wire [15:0] led_pin;

    initial begin
        clk = 0;
        rst_n = 0;
        sw_pin = 0;
        dip_pin = 0;

        #30;
        rst_n = 1;

        // 全部关闭
        #1000;

        // 16 个开关全部打开
        sw_pin = 8'hFF;
        dip_pin = 8'hFF;
        #2000;

        // 6 个开关打开
        sw_pin = 8'h3F;
        dip_pin = 8'h00;
        #1000;

        $stop;
    end

    always #5 clk = ~clk;

    flash_led_top #(
        .CLK_HZ(100)
    ) uut (
        .sys_clk_in(clk),
        .sys_rst_n(rst_n),
        .sw_pin(sw_pin),
        .dip_pin(dip_pin),
        .led_pin(led_pin)
    );

endmodule
