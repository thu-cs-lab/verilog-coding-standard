module tri_state_logic(
  inout signal_io
);
  wire signal_i;
  wire signal_o;
  wire signal_t;

  assign signal_io = signal_t ? 1'bz : signal_o;
  assign signal_i = signal_io;
endmodule