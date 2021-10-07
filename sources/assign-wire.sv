module test(
  output c
);

  wire a;
  wire b;

  always_comb begin
    a = 0;
    b = 0;
    c = a + b;
  end
endmodule