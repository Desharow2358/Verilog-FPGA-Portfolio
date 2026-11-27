
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/16 17:25:19
// Design Name: 
// Module Name: flash_led_top
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

module flash_led_top #(
    parameter integer CLK_HZ = 100_000_000
)(
    input wire sys_clk_in,
    input wire sys_rst_n,

    input wire [7:0] sw_pin,
    input wire [7:0] dip_pin,

    output wire [15:0] led_pin
);

    wire rst;
    wire dir;
    wire clk_bps;

    wire [15:0] sw;
    reg [4:0] sw_count;
    wire [4:0] delta;

    integer i;

    assign rst = ~sys_rst_n;

    // 将普通拨码开关和 DIP 开关合并为 16 位
    assign sw = {dip_pin, sw_pin};

    // 统计高电平开关数量
    always @(*) begin
        sw_count = 0;
        for (i = 0; i < 16; i = i + 1)
            sw_count = sw_count + sw[i];
    end

    // 计算速度绝对值对应的参数
    assign delta = (sw_count >= 6) ?
                   (sw_count - 6) : (6 - sw_count);

    // 速度大于 -1 时切换方向
    assign dir = (sw_count >= 5);

    counter #(
        .CLK_HZ(CLK_HZ)
    ) counter_inst (
        .clk(sys_clk_in),
        .rst(rst),
        .delta(delta),
        .clk_bps(clk_bps)
    );

    flash_led_ctl flash_led_ctl_inst (
        .clk(sys_clk_in),
        .rst(rst),
        .dir(dir),
        .clk_bps(clk_bps),
        .led(led_pin)
    );

endmodule

