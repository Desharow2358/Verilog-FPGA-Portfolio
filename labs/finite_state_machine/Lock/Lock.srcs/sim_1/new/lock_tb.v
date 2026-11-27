`timescale 1ns / 1ps

module lock_tb;

reg clk;
    reg rst;
    reg in;

wire unlock;
    wire blocked;

// 实例化密码锁，密码设置为学号后四位2402
    lock #(
        .PASSWORD(16'h2402)
    ) uut (
        .clk(clk),
        .rst(rst),
        .in(in),
        .unlock(unlock),
        .blocked(blocked)
    );

// 100MHz仿真时钟，周期10ns
    initial clk = 1'b0;
    always #5 clk = ~clk;

// 输入一个4位数字
    // 按高位到低位输入
    task send_digit;
        input [3:0] digit;
        integer i;
        begin
            for (i = 3; i >= 0; i = i - 1) begin
                // 在下降沿改变输入
                in = digit[i];

// 等待下一个下降沿
                @(negedge clk);
            end
        end
    endtask

// 输入结束符#
    // 1010属于other编码
    task send_end;
        begin
            send_digit(4'b1010);
        end
    endtask

// 输入一个完整的4位BCD密码
    task send_code;
        input [15:0] code;
        begin
            send_digit(code[15:12]);
            send_digit(code[11:8]);
            send_digit(code[7:4]);
            send_digit(code[3:0]);
        end
    endtask

// 等待结束符后的密码比较
   // 等待结束符接收和密码比较全部完成
task wait_check;
    begin
        // 结束符接收后，状态进入CHECK
        @(posedge clk);

        // 下一个上升沿执行密码比较
        @(posedge clk);

        // 等待非阻塞赋值更新完成
        #1;
    end
endtask

    initial begin

// 初始化
        rst = 1'b1;
        in  = 1'b0;

// 保持复位3个时钟周期
        repeat (3) @(negedge clk);

// 在下降沿释放复位
        rst = 1'b0;

// 复位释放后立即输入第一位
        // 避免多采样一个空闲0

//================================
        // 测试1：正确密码2402
        //================================

$display("--------------------------------");
        $display("TEST 1: 正确密码2402");

send_code(16'h2402);
        send_end();

        wait_check();

if (unlock == 1'b1)
            $display("PASS: 正确密码，unlock=1");
        else
            $display("FAIL: 正确密码未解锁");

if (blocked == 1'b0)
            $display("PASS: blocked=0");

// 解锁保持时间检查
        @(posedge clk);
        #1;

if (unlock == 1'b1)
            $display("PASS: unlock保持");

@(posedge clk);
        #1;

if (unlock == 1'b0)
            $display("PASS: unlock已关闭");

//================================
        // 测试2：第一次错误密码
        //================================

$display("--------------------------------");
        $display("TEST 2: 错误密码1234");

send_code(16'h1234);
        send_end();

        wait_check();

if (unlock == 1'b0)
            $display("PASS: 错误密码不解锁");

//================================
        // 测试3：第二次错误密码
        //================================

$display("--------------------------------");
        $display("TEST 3: 第二次错误密码1111");

send_code(16'h1111);
        send_end();

        wait_check();

if (blocked == 1'b0)
            $display("PASS: 两次错误后未锁定");

//================================
        // 测试4：第三次错误密码
        //================================

$display("--------------------------------");
        $display("TEST 4: 第三次错误密码3333");

send_code(16'h3333);
        send_end();

        wait_check();

if (blocked == 1'b1)
            $display("PASS: 连续3次错误，进入锁定");
        else
            $display("FAIL: 未进入锁定状态");

if (unlock == 1'b0)
            $display("PASS: 锁定时未解锁");

//================================
        // 测试5：锁定8个时钟周期
        //================================

$display("--------------------------------");
        $display("TEST 5: 等待锁定计时结束");

repeat (8) @(posedge clk);
        #1;

if (blocked == 1'b0)
            $display("PASS: 8个周期后自动解除锁定");
        else
            $display("FAIL: 锁定未解除");

//================================
        // 测试6：解除锁定后重新输入正确密码
        //================================

$display("--------------------------------");
        $display("TEST 6: 锁定解除后输入2402");

send_code(16'h2402);
        send_end();

        wait_check();

if (unlock == 1'b1)
            $display("PASS: 锁定解除后可以正常解锁");
        else
            $display("FAIL: 锁定解除后仍无法解锁");

// 等待解锁结束
        repeat (3) @(posedge clk);

        #1;

$display("--------------------------------");
        $display("全部测试结束");

        $finish;

    end

endmodule