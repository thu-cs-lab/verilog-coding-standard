module tri_state_logic(
  inout signal_io,
  output signal_i,
  input signal_o,
  input signal_t,
);
  assign signal_io = signal_t ? 1'bz : signal_o;
  assign signal_i = signal_io;
endmodule