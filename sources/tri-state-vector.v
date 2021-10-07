module tri_state_logic(
  inout [31:0] signal_io,
  output [31:0] signal_i,
  input [31:0] signal_o,
  input signal_t,
);
  assign signal_io = signal_t ? 32'bz : signal_o;
  assign signal_i = signal_io;
endmodule