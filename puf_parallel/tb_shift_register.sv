`timescale 1ns/1ps

module tb_shift_register();
  logic clk, in;  // Instantiating inputs of shift logicister
  wire out;     // Instantiating output of shift logicister

  shift_logicister dut(.clk(clk), .in(in), .out(out)); // Instantiating shift logicister dut

  initial begin
    $display("Start of Shift logicister Test");
    $monitor("Output of shift logicister: %d \t Time: %d", out, $time);
    clk = 0;
    in = 0;
    #6;
    in = 1;
    #20;
    in = 0;
    #70;
    $finish;
  end

  always #5 clk = !clk;

endmodule
