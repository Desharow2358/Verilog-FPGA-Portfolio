
`timescale 1ns / 1ps

module lock #(
    parameter [15:0] PASSWORD = 16'h2402
)(
    input  wire clk,
    input  wire rst,       // 高电平异步复位
    input  wire in,        // 串行输入，每个时钟周期1位
    output reg  unlock,
    output reg  blocked
);

    // 状态定义
    localparam IDLE   = 2'd0;
    localparam CHECK  = 2'd1;
    localparam OPEN   = 2'd2;
    localparam LOCKED = 2'd3;

    reg [1:0] state;

    // 串行接收：每4位组成一个数字
    reg [3:0] shift_reg;
    reg [2:0] bit_count;

    // 保存输入的4个BCD数字
    reg [15:0] input_code;
    reg [2:0] digit_count;

    // 输入格式错误标志
    reg format_error;

    // 连续错误次数
    reg [1:0] error_count;

    // 解锁和锁定计数器
    reg [1:0] unlock_count;
    reg [3:0] block_count;

    // 当前接收到的完整4位数据
    wire [3:0] received_nibble;

    assign received_nibble = {
        shift_reg[2:0],
        in
    };

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= IDLE;

            shift_reg    <= 4'd0;
            bit_count    <= 3'd0;

            input_code   <= 16'd0;
            digit_count  <= 3'd0;
            format_error <= 1'b0;

            error_count  <= 2'd0;
            unlock_count <= 2'd0;
            block_count  <= 4'd0;

            unlock       <= 1'b0;
            blocked      <= 1'b0;
        end
        else begin
            case (state)

                // 接收密码
                IDLE: begin
                    unlock <= 1'b0;

                    // 每个上升沿接收一位
                    shift_reg <= received_nibble;

                    if (bit_count == 3'd3) begin
                        // 已接收4位，准备接收下一组
                        bit_count <= 3'd0;
                        shift_reg <= 4'd0;

                        // 0~9为有效数字
                        if (received_nibble <= 4'd9) begin

                            if (digit_count < 3'd4) begin
                                // 按输入顺序保存数字
                                input_code <= {
                                    input_code[11:0],
                                    received_nibble
                                };

                                digit_count <=
                                    digit_count + 1'b1;
                            end
                            else begin
                                // 结束符之前超过4个数字
                                format_error <= 1'b1;
                            end
                        end
                        else begin
                            // 非0~9编码作为结束符#
                            if (digit_count != 3'd4) begin
                                // 输入数字不足4个
                                format_error <= 1'b1;
                            end

                            // 结束符接收完成，下一周期比较
                            state <= CHECK;
                        end
                    end
                    else begin
                        bit_count <= bit_count + 1'b1;
                    end
                end

                // 比较密码
                CHECK: begin
                    if ((input_code == PASSWORD) &&
                        (digit_count == 3'd4) &&
                        (format_error == 1'b0)) begin

                        // 密码正确
                        unlock       <= 1'b1;
                        unlock_count <= 2'd2;

                        // 正确密码清零连续错误次数
                        error_count <= 2'd0;

                        state <= OPEN;
                    end
                    else begin
                        // 密码错误
                        unlock <= 1'b0;

                        if (error_count == 2'd2) begin
                            // 第3次连续错误，进入锁定
                            blocked     <= 1'b1;
                            block_count <= 4'd8;

                            state <= LOCKED;
                        end
                        else begin
                            error_count <=
                                error_count + 1'b1;

                            state <= IDLE;
                        end
                    end

                    // 清理本次输入，为下一次输入准备
                    shift_reg    <= 4'd0;
                    bit_count    <= 3'd0;
                    input_code   <= 16'd0;
                    digit_count  <= 3'd0;
                    format_error <= 1'b0;
                end

                // 解锁保持2个时钟周期
                OPEN: begin
                    if (unlock_count == 2'd1) begin
                        unlock       <= 1'b0;
                        unlock_count <= 2'd0;

                        state <= IDLE;
                    end
                    else begin
                        unlock_count <=
                            unlock_count - 1'b1;
                    end
                end

                // 锁定8个时钟周期
                LOCKED: begin
                    unlock  <= 1'b0;
                    blocked <= 1'b1;

                    // 锁定期间忽略输入
                    if (block_count == 4'd1) begin
                        block_count <= 4'd0;
                        blocked     <= 1'b0;
                        error_count <= 2'd0;

                        state <= IDLE;
                    end
                    else begin
                        block_count <=
                            block_count - 1'b1;
                    end
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule
