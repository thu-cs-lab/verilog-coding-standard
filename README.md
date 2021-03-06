# verilog-coding-standard

本文档是 Verilog 和 SystemVerilog 推荐编程规范。

# 规范要求

## VCS-001 信号名称采用 `snake_case`

信号名称通常采用 `snake_case`，即变量名全小写，单词之间用下划线分隔。

## VCS-002 信号极性为低有效用 `_n` 后缀表示

对于复位和使能信号，例如 `rst` 和 `we`，如果添加了 `_n` 后缀，表示值为零时生效（低有效，Active Low），值为一时不生效；如果没有添加 `_n` 后缀，表示值为一时生效（高有效，Active High），值为零时不生效。详细解释见下面的表格：

| 信号名称 | 极性   | 1'b1   | 1'b0   |
| -------- | ------ | ------ | ------ |
| rst      | 高有效 | 复位   | 不复位 |
| rst_n    | 低有效 | 不复位 | 复位   |
| we       | 高有效 | 写入   | 不写入 |
| we_n     | 低有效 | 不写入 | 写入   |

当代码中需要混合使用 `rst` 和 `rst_n` 的时候，采用以下的方式来转换：

```sv
module test(
  input rst_n
);
  wire rst;

  // GOOD
  assign rst = ~rst_n;

  // GOOD
  // Verilog
  always @(*) begin
    rst = ~rst_n;
  end

  // System Verilog
  always_comb begin
    rst = ~rst_n;
  end

endmodule
```

## VCS-003 选择 Verilog 或者 SystemVerilog 的功能子集

推荐使用 SystemVerilog，但不推荐使用 SystemVerilog 的高级语法，因为工具可能不支持。

## VCS-004 需要寄存器时用 `reg`，纯组合逻辑用 `wire`

推荐对于所有组合逻辑产生的信号，都采用 `wire` 类型；对于所有寄存器，都采用 `reg` 类型。不推荐使用 `logic` 类型。

严格来说，Verilog 和 SystemVerilog 不允许对 `wire` 类型进行 Procedural Assignment，也就是在 `always` 块中进行赋值，但很多环境中这个约束可以不遵守。笔者认为这是 Verilog 的一个设计里比较失败的一点。如果采用 Vivado 等不允许对 `wire` 进行 Procedural Assignment 的 EDA 软件，可以考虑都用 `reg` 类型，然后通过名字来区分：`r_` 开头都是寄存器，`w_` 开头都是组合逻辑。

```sv
// GOOD
wire c;
always_comb begin
  c = a + b;
end

// BAD
reg c;
always_comb begin
  c = a + b;
end

// GOOD
reg c;
always_ff @(posedge clock) begin
  c <= a + b;
end

// BAD
wire c;
always_ff @(posedge clock) begin
  c <= a + b;
end
```

对于常量信号，请使用 `wire` 类型并用 `assign` 进行赋值，而不要用 `reg`：

```sv
// GOOD
wire one;
assign one = 1'b1;

// BAD
reg one;
always @(*) begin
  one = 1'b1;
end
```

## VCS-005 信号仅在一个 `always` 块中赋值

通常情况下，一个信号只会在一个 `always` 块中赋值。

## VCS-006 组合逻辑采用 `always @(*)` 或者 `always_comb` 块或者 `assign` 编写

组合逻辑的 `always` 块，使用以下的写法：

```sv
// Verilog
always @(*) begin
  c = a + b;
end

// System Verilog
always_comb begin
  c = a + b;
end

// GOOD
assign c = a + b;
```

## VCS-007 组合逻辑 `always` 块中仅使用阻塞赋值

表示组合逻辑的 `always` 块中所有的赋值请使用阻塞赋值（`=`）。

## VCS-008 组合逻辑 `always` 块中保证每个分支都进行赋值

如果使用了条件语句 `if`，需要保证信号在每个可能的分支途径下都进行了赋值。

```sv
// GOOD
always_comb begin
  if (reset_n) begin
    c = a + b;
  end else begin
    c = 1'b0;
  end
end

// BAD
always_comb begin
  if (reset_n) begin
    c = a + b;
  end
end
```

请不要列举敏感信号：

```sv
// BAD
always @ (b, c) begin
  a = b + c;
end
```

## VCS-009 时序逻辑在 `always @(posedge clock)` 或者 `always_ff @(posedge clock)` 块中实现

当需要表示时序逻辑时，使用以下的写法：

```sv
// Verilog
always @(posedge clock) begin
  c <= a + b;
end

// System Verilog
always_ff @(posedge clock) begin
  c <= a + b;
end
```

## VCS-011 时序逻辑 `always` 块中仅使用非阻塞赋值

时序逻辑 `always` 块中，所有的赋值请使用非阻塞赋值（`<=`）。

## VCS-012 不要使用下降沿触发，特殊协议除外

通常情况下，请不要使用下降沿触发：

```sv
// BAD: do not use negedge
always @ (negedge clock) begin
end
```

## VCS-013 不要使用非时钟/复位信号的边沿触发

通常情况下，不要使用除了时钟和复位以外的信号做边沿触发

```sv
// BAD: do not use non-clock/reset signals
always @ (posedge signal) begin
end
```

## VCS-014 时序逻辑中不要使用时钟信号

请不要在时序逻辑中使用时钟信号：

```sv
// BAD
always @ (posedge clock) begin
  if (clock) begin
    a <= 1;
  end
end
```

## VCS-015 使用同步复位而不是异步复位

对于 FPGA，请使用同步复位：

```sv
// Verilog
always @(posedge clock) begin
  if (reset) begin
    c <= 1'b0;
  end else begin
    c <= a + b;
  end
end

// System Verilog
always_ff @(posedge clock) begin
  if (reset) begin
    c <= 1'b0;
  end else begin
    c <= a + b;
  end
end
```

## VCS-016 三态门拆分成三个信号后使用

在涉及与外设双向通信的信号时，需要使用三态门。使用三态门时，通过以下的代码拆分为三个信号：

```sv
module tri_state_logic(
  inout signal_io
);
  wire signal_i;
  wire signal_o;
  wire signal_t;

  assign signal_io = signal_t ? 1'bz : signal_o;
  assign signal_i = signal_io;
endmodule
```

其中 `signal_o` 表示输出，`signal_i` 表示输入，`signal_t` 为高时进入高阻态，`signal_t` 为低时信号输出。其余代码不操作 `signal_io` 信号。

推荐在顶层模块实现三态门信号的拆分，再按照需要把三个拆分后的信号接到内层模块。

## VCS-017 不要在内部模块中使用 `inout`

FPGA 内部的模块之间请不要使用 `inout`，仿真环境除外。

## VCS-018 不要在变量声明处赋值

不要在变量声明处赋值，因为不同的类型赋值的意义不同：

```sv
// Wire
wire signal = 1;
// Equals to
wire signal;
assign signal = 1;

// Reg
reg signal = 1;
// Equals to
reg signal;
initial signal = 1;
```

不建议在声明处赋值，而是采用等价的写法，来区分不同的语义。

在 FPGA 中，寄存器可以有初始值，即在 FPGA 进行配置时复位到初始值，但通常情况下还需要在自定义的 reset 信号有效时复位。

## VCS-019 用 localparam 命名状态机的各个状态

编写状态机的时候，用 `localparam` 命名各个状态：

```sv
// GOOD
localparam sInit = 2'd0;
localparam sIdle = 2'd1;
localparam sWork = 2'd2;
localparam sDone = 2'd3;

reg [1:0] state;
```

如果仿真工具不支持在波形中显示为对应的状态名称，可以采用以下的方法：

```sv
`ifndef SYNTHESIS
  reg [39:0] state_string; // 40 bits = 5 byte

  always @ (*) begin
    case(state)
      sInit: state_string = "sInit";
      sIdle: state_string = "sIdle";
      sWork: state_string = "sWork";
      sDone: state_string = "sDone";
      default: state_string = "?????";
    endcase
  end
`endif
```

此时在仿真波形中，`state_string` 信号就可以看到状态的名称了。

# 其他可参考的 Verilog 编程规范

- [数字逻辑设计实验文档](https://lab.cs.tsinghua.edu.cn/digital-design/doc/)
- [Verilog Coding Standard](http://fpgacpu.ca/fpga/verilog.html)
- [lowRISC Verilog Coding Style](https://github.com/lowRISC/style-guides/blob/master/VerilogCodingStyle.md)