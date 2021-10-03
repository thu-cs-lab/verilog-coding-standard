module test(
  input rst_n
);
  wire rst;

  // GOOD
  assign rst = ~rst_n;
endmodule