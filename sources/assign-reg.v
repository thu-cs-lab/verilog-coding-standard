module test(
  input clock,
  input a,
  input b,
  output c
);

  reg reg_a = 0;
  reg reg_b = 0;
  reg reg_c;
  assign c = reg_c;

  always @(posedge clock) begin
    reg_a <= a;
    reg_b <= b;
    reg_c <= reg_a + reg_b;
  end
endmodule