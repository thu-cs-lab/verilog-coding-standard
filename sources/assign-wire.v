module test(
  output c
);

  wire a = 0;
  wire b = 0;

  always @(*) begin
    c = a + b;
    a = 1;
  end
endmodule