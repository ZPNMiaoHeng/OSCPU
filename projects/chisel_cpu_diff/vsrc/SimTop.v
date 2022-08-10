module InstFetch(
  input         clock,
  input         reset,
  output [63:0] io_imem_addr,
  input  [63:0] io_imem_rdata,
  input  [1:0]  io_pcSrc,
  input  [31:0] io_nextPC,
  input         io_stall,
  output [31:0] io_out_pc,
  output [31:0] io_out_inst
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] pc; // @[InstFetch.scala 22:19]
  wire [31:0] _ifPC_T_2 = pc + 32'h4; // @[InstFetch.scala 24:31]
  wire [31:0] _ifPC_T_3 = io_pcSrc == 2'h0 ? _ifPC_T_2 : io_nextPC; // @[InstFetch.scala 24:9]
  wire [31:0] ifPC = io_stall ? pc : _ifPC_T_3; // @[InstFetch.scala 23:17]
  assign io_imem_addr = {{32'd0}, ifPC}; // @[InstFetch.scala 28:18]
  assign io_out_pc = io_stall ? pc : _ifPC_T_3; // @[InstFetch.scala 23:17]
  assign io_out_inst = io_imem_rdata[31:0]; // @[InstFetch.scala 30:29]
  always @(posedge clock) begin
    if (reset) begin // @[InstFetch.scala 22:19]
      pc <= 32'h7ffffff8; // @[InstFetch.scala 22:19]
    end else if (!(io_stall)) begin // @[InstFetch.scala 23:17]
      if (io_pcSrc == 2'h0) begin // @[InstFetch.scala 24:9]
        pc <= _ifPC_T_2;
      end else begin
        pc <= io_nextPC;
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  pc = _RAND_0[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module PipelineReg(
  input         clock,
  input         reset,
  input  [31:0] io_in_pc,
  input  [31:0] io_in_inst,
  input         io_in_typeL,
  input         io_in_aluA,
  input  [1:0]  io_in_aluB,
  input  [3:0]  io_in_aluOp,
  input  [2:0]  io_in_branch,
  input  [1:0]  io_in_memtoReg,
  input         io_in_memWr,
  input  [2:0]  io_in_memOp,
  input         io_in_rdEn,
  input  [4:0]  io_in_rdAddr,
  input  [63:0] io_in_rs1Data,
  input  [63:0] io_in_rs2Data,
  input  [63:0] io_in_imm,
  input  [1:0]  io_in_pcSrc,
  input  [31:0] io_in_nextPC,
  input  [63:0] io_in_aluRes,
  input  [63:0] io_in_memData,
  output        io_out_valid,
  output [31:0] io_out_pc,
  output [31:0] io_out_inst,
  output        io_out_typeL,
  output        io_out_aluA,
  output [1:0]  io_out_aluB,
  output [3:0]  io_out_aluOp,
  output [2:0]  io_out_branch,
  output [1:0]  io_out_memtoReg,
  output        io_out_memWr,
  output [2:0]  io_out_memOp,
  output        io_out_rdEn,
  output [4:0]  io_out_rdAddr,
  output [63:0] io_out_rs1Data,
  output [63:0] io_out_rs2Data,
  output [63:0] io_out_imm,
  output [1:0]  io_out_pcSrc,
  output [31:0] io_out_nextPC,
  output [63:0] io_out_aluRes,
  output [63:0] io_out_memData,
  input         io_flush,
  input         io_stall
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [63:0] _RAND_13;
  reg [63:0] _RAND_14;
  reg [63:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [63:0] _RAND_18;
  reg [63:0] _RAND_19;
`endif // RANDOMIZE_REG_INIT
  reg  reg_valid; // @[PipelineReg.scala 73:20]
  reg [31:0] reg_pc; // @[PipelineReg.scala 73:20]
  reg [31:0] reg_inst; // @[PipelineReg.scala 73:20]
  reg  reg_typeL; // @[PipelineReg.scala 73:20]
  reg  reg_aluA; // @[PipelineReg.scala 73:20]
  reg [1:0] reg_aluB; // @[PipelineReg.scala 73:20]
  reg [3:0] reg_aluOp; // @[PipelineReg.scala 73:20]
  reg [2:0] reg_branch; // @[PipelineReg.scala 73:20]
  reg [1:0] reg_memtoReg; // @[PipelineReg.scala 73:20]
  reg  reg_memWr; // @[PipelineReg.scala 73:20]
  reg [2:0] reg_memOp; // @[PipelineReg.scala 73:20]
  reg  reg_rdEn; // @[PipelineReg.scala 73:20]
  reg [4:0] reg_rdAddr; // @[PipelineReg.scala 73:20]
  reg [63:0] reg_rs1Data; // @[PipelineReg.scala 73:20]
  reg [63:0] reg_rs2Data; // @[PipelineReg.scala 73:20]
  reg [63:0] reg_imm; // @[PipelineReg.scala 73:20]
  reg [1:0] reg_pcSrc; // @[PipelineReg.scala 73:20]
  reg [31:0] reg_nextPC; // @[PipelineReg.scala 73:20]
  reg [63:0] reg_aluRes; // @[PipelineReg.scala 73:20]
  reg [63:0] reg_memData; // @[PipelineReg.scala 73:20]
  wire  _T = ~io_stall; // @[PipelineReg.scala 75:21]
  wire  _GEN_0 = _T | reg_valid; // @[PipelineReg.scala 73:20 77:27 78:9]
  assign io_out_valid = reg_valid; // @[PipelineReg.scala 81:10]
  assign io_out_pc = reg_pc; // @[PipelineReg.scala 81:10]
  assign io_out_inst = reg_inst; // @[PipelineReg.scala 81:10]
  assign io_out_typeL = reg_typeL; // @[PipelineReg.scala 81:10]
  assign io_out_aluA = reg_aluA; // @[PipelineReg.scala 81:10]
  assign io_out_aluB = reg_aluB; // @[PipelineReg.scala 81:10]
  assign io_out_aluOp = reg_aluOp; // @[PipelineReg.scala 81:10]
  assign io_out_branch = reg_branch; // @[PipelineReg.scala 81:10]
  assign io_out_memtoReg = reg_memtoReg; // @[PipelineReg.scala 81:10]
  assign io_out_memWr = reg_memWr; // @[PipelineReg.scala 81:10]
  assign io_out_memOp = reg_memOp; // @[PipelineReg.scala 81:10]
  assign io_out_rdEn = reg_rdEn; // @[PipelineReg.scala 81:10]
  assign io_out_rdAddr = reg_rdAddr; // @[PipelineReg.scala 81:10]
  assign io_out_rs1Data = reg_rs1Data; // @[PipelineReg.scala 81:10]
  assign io_out_rs2Data = reg_rs2Data; // @[PipelineReg.scala 81:10]
  assign io_out_imm = reg_imm; // @[PipelineReg.scala 81:10]
  assign io_out_pcSrc = reg_pcSrc; // @[PipelineReg.scala 81:10]
  assign io_out_nextPC = reg_nextPC; // @[PipelineReg.scala 81:10]
  assign io_out_aluRes = reg_aluRes; // @[PipelineReg.scala 81:10]
  assign io_out_memData = reg_memData; // @[PipelineReg.scala 81:10]
  always @(posedge clock) begin
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_valid <= 1'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_valid <= 1'h0; // @[PipelineReg.scala 36:14]
    end else begin
      reg_valid <= _GEN_0;
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_pc <= 32'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_pc <= 32'h0; // @[PipelineReg.scala 37:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_pc <= io_in_pc; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_inst <= 32'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_inst <= 32'h0; // @[PipelineReg.scala 38:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_inst <= io_in_inst; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_typeL <= 1'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_typeL <= 1'h0; // @[PipelineReg.scala 39:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_typeL <= io_in_typeL; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_aluA <= 1'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_aluA <= 1'h0; // @[PipelineReg.scala 41:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_aluA <= io_in_aluA; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_aluB <= 2'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_aluB <= 2'h3; // @[PipelineReg.scala 42:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_aluB <= io_in_aluB; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_aluOp <= 4'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_aluOp <= 4'h0; // @[PipelineReg.scala 43:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_aluOp <= io_in_aluOp; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_branch <= 3'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_branch <= 3'h0; // @[PipelineReg.scala 45:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_branch <= io_in_branch; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_memtoReg <= 2'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_memtoReg <= 2'h0; // @[PipelineReg.scala 46:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_memtoReg <= io_in_memtoReg; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_memWr <= 1'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_memWr <= 1'h0; // @[PipelineReg.scala 47:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_memWr <= io_in_memWr; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_memOp <= 3'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_memOp <= 3'h0; // @[PipelineReg.scala 48:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_memOp <= io_in_memOp; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_rdEn <= 1'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_rdEn <= 1'h0; // @[PipelineReg.scala 50:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_rdEn <= io_in_rdEn; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_rdAddr <= 5'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_rdAddr <= 5'h0; // @[PipelineReg.scala 51:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_rdAddr <= io_in_rdAddr; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_rs1Data <= 64'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_rs1Data <= 64'h0; // @[PipelineReg.scala 53:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_rs1Data <= io_in_rs1Data; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_rs2Data <= 64'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_rs2Data <= 64'h0; // @[PipelineReg.scala 54:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_rs2Data <= io_in_rs2Data; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_imm <= 64'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_imm <= 64'h0; // @[PipelineReg.scala 55:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_imm <= io_in_imm; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_pcSrc <= 2'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_pcSrc <= 2'h0; // @[PipelineReg.scala 56:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_pcSrc <= io_in_pcSrc; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_nextPC <= 32'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_nextPC <= 32'h0; // @[PipelineReg.scala 57:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_nextPC <= io_in_nextPC; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_aluRes <= 64'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_aluRes <= 64'h0; // @[PipelineReg.scala 58:14]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_aluRes <= io_in_aluRes; // @[PipelineReg.scala 78:9]
    end
    if (reset) begin // @[PipelineReg.scala 73:20]
      reg_memData <= 64'h0; // @[PipelineReg.scala 73:20]
    end else if (io_flush & ~io_stall) begin // @[PipelineReg.scala 75:32]
      reg_memData <= 64'h0; // @[PipelineReg.scala 59:16]
    end else if (_T) begin // @[PipelineReg.scala 77:27]
      reg_memData <= io_in_memData; // @[PipelineReg.scala 78:9]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  reg_valid = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  reg_pc = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  reg_inst = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  reg_typeL = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  reg_aluA = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  reg_aluB = _RAND_5[1:0];
  _RAND_6 = {1{`RANDOM}};
  reg_aluOp = _RAND_6[3:0];
  _RAND_7 = {1{`RANDOM}};
  reg_branch = _RAND_7[2:0];
  _RAND_8 = {1{`RANDOM}};
  reg_memtoReg = _RAND_8[1:0];
  _RAND_9 = {1{`RANDOM}};
  reg_memWr = _RAND_9[0:0];
  _RAND_10 = {1{`RANDOM}};
  reg_memOp = _RAND_10[2:0];
  _RAND_11 = {1{`RANDOM}};
  reg_rdEn = _RAND_11[0:0];
  _RAND_12 = {1{`RANDOM}};
  reg_rdAddr = _RAND_12[4:0];
  _RAND_13 = {2{`RANDOM}};
  reg_rs1Data = _RAND_13[63:0];
  _RAND_14 = {2{`RANDOM}};
  reg_rs2Data = _RAND_14[63:0];
  _RAND_15 = {2{`RANDOM}};
  reg_imm = _RAND_15[63:0];
  _RAND_16 = {1{`RANDOM}};
  reg_pcSrc = _RAND_16[1:0];
  _RAND_17 = {1{`RANDOM}};
  reg_nextPC = _RAND_17[31:0];
  _RAND_18 = {2{`RANDOM}};
  reg_aluRes = _RAND_18[63:0];
  _RAND_19 = {2{`RANDOM}};
  reg_memData = _RAND_19[63:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module RegFile(
  input         clock,
  input         reset,
  output [63:0] io_rs1Data,
  output [63:0] io_rs2Data,
  input         io_rdEn,
  input  [31:0] io_rdAddr,
  input  [63:0] io_rdData,
  input         io_ctrl_rs1En,
  input         io_ctrl_rs2En,
  input  [4:0]  io_ctrl_rs1Addr,
  input  [4:0]  io_ctrl_rs2Addr,
  output [63:0] rf_10
);
`ifdef RANDOMIZE_REG_INIT
  reg [63:0] _RAND_0;
  reg [63:0] _RAND_1;
  reg [63:0] _RAND_2;
  reg [63:0] _RAND_3;
  reg [63:0] _RAND_4;
  reg [63:0] _RAND_5;
  reg [63:0] _RAND_6;
  reg [63:0] _RAND_7;
  reg [63:0] _RAND_8;
  reg [63:0] _RAND_9;
  reg [63:0] _RAND_10;
  reg [63:0] _RAND_11;
  reg [63:0] _RAND_12;
  reg [63:0] _RAND_13;
  reg [63:0] _RAND_14;
  reg [63:0] _RAND_15;
  reg [63:0] _RAND_16;
  reg [63:0] _RAND_17;
  reg [63:0] _RAND_18;
  reg [63:0] _RAND_19;
  reg [63:0] _RAND_20;
  reg [63:0] _RAND_21;
  reg [63:0] _RAND_22;
  reg [63:0] _RAND_23;
  reg [63:0] _RAND_24;
  reg [63:0] _RAND_25;
  reg [63:0] _RAND_26;
  reg [63:0] _RAND_27;
  reg [63:0] _RAND_28;
  reg [63:0] _RAND_29;
  reg [63:0] _RAND_30;
  reg [63:0] _RAND_31;
`endif // RANDOMIZE_REG_INIT
  wire  dt_ar_clock; // @[RegFile.scala 26:21]
  wire [7:0] dt_ar_coreid; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_0; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_1; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_2; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_3; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_4; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_5; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_6; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_7; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_8; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_9; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_10; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_11; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_12; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_13; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_14; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_15; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_16; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_17; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_18; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_19; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_20; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_21; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_22; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_23; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_24; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_25; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_26; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_27; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_28; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_29; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_30; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_31; // @[RegFile.scala 26:21]
  reg [63:0] rf__0; // @[RegFile.scala 17:19]
  reg [63:0] rf__1; // @[RegFile.scala 17:19]
  reg [63:0] rf__2; // @[RegFile.scala 17:19]
  reg [63:0] rf__3; // @[RegFile.scala 17:19]
  reg [63:0] rf__4; // @[RegFile.scala 17:19]
  reg [63:0] rf__5; // @[RegFile.scala 17:19]
  reg [63:0] rf__6; // @[RegFile.scala 17:19]
  reg [63:0] rf__7; // @[RegFile.scala 17:19]
  reg [63:0] rf__8; // @[RegFile.scala 17:19]
  reg [63:0] rf__9; // @[RegFile.scala 17:19]
  reg [63:0] rf__10; // @[RegFile.scala 17:19]
  reg [63:0] rf__11; // @[RegFile.scala 17:19]
  reg [63:0] rf__12; // @[RegFile.scala 17:19]
  reg [63:0] rf__13; // @[RegFile.scala 17:19]
  reg [63:0] rf__14; // @[RegFile.scala 17:19]
  reg [63:0] rf__15; // @[RegFile.scala 17:19]
  reg [63:0] rf__16; // @[RegFile.scala 17:19]
  reg [63:0] rf__17; // @[RegFile.scala 17:19]
  reg [63:0] rf__18; // @[RegFile.scala 17:19]
  reg [63:0] rf__19; // @[RegFile.scala 17:19]
  reg [63:0] rf__20; // @[RegFile.scala 17:19]
  reg [63:0] rf__21; // @[RegFile.scala 17:19]
  reg [63:0] rf__22; // @[RegFile.scala 17:19]
  reg [63:0] rf__23; // @[RegFile.scala 17:19]
  reg [63:0] rf__24; // @[RegFile.scala 17:19]
  reg [63:0] rf__25; // @[RegFile.scala 17:19]
  reg [63:0] rf__26; // @[RegFile.scala 17:19]
  reg [63:0] rf__27; // @[RegFile.scala 17:19]
  reg [63:0] rf__28; // @[RegFile.scala 17:19]
  reg [63:0] rf__29; // @[RegFile.scala 17:19]
  reg [63:0] rf__30; // @[RegFile.scala 17:19]
  reg [63:0] rf__31; // @[RegFile.scala 17:19]
  wire [63:0] _GEN_65 = 5'h1 == io_ctrl_rs1Addr ? rf__1 : rf__0; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_66 = 5'h2 == io_ctrl_rs1Addr ? rf__2 : _GEN_65; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_67 = 5'h3 == io_ctrl_rs1Addr ? rf__3 : _GEN_66; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_68 = 5'h4 == io_ctrl_rs1Addr ? rf__4 : _GEN_67; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_69 = 5'h5 == io_ctrl_rs1Addr ? rf__5 : _GEN_68; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_70 = 5'h6 == io_ctrl_rs1Addr ? rf__6 : _GEN_69; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_71 = 5'h7 == io_ctrl_rs1Addr ? rf__7 : _GEN_70; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_72 = 5'h8 == io_ctrl_rs1Addr ? rf__8 : _GEN_71; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_73 = 5'h9 == io_ctrl_rs1Addr ? rf__9 : _GEN_72; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_74 = 5'ha == io_ctrl_rs1Addr ? rf__10 : _GEN_73; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_75 = 5'hb == io_ctrl_rs1Addr ? rf__11 : _GEN_74; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_76 = 5'hc == io_ctrl_rs1Addr ? rf__12 : _GEN_75; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_77 = 5'hd == io_ctrl_rs1Addr ? rf__13 : _GEN_76; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_78 = 5'he == io_ctrl_rs1Addr ? rf__14 : _GEN_77; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_79 = 5'hf == io_ctrl_rs1Addr ? rf__15 : _GEN_78; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_80 = 5'h10 == io_ctrl_rs1Addr ? rf__16 : _GEN_79; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_81 = 5'h11 == io_ctrl_rs1Addr ? rf__17 : _GEN_80; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_82 = 5'h12 == io_ctrl_rs1Addr ? rf__18 : _GEN_81; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_83 = 5'h13 == io_ctrl_rs1Addr ? rf__19 : _GEN_82; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_84 = 5'h14 == io_ctrl_rs1Addr ? rf__20 : _GEN_83; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_85 = 5'h15 == io_ctrl_rs1Addr ? rf__21 : _GEN_84; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_86 = 5'h16 == io_ctrl_rs1Addr ? rf__22 : _GEN_85; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_87 = 5'h17 == io_ctrl_rs1Addr ? rf__23 : _GEN_86; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_88 = 5'h18 == io_ctrl_rs1Addr ? rf__24 : _GEN_87; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_89 = 5'h19 == io_ctrl_rs1Addr ? rf__25 : _GEN_88; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_90 = 5'h1a == io_ctrl_rs1Addr ? rf__26 : _GEN_89; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_91 = 5'h1b == io_ctrl_rs1Addr ? rf__27 : _GEN_90; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_92 = 5'h1c == io_ctrl_rs1Addr ? rf__28 : _GEN_91; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_93 = 5'h1d == io_ctrl_rs1Addr ? rf__29 : _GEN_92; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_94 = 5'h1e == io_ctrl_rs1Addr ? rf__30 : _GEN_93; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_95 = 5'h1f == io_ctrl_rs1Addr ? rf__31 : _GEN_94; // @[RegFile.scala 23:{20,20}]
  wire [63:0] _GEN_97 = 5'h1 == io_ctrl_rs2Addr ? rf__1 : rf__0; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_98 = 5'h2 == io_ctrl_rs2Addr ? rf__2 : _GEN_97; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_99 = 5'h3 == io_ctrl_rs2Addr ? rf__3 : _GEN_98; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_100 = 5'h4 == io_ctrl_rs2Addr ? rf__4 : _GEN_99; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_101 = 5'h5 == io_ctrl_rs2Addr ? rf__5 : _GEN_100; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_102 = 5'h6 == io_ctrl_rs2Addr ? rf__6 : _GEN_101; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_103 = 5'h7 == io_ctrl_rs2Addr ? rf__7 : _GEN_102; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_104 = 5'h8 == io_ctrl_rs2Addr ? rf__8 : _GEN_103; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_105 = 5'h9 == io_ctrl_rs2Addr ? rf__9 : _GEN_104; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_106 = 5'ha == io_ctrl_rs2Addr ? rf__10 : _GEN_105; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_107 = 5'hb == io_ctrl_rs2Addr ? rf__11 : _GEN_106; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_108 = 5'hc == io_ctrl_rs2Addr ? rf__12 : _GEN_107; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_109 = 5'hd == io_ctrl_rs2Addr ? rf__13 : _GEN_108; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_110 = 5'he == io_ctrl_rs2Addr ? rf__14 : _GEN_109; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_111 = 5'hf == io_ctrl_rs2Addr ? rf__15 : _GEN_110; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_112 = 5'h10 == io_ctrl_rs2Addr ? rf__16 : _GEN_111; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_113 = 5'h11 == io_ctrl_rs2Addr ? rf__17 : _GEN_112; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_114 = 5'h12 == io_ctrl_rs2Addr ? rf__18 : _GEN_113; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_115 = 5'h13 == io_ctrl_rs2Addr ? rf__19 : _GEN_114; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_116 = 5'h14 == io_ctrl_rs2Addr ? rf__20 : _GEN_115; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_117 = 5'h15 == io_ctrl_rs2Addr ? rf__21 : _GEN_116; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_118 = 5'h16 == io_ctrl_rs2Addr ? rf__22 : _GEN_117; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_119 = 5'h17 == io_ctrl_rs2Addr ? rf__23 : _GEN_118; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_120 = 5'h18 == io_ctrl_rs2Addr ? rf__24 : _GEN_119; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_121 = 5'h19 == io_ctrl_rs2Addr ? rf__25 : _GEN_120; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_122 = 5'h1a == io_ctrl_rs2Addr ? rf__26 : _GEN_121; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_123 = 5'h1b == io_ctrl_rs2Addr ? rf__27 : _GEN_122; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_124 = 5'h1c == io_ctrl_rs2Addr ? rf__28 : _GEN_123; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_125 = 5'h1d == io_ctrl_rs2Addr ? rf__29 : _GEN_124; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_126 = 5'h1e == io_ctrl_rs2Addr ? rf__30 : _GEN_125; // @[RegFile.scala 24:{20,20}]
  wire [63:0] _GEN_127 = 5'h1f == io_ctrl_rs2Addr ? rf__31 : _GEN_126; // @[RegFile.scala 24:{20,20}]
  DifftestArchIntRegState dt_ar ( // @[RegFile.scala 26:21]
    .clock(dt_ar_clock),
    .coreid(dt_ar_coreid),
    .gpr_0(dt_ar_gpr_0),
    .gpr_1(dt_ar_gpr_1),
    .gpr_2(dt_ar_gpr_2),
    .gpr_3(dt_ar_gpr_3),
    .gpr_4(dt_ar_gpr_4),
    .gpr_5(dt_ar_gpr_5),
    .gpr_6(dt_ar_gpr_6),
    .gpr_7(dt_ar_gpr_7),
    .gpr_8(dt_ar_gpr_8),
    .gpr_9(dt_ar_gpr_9),
    .gpr_10(dt_ar_gpr_10),
    .gpr_11(dt_ar_gpr_11),
    .gpr_12(dt_ar_gpr_12),
    .gpr_13(dt_ar_gpr_13),
    .gpr_14(dt_ar_gpr_14),
    .gpr_15(dt_ar_gpr_15),
    .gpr_16(dt_ar_gpr_16),
    .gpr_17(dt_ar_gpr_17),
    .gpr_18(dt_ar_gpr_18),
    .gpr_19(dt_ar_gpr_19),
    .gpr_20(dt_ar_gpr_20),
    .gpr_21(dt_ar_gpr_21),
    .gpr_22(dt_ar_gpr_22),
    .gpr_23(dt_ar_gpr_23),
    .gpr_24(dt_ar_gpr_24),
    .gpr_25(dt_ar_gpr_25),
    .gpr_26(dt_ar_gpr_26),
    .gpr_27(dt_ar_gpr_27),
    .gpr_28(dt_ar_gpr_28),
    .gpr_29(dt_ar_gpr_29),
    .gpr_30(dt_ar_gpr_30),
    .gpr_31(dt_ar_gpr_31)
  );
  assign io_rs1Data = io_ctrl_rs1Addr != 5'h0 & io_ctrl_rs1En ? _GEN_95 : 64'h0; // @[RegFile.scala 23:20]
  assign io_rs2Data = io_ctrl_rs2Addr != 5'h0 & io_ctrl_rs2En ? _GEN_127 : 64'h0; // @[RegFile.scala 24:20]
  assign rf_10 = rf__10;
  assign dt_ar_clock = clock; // @[RegFile.scala 27:19]
  assign dt_ar_coreid = 8'h0; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_0 = rf__0; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_1 = rf__1; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_2 = rf__2; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_3 = rf__3; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_4 = rf__4; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_5 = rf__5; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_6 = rf__6; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_7 = rf__7; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_8 = rf__8; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_9 = rf__9; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_10 = rf__10; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_11 = rf__11; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_12 = rf__12; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_13 = rf__13; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_14 = rf__14; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_15 = rf__15; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_16 = rf__16; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_17 = rf__17; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_18 = rf__18; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_19 = rf__19; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_20 = rf__20; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_21 = rf__21; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_22 = rf__22; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_23 = rf__23; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_24 = rf__24; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_25 = rf__25; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_26 = rf__26; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_27 = rf__27; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_28 = rf__28; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_29 = rf__29; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_30 = rf__30; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_31 = rf__31; // @[RegFile.scala 29:19]
  always @(posedge clock) begin
    if (reset) begin // @[RegFile.scala 17:19]
      rf__0 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h0 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__0 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__1 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h1 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__1 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__2 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h2 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__2 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__3 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h3 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__3 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__4 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h4 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__4 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__5 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h5 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__5 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__6 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h6 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__6 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__7 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h7 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__7 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__8 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h8 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__8 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__9 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h9 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__9 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__10 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'ha == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__10 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__11 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'hb == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__11 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__12 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'hc == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__12 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__13 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'hd == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__13 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__14 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'he == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__14 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__15 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'hf == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__15 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__16 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h10 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__16 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__17 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h11 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__17 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__18 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h12 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__18 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__19 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h13 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__19 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__20 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h14 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__20 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__21 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h15 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__21 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__22 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h16 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__22 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__23 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h17 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__23 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__24 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h18 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__24 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__25 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h19 == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__25 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__26 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h1a == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__26 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__27 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h1b == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__27 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__28 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h1c == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__28 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__29 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h1d == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__29 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__30 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h1e == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__30 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__31 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rdEn & io_rdAddr != 32'h0) begin // @[RegFile.scala 19:41]
      if (5'h1f == io_rdAddr[4:0]) begin // @[RegFile.scala 20:19]
        rf__31 <= io_rdData; // @[RegFile.scala 20:19]
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {2{`RANDOM}};
  rf__0 = _RAND_0[63:0];
  _RAND_1 = {2{`RANDOM}};
  rf__1 = _RAND_1[63:0];
  _RAND_2 = {2{`RANDOM}};
  rf__2 = _RAND_2[63:0];
  _RAND_3 = {2{`RANDOM}};
  rf__3 = _RAND_3[63:0];
  _RAND_4 = {2{`RANDOM}};
  rf__4 = _RAND_4[63:0];
  _RAND_5 = {2{`RANDOM}};
  rf__5 = _RAND_5[63:0];
  _RAND_6 = {2{`RANDOM}};
  rf__6 = _RAND_6[63:0];
  _RAND_7 = {2{`RANDOM}};
  rf__7 = _RAND_7[63:0];
  _RAND_8 = {2{`RANDOM}};
  rf__8 = _RAND_8[63:0];
  _RAND_9 = {2{`RANDOM}};
  rf__9 = _RAND_9[63:0];
  _RAND_10 = {2{`RANDOM}};
  rf__10 = _RAND_10[63:0];
  _RAND_11 = {2{`RANDOM}};
  rf__11 = _RAND_11[63:0];
  _RAND_12 = {2{`RANDOM}};
  rf__12 = _RAND_12[63:0];
  _RAND_13 = {2{`RANDOM}};
  rf__13 = _RAND_13[63:0];
  _RAND_14 = {2{`RANDOM}};
  rf__14 = _RAND_14[63:0];
  _RAND_15 = {2{`RANDOM}};
  rf__15 = _RAND_15[63:0];
  _RAND_16 = {2{`RANDOM}};
  rf__16 = _RAND_16[63:0];
  _RAND_17 = {2{`RANDOM}};
  rf__17 = _RAND_17[63:0];
  _RAND_18 = {2{`RANDOM}};
  rf__18 = _RAND_18[63:0];
  _RAND_19 = {2{`RANDOM}};
  rf__19 = _RAND_19[63:0];
  _RAND_20 = {2{`RANDOM}};
  rf__20 = _RAND_20[63:0];
  _RAND_21 = {2{`RANDOM}};
  rf__21 = _RAND_21[63:0];
  _RAND_22 = {2{`RANDOM}};
  rf__22 = _RAND_22[63:0];
  _RAND_23 = {2{`RANDOM}};
  rf__23 = _RAND_23[63:0];
  _RAND_24 = {2{`RANDOM}};
  rf__24 = _RAND_24[63:0];
  _RAND_25 = {2{`RANDOM}};
  rf__25 = _RAND_25[63:0];
  _RAND_26 = {2{`RANDOM}};
  rf__26 = _RAND_26[63:0];
  _RAND_27 = {2{`RANDOM}};
  rf__27 = _RAND_27[63:0];
  _RAND_28 = {2{`RANDOM}};
  rf__28 = _RAND_28[63:0];
  _RAND_29 = {2{`RANDOM}};
  rf__29 = _RAND_29[63:0];
  _RAND_30 = {2{`RANDOM}};
  rf__30 = _RAND_30[63:0];
  _RAND_31 = {2{`RANDOM}};
  rf__31 = _RAND_31[63:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module ImmGen(
  input  [31:0] io_inst,
  input  [2:0]  io_immOp,
  output [63:0] io_imm
);
  wire [51:0] _immType_0_T_2 = io_inst[31] ? 52'hfffffffffffff : 52'h0; // @[Bitwise.scala 74:12]
  wire [63:0] immType_0 = {_immType_0_T_2,io_inst[31:20]}; // @[ImmGen.scala 19:41]
  wire [31:0] _immType_1_T_2 = io_inst[31] ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [63:0] immType_1 = {_immType_1_T_2,io_inst[31:12],12'h0}; // @[ImmGen.scala 20:59]
  wire [63:0] immType_2 = {_immType_0_T_2,io_inst[31:25],io_inst[11:7]}; // @[ImmGen.scala 21:59]
  wire [64:0] _immType_3_T_11 = {_immType_0_T_2,io_inst[31],io_inst[7],io_inst[30:25],io_inst[11:8],1'h0}; // @[ImmGen.scala 22:113]
  wire [42:0] _immType_4_T_2 = io_inst[31] ? 43'h7ffffffffff : 43'h0; // @[Bitwise.scala 74:12]
  wire [63:0] immType_4 = {_immType_4_T_2,io_inst[31],io_inst[19:12],io_inst[20],io_inst[30:21],1'h0}; // @[ImmGen.scala 23:113]
  wire [63:0] _GEN_1 = 3'h1 == io_immOp ? immType_1 : immType_0; // @[ImmGen.scala 25:{10,10}]
  wire [63:0] _GEN_2 = 3'h2 == io_immOp ? immType_2 : _GEN_1; // @[ImmGen.scala 25:{10,10}]
  wire [63:0] immType_3 = _immType_3_T_11[63:0]; // @[ImmGen.scala 17:21 22:16]
  wire [63:0] _GEN_3 = 3'h3 == io_immOp ? immType_3 : _GEN_2; // @[ImmGen.scala 25:{10,10}]
  assign io_imm = 3'h4 == io_immOp ? immType_4 : _GEN_3; // @[ImmGen.scala 25:{10,10}]
endmodule
module ContrGen(
  input  [31:0] io_inst,
  output [2:0]  io_branch,
  output [2:0]  io_immOp,
  output        io_rdEn,
  output [4:0]  io_rdAddr,
  output        io_typeL,
  output        io_aluCtr_aluA,
  output [1:0]  io_aluCtr_aluB,
  output [3:0]  io_aluCtr_aluOp,
  output [1:0]  io_memCtr_memtoReg,
  output        io_memCtr_memWr,
  output [2:0]  io_memCtr_memOP,
  output        io_regCtrl_rs1En,
  output        io_regCtrl_rs2En,
  output [4:0]  io_regCtrl_rs1Addr,
  output [4:0]  io_regCtrl_rs2Addr
);
  wire [31:0] _instLui_T = io_inst & 32'h7f; // @[ContrGen.scala 24:26]
  wire  instLui = 32'h37 == _instLui_T; // @[ContrGen.scala 24:26]
  wire  instAuipc = 32'h17 == _instLui_T; // @[ContrGen.scala 25:26]
  wire  typeU = instLui | instAuipc; // @[ContrGen.scala 26:29]
  wire [31:0] _instAddi_T = io_inst & 32'h707f; // @[ContrGen.scala 28:26]
  wire  instAddi = 32'h13 == _instAddi_T; // @[ContrGen.scala 28:26]
  wire  instAndi = 32'h7013 == _instAddi_T; // @[ContrGen.scala 29:26]
  wire  instXori = 32'h4013 == _instAddi_T; // @[ContrGen.scala 30:26]
  wire  instOri = 32'h6013 == _instAddi_T; // @[ContrGen.scala 31:26]
  wire [31:0] _instSlli_T = io_inst & 32'hfc00707f; // @[ContrGen.scala 32:26]
  wire  instSlli = 32'h1013 == _instSlli_T; // @[ContrGen.scala 32:26]
  wire  instSrli = 32'h5013 == _instSlli_T; // @[ContrGen.scala 33:26]
  wire  instSrai = 32'h40005013 == _instSlli_T; // @[ContrGen.scala 34:26]
  wire  instSlti = 32'h2013 == _instAddi_T; // @[ContrGen.scala 35:26]
  wire  instSltiu = 32'h3013 == _instAddi_T; // @[ContrGen.scala 36:26]
  wire  instAddiw = 32'h1b == _instAddi_T; // @[ContrGen.scala 37:26]
  wire [31:0] _instSlliw_T = io_inst & 32'hfe00707f; // @[ContrGen.scala 38:26]
  wire  instSlliw = 32'h101b == _instSlliw_T; // @[ContrGen.scala 38:26]
  wire  instSrliw = 32'h501b == _instSlliw_T; // @[ContrGen.scala 39:26]
  wire  instSraiw = 32'h4000501b == _instSlliw_T; // @[ContrGen.scala 40:26]
  wire  instJalr = 32'h67 == _instAddi_T; // @[ContrGen.scala 41:26]
  wire  instLb = 32'h3 == _instAddi_T; // @[ContrGen.scala 42:26]
  wire  instLh = 32'h1003 == _instAddi_T; // @[ContrGen.scala 43:26]
  wire  instLw = 32'h2003 == _instAddi_T; // @[ContrGen.scala 44:26]
  wire  instLd = 32'h3003 == _instAddi_T; // @[ContrGen.scala 45:26]
  wire  instLbu = 32'h4003 == _instAddi_T; // @[ContrGen.scala 46:26]
  wire  instLhu = 32'h5003 == _instAddi_T; // @[ContrGen.scala 47:26]
  wire  instLwu = 32'h6003 == _instAddi_T; // @[ContrGen.scala 48:26]
  wire  _typeL_T_1 = instLb | instLh | instLw; // @[ContrGen.scala 53:32]
  wire  _typeL_T_4 = instLb | instLh | instLw | instLd | instLbu | instLhu; // @[ContrGen.scala 53:63]
  wire  instJal = 32'h6f == _instLui_T; // @[ContrGen.scala 56:26]
  wire  typeJ = instJal | instJalr; // @[ContrGen.scala 57:29]
  wire  instAdd = 32'h33 == _instSlliw_T; // @[ContrGen.scala 59:26]
  wire  instSub = 32'h40000033 == _instSlliw_T; // @[ContrGen.scala 60:26]
  wire  instSll = 32'h1033 == _instSlliw_T; // @[ContrGen.scala 61:26]
  wire  instSlt = 32'h2033 == _instSlliw_T; // @[ContrGen.scala 62:26]
  wire  instSltu = 32'h3033 == _instSlliw_T; // @[ContrGen.scala 63:26]
  wire  instXor = 32'h4033 == _instSlliw_T; // @[ContrGen.scala 64:26]
  wire  instSrl = 32'h5033 == _instSlliw_T; // @[ContrGen.scala 65:26]
  wire  instSra = 32'h40005033 == _instSlliw_T; // @[ContrGen.scala 66:26]
  wire  instOr = 32'h6033 == _instSlliw_T; // @[ContrGen.scala 67:26]
  wire  instAnd = 32'h7033 == _instSlliw_T; // @[ContrGen.scala 68:26]
  wire  instAddw = 32'h3b == _instSlliw_T; // @[ContrGen.scala 69:26]
  wire  instSubw = 32'h4000003b == _instSlliw_T; // @[ContrGen.scala 70:26]
  wire  instSllw = 32'h103b == _instSlliw_T; // @[ContrGen.scala 71:26]
  wire  instSrlw = 32'h503b == _instSlliw_T; // @[ContrGen.scala 72:26]
  wire  instSraw = 32'h4000503b == _instSlliw_T; // @[ContrGen.scala 73:26]
  wire  instMret = 32'h30200073 == io_inst; // @[ContrGen.scala 74:26]
  wire  aluRem = 32'h200603b == _instSlliw_T; // @[ContrGen.scala 75:26]
  wire  instDiv = 32'h2004033 == _instSlliw_T; // @[ContrGen.scala 76:26]
  wire  instDivw = 32'h200403b == _instSlliw_T; // @[ContrGen.scala 77:26]
  wire  instMul = 32'h2000033 == _instSlliw_T; // @[ContrGen.scala 78:26]
  wire  instMulw = 32'h200003b == _instSlliw_T; // @[ContrGen.scala 79:26]
  wire  _typeR_T_4 = instAdd | instSub | instSll | instSlt | instSltu | instXor; // @[ContrGen.scala 80:78]
  wire  _typeR_T_9 = _typeR_T_4 | instSrl | instSra | instOr | instAnd | instAddw; // @[ContrGen.scala 81:78]
  wire  _typeR_T_14 = _typeR_T_9 | instSubw | instSllw | instSrlw | instSraw | instMret; // @[ContrGen.scala 82:78]
  wire  typeR = _typeR_T_14 | aluRem | instDiv | instDivw | instMul | instMulw; // @[ContrGen.scala 83:78]
  wire  instBeq = 32'h63 == _instAddi_T; // @[ContrGen.scala 85:27]
  wire  instBne = 32'h1063 == _instAddi_T; // @[ContrGen.scala 86:27]
  wire  instBlt = 32'h4063 == _instAddi_T; // @[ContrGen.scala 87:27]
  wire  instBge = 32'h5063 == _instAddi_T; // @[ContrGen.scala 88:27]
  wire  instBltu = 32'h6063 == _instAddi_T; // @[ContrGen.scala 89:27]
  wire  instBgeu = 32'h7063 == _instAddi_T; // @[ContrGen.scala 90:27]
  wire  _typeB_T = instBeq | instBne; // @[ContrGen.scala 91:30]
  wire  typeB = instBeq | instBne | instBlt | instBge | instBltu | instBgeu; // @[ContrGen.scala 91:74]
  wire  instSb = 32'h23 == _instAddi_T; // @[ContrGen.scala 93:27]
  wire  instSh = 32'h1023 == _instAddi_T; // @[ContrGen.scala 94:27]
  wire  instSw = 32'h2023 == _instAddi_T; // @[ContrGen.scala 95:27]
  wire  instSd = 32'h3023 == _instAddi_T; // @[ContrGen.scala 96:27]
  wire  _typeS_T_1 = instSb | instSh | instSw; // @[ContrGen.scala 97:39]
  wire  typeS = instSb | instSh | instSw | instSd; // @[ContrGen.scala 97:49]
  wire  Ebreak = 32'h100073 == io_inst; // @[ContrGen.scala 99:27]
  wire  _typeW_T_3 = instAddw | instSubw | instSllw | instSlliw | instSraw; // @[ContrGen.scala 101:68]
  wire  _typeW_T_9 = _typeW_T_3 | instSrlw | instSrliw | instSraiw | instAddiw | aluRem | instDivw; // @[ContrGen.scala 102:76]
  wire  typeW = _typeW_T_9 | instMulw; // @[ContrGen.scala 103:14]
  wire  _io_aluCtr_aluB_T = typeR | typeB; // @[ContrGen.scala 109:12]
  wire [1:0] _io_aluCtr_aluB_T_1 = typeJ ? 2'h2 : 2'h1; // @[Mux.scala 101:16]
  wire  aluSub = instSub | instSubw; // @[ContrGen.scala 116:28]
  wire  aluSlt = instSlti | instSlt; // @[ContrGen.scala 117:29]
  wire  aluSltu = instSltiu | instSltu; // @[ContrGen.scala 118:29]
  wire  aluAnd = instAndi | instAnd; // @[ContrGen.scala 119:29]
  wire  aluOr = instOri | instOr; // @[ContrGen.scala 120:29]
  wire  aluXor = instXori | instXor; // @[ContrGen.scala 121:29]
  wire  aluSll = instSlli | instSlliw | instSll | instSllw; // @[ContrGen.scala 122:53]
  wire  aluSrl = instSrli | instSrliw | instSrl | instSrlw; // @[ContrGen.scala 123:53]
  wire  aluSra = instSrai | instSraiw | instSra | instSraw; // @[ContrGen.scala 124:53]
  wire  aluDiv = instDiv | instDivw; // @[ContrGen.scala 126:27]
  wire  aluMul = instMul | instMulw; // @[ContrGen.scala 127:27]
  wire  _io_aluCtr_aluOp_T_2 = aluSlt | instBlt | instBge; // @[ContrGen.scala 133:37]
  wire  _io_aluCtr_aluOp_T_6 = aluSltu | instBltu | instBgeu; // @[ContrGen.scala 135:40]
  wire [2:0] _io_aluCtr_aluOp_T_7 = aluAnd ? 3'h7 : 3'h0; // @[Mux.scala 101:16]
  wire [3:0] _io_aluCtr_aluOp_T_8 = aluMul ? 4'he : {{1'd0}, _io_aluCtr_aluOp_T_7}; // @[Mux.scala 101:16]
  wire [3:0] _io_aluCtr_aluOp_T_9 = aluOr ? 4'h6 : _io_aluCtr_aluOp_T_8; // @[Mux.scala 101:16]
  wire [3:0] _io_aluCtr_aluOp_T_10 = aluSra ? 4'hd : _io_aluCtr_aluOp_T_9; // @[Mux.scala 101:16]
  wire [3:0] _io_aluCtr_aluOp_T_11 = aluSrl ? 4'h5 : _io_aluCtr_aluOp_T_10; // @[Mux.scala 101:16]
  wire [3:0] _io_aluCtr_aluOp_T_12 = aluDiv ? 4'hc : _io_aluCtr_aluOp_T_11; // @[Mux.scala 101:16]
  wire [3:0] _io_aluCtr_aluOp_T_13 = aluXor ? 4'h4 : _io_aluCtr_aluOp_T_12; // @[Mux.scala 101:16]
  wire [3:0] _io_aluCtr_aluOp_T_14 = aluRem ? 4'hb : _io_aluCtr_aluOp_T_13; // @[Mux.scala 101:16]
  wire [3:0] _io_aluCtr_aluOp_T_15 = instLui ? 4'h3 : _io_aluCtr_aluOp_T_14; // @[Mux.scala 101:16]
  wire [3:0] _io_aluCtr_aluOp_T_16 = _io_aluCtr_aluOp_T_6 ? 4'ha : _io_aluCtr_aluOp_T_15; // @[Mux.scala 101:16]
  wire [3:0] _io_aluCtr_aluOp_T_17 = _typeB_T ? 4'h9 : _io_aluCtr_aluOp_T_16; // @[Mux.scala 101:16]
  wire [3:0] _io_aluCtr_aluOp_T_18 = _io_aluCtr_aluOp_T_2 ? 4'h2 : _io_aluCtr_aluOp_T_17; // @[Mux.scala 101:16]
  wire [3:0] _io_aluCtr_aluOp_T_19 = aluSll ? 4'h1 : _io_aluCtr_aluOp_T_18; // @[Mux.scala 101:16]
  wire  _io_branch_T = instBlt | instBltu; // @[ContrGen.scala 151:20]
  wire  _io_branch_T_1 = instBge | instBgeu; // @[ContrGen.scala 152:20]
  wire [2:0] _io_branch_T_2 = _io_branch_T_1 ? 3'h7 : 3'h0; // @[Mux.scala 101:16]
  wire [2:0] _io_branch_T_3 = _io_branch_T ? 3'h6 : _io_branch_T_2; // @[Mux.scala 101:16]
  wire [2:0] _io_branch_T_4 = instBne ? 3'h5 : _io_branch_T_3; // @[Mux.scala 101:16]
  wire [2:0] _io_branch_T_5 = instBeq ? 3'h4 : _io_branch_T_4; // @[Mux.scala 101:16]
  wire [2:0] _io_branch_T_6 = instJalr ? 3'h2 : _io_branch_T_5; // @[Mux.scala 101:16]
  wire  wRegEn = ~(typeS | typeB | Ebreak); // @[ContrGen.scala 159:16]
  wire  _io_immOp_T_8 = instAddi | instAddiw | instSlti | instSltiu | instXori | instOri | instAndi | instSlli |
    instSlliw | instSrli; // @[ContrGen.scala 164:120]
  wire  _io_immOp_T_15 = _io_immOp_T_8 | instSrliw | instSrai | instSraiw | instJalr | instLb | instLh | instLw; // @[ContrGen.scala 165:92]
  wire  _io_immOp_T_19 = _io_immOp_T_15 | instLwu | instLd | instLbu | instLhu; // @[ContrGen.scala 166:57]
  wire  _io_immOp_T_20 = instAuipc | instLui; // @[ContrGen.scala 167:22]
  wire  _io_immOp_T_23 = instSd | instSb | instSw | instSh; // @[ContrGen.scala 168:39]
  wire [2:0] _io_immOp_T_29 = instJal ? 3'h4 : 3'h7; // @[Mux.scala 101:16]
  wire [2:0] _io_immOp_T_30 = typeB ? 3'h3 : _io_immOp_T_29; // @[Mux.scala 101:16]
  wire [2:0] _io_immOp_T_31 = _io_immOp_T_23 ? 3'h2 : _io_immOp_T_30; // @[Mux.scala 101:16]
  wire [2:0] _io_immOp_T_32 = _io_immOp_T_20 ? 3'h1 : _io_immOp_T_31; // @[Mux.scala 101:16]
  wire  _io_memCtr_memtoReg_T_5 = _typeL_T_1 | instLwu | instLd | instLbu | instLhu; // @[ContrGen.scala 173:65]
  wire [1:0] _io_memCtr_memtoReg_T_6 = typeW ? 2'h2 : 2'h0; // @[Mux.scala 101:16]
  wire  _io_memCtr_memOP_T = instLb | instSb; // @[ContrGen.scala 179:19]
  wire  _io_memCtr_memOP_T_1 = instLh | instSh; // @[ContrGen.scala 180:19]
  wire  _io_memCtr_memOP_T_2 = instLw | instSw; // @[ContrGen.scala 181:19]
  wire  _io_memCtr_memOP_T_3 = instLd | instSd; // @[ContrGen.scala 182:19]
  wire [2:0] _io_memCtr_memOP_T_4 = instLwu ? 3'h6 : 3'h7; // @[Mux.scala 101:16]
  wire [2:0] _io_memCtr_memOP_T_5 = instLhu ? 3'h5 : _io_memCtr_memOP_T_4; // @[Mux.scala 101:16]
  wire [2:0] _io_memCtr_memOP_T_6 = instLbu ? 3'h4 : _io_memCtr_memOP_T_5; // @[Mux.scala 101:16]
  wire [2:0] _io_memCtr_memOP_T_7 = _io_memCtr_memOP_T_3 ? 3'h3 : _io_memCtr_memOP_T_6; // @[Mux.scala 101:16]
  wire [2:0] _io_memCtr_memOP_T_8 = _io_memCtr_memOP_T_2 ? 3'h2 : _io_memCtr_memOP_T_7; // @[Mux.scala 101:16]
  wire [2:0] _io_memCtr_memOP_T_9 = _io_memCtr_memOP_T_1 ? 3'h1 : _io_memCtr_memOP_T_8; // @[Mux.scala 101:16]
  assign io_branch = instJal ? 3'h1 : _io_branch_T_6; // @[Mux.scala 101:16]
  assign io_immOp = _io_immOp_T_19 ? 3'h0 : _io_immOp_T_32; // @[Mux.scala 101:16]
  assign io_rdEn = ~(typeS | typeB | Ebreak); // @[ContrGen.scala 159:16]
  assign io_rdAddr = wRegEn ? io_inst[11:7] : 5'h0; // @[ContrGen.scala 161:19]
  assign io_typeL = _typeL_T_4 | instLwu; // @[ContrGen.scala 54:22]
  assign io_aluCtr_aluA = instAuipc | typeJ; // @[ContrGen.scala 106:35]
  assign io_aluCtr_aluB = _io_aluCtr_aluB_T ? 2'h0 : _io_aluCtr_aluB_T_1; // @[Mux.scala 101:16]
  assign io_aluCtr_aluOp = aluSub ? 4'h8 : _io_aluCtr_aluOp_T_19; // @[Mux.scala 101:16]
  assign io_memCtr_memtoReg = _io_memCtr_memtoReg_T_5 ? 2'h1 : _io_memCtr_memtoReg_T_6; // @[Mux.scala 101:16]
  assign io_memCtr_memWr = _typeS_T_1 | instSd; // @[ContrGen.scala 177:56]
  assign io_memCtr_memOP = _io_memCtr_memOP_T ? 3'h0 : _io_memCtr_memOP_T_9; // @[Mux.scala 101:16]
  assign io_regCtrl_rs1En = ~(typeU | instJal); // @[ContrGen.scala 154:23]
  assign io_regCtrl_rs2En = _io_aluCtr_aluB_T | typeS; // @[ContrGen.scala 155:40]
  assign io_regCtrl_rs1Addr = Ebreak ? 5'ha : io_inst[19:15]; // @[ContrGen.scala 156:28]
  assign io_regCtrl_rs2Addr = io_inst[24:20]; // @[ContrGen.scala 157:29]
endmodule
module Decode(
  input         clock,
  input         reset,
  input         io_rdEn,
  input  [4:0]  io_rdAddr,
  input  [63:0] io_rdData,
  input  [31:0] io_in_pc,
  input  [31:0] io_in_inst,
  input         io_exeRdEn,
  input  [4:0]  io_exeRdAddr,
  input  [63:0] io_exeRdData,
  input         io_memRdEn,
  input  [4:0]  io_memRdAddr,
  input  [63:0] io_memRdData,
  input         io_wbRdEn,
  input  [4:0]  io_wbRdAddr,
  input  [63:0] io_wbRdData,
  output        io_bubbleId,
  output [31:0] io_out_pc,
  output [31:0] io_out_inst,
  output        io_out_typeL,
  output        io_out_aluA,
  output [1:0]  io_out_aluB,
  output [3:0]  io_out_aluOp,
  output [2:0]  io_out_branch,
  output [1:0]  io_out_memtoReg,
  output        io_out_memWr,
  output [2:0]  io_out_memOp,
  output        io_out_rdEn,
  output [4:0]  io_out_rdAddr,
  output [63:0] io_out_rs1Data,
  output [63:0] io_out_rs2Data,
  output [63:0] io_out_imm,
  output [63:0] rf_10
);
  wire  regs_clock; // @[Decode.scala 40:20]
  wire  regs_reset; // @[Decode.scala 40:20]
  wire [63:0] regs_io_rs1Data; // @[Decode.scala 40:20]
  wire [63:0] regs_io_rs2Data; // @[Decode.scala 40:20]
  wire  regs_io_rdEn; // @[Decode.scala 40:20]
  wire [31:0] regs_io_rdAddr; // @[Decode.scala 40:20]
  wire [63:0] regs_io_rdData; // @[Decode.scala 40:20]
  wire  regs_io_ctrl_rs1En; // @[Decode.scala 40:20]
  wire  regs_io_ctrl_rs2En; // @[Decode.scala 40:20]
  wire [4:0] regs_io_ctrl_rs1Addr; // @[Decode.scala 40:20]
  wire [4:0] regs_io_ctrl_rs2Addr; // @[Decode.scala 40:20]
  wire [63:0] regs_rf_10; // @[Decode.scala 40:20]
  wire [31:0] imm_io_inst; // @[Decode.scala 41:20]
  wire [2:0] imm_io_immOp; // @[Decode.scala 41:20]
  wire [63:0] imm_io_imm; // @[Decode.scala 41:20]
  wire [31:0] con_io_inst; // @[Decode.scala 42:20]
  wire [2:0] con_io_branch; // @[Decode.scala 42:20]
  wire [2:0] con_io_immOp; // @[Decode.scala 42:20]
  wire  con_io_rdEn; // @[Decode.scala 42:20]
  wire [4:0] con_io_rdAddr; // @[Decode.scala 42:20]
  wire  con_io_typeL; // @[Decode.scala 42:20]
  wire  con_io_aluCtr_aluA; // @[Decode.scala 42:20]
  wire [1:0] con_io_aluCtr_aluB; // @[Decode.scala 42:20]
  wire [3:0] con_io_aluCtr_aluOp; // @[Decode.scala 42:20]
  wire [1:0] con_io_memCtr_memtoReg; // @[Decode.scala 42:20]
  wire  con_io_memCtr_memWr; // @[Decode.scala 42:20]
  wire [2:0] con_io_memCtr_memOP; // @[Decode.scala 42:20]
  wire  con_io_regCtrl_rs1En; // @[Decode.scala 42:20]
  wire  con_io_regCtrl_rs2En; // @[Decode.scala 42:20]
  wire [4:0] con_io_regCtrl_rs1Addr; // @[Decode.scala 42:20]
  wire [4:0] con_io_regCtrl_rs2Addr; // @[Decode.scala 42:20]
  wire  _rdRs1HitEx_T_2 = con_io_regCtrl_rs1Addr != 5'h0; // @[Decode.scala 62:73]
  wire  rdRs1HitEx = io_exeRdEn & con_io_regCtrl_rs1Addr == io_exeRdAddr & con_io_regCtrl_rs1Addr != 5'h0; // @[Decode.scala 62:61]
  wire  rdRs1HitMem = io_memRdEn & con_io_regCtrl_rs1Addr == io_memRdAddr & _rdRs1HitEx_T_2; // @[Decode.scala 63:62]
  wire  rdRs1HitWb = io_wbRdEn & con_io_regCtrl_rs1Addr == io_wbRdAddr & _rdRs1HitEx_T_2; // @[Decode.scala 64:59]
  wire  _rdRs2HitEx_T_2 = con_io_regCtrl_rs2Addr != 5'h0; // @[Decode.scala 66:73]
  wire  rdRs2HitEx = io_exeRdEn & con_io_regCtrl_rs2Addr == io_exeRdAddr & con_io_regCtrl_rs2Addr != 5'h0; // @[Decode.scala 66:61]
  wire  rdRs2HitMem = io_memRdEn & con_io_regCtrl_rs2Addr == io_memRdAddr & _rdRs2HitEx_T_2; // @[Decode.scala 67:62]
  wire  rdRs2HitWb = io_wbRdEn & con_io_regCtrl_rs2Addr == io_wbRdAddr & _rdRs2HitEx_T_2; // @[Decode.scala 68:59]
  wire [63:0] _rs1Data_T = rdRs1HitWb ? io_wbRdData : regs_io_rs1Data; // @[Decode.scala 73:8]
  wire [63:0] _rs1Data_T_1 = rdRs1HitMem ? io_memRdData : _rs1Data_T; // @[Decode.scala 72:8]
  wire [63:0] _rs1Data_T_2 = rdRs1HitEx ? io_exeRdData : _rs1Data_T_1; // @[Decode.scala 71:8]
  wire [63:0] _rs2Data_T = rdRs2HitWb ? io_wbRdData : regs_io_rs2Data; // @[Decode.scala 78:8]
  wire [63:0] _rs2Data_T_1 = rdRs2HitMem ? io_memRdData : _rs2Data_T; // @[Decode.scala 77:8]
  wire [63:0] _rs2Data_T_2 = rdRs2HitEx ? io_exeRdData : _rs2Data_T_1; // @[Decode.scala 76:8]
  RegFile regs ( // @[Decode.scala 40:20]
    .clock(regs_clock),
    .reset(regs_reset),
    .io_rs1Data(regs_io_rs1Data),
    .io_rs2Data(regs_io_rs2Data),
    .io_rdEn(regs_io_rdEn),
    .io_rdAddr(regs_io_rdAddr),
    .io_rdData(regs_io_rdData),
    .io_ctrl_rs1En(regs_io_ctrl_rs1En),
    .io_ctrl_rs2En(regs_io_ctrl_rs2En),
    .io_ctrl_rs1Addr(regs_io_ctrl_rs1Addr),
    .io_ctrl_rs2Addr(regs_io_ctrl_rs2Addr),
    .rf_10(regs_rf_10)
  );
  ImmGen imm ( // @[Decode.scala 41:20]
    .io_inst(imm_io_inst),
    .io_immOp(imm_io_immOp),
    .io_imm(imm_io_imm)
  );
  ContrGen con ( // @[Decode.scala 42:20]
    .io_inst(con_io_inst),
    .io_branch(con_io_branch),
    .io_immOp(con_io_immOp),
    .io_rdEn(con_io_rdEn),
    .io_rdAddr(con_io_rdAddr),
    .io_typeL(con_io_typeL),
    .io_aluCtr_aluA(con_io_aluCtr_aluA),
    .io_aluCtr_aluB(con_io_aluCtr_aluB),
    .io_aluCtr_aluOp(con_io_aluCtr_aluOp),
    .io_memCtr_memtoReg(con_io_memCtr_memtoReg),
    .io_memCtr_memWr(con_io_memCtr_memWr),
    .io_memCtr_memOP(con_io_memCtr_memOP),
    .io_regCtrl_rs1En(con_io_regCtrl_rs1En),
    .io_regCtrl_rs2En(con_io_regCtrl_rs2En),
    .io_regCtrl_rs1Addr(con_io_regCtrl_rs1Addr),
    .io_regCtrl_rs2Addr(con_io_regCtrl_rs2Addr)
  );
  assign io_bubbleId = rdRs1HitEx & rdRs2HitEx; // @[Decode.scala 137:29]
  assign io_out_pc = io_in_pc; // @[Decode.scala 116:19]
  assign io_out_inst = io_in_inst; // @[Decode.scala 117:19]
  assign io_out_typeL = con_io_typeL; // @[Decode.scala 118:19]
  assign io_out_aluA = con_io_aluCtr_aluA; // @[Decode.scala 119:19]
  assign io_out_aluB = con_io_aluCtr_aluB; // @[Decode.scala 120:19]
  assign io_out_aluOp = con_io_aluCtr_aluOp; // @[Decode.scala 121:19]
  assign io_out_branch = con_io_branch; // @[Decode.scala 122:19]
  assign io_out_memtoReg = con_io_memCtr_memtoReg; // @[Decode.scala 123:19]
  assign io_out_memWr = con_io_memCtr_memWr; // @[Decode.scala 124:19]
  assign io_out_memOp = con_io_memCtr_memOP; // @[Decode.scala 125:19]
  assign io_out_rdEn = con_io_rdEn; // @[Decode.scala 126:19]
  assign io_out_rdAddr = con_io_rdAddr; // @[Decode.scala 127:19]
  assign io_out_rs1Data = con_io_regCtrl_rs1En ? _rs1Data_T_2 : 64'h0; // @[Decode.scala 70:20]
  assign io_out_rs2Data = con_io_regCtrl_rs2En ? _rs2Data_T_2 : 64'h0; // @[Decode.scala 75:20]
  assign io_out_imm = imm_io_imm; // @[Decode.scala 131:19]
  assign rf_10 = regs_rf_10;
  assign regs_clock = clock;
  assign regs_reset = reset;
  assign regs_io_rdEn = io_rdEn; // @[Decode.scala 45:16]
  assign regs_io_rdAddr = {{27'd0}, io_rdAddr}; // @[Decode.scala 46:18]
  assign regs_io_rdData = io_rdData; // @[Decode.scala 47:18]
  assign regs_io_ctrl_rs1En = con_io_regCtrl_rs1En; // @[Decode.scala 44:16]
  assign regs_io_ctrl_rs2En = con_io_regCtrl_rs2En; // @[Decode.scala 44:16]
  assign regs_io_ctrl_rs1Addr = con_io_regCtrl_rs1Addr; // @[Decode.scala 44:16]
  assign regs_io_ctrl_rs2Addr = con_io_regCtrl_rs2Addr; // @[Decode.scala 44:16]
  assign imm_io_inst = io_in_inst; // @[Decode.scala 49:15]
  assign imm_io_immOp = con_io_immOp; // @[Decode.scala 50:16]
  assign con_io_inst = io_in_inst; // @[Decode.scala 51:15]
endmodule
module ALU(
  input  [1:0]  io_memtoReg,
  input  [31:0] io_pc,
  output [63:0] io_aluRes,
  output        io_less,
  output        io_zero,
  input         ctrl_aluA,
  input  [1:0]  ctrl_aluB,
  input  [3:0]  ctrl_aluOp,
  input  [63:0] data_rData1,
  input  [63:0] data_rData2,
  input  [63:0] data_imm
);
  wire [63:0] Asrc = ~ctrl_aluA ? data_rData1 : {{32'd0}, io_pc}; // @[ALU.scala 23:19]
  wire  instW = io_memtoReg[1]; // @[ALU.scala 25:28]
  wire  in1_signBit = Asrc[31]; // @[BitUtils.scala 18:20]
  wire [31:0] _in1_T_3 = in1_signBit ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [63:0] _in1_T_4 = {_in1_T_3,Asrc[31:0]}; // @[Cat.scala 31:58]
  wire [63:0] _in1_T_6 = {32'h0,Asrc[31:0]}; // @[Cat.scala 31:58]
  wire [63:0] _in1_T_7 = ctrl_aluOp == 4'hd ? _in1_T_4 : _in1_T_6; // @[ALU.scala 26:30]
  wire [63:0] in1 = instW ? _in1_T_7 : Asrc; // @[ALU.scala 26:18]
  wire [63:0] _in2_T_1 = 2'h1 == ctrl_aluB ? data_imm : data_rData2; // @[Mux.scala 81:58]
  wire [63:0] _in2_T_3 = 2'h2 == ctrl_aluB ? 64'h4 : _in2_T_1; // @[Mux.scala 81:58]
  wire [63:0] in2 = 2'h3 == ctrl_aluB ? 64'h0 : _in2_T_3; // @[Mux.scala 81:58]
  wire [5:0] shamt = instW ? {{1'd0}, in2[4:0]} : in2[5:0]; // @[ALU.scala 36:20]
  wire [63:0] addRes = in1 + in2; // @[ALU.scala 38:25]
  wire [63:0] subRes = in1 - in2; // @[ALU.scala 39:25]
  wire [63:0] xorRes = in1 ^ in2; // @[ALU.scala 40:25]
  wire [63:0] orRes = in1 | in2; // @[ALU.scala 41:25]
  wire [63:0] andRes = in1 & in2; // @[ALU.scala 42:25]
  wire [126:0] _GEN_0 = {{63'd0}, in1}; // @[ALU.scala 43:28]
  wire [126:0] _sLRes_T = _GEN_0 << shamt; // @[ALU.scala 43:28]
  wire [63:0] sLRes = _sLRes_T[63:0]; // @[ALU.scala 43:37]
  wire [63:0] sRLRes = in1 >> shamt; // @[ALU.scala 44:27]
  wire [63:0] _sRARes_T = instW ? _in1_T_7 : Asrc; // @[ALU.scala 45:33]
  wire [63:0] sRARes = $signed(_sRARes_T) >>> shamt; // @[ALU.scala 45:52]
  wire [63:0] _sLTRes_T_1 = 2'h3 == ctrl_aluB ? 64'h0 : _in2_T_3; // @[ALU.scala 47:48]
  wire  sLTRes = $signed(_sRARes_T) < $signed(_sLTRes_T_1); // @[ALU.scala 47:36]
  wire  sLTURes = in1 < in2; // @[ALU.scala 48:27]
  wire [63:0] remwRes = $signed(_sRARes_T) % $signed(_sLTRes_T_1); // @[ALU.scala 50:48]
  wire [63:0] divRes = in1 / in2; // @[ALU.scala 51:27]
  wire [127:0] mulRes = in1 * in2; // @[ALU.scala 52:27]
  wire [63:0] _aluResult_T_1 = 4'h0 == ctrl_aluOp ? addRes : 64'h0; // @[Mux.scala 81:58]
  wire [63:0] _aluResult_T_3 = 4'h8 == ctrl_aluOp ? subRes : _aluResult_T_1; // @[Mux.scala 81:58]
  wire [63:0] _aluResult_T_5 = 4'h9 == ctrl_aluOp ? subRes : _aluResult_T_3; // @[Mux.scala 81:58]
  wire [63:0] _aluResult_T_7 = 4'h2 == ctrl_aluOp ? {{63'd0}, sLTRes} : _aluResult_T_5; // @[Mux.scala 81:58]
  wire [63:0] _aluResult_T_9 = 4'ha == ctrl_aluOp ? {{63'd0}, sLTURes} : _aluResult_T_7; // @[Mux.scala 81:58]
  wire [63:0] _aluResult_T_11 = 4'h5 == ctrl_aluOp ? sRLRes : _aluResult_T_9; // @[Mux.scala 81:58]
  wire [63:0] _aluResult_T_13 = 4'hd == ctrl_aluOp ? sRARes : _aluResult_T_11; // @[Mux.scala 81:58]
  wire [63:0] _aluResult_T_15 = 4'h1 == ctrl_aluOp ? sLRes : _aluResult_T_13; // @[Mux.scala 81:58]
  wire [63:0] _aluResult_T_17 = 4'h3 == ctrl_aluOp ? in2 : _aluResult_T_15; // @[Mux.scala 81:58]
  wire [63:0] _aluResult_T_19 = 4'hb == ctrl_aluOp ? remwRes : _aluResult_T_17; // @[Mux.scala 81:58]
  wire [63:0] _aluResult_T_21 = 4'h4 == ctrl_aluOp ? xorRes : _aluResult_T_19; // @[Mux.scala 81:58]
  wire [63:0] _aluResult_T_23 = 4'hc == ctrl_aluOp ? divRes : _aluResult_T_21; // @[Mux.scala 81:58]
  wire [63:0] _aluResult_T_25 = 4'h6 == ctrl_aluOp ? orRes : _aluResult_T_23; // @[Mux.scala 81:58]
  wire [127:0] _aluResult_T_27 = 4'he == ctrl_aluOp ? mulRes : {{64'd0}, _aluResult_T_25}; // @[Mux.scala 81:58]
  wire [127:0] aluResult = 4'h7 == ctrl_aluOp ? {{64'd0}, andRes} : _aluResult_T_27; // @[Mux.scala 81:58]
  wire  io_aluRes_signBit = aluResult[31]; // @[BitUtils.scala 18:20]
  wire [31:0] _io_aluRes_T_2 = io_aluRes_signBit ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [63:0] _io_aluRes_T_3 = {_io_aluRes_T_2,aluResult[31:0]}; // @[Cat.scala 31:58]
  wire [127:0] _io_aluRes_T_4 = instW ? {{64'd0}, _io_aluRes_T_3} : aluResult; // @[ALU.scala 80:21]
  assign io_aluRes = _io_aluRes_T_4[63:0]; // @[ALU.scala 80:15]
  assign io_less = ctrl_aluOp[3] ? sLTURes : sLTRes; // @[ALU.scala 78:19]
  assign io_zero = aluResult == 128'h0; // @[ALU.scala 79:27]
endmodule
module NextPC(
  input  [31:0] io_pc,
  input  [63:0] io_imm,
  input  [63:0] io_rs1Data,
  input  [2:0]  io_branch,
  input         io_less,
  input         io_zero,
  output [31:0] io_nextPC,
  output [1:0]  io_pcSrc
);
  wire  less = io_branch == 3'h7 ? ~io_less : io_less; // @[NextPC.scala 23:17]
  wire [3:0] _pcSrc_T_1 = {io_branch,io_zero}; // @[NextPC.scala 26:43]
  wire [3:0] _pcSrc_T_7 = {io_branch,less}; // @[NextPC.scala 27:20]
  wire  _pcSrc_T_8 = _pcSrc_T_7 == 4'hc; // @[NextPC.scala 27:28]
  wire  _pcSrc_T_9 = io_branch == 3'h0 | _pcSrc_T_1 == 4'h8 | _pcSrc_T_1 == 4'hb | _pcSrc_T_8; // @[NextPC.scala 26:109]
  wire  _pcSrc_T_12 = _pcSrc_T_9 | _pcSrc_T_7 == 4'he; // @[NextPC.scala 27:43]
  wire  _pcSrc_T_21 = _pcSrc_T_7 == 4'hd; // @[NextPC.scala 29:28]
  wire  _pcSrc_T_22 = io_branch == 3'h1 | _pcSrc_T_1 == 4'h9 | _pcSrc_T_1 == 4'ha | _pcSrc_T_21; // @[NextPC.scala 28:108]
  wire  _pcSrc_T_25 = _pcSrc_T_22 | _pcSrc_T_7 == 4'hf; // @[NextPC.scala 29:43]
  wire  _pcSrc_T_26 = io_branch == 3'h2; // @[NextPC.scala 30:16]
  wire [1:0] _pcSrc_T_27 = _pcSrc_T_26 ? 2'h3 : 2'h1; // @[Mux.scala 101:16]
  wire [1:0] _pcSrc_T_28 = _pcSrc_T_25 ? 2'h2 : _pcSrc_T_27; // @[Mux.scala 101:16]
  wire [1:0] pcSrc = _pcSrc_T_12 ? 2'h0 : _pcSrc_T_28; // @[Mux.scala 101:16]
  wire [31:0] _io_nextPC_T_1 = io_pc + 32'h4; // @[NextPC.scala 34:23]
  wire [63:0] _GEN_0 = {{32'd0}, io_pc}; // @[NextPC.scala 35:23]
  wire [63:0] _io_nextPC_T_3 = _GEN_0 + io_imm; // @[NextPC.scala 35:23]
  wire [63:0] _io_nextPC_T_5 = io_rs1Data + io_imm; // @[NextPC.scala 36:28]
  wire [31:0] _io_nextPC_T_7 = 2'h0 == pcSrc ? _io_nextPC_T_1 : 32'h80000000; // @[Mux.scala 81:58]
  wire [63:0] _io_nextPC_T_9 = 2'h2 == pcSrc ? _io_nextPC_T_3 : {{32'd0}, _io_nextPC_T_7}; // @[Mux.scala 81:58]
  wire [63:0] _io_nextPC_T_11 = 2'h3 == pcSrc ? _io_nextPC_T_5 : _io_nextPC_T_9; // @[Mux.scala 81:58]
  assign io_nextPC = _io_nextPC_T_11[31:0]; // @[NextPC.scala 33:13]
  assign io_pcSrc = _pcSrc_T_12 ? 2'h0 : _pcSrc_T_28; // @[Mux.scala 101:16]
endmodule
module Execution(
  input  [31:0] io_in_pc,
  input  [31:0] io_in_inst,
  input         io_in_typeL,
  input         io_in_aluA,
  input  [1:0]  io_in_aluB,
  input  [3:0]  io_in_aluOp,
  input  [2:0]  io_in_branch,
  input  [1:0]  io_in_memtoReg,
  input         io_in_memWr,
  input  [2:0]  io_in_memOp,
  input         io_in_rdEn,
  input  [4:0]  io_in_rdAddr,
  input  [63:0] io_in_rs1Data,
  input  [63:0] io_in_rs2Data,
  input  [63:0] io_in_imm,
  output [31:0] io_out_pc,
  output [31:0] io_out_inst,
  output        io_out_typeL,
  output        io_out_aluA,
  output [1:0]  io_out_aluB,
  output [3:0]  io_out_aluOp,
  output [2:0]  io_out_branch,
  output [1:0]  io_out_memtoReg,
  output        io_out_memWr,
  output [2:0]  io_out_memOp,
  output        io_out_rdEn,
  output [4:0]  io_out_rdAddr,
  output [63:0] io_out_rs1Data,
  output [63:0] io_out_rs2Data,
  output [63:0] io_out_imm,
  output [1:0]  io_out_pcSrc,
  output [31:0] io_out_nextPC,
  output [63:0] io_out_aluRes,
  output        io_exeRdEn,
  output [31:0] io_exeRdAddr,
  output [63:0] io_exeRdData,
  output        io_bubbleEx
);
  wire [1:0] alu_io_memtoReg; // @[Execution.scala 19:21]
  wire [31:0] alu_io_pc; // @[Execution.scala 19:21]
  wire [63:0] alu_io_aluRes; // @[Execution.scala 19:21]
  wire  alu_io_less; // @[Execution.scala 19:21]
  wire  alu_io_zero; // @[Execution.scala 19:21]
  wire  alu_ctrl_aluA; // @[Execution.scala 19:21]
  wire [1:0] alu_ctrl_aluB; // @[Execution.scala 19:21]
  wire [3:0] alu_ctrl_aluOp; // @[Execution.scala 19:21]
  wire [63:0] alu_data_rData1; // @[Execution.scala 19:21]
  wire [63:0] alu_data_rData2; // @[Execution.scala 19:21]
  wire [63:0] alu_data_imm; // @[Execution.scala 19:21]
  wire [31:0] nextPC_io_pc; // @[Execution.scala 20:24]
  wire [63:0] nextPC_io_imm; // @[Execution.scala 20:24]
  wire [63:0] nextPC_io_rs1Data; // @[Execution.scala 20:24]
  wire [2:0] nextPC_io_branch; // @[Execution.scala 20:24]
  wire  nextPC_io_less; // @[Execution.scala 20:24]
  wire  nextPC_io_zero; // @[Execution.scala 20:24]
  wire [31:0] nextPC_io_nextPC; // @[Execution.scala 20:24]
  wire [1:0] nextPC_io_pcSrc; // @[Execution.scala 20:24]
  ALU alu ( // @[Execution.scala 19:21]
    .io_memtoReg(alu_io_memtoReg),
    .io_pc(alu_io_pc),
    .io_aluRes(alu_io_aluRes),
    .io_less(alu_io_less),
    .io_zero(alu_io_zero),
    .ctrl_aluA(alu_ctrl_aluA),
    .ctrl_aluB(alu_ctrl_aluB),
    .ctrl_aluOp(alu_ctrl_aluOp),
    .data_rData1(alu_data_rData1),
    .data_rData2(alu_data_rData2),
    .data_imm(alu_data_imm)
  );
  NextPC nextPC ( // @[Execution.scala 20:24]
    .io_pc(nextPC_io_pc),
    .io_imm(nextPC_io_imm),
    .io_rs1Data(nextPC_io_rs1Data),
    .io_branch(nextPC_io_branch),
    .io_less(nextPC_io_less),
    .io_zero(nextPC_io_zero),
    .io_nextPC(nextPC_io_nextPC),
    .io_pcSrc(nextPC_io_pcSrc)
  );
  assign io_out_pc = io_in_pc; // @[Execution.scala 62:19]
  assign io_out_inst = io_in_inst; // @[Execution.scala 63:19]
  assign io_out_typeL = io_in_typeL; // @[Execution.scala 64:19]
  assign io_out_aluA = io_in_aluA; // @[Execution.scala 65:19]
  assign io_out_aluB = io_in_aluB; // @[Execution.scala 66:19]
  assign io_out_aluOp = io_in_aluOp; // @[Execution.scala 67:19]
  assign io_out_branch = io_in_branch; // @[Execution.scala 68:19]
  assign io_out_memtoReg = io_in_memtoReg; // @[Execution.scala 69:19]
  assign io_out_memWr = io_in_memWr; // @[Execution.scala 70:19]
  assign io_out_memOp = io_in_memOp; // @[Execution.scala 71:19]
  assign io_out_rdEn = io_in_rdEn; // @[Execution.scala 72:19]
  assign io_out_rdAddr = io_in_rdAddr; // @[Execution.scala 73:19]
  assign io_out_rs1Data = io_in_rs1Data; // @[Execution.scala 75:19]
  assign io_out_rs2Data = io_in_rs2Data; // @[Execution.scala 76:19]
  assign io_out_imm = io_in_imm; // @[Execution.scala 77:19]
  assign io_out_pcSrc = nextPC_io_pcSrc; // @[Execution.scala 78:19]
  assign io_out_nextPC = nextPC_io_nextPC; // @[Execution.scala 79:19]
  assign io_out_aluRes = alu_io_aluRes; // @[Execution.scala 80:19]
  assign io_exeRdEn = io_in_rdEn; // @[Execution.scala 83:14]
  assign io_exeRdAddr = {{27'd0}, io_in_rdAddr}; // @[Execution.scala 84:16]
  assign io_exeRdData = alu_io_aluRes; // @[Execution.scala 85:16]
  assign io_bubbleEx = io_in_typeL; // @[Execution.scala 89:15]
  assign alu_io_memtoReg = io_in_memtoReg; // @[Execution.scala 27:21]
  assign alu_io_pc = io_in_pc; // @[Execution.scala 28:15]
  assign alu_ctrl_aluA = io_in_aluA; // @[Execution.scala 21:25]
  assign alu_ctrl_aluB = io_in_aluB; // @[Execution.scala 22:25]
  assign alu_ctrl_aluOp = io_in_aluOp; // @[Execution.scala 23:26]
  assign alu_data_rData1 = io_in_rs1Data; // @[Execution.scala 24:27]
  assign alu_data_rData2 = io_in_rs2Data; // @[Execution.scala 25:27]
  assign alu_data_imm = io_in_imm; // @[Execution.scala 26:24]
  assign nextPC_io_pc = io_in_pc; // @[Execution.scala 30:18]
  assign nextPC_io_imm = io_in_imm; // @[Execution.scala 31:19]
  assign nextPC_io_rs1Data = io_in_rs1Data; // @[Execution.scala 32:23]
  assign nextPC_io_branch = io_in_branch; // @[Execution.scala 33:22]
  assign nextPC_io_less = alu_io_less; // @[Execution.scala 34:20]
  assign nextPC_io_zero = alu_io_zero; // @[Execution.scala 35:20]
endmodule
module DataMem(
  output        io_dmem_en,
  output [63:0] io_dmem_addr,
  input  [63:0] io_dmem_rdata,
  output [63:0] io_dmem_wdata,
  output [63:0] io_dmem_wmask,
  output        io_dmem_wen,
  input  [31:0] io_in_pc,
  input  [31:0] io_in_inst,
  input         io_in_typeL,
  input         io_in_aluA,
  input  [1:0]  io_in_aluB,
  input  [3:0]  io_in_aluOp,
  input  [2:0]  io_in_branch,
  input  [1:0]  io_in_memtoReg,
  input         io_in_memWr,
  input  [2:0]  io_in_memOp,
  input         io_in_rdEn,
  input  [4:0]  io_in_rdAddr,
  input  [63:0] io_in_rs1Data,
  input  [63:0] io_in_rs2Data,
  input  [63:0] io_in_imm,
  input  [1:0]  io_in_pcSrc,
  input  [31:0] io_in_nextPC,
  input  [63:0] io_in_aluRes,
  output [31:0] io_out_pc,
  output [31:0] io_out_inst,
  output        io_out_typeL,
  output        io_out_aluA,
  output [1:0]  io_out_aluB,
  output [3:0]  io_out_aluOp,
  output [2:0]  io_out_branch,
  output [1:0]  io_out_memtoReg,
  output        io_out_memWr,
  output [2:0]  io_out_memOp,
  output        io_out_rdEn,
  output [4:0]  io_out_rdAddr,
  output [63:0] io_out_rs1Data,
  output [63:0] io_out_rs2Data,
  output [63:0] io_out_imm,
  output [1:0]  io_out_pcSrc,
  output [31:0] io_out_nextPC,
  output [63:0] io_out_aluRes,
  output [63:0] io_out_memData,
  output        io_memRdEn,
  output [4:0]  io_memRdAddr,
  output [63:0] io_memRdData,
  output [1:0]  io_pcSrc,
  output [31:0] io_nextPC
);
  wire  _io_dmem_en_T_3 = ~(io_in_aluRes < 64'h80000000 | io_in_aluRes > 64'h88000000); // @[DataMem.scala 36:17]
  wire  _io_dmem_en_T_6 = io_in_memtoReg == 2'h1 | io_in_memWr; // @[DataMem.scala 37:32]
  wire [63:0] _GEN_0 = io_in_aluRes % 64'h8; // @[DataMem.scala 40:27]
  wire [3:0] alignBits = _GEN_0[3:0]; // @[DataMem.scala 40:27]
  wire [7:0] _io_dmem_wdata_T = alignBits * 4'h8; // @[DataMem.scala 41:43]
  wire [318:0] _GEN_1 = {{255'd0}, io_in_rs2Data}; // @[DataMem.scala 41:30]
  wire [318:0] _io_dmem_wdata_T_1 = _GEN_1 << _io_dmem_wdata_T; // @[DataMem.scala 41:30]
  wire [15:0] _io_dmem_wmask_T_1 = 4'h1 == alignBits ? 16'hff00 : 16'hff; // @[Mux.scala 81:58]
  wire [23:0] _io_dmem_wmask_T_3 = 4'h2 == alignBits ? 24'hff0000 : {{8'd0}, _io_dmem_wmask_T_1}; // @[Mux.scala 81:58]
  wire [31:0] _io_dmem_wmask_T_5 = 4'h3 == alignBits ? 32'hff000000 : {{8'd0}, _io_dmem_wmask_T_3}; // @[Mux.scala 81:58]
  wire [39:0] _io_dmem_wmask_T_7 = 4'h4 == alignBits ? 40'hff00000000 : {{8'd0}, _io_dmem_wmask_T_5}; // @[Mux.scala 81:58]
  wire [47:0] _io_dmem_wmask_T_9 = 4'h5 == alignBits ? 48'hff0000000000 : {{8'd0}, _io_dmem_wmask_T_7}; // @[Mux.scala 81:58]
  wire [55:0] _io_dmem_wmask_T_11 = 4'h6 == alignBits ? 56'hff000000000000 : {{8'd0}, _io_dmem_wmask_T_9}; // @[Mux.scala 81:58]
  wire [63:0] _io_dmem_wmask_T_13 = 4'h7 == alignBits ? 64'hff00000000000000 : {{8'd0}, _io_dmem_wmask_T_11}; // @[Mux.scala 81:58]
  wire [31:0] _io_dmem_wmask_T_15 = 4'h2 == alignBits ? 32'hffff0000 : 32'hffff; // @[Mux.scala 81:58]
  wire [47:0] _io_dmem_wmask_T_17 = 4'h4 == alignBits ? 48'hffff00000000 : {{16'd0}, _io_dmem_wmask_T_15}; // @[Mux.scala 81:58]
  wire [63:0] _io_dmem_wmask_T_19 = 4'h6 == alignBits ? 64'hffff000000000000 : {{16'd0}, _io_dmem_wmask_T_17}; // @[Mux.scala 81:58]
  wire [63:0] _io_dmem_wmask_T_21 = alignBits == 4'h0 ? 64'hffffffff : 64'hffffffff00000000; // @[DataMem.scala 58:20]
  wire [63:0] _io_dmem_wmask_T_23 = 3'h0 == io_in_memOp ? _io_dmem_wmask_T_13 : 64'h0; // @[Mux.scala 81:58]
  wire [63:0] _io_dmem_wmask_T_25 = 3'h1 == io_in_memOp ? _io_dmem_wmask_T_19 : _io_dmem_wmask_T_23; // @[Mux.scala 81:58]
  wire [63:0] _io_dmem_wmask_T_27 = 3'h2 == io_in_memOp ? _io_dmem_wmask_T_21 : _io_dmem_wmask_T_25; // @[Mux.scala 81:58]
  wire [63:0] rdata = io_dmem_rdata >> _io_dmem_wdata_T; // @[DataMem.scala 62:29]
  wire  rData_signBit = rdata[7]; // @[BitUtils.scala 18:20]
  wire [55:0] _rData_T_2 = rData_signBit ? 56'hffffffffffffff : 56'h0; // @[Bitwise.scala 74:12]
  wire [63:0] _rData_T_3 = {_rData_T_2,rdata[7:0]}; // @[Cat.scala 31:58]
  wire  rData_signBit_1 = rdata[15]; // @[BitUtils.scala 18:20]
  wire [47:0] _rData_T_6 = rData_signBit_1 ? 48'hffffffffffff : 48'h0; // @[Bitwise.scala 74:12]
  wire [63:0] _rData_T_7 = {_rData_T_6,rdata[15:0]}; // @[Cat.scala 31:58]
  wire  rData_signBit_2 = rdata[31]; // @[BitUtils.scala 18:20]
  wire [31:0] _rData_T_10 = rData_signBit_2 ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [63:0] _rData_T_11 = {_rData_T_10,rdata[31:0]}; // @[Cat.scala 31:58]
  wire [63:0] _rData_T_13 = {56'h0,rdata[7:0]}; // @[Cat.scala 31:58]
  wire [63:0] _rData_T_15 = {48'h0,rdata[15:0]}; // @[Cat.scala 31:58]
  wire [63:0] _rData_T_17 = {32'h0,rdata[31:0]}; // @[Cat.scala 31:58]
  wire [63:0] _rData_T_19 = 3'h0 == io_in_memOp ? _rData_T_3 : 64'h0; // @[Mux.scala 81:58]
  wire [63:0] _rData_T_21 = 3'h1 == io_in_memOp ? _rData_T_7 : _rData_T_19; // @[Mux.scala 81:58]
  wire [63:0] _rData_T_23 = 3'h2 == io_in_memOp ? _rData_T_11 : _rData_T_21; // @[Mux.scala 81:58]
  wire [63:0] _rData_T_25 = 3'h3 == io_in_memOp ? rdata : _rData_T_23; // @[Mux.scala 81:58]
  wire [63:0] _rData_T_27 = 3'h4 == io_in_memOp ? _rData_T_13 : _rData_T_25; // @[Mux.scala 81:58]
  wire [63:0] _rData_T_29 = 3'h5 == io_in_memOp ? _rData_T_15 : _rData_T_27; // @[Mux.scala 81:58]
  wire [63:0] rData = 3'h6 == io_in_memOp ? _rData_T_17 : _rData_T_29; // @[Mux.scala 81:58]
  assign io_dmem_en = ~(io_in_aluRes < 64'h80000000 | io_in_aluRes > 64'h88000000) & _io_dmem_en_T_6; // @[DataMem.scala 36:73]
  assign io_dmem_addr = io_in_aluRes; // @[DataMem.scala 38:16]
  assign io_dmem_wdata = _io_dmem_wdata_T_1[63:0]; // @[DataMem.scala 41:17]
  assign io_dmem_wmask = 3'h3 == io_in_memOp ? 64'hffffffffffffffff : _io_dmem_wmask_T_27; // @[Mux.scala 81:58]
  assign io_dmem_wen = _io_dmem_en_T_3 & io_in_memWr; // @[DataMem.scala 39:74]
  assign io_out_pc = io_in_pc; // @[DataMem.scala 100:19]
  assign io_out_inst = io_in_inst; // @[DataMem.scala 101:19]
  assign io_out_typeL = io_in_typeL; // @[DataMem.scala 102:16]
  assign io_out_aluA = io_in_aluA; // @[DataMem.scala 103:19]
  assign io_out_aluB = io_in_aluB; // @[DataMem.scala 104:19]
  assign io_out_aluOp = io_in_aluOp; // @[DataMem.scala 105:19]
  assign io_out_branch = io_in_branch; // @[DataMem.scala 106:19]
  assign io_out_memtoReg = io_in_memtoReg; // @[DataMem.scala 107:19]
  assign io_out_memWr = io_in_memWr; // @[DataMem.scala 108:19]
  assign io_out_memOp = io_in_memOp; // @[DataMem.scala 109:19]
  assign io_out_rdEn = io_in_rdEn; // @[DataMem.scala 110:19]
  assign io_out_rdAddr = io_in_rdAddr; // @[DataMem.scala 111:19]
  assign io_out_rs1Data = io_in_rs1Data; // @[DataMem.scala 113:19]
  assign io_out_rs2Data = io_in_rs2Data; // @[DataMem.scala 114:19]
  assign io_out_imm = io_in_imm; // @[DataMem.scala 115:19]
  assign io_out_pcSrc = io_in_pcSrc; // @[DataMem.scala 116:19]
  assign io_out_nextPC = io_in_nextPC; // @[DataMem.scala 117:19]
  assign io_out_aluRes = io_in_aluRes; // @[DataMem.scala 118:19]
  assign io_out_memData = io_in_memWr ? 64'h0 : rData; // @[DataMem.scala 73:18]
  assign io_memRdEn = io_in_rdEn; // @[DataMem.scala 121:14]
  assign io_memRdAddr = io_in_rdAddr; // @[DataMem.scala 122:16]
  assign io_memRdData = io_in_aluRes; // @[DataMem.scala 123:16]
  assign io_pcSrc = io_in_pcSrc; // @[DataMem.scala 125:12]
  assign io_nextPC = io_in_nextPC; // @[DataMem.scala 126:13]
endmodule
module WriteBack(
  input         io_in_valid,
  input  [31:0] io_in_pc,
  input  [31:0] io_in_inst,
  input  [1:0]  io_in_memtoReg,
  input         io_in_rdEn,
  input  [4:0]  io_in_rdAddr,
  input  [63:0] io_in_aluRes,
  input  [63:0] io_in_memData,
  output [31:0] io_pc,
  output [31:0] io_inst,
  output        io_rdEn,
  output [4:0]  io_rdAddr,
  output [63:0] io_rdData,
  output        io_wbRdEn,
  output [4:0]  io_wbRdAddr,
  output [63:0] io_wbRdData,
  output        io_ready_cmt
);
  wire  resW_signBit = io_in_aluRes[31]; // @[BitUtils.scala 18:20]
  wire [31:0] _resW_T_2 = resW_signBit ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [63:0] resW = {_resW_T_2,io_in_aluRes[31:0]}; // @[Cat.scala 31:58]
  wire [63:0] _rdData_T_1 = 2'h0 == io_in_memtoReg ? io_in_aluRes : 64'h0; // @[Mux.scala 81:58]
  wire [63:0] _rdData_T_3 = 2'h1 == io_in_memtoReg ? io_in_memData : _rdData_T_1; // @[Mux.scala 81:58]
  assign io_pc = io_in_pc; // @[WriteBack.scala 32:9]
  assign io_inst = io_in_inst; // @[WriteBack.scala 33:11]
  assign io_rdEn = io_in_rdEn; // @[WriteBack.scala 35:11]
  assign io_rdAddr = io_in_rdAddr; // @[WriteBack.scala 36:13]
  assign io_rdData = 2'h2 == io_in_memtoReg ? resW : _rdData_T_3; // @[Mux.scala 81:58]
  assign io_wbRdEn = io_in_rdEn; // @[WriteBack.scala 40:13]
  assign io_wbRdAddr = io_in_rdAddr; // @[WriteBack.scala 41:15]
  assign io_wbRdData = io_in_aluRes; // @[WriteBack.scala 42:15]
  assign io_ready_cmt = io_in_inst != 32'h0 & io_in_valid; // @[WriteBack.scala 38:39]
endmodule
module Core(
  input         clock,
  input         reset,
  output [63:0] io_imem_addr,
  input  [63:0] io_imem_rdata,
  output        io_dmem_en,
  output [63:0] io_dmem_addr,
  input  [63:0] io_dmem_rdata,
  output [63:0] io_dmem_wdata,
  output [63:0] io_dmem_wmask,
  output        io_dmem_wen
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [63:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [63:0] _RAND_6;
  reg [63:0] _RAND_7;
`endif // RANDOMIZE_REG_INIT
  wire  fetch_clock; // @[Core.scala 12:21]
  wire  fetch_reset; // @[Core.scala 12:21]
  wire [63:0] fetch_io_imem_addr; // @[Core.scala 12:21]
  wire [63:0] fetch_io_imem_rdata; // @[Core.scala 12:21]
  wire [1:0] fetch_io_pcSrc; // @[Core.scala 12:21]
  wire [31:0] fetch_io_nextPC; // @[Core.scala 12:21]
  wire  fetch_io_stall; // @[Core.scala 12:21]
  wire [31:0] fetch_io_out_pc; // @[Core.scala 12:21]
  wire [31:0] fetch_io_out_inst; // @[Core.scala 12:21]
  wire  IfRegId_clock; // @[Core.scala 13:23]
  wire  IfRegId_reset; // @[Core.scala 13:23]
  wire [31:0] IfRegId_io_in_pc; // @[Core.scala 13:23]
  wire [31:0] IfRegId_io_in_inst; // @[Core.scala 13:23]
  wire  IfRegId_io_in_typeL; // @[Core.scala 13:23]
  wire  IfRegId_io_in_aluA; // @[Core.scala 13:23]
  wire [1:0] IfRegId_io_in_aluB; // @[Core.scala 13:23]
  wire [3:0] IfRegId_io_in_aluOp; // @[Core.scala 13:23]
  wire [2:0] IfRegId_io_in_branch; // @[Core.scala 13:23]
  wire [1:0] IfRegId_io_in_memtoReg; // @[Core.scala 13:23]
  wire  IfRegId_io_in_memWr; // @[Core.scala 13:23]
  wire [2:0] IfRegId_io_in_memOp; // @[Core.scala 13:23]
  wire  IfRegId_io_in_rdEn; // @[Core.scala 13:23]
  wire [4:0] IfRegId_io_in_rdAddr; // @[Core.scala 13:23]
  wire [63:0] IfRegId_io_in_rs1Data; // @[Core.scala 13:23]
  wire [63:0] IfRegId_io_in_rs2Data; // @[Core.scala 13:23]
  wire [63:0] IfRegId_io_in_imm; // @[Core.scala 13:23]
  wire [1:0] IfRegId_io_in_pcSrc; // @[Core.scala 13:23]
  wire [31:0] IfRegId_io_in_nextPC; // @[Core.scala 13:23]
  wire [63:0] IfRegId_io_in_aluRes; // @[Core.scala 13:23]
  wire [63:0] IfRegId_io_in_memData; // @[Core.scala 13:23]
  wire  IfRegId_io_out_valid; // @[Core.scala 13:23]
  wire [31:0] IfRegId_io_out_pc; // @[Core.scala 13:23]
  wire [31:0] IfRegId_io_out_inst; // @[Core.scala 13:23]
  wire  IfRegId_io_out_typeL; // @[Core.scala 13:23]
  wire  IfRegId_io_out_aluA; // @[Core.scala 13:23]
  wire [1:0] IfRegId_io_out_aluB; // @[Core.scala 13:23]
  wire [3:0] IfRegId_io_out_aluOp; // @[Core.scala 13:23]
  wire [2:0] IfRegId_io_out_branch; // @[Core.scala 13:23]
  wire [1:0] IfRegId_io_out_memtoReg; // @[Core.scala 13:23]
  wire  IfRegId_io_out_memWr; // @[Core.scala 13:23]
  wire [2:0] IfRegId_io_out_memOp; // @[Core.scala 13:23]
  wire  IfRegId_io_out_rdEn; // @[Core.scala 13:23]
  wire [4:0] IfRegId_io_out_rdAddr; // @[Core.scala 13:23]
  wire [63:0] IfRegId_io_out_rs1Data; // @[Core.scala 13:23]
  wire [63:0] IfRegId_io_out_rs2Data; // @[Core.scala 13:23]
  wire [63:0] IfRegId_io_out_imm; // @[Core.scala 13:23]
  wire [1:0] IfRegId_io_out_pcSrc; // @[Core.scala 13:23]
  wire [31:0] IfRegId_io_out_nextPC; // @[Core.scala 13:23]
  wire [63:0] IfRegId_io_out_aluRes; // @[Core.scala 13:23]
  wire [63:0] IfRegId_io_out_memData; // @[Core.scala 13:23]
  wire  IfRegId_io_flush; // @[Core.scala 13:23]
  wire  IfRegId_io_stall; // @[Core.scala 13:23]
  wire  decode_clock; // @[Core.scala 14:22]
  wire  decode_reset; // @[Core.scala 14:22]
  wire  decode_io_rdEn; // @[Core.scala 14:22]
  wire [4:0] decode_io_rdAddr; // @[Core.scala 14:22]
  wire [63:0] decode_io_rdData; // @[Core.scala 14:22]
  wire [31:0] decode_io_in_pc; // @[Core.scala 14:22]
  wire [31:0] decode_io_in_inst; // @[Core.scala 14:22]
  wire  decode_io_exeRdEn; // @[Core.scala 14:22]
  wire [4:0] decode_io_exeRdAddr; // @[Core.scala 14:22]
  wire [63:0] decode_io_exeRdData; // @[Core.scala 14:22]
  wire  decode_io_memRdEn; // @[Core.scala 14:22]
  wire [4:0] decode_io_memRdAddr; // @[Core.scala 14:22]
  wire [63:0] decode_io_memRdData; // @[Core.scala 14:22]
  wire  decode_io_wbRdEn; // @[Core.scala 14:22]
  wire [4:0] decode_io_wbRdAddr; // @[Core.scala 14:22]
  wire [63:0] decode_io_wbRdData; // @[Core.scala 14:22]
  wire  decode_io_bubbleId; // @[Core.scala 14:22]
  wire [31:0] decode_io_out_pc; // @[Core.scala 14:22]
  wire [31:0] decode_io_out_inst; // @[Core.scala 14:22]
  wire  decode_io_out_typeL; // @[Core.scala 14:22]
  wire  decode_io_out_aluA; // @[Core.scala 14:22]
  wire [1:0] decode_io_out_aluB; // @[Core.scala 14:22]
  wire [3:0] decode_io_out_aluOp; // @[Core.scala 14:22]
  wire [2:0] decode_io_out_branch; // @[Core.scala 14:22]
  wire [1:0] decode_io_out_memtoReg; // @[Core.scala 14:22]
  wire  decode_io_out_memWr; // @[Core.scala 14:22]
  wire [2:0] decode_io_out_memOp; // @[Core.scala 14:22]
  wire  decode_io_out_rdEn; // @[Core.scala 14:22]
  wire [4:0] decode_io_out_rdAddr; // @[Core.scala 14:22]
  wire [63:0] decode_io_out_rs1Data; // @[Core.scala 14:22]
  wire [63:0] decode_io_out_rs2Data; // @[Core.scala 14:22]
  wire [63:0] decode_io_out_imm; // @[Core.scala 14:22]
  wire [63:0] decode_rf_10; // @[Core.scala 14:22]
  wire  IdRegEx_clock; // @[Core.scala 15:23]
  wire  IdRegEx_reset; // @[Core.scala 15:23]
  wire [31:0] IdRegEx_io_in_pc; // @[Core.scala 15:23]
  wire [31:0] IdRegEx_io_in_inst; // @[Core.scala 15:23]
  wire  IdRegEx_io_in_typeL; // @[Core.scala 15:23]
  wire  IdRegEx_io_in_aluA; // @[Core.scala 15:23]
  wire [1:0] IdRegEx_io_in_aluB; // @[Core.scala 15:23]
  wire [3:0] IdRegEx_io_in_aluOp; // @[Core.scala 15:23]
  wire [2:0] IdRegEx_io_in_branch; // @[Core.scala 15:23]
  wire [1:0] IdRegEx_io_in_memtoReg; // @[Core.scala 15:23]
  wire  IdRegEx_io_in_memWr; // @[Core.scala 15:23]
  wire [2:0] IdRegEx_io_in_memOp; // @[Core.scala 15:23]
  wire  IdRegEx_io_in_rdEn; // @[Core.scala 15:23]
  wire [4:0] IdRegEx_io_in_rdAddr; // @[Core.scala 15:23]
  wire [63:0] IdRegEx_io_in_rs1Data; // @[Core.scala 15:23]
  wire [63:0] IdRegEx_io_in_rs2Data; // @[Core.scala 15:23]
  wire [63:0] IdRegEx_io_in_imm; // @[Core.scala 15:23]
  wire [1:0] IdRegEx_io_in_pcSrc; // @[Core.scala 15:23]
  wire [31:0] IdRegEx_io_in_nextPC; // @[Core.scala 15:23]
  wire [63:0] IdRegEx_io_in_aluRes; // @[Core.scala 15:23]
  wire [63:0] IdRegEx_io_in_memData; // @[Core.scala 15:23]
  wire  IdRegEx_io_out_valid; // @[Core.scala 15:23]
  wire [31:0] IdRegEx_io_out_pc; // @[Core.scala 15:23]
  wire [31:0] IdRegEx_io_out_inst; // @[Core.scala 15:23]
  wire  IdRegEx_io_out_typeL; // @[Core.scala 15:23]
  wire  IdRegEx_io_out_aluA; // @[Core.scala 15:23]
  wire [1:0] IdRegEx_io_out_aluB; // @[Core.scala 15:23]
  wire [3:0] IdRegEx_io_out_aluOp; // @[Core.scala 15:23]
  wire [2:0] IdRegEx_io_out_branch; // @[Core.scala 15:23]
  wire [1:0] IdRegEx_io_out_memtoReg; // @[Core.scala 15:23]
  wire  IdRegEx_io_out_memWr; // @[Core.scala 15:23]
  wire [2:0] IdRegEx_io_out_memOp; // @[Core.scala 15:23]
  wire  IdRegEx_io_out_rdEn; // @[Core.scala 15:23]
  wire [4:0] IdRegEx_io_out_rdAddr; // @[Core.scala 15:23]
  wire [63:0] IdRegEx_io_out_rs1Data; // @[Core.scala 15:23]
  wire [63:0] IdRegEx_io_out_rs2Data; // @[Core.scala 15:23]
  wire [63:0] IdRegEx_io_out_imm; // @[Core.scala 15:23]
  wire [1:0] IdRegEx_io_out_pcSrc; // @[Core.scala 15:23]
  wire [31:0] IdRegEx_io_out_nextPC; // @[Core.scala 15:23]
  wire [63:0] IdRegEx_io_out_aluRes; // @[Core.scala 15:23]
  wire [63:0] IdRegEx_io_out_memData; // @[Core.scala 15:23]
  wire  IdRegEx_io_flush; // @[Core.scala 15:23]
  wire  IdRegEx_io_stall; // @[Core.scala 15:23]
  wire [31:0] ex_io_in_pc; // @[Core.scala 16:18]
  wire [31:0] ex_io_in_inst; // @[Core.scala 16:18]
  wire  ex_io_in_typeL; // @[Core.scala 16:18]
  wire  ex_io_in_aluA; // @[Core.scala 16:18]
  wire [1:0] ex_io_in_aluB; // @[Core.scala 16:18]
  wire [3:0] ex_io_in_aluOp; // @[Core.scala 16:18]
  wire [2:0] ex_io_in_branch; // @[Core.scala 16:18]
  wire [1:0] ex_io_in_memtoReg; // @[Core.scala 16:18]
  wire  ex_io_in_memWr; // @[Core.scala 16:18]
  wire [2:0] ex_io_in_memOp; // @[Core.scala 16:18]
  wire  ex_io_in_rdEn; // @[Core.scala 16:18]
  wire [4:0] ex_io_in_rdAddr; // @[Core.scala 16:18]
  wire [63:0] ex_io_in_rs1Data; // @[Core.scala 16:18]
  wire [63:0] ex_io_in_rs2Data; // @[Core.scala 16:18]
  wire [63:0] ex_io_in_imm; // @[Core.scala 16:18]
  wire [31:0] ex_io_out_pc; // @[Core.scala 16:18]
  wire [31:0] ex_io_out_inst; // @[Core.scala 16:18]
  wire  ex_io_out_typeL; // @[Core.scala 16:18]
  wire  ex_io_out_aluA; // @[Core.scala 16:18]
  wire [1:0] ex_io_out_aluB; // @[Core.scala 16:18]
  wire [3:0] ex_io_out_aluOp; // @[Core.scala 16:18]
  wire [2:0] ex_io_out_branch; // @[Core.scala 16:18]
  wire [1:0] ex_io_out_memtoReg; // @[Core.scala 16:18]
  wire  ex_io_out_memWr; // @[Core.scala 16:18]
  wire [2:0] ex_io_out_memOp; // @[Core.scala 16:18]
  wire  ex_io_out_rdEn; // @[Core.scala 16:18]
  wire [4:0] ex_io_out_rdAddr; // @[Core.scala 16:18]
  wire [63:0] ex_io_out_rs1Data; // @[Core.scala 16:18]
  wire [63:0] ex_io_out_rs2Data; // @[Core.scala 16:18]
  wire [63:0] ex_io_out_imm; // @[Core.scala 16:18]
  wire [1:0] ex_io_out_pcSrc; // @[Core.scala 16:18]
  wire [31:0] ex_io_out_nextPC; // @[Core.scala 16:18]
  wire [63:0] ex_io_out_aluRes; // @[Core.scala 16:18]
  wire  ex_io_exeRdEn; // @[Core.scala 16:18]
  wire [31:0] ex_io_exeRdAddr; // @[Core.scala 16:18]
  wire [63:0] ex_io_exeRdData; // @[Core.scala 16:18]
  wire  ex_io_bubbleEx; // @[Core.scala 16:18]
  wire  ExRegMem_clock; // @[Core.scala 17:24]
  wire  ExRegMem_reset; // @[Core.scala 17:24]
  wire [31:0] ExRegMem_io_in_pc; // @[Core.scala 17:24]
  wire [31:0] ExRegMem_io_in_inst; // @[Core.scala 17:24]
  wire  ExRegMem_io_in_typeL; // @[Core.scala 17:24]
  wire  ExRegMem_io_in_aluA; // @[Core.scala 17:24]
  wire [1:0] ExRegMem_io_in_aluB; // @[Core.scala 17:24]
  wire [3:0] ExRegMem_io_in_aluOp; // @[Core.scala 17:24]
  wire [2:0] ExRegMem_io_in_branch; // @[Core.scala 17:24]
  wire [1:0] ExRegMem_io_in_memtoReg; // @[Core.scala 17:24]
  wire  ExRegMem_io_in_memWr; // @[Core.scala 17:24]
  wire [2:0] ExRegMem_io_in_memOp; // @[Core.scala 17:24]
  wire  ExRegMem_io_in_rdEn; // @[Core.scala 17:24]
  wire [4:0] ExRegMem_io_in_rdAddr; // @[Core.scala 17:24]
  wire [63:0] ExRegMem_io_in_rs1Data; // @[Core.scala 17:24]
  wire [63:0] ExRegMem_io_in_rs2Data; // @[Core.scala 17:24]
  wire [63:0] ExRegMem_io_in_imm; // @[Core.scala 17:24]
  wire [1:0] ExRegMem_io_in_pcSrc; // @[Core.scala 17:24]
  wire [31:0] ExRegMem_io_in_nextPC; // @[Core.scala 17:24]
  wire [63:0] ExRegMem_io_in_aluRes; // @[Core.scala 17:24]
  wire [63:0] ExRegMem_io_in_memData; // @[Core.scala 17:24]
  wire  ExRegMem_io_out_valid; // @[Core.scala 17:24]
  wire [31:0] ExRegMem_io_out_pc; // @[Core.scala 17:24]
  wire [31:0] ExRegMem_io_out_inst; // @[Core.scala 17:24]
  wire  ExRegMem_io_out_typeL; // @[Core.scala 17:24]
  wire  ExRegMem_io_out_aluA; // @[Core.scala 17:24]
  wire [1:0] ExRegMem_io_out_aluB; // @[Core.scala 17:24]
  wire [3:0] ExRegMem_io_out_aluOp; // @[Core.scala 17:24]
  wire [2:0] ExRegMem_io_out_branch; // @[Core.scala 17:24]
  wire [1:0] ExRegMem_io_out_memtoReg; // @[Core.scala 17:24]
  wire  ExRegMem_io_out_memWr; // @[Core.scala 17:24]
  wire [2:0] ExRegMem_io_out_memOp; // @[Core.scala 17:24]
  wire  ExRegMem_io_out_rdEn; // @[Core.scala 17:24]
  wire [4:0] ExRegMem_io_out_rdAddr; // @[Core.scala 17:24]
  wire [63:0] ExRegMem_io_out_rs1Data; // @[Core.scala 17:24]
  wire [63:0] ExRegMem_io_out_rs2Data; // @[Core.scala 17:24]
  wire [63:0] ExRegMem_io_out_imm; // @[Core.scala 17:24]
  wire [1:0] ExRegMem_io_out_pcSrc; // @[Core.scala 17:24]
  wire [31:0] ExRegMem_io_out_nextPC; // @[Core.scala 17:24]
  wire [63:0] ExRegMem_io_out_aluRes; // @[Core.scala 17:24]
  wire [63:0] ExRegMem_io_out_memData; // @[Core.scala 17:24]
  wire  ExRegMem_io_flush; // @[Core.scala 17:24]
  wire  ExRegMem_io_stall; // @[Core.scala 17:24]
  wire  mem_io_dmem_en; // @[Core.scala 18:19]
  wire [63:0] mem_io_dmem_addr; // @[Core.scala 18:19]
  wire [63:0] mem_io_dmem_rdata; // @[Core.scala 18:19]
  wire [63:0] mem_io_dmem_wdata; // @[Core.scala 18:19]
  wire [63:0] mem_io_dmem_wmask; // @[Core.scala 18:19]
  wire  mem_io_dmem_wen; // @[Core.scala 18:19]
  wire [31:0] mem_io_in_pc; // @[Core.scala 18:19]
  wire [31:0] mem_io_in_inst; // @[Core.scala 18:19]
  wire  mem_io_in_typeL; // @[Core.scala 18:19]
  wire  mem_io_in_aluA; // @[Core.scala 18:19]
  wire [1:0] mem_io_in_aluB; // @[Core.scala 18:19]
  wire [3:0] mem_io_in_aluOp; // @[Core.scala 18:19]
  wire [2:0] mem_io_in_branch; // @[Core.scala 18:19]
  wire [1:0] mem_io_in_memtoReg; // @[Core.scala 18:19]
  wire  mem_io_in_memWr; // @[Core.scala 18:19]
  wire [2:0] mem_io_in_memOp; // @[Core.scala 18:19]
  wire  mem_io_in_rdEn; // @[Core.scala 18:19]
  wire [4:0] mem_io_in_rdAddr; // @[Core.scala 18:19]
  wire [63:0] mem_io_in_rs1Data; // @[Core.scala 18:19]
  wire [63:0] mem_io_in_rs2Data; // @[Core.scala 18:19]
  wire [63:0] mem_io_in_imm; // @[Core.scala 18:19]
  wire [1:0] mem_io_in_pcSrc; // @[Core.scala 18:19]
  wire [31:0] mem_io_in_nextPC; // @[Core.scala 18:19]
  wire [63:0] mem_io_in_aluRes; // @[Core.scala 18:19]
  wire [31:0] mem_io_out_pc; // @[Core.scala 18:19]
  wire [31:0] mem_io_out_inst; // @[Core.scala 18:19]
  wire  mem_io_out_typeL; // @[Core.scala 18:19]
  wire  mem_io_out_aluA; // @[Core.scala 18:19]
  wire [1:0] mem_io_out_aluB; // @[Core.scala 18:19]
  wire [3:0] mem_io_out_aluOp; // @[Core.scala 18:19]
  wire [2:0] mem_io_out_branch; // @[Core.scala 18:19]
  wire [1:0] mem_io_out_memtoReg; // @[Core.scala 18:19]
  wire  mem_io_out_memWr; // @[Core.scala 18:19]
  wire [2:0] mem_io_out_memOp; // @[Core.scala 18:19]
  wire  mem_io_out_rdEn; // @[Core.scala 18:19]
  wire [4:0] mem_io_out_rdAddr; // @[Core.scala 18:19]
  wire [63:0] mem_io_out_rs1Data; // @[Core.scala 18:19]
  wire [63:0] mem_io_out_rs2Data; // @[Core.scala 18:19]
  wire [63:0] mem_io_out_imm; // @[Core.scala 18:19]
  wire [1:0] mem_io_out_pcSrc; // @[Core.scala 18:19]
  wire [31:0] mem_io_out_nextPC; // @[Core.scala 18:19]
  wire [63:0] mem_io_out_aluRes; // @[Core.scala 18:19]
  wire [63:0] mem_io_out_memData; // @[Core.scala 18:19]
  wire  mem_io_memRdEn; // @[Core.scala 18:19]
  wire [4:0] mem_io_memRdAddr; // @[Core.scala 18:19]
  wire [63:0] mem_io_memRdData; // @[Core.scala 18:19]
  wire [1:0] mem_io_pcSrc; // @[Core.scala 18:19]
  wire [31:0] mem_io_nextPC; // @[Core.scala 18:19]
  wire  MemRegWb_clock; // @[Core.scala 19:24]
  wire  MemRegWb_reset; // @[Core.scala 19:24]
  wire [31:0] MemRegWb_io_in_pc; // @[Core.scala 19:24]
  wire [31:0] MemRegWb_io_in_inst; // @[Core.scala 19:24]
  wire  MemRegWb_io_in_typeL; // @[Core.scala 19:24]
  wire  MemRegWb_io_in_aluA; // @[Core.scala 19:24]
  wire [1:0] MemRegWb_io_in_aluB; // @[Core.scala 19:24]
  wire [3:0] MemRegWb_io_in_aluOp; // @[Core.scala 19:24]
  wire [2:0] MemRegWb_io_in_branch; // @[Core.scala 19:24]
  wire [1:0] MemRegWb_io_in_memtoReg; // @[Core.scala 19:24]
  wire  MemRegWb_io_in_memWr; // @[Core.scala 19:24]
  wire [2:0] MemRegWb_io_in_memOp; // @[Core.scala 19:24]
  wire  MemRegWb_io_in_rdEn; // @[Core.scala 19:24]
  wire [4:0] MemRegWb_io_in_rdAddr; // @[Core.scala 19:24]
  wire [63:0] MemRegWb_io_in_rs1Data; // @[Core.scala 19:24]
  wire [63:0] MemRegWb_io_in_rs2Data; // @[Core.scala 19:24]
  wire [63:0] MemRegWb_io_in_imm; // @[Core.scala 19:24]
  wire [1:0] MemRegWb_io_in_pcSrc; // @[Core.scala 19:24]
  wire [31:0] MemRegWb_io_in_nextPC; // @[Core.scala 19:24]
  wire [63:0] MemRegWb_io_in_aluRes; // @[Core.scala 19:24]
  wire [63:0] MemRegWb_io_in_memData; // @[Core.scala 19:24]
  wire  MemRegWb_io_out_valid; // @[Core.scala 19:24]
  wire [31:0] MemRegWb_io_out_pc; // @[Core.scala 19:24]
  wire [31:0] MemRegWb_io_out_inst; // @[Core.scala 19:24]
  wire  MemRegWb_io_out_typeL; // @[Core.scala 19:24]
  wire  MemRegWb_io_out_aluA; // @[Core.scala 19:24]
  wire [1:0] MemRegWb_io_out_aluB; // @[Core.scala 19:24]
  wire [3:0] MemRegWb_io_out_aluOp; // @[Core.scala 19:24]
  wire [2:0] MemRegWb_io_out_branch; // @[Core.scala 19:24]
  wire [1:0] MemRegWb_io_out_memtoReg; // @[Core.scala 19:24]
  wire  MemRegWb_io_out_memWr; // @[Core.scala 19:24]
  wire [2:0] MemRegWb_io_out_memOp; // @[Core.scala 19:24]
  wire  MemRegWb_io_out_rdEn; // @[Core.scala 19:24]
  wire [4:0] MemRegWb_io_out_rdAddr; // @[Core.scala 19:24]
  wire [63:0] MemRegWb_io_out_rs1Data; // @[Core.scala 19:24]
  wire [63:0] MemRegWb_io_out_rs2Data; // @[Core.scala 19:24]
  wire [63:0] MemRegWb_io_out_imm; // @[Core.scala 19:24]
  wire [1:0] MemRegWb_io_out_pcSrc; // @[Core.scala 19:24]
  wire [31:0] MemRegWb_io_out_nextPC; // @[Core.scala 19:24]
  wire [63:0] MemRegWb_io_out_aluRes; // @[Core.scala 19:24]
  wire [63:0] MemRegWb_io_out_memData; // @[Core.scala 19:24]
  wire  MemRegWb_io_flush; // @[Core.scala 19:24]
  wire  MemRegWb_io_stall; // @[Core.scala 19:24]
  wire  wb_io_in_valid; // @[Core.scala 20:18]
  wire [31:0] wb_io_in_pc; // @[Core.scala 20:18]
  wire [31:0] wb_io_in_inst; // @[Core.scala 20:18]
  wire [1:0] wb_io_in_memtoReg; // @[Core.scala 20:18]
  wire  wb_io_in_rdEn; // @[Core.scala 20:18]
  wire [4:0] wb_io_in_rdAddr; // @[Core.scala 20:18]
  wire [63:0] wb_io_in_aluRes; // @[Core.scala 20:18]
  wire [63:0] wb_io_in_memData; // @[Core.scala 20:18]
  wire [31:0] wb_io_pc; // @[Core.scala 20:18]
  wire [31:0] wb_io_inst; // @[Core.scala 20:18]
  wire  wb_io_rdEn; // @[Core.scala 20:18]
  wire [4:0] wb_io_rdAddr; // @[Core.scala 20:18]
  wire [63:0] wb_io_rdData; // @[Core.scala 20:18]
  wire  wb_io_wbRdEn; // @[Core.scala 20:18]
  wire [4:0] wb_io_wbRdAddr; // @[Core.scala 20:18]
  wire [63:0] wb_io_wbRdData; // @[Core.scala 20:18]
  wire  wb_io_ready_cmt; // @[Core.scala 20:18]
  wire  dt_ic_clock; // @[Core.scala 81:21]
  wire [7:0] dt_ic_coreid; // @[Core.scala 81:21]
  wire [7:0] dt_ic_index; // @[Core.scala 81:21]
  wire  dt_ic_valid; // @[Core.scala 81:21]
  wire [63:0] dt_ic_pc; // @[Core.scala 81:21]
  wire [31:0] dt_ic_instr; // @[Core.scala 81:21]
  wire  dt_ic_skip; // @[Core.scala 81:21]
  wire  dt_ic_isRVC; // @[Core.scala 81:21]
  wire  dt_ic_scFailed; // @[Core.scala 81:21]
  wire  dt_ic_wen; // @[Core.scala 81:21]
  wire [63:0] dt_ic_wdata; // @[Core.scala 81:21]
  wire [7:0] dt_ic_wdest; // @[Core.scala 81:21]
  wire  dt_ae_clock; // @[Core.scala 95:21]
  wire [7:0] dt_ae_coreid; // @[Core.scala 95:21]
  wire [31:0] dt_ae_intrNO; // @[Core.scala 95:21]
  wire [31:0] dt_ae_cause; // @[Core.scala 95:21]
  wire [63:0] dt_ae_exceptionPC; // @[Core.scala 95:21]
  wire [31:0] dt_ae_exceptionInst; // @[Core.scala 95:21]
  wire  dt_te_clock; // @[Core.scala 111:21]
  wire [7:0] dt_te_coreid; // @[Core.scala 111:21]
  wire  dt_te_valid; // @[Core.scala 111:21]
  wire [2:0] dt_te_code; // @[Core.scala 111:21]
  wire [63:0] dt_te_pc; // @[Core.scala 111:21]
  wire [63:0] dt_te_cycleCnt; // @[Core.scala 111:21]
  wire [63:0] dt_te_instrCnt; // @[Core.scala 111:21]
  wire  dt_cs_clock; // @[Core.scala 120:21]
  wire [7:0] dt_cs_coreid; // @[Core.scala 120:21]
  wire [1:0] dt_cs_priviledgeMode; // @[Core.scala 120:21]
  wire [63:0] dt_cs_mstatus; // @[Core.scala 120:21]
  wire [63:0] dt_cs_sstatus; // @[Core.scala 120:21]
  wire [63:0] dt_cs_mepc; // @[Core.scala 120:21]
  wire [63:0] dt_cs_sepc; // @[Core.scala 120:21]
  wire [63:0] dt_cs_mtval; // @[Core.scala 120:21]
  wire [63:0] dt_cs_stval; // @[Core.scala 120:21]
  wire [63:0] dt_cs_mtvec; // @[Core.scala 120:21]
  wire [63:0] dt_cs_stvec; // @[Core.scala 120:21]
  wire [63:0] dt_cs_mcause; // @[Core.scala 120:21]
  wire [63:0] dt_cs_scause; // @[Core.scala 120:21]
  wire [63:0] dt_cs_satp; // @[Core.scala 120:21]
  wire [63:0] dt_cs_mip; // @[Core.scala 120:21]
  wire [63:0] dt_cs_mie; // @[Core.scala 120:21]
  wire [63:0] dt_cs_mscratch; // @[Core.scala 120:21]
  wire [63:0] dt_cs_sscratch; // @[Core.scala 120:21]
  wire [63:0] dt_cs_mideleg; // @[Core.scala 120:21]
  wire [63:0] dt_cs_medeleg; // @[Core.scala 120:21]
  wire  stallEn = decode_io_bubbleId & ex_io_bubbleEx; // @[Core.scala 22:36]
  reg  dt_ic_io_valid_REG; // @[Core.scala 85:31]
  reg [31:0] dt_ic_io_pc_REG; // @[Core.scala 86:31]
  reg [31:0] dt_ic_io_instr_REG; // @[Core.scala 87:31]
  reg  dt_ic_io_wen_REG; // @[Core.scala 91:31]
  reg [63:0] dt_ic_io_wdata_REG; // @[Core.scala 92:31]
  reg [4:0] dt_ic_io_wdest_REG; // @[Core.scala 93:31]
  reg [63:0] cycle_cnt; // @[Core.scala 102:26]
  reg [63:0] instr_cnt; // @[Core.scala 103:26]
  wire [63:0] _cycle_cnt_T_1 = cycle_cnt + 64'h1; // @[Core.scala 105:26]
  wire [63:0] _instr_cnt_T_1 = instr_cnt + 64'h1; // @[Core.scala 106:26]
  wire [63:0] rf_a0_0 = decode_rf_10;
  InstFetch fetch ( // @[Core.scala 12:21]
    .clock(fetch_clock),
    .reset(fetch_reset),
    .io_imem_addr(fetch_io_imem_addr),
    .io_imem_rdata(fetch_io_imem_rdata),
    .io_pcSrc(fetch_io_pcSrc),
    .io_nextPC(fetch_io_nextPC),
    .io_stall(fetch_io_stall),
    .io_out_pc(fetch_io_out_pc),
    .io_out_inst(fetch_io_out_inst)
  );
  PipelineReg IfRegId ( // @[Core.scala 13:23]
    .clock(IfRegId_clock),
    .reset(IfRegId_reset),
    .io_in_pc(IfRegId_io_in_pc),
    .io_in_inst(IfRegId_io_in_inst),
    .io_in_typeL(IfRegId_io_in_typeL),
    .io_in_aluA(IfRegId_io_in_aluA),
    .io_in_aluB(IfRegId_io_in_aluB),
    .io_in_aluOp(IfRegId_io_in_aluOp),
    .io_in_branch(IfRegId_io_in_branch),
    .io_in_memtoReg(IfRegId_io_in_memtoReg),
    .io_in_memWr(IfRegId_io_in_memWr),
    .io_in_memOp(IfRegId_io_in_memOp),
    .io_in_rdEn(IfRegId_io_in_rdEn),
    .io_in_rdAddr(IfRegId_io_in_rdAddr),
    .io_in_rs1Data(IfRegId_io_in_rs1Data),
    .io_in_rs2Data(IfRegId_io_in_rs2Data),
    .io_in_imm(IfRegId_io_in_imm),
    .io_in_pcSrc(IfRegId_io_in_pcSrc),
    .io_in_nextPC(IfRegId_io_in_nextPC),
    .io_in_aluRes(IfRegId_io_in_aluRes),
    .io_in_memData(IfRegId_io_in_memData),
    .io_out_valid(IfRegId_io_out_valid),
    .io_out_pc(IfRegId_io_out_pc),
    .io_out_inst(IfRegId_io_out_inst),
    .io_out_typeL(IfRegId_io_out_typeL),
    .io_out_aluA(IfRegId_io_out_aluA),
    .io_out_aluB(IfRegId_io_out_aluB),
    .io_out_aluOp(IfRegId_io_out_aluOp),
    .io_out_branch(IfRegId_io_out_branch),
    .io_out_memtoReg(IfRegId_io_out_memtoReg),
    .io_out_memWr(IfRegId_io_out_memWr),
    .io_out_memOp(IfRegId_io_out_memOp),
    .io_out_rdEn(IfRegId_io_out_rdEn),
    .io_out_rdAddr(IfRegId_io_out_rdAddr),
    .io_out_rs1Data(IfRegId_io_out_rs1Data),
    .io_out_rs2Data(IfRegId_io_out_rs2Data),
    .io_out_imm(IfRegId_io_out_imm),
    .io_out_pcSrc(IfRegId_io_out_pcSrc),
    .io_out_nextPC(IfRegId_io_out_nextPC),
    .io_out_aluRes(IfRegId_io_out_aluRes),
    .io_out_memData(IfRegId_io_out_memData),
    .io_flush(IfRegId_io_flush),
    .io_stall(IfRegId_io_stall)
  );
  Decode decode ( // @[Core.scala 14:22]
    .clock(decode_clock),
    .reset(decode_reset),
    .io_rdEn(decode_io_rdEn),
    .io_rdAddr(decode_io_rdAddr),
    .io_rdData(decode_io_rdData),
    .io_in_pc(decode_io_in_pc),
    .io_in_inst(decode_io_in_inst),
    .io_exeRdEn(decode_io_exeRdEn),
    .io_exeRdAddr(decode_io_exeRdAddr),
    .io_exeRdData(decode_io_exeRdData),
    .io_memRdEn(decode_io_memRdEn),
    .io_memRdAddr(decode_io_memRdAddr),
    .io_memRdData(decode_io_memRdData),
    .io_wbRdEn(decode_io_wbRdEn),
    .io_wbRdAddr(decode_io_wbRdAddr),
    .io_wbRdData(decode_io_wbRdData),
    .io_bubbleId(decode_io_bubbleId),
    .io_out_pc(decode_io_out_pc),
    .io_out_inst(decode_io_out_inst),
    .io_out_typeL(decode_io_out_typeL),
    .io_out_aluA(decode_io_out_aluA),
    .io_out_aluB(decode_io_out_aluB),
    .io_out_aluOp(decode_io_out_aluOp),
    .io_out_branch(decode_io_out_branch),
    .io_out_memtoReg(decode_io_out_memtoReg),
    .io_out_memWr(decode_io_out_memWr),
    .io_out_memOp(decode_io_out_memOp),
    .io_out_rdEn(decode_io_out_rdEn),
    .io_out_rdAddr(decode_io_out_rdAddr),
    .io_out_rs1Data(decode_io_out_rs1Data),
    .io_out_rs2Data(decode_io_out_rs2Data),
    .io_out_imm(decode_io_out_imm),
    .rf_10(decode_rf_10)
  );
  PipelineReg IdRegEx ( // @[Core.scala 15:23]
    .clock(IdRegEx_clock),
    .reset(IdRegEx_reset),
    .io_in_pc(IdRegEx_io_in_pc),
    .io_in_inst(IdRegEx_io_in_inst),
    .io_in_typeL(IdRegEx_io_in_typeL),
    .io_in_aluA(IdRegEx_io_in_aluA),
    .io_in_aluB(IdRegEx_io_in_aluB),
    .io_in_aluOp(IdRegEx_io_in_aluOp),
    .io_in_branch(IdRegEx_io_in_branch),
    .io_in_memtoReg(IdRegEx_io_in_memtoReg),
    .io_in_memWr(IdRegEx_io_in_memWr),
    .io_in_memOp(IdRegEx_io_in_memOp),
    .io_in_rdEn(IdRegEx_io_in_rdEn),
    .io_in_rdAddr(IdRegEx_io_in_rdAddr),
    .io_in_rs1Data(IdRegEx_io_in_rs1Data),
    .io_in_rs2Data(IdRegEx_io_in_rs2Data),
    .io_in_imm(IdRegEx_io_in_imm),
    .io_in_pcSrc(IdRegEx_io_in_pcSrc),
    .io_in_nextPC(IdRegEx_io_in_nextPC),
    .io_in_aluRes(IdRegEx_io_in_aluRes),
    .io_in_memData(IdRegEx_io_in_memData),
    .io_out_valid(IdRegEx_io_out_valid),
    .io_out_pc(IdRegEx_io_out_pc),
    .io_out_inst(IdRegEx_io_out_inst),
    .io_out_typeL(IdRegEx_io_out_typeL),
    .io_out_aluA(IdRegEx_io_out_aluA),
    .io_out_aluB(IdRegEx_io_out_aluB),
    .io_out_aluOp(IdRegEx_io_out_aluOp),
    .io_out_branch(IdRegEx_io_out_branch),
    .io_out_memtoReg(IdRegEx_io_out_memtoReg),
    .io_out_memWr(IdRegEx_io_out_memWr),
    .io_out_memOp(IdRegEx_io_out_memOp),
    .io_out_rdEn(IdRegEx_io_out_rdEn),
    .io_out_rdAddr(IdRegEx_io_out_rdAddr),
    .io_out_rs1Data(IdRegEx_io_out_rs1Data),
    .io_out_rs2Data(IdRegEx_io_out_rs2Data),
    .io_out_imm(IdRegEx_io_out_imm),
    .io_out_pcSrc(IdRegEx_io_out_pcSrc),
    .io_out_nextPC(IdRegEx_io_out_nextPC),
    .io_out_aluRes(IdRegEx_io_out_aluRes),
    .io_out_memData(IdRegEx_io_out_memData),
    .io_flush(IdRegEx_io_flush),
    .io_stall(IdRegEx_io_stall)
  );
  Execution ex ( // @[Core.scala 16:18]
    .io_in_pc(ex_io_in_pc),
    .io_in_inst(ex_io_in_inst),
    .io_in_typeL(ex_io_in_typeL),
    .io_in_aluA(ex_io_in_aluA),
    .io_in_aluB(ex_io_in_aluB),
    .io_in_aluOp(ex_io_in_aluOp),
    .io_in_branch(ex_io_in_branch),
    .io_in_memtoReg(ex_io_in_memtoReg),
    .io_in_memWr(ex_io_in_memWr),
    .io_in_memOp(ex_io_in_memOp),
    .io_in_rdEn(ex_io_in_rdEn),
    .io_in_rdAddr(ex_io_in_rdAddr),
    .io_in_rs1Data(ex_io_in_rs1Data),
    .io_in_rs2Data(ex_io_in_rs2Data),
    .io_in_imm(ex_io_in_imm),
    .io_out_pc(ex_io_out_pc),
    .io_out_inst(ex_io_out_inst),
    .io_out_typeL(ex_io_out_typeL),
    .io_out_aluA(ex_io_out_aluA),
    .io_out_aluB(ex_io_out_aluB),
    .io_out_aluOp(ex_io_out_aluOp),
    .io_out_branch(ex_io_out_branch),
    .io_out_memtoReg(ex_io_out_memtoReg),
    .io_out_memWr(ex_io_out_memWr),
    .io_out_memOp(ex_io_out_memOp),
    .io_out_rdEn(ex_io_out_rdEn),
    .io_out_rdAddr(ex_io_out_rdAddr),
    .io_out_rs1Data(ex_io_out_rs1Data),
    .io_out_rs2Data(ex_io_out_rs2Data),
    .io_out_imm(ex_io_out_imm),
    .io_out_pcSrc(ex_io_out_pcSrc),
    .io_out_nextPC(ex_io_out_nextPC),
    .io_out_aluRes(ex_io_out_aluRes),
    .io_exeRdEn(ex_io_exeRdEn),
    .io_exeRdAddr(ex_io_exeRdAddr),
    .io_exeRdData(ex_io_exeRdData),
    .io_bubbleEx(ex_io_bubbleEx)
  );
  PipelineReg ExRegMem ( // @[Core.scala 17:24]
    .clock(ExRegMem_clock),
    .reset(ExRegMem_reset),
    .io_in_pc(ExRegMem_io_in_pc),
    .io_in_inst(ExRegMem_io_in_inst),
    .io_in_typeL(ExRegMem_io_in_typeL),
    .io_in_aluA(ExRegMem_io_in_aluA),
    .io_in_aluB(ExRegMem_io_in_aluB),
    .io_in_aluOp(ExRegMem_io_in_aluOp),
    .io_in_branch(ExRegMem_io_in_branch),
    .io_in_memtoReg(ExRegMem_io_in_memtoReg),
    .io_in_memWr(ExRegMem_io_in_memWr),
    .io_in_memOp(ExRegMem_io_in_memOp),
    .io_in_rdEn(ExRegMem_io_in_rdEn),
    .io_in_rdAddr(ExRegMem_io_in_rdAddr),
    .io_in_rs1Data(ExRegMem_io_in_rs1Data),
    .io_in_rs2Data(ExRegMem_io_in_rs2Data),
    .io_in_imm(ExRegMem_io_in_imm),
    .io_in_pcSrc(ExRegMem_io_in_pcSrc),
    .io_in_nextPC(ExRegMem_io_in_nextPC),
    .io_in_aluRes(ExRegMem_io_in_aluRes),
    .io_in_memData(ExRegMem_io_in_memData),
    .io_out_valid(ExRegMem_io_out_valid),
    .io_out_pc(ExRegMem_io_out_pc),
    .io_out_inst(ExRegMem_io_out_inst),
    .io_out_typeL(ExRegMem_io_out_typeL),
    .io_out_aluA(ExRegMem_io_out_aluA),
    .io_out_aluB(ExRegMem_io_out_aluB),
    .io_out_aluOp(ExRegMem_io_out_aluOp),
    .io_out_branch(ExRegMem_io_out_branch),
    .io_out_memtoReg(ExRegMem_io_out_memtoReg),
    .io_out_memWr(ExRegMem_io_out_memWr),
    .io_out_memOp(ExRegMem_io_out_memOp),
    .io_out_rdEn(ExRegMem_io_out_rdEn),
    .io_out_rdAddr(ExRegMem_io_out_rdAddr),
    .io_out_rs1Data(ExRegMem_io_out_rs1Data),
    .io_out_rs2Data(ExRegMem_io_out_rs2Data),
    .io_out_imm(ExRegMem_io_out_imm),
    .io_out_pcSrc(ExRegMem_io_out_pcSrc),
    .io_out_nextPC(ExRegMem_io_out_nextPC),
    .io_out_aluRes(ExRegMem_io_out_aluRes),
    .io_out_memData(ExRegMem_io_out_memData),
    .io_flush(ExRegMem_io_flush),
    .io_stall(ExRegMem_io_stall)
  );
  DataMem mem ( // @[Core.scala 18:19]
    .io_dmem_en(mem_io_dmem_en),
    .io_dmem_addr(mem_io_dmem_addr),
    .io_dmem_rdata(mem_io_dmem_rdata),
    .io_dmem_wdata(mem_io_dmem_wdata),
    .io_dmem_wmask(mem_io_dmem_wmask),
    .io_dmem_wen(mem_io_dmem_wen),
    .io_in_pc(mem_io_in_pc),
    .io_in_inst(mem_io_in_inst),
    .io_in_typeL(mem_io_in_typeL),
    .io_in_aluA(mem_io_in_aluA),
    .io_in_aluB(mem_io_in_aluB),
    .io_in_aluOp(mem_io_in_aluOp),
    .io_in_branch(mem_io_in_branch),
    .io_in_memtoReg(mem_io_in_memtoReg),
    .io_in_memWr(mem_io_in_memWr),
    .io_in_memOp(mem_io_in_memOp),
    .io_in_rdEn(mem_io_in_rdEn),
    .io_in_rdAddr(mem_io_in_rdAddr),
    .io_in_rs1Data(mem_io_in_rs1Data),
    .io_in_rs2Data(mem_io_in_rs2Data),
    .io_in_imm(mem_io_in_imm),
    .io_in_pcSrc(mem_io_in_pcSrc),
    .io_in_nextPC(mem_io_in_nextPC),
    .io_in_aluRes(mem_io_in_aluRes),
    .io_out_pc(mem_io_out_pc),
    .io_out_inst(mem_io_out_inst),
    .io_out_typeL(mem_io_out_typeL),
    .io_out_aluA(mem_io_out_aluA),
    .io_out_aluB(mem_io_out_aluB),
    .io_out_aluOp(mem_io_out_aluOp),
    .io_out_branch(mem_io_out_branch),
    .io_out_memtoReg(mem_io_out_memtoReg),
    .io_out_memWr(mem_io_out_memWr),
    .io_out_memOp(mem_io_out_memOp),
    .io_out_rdEn(mem_io_out_rdEn),
    .io_out_rdAddr(mem_io_out_rdAddr),
    .io_out_rs1Data(mem_io_out_rs1Data),
    .io_out_rs2Data(mem_io_out_rs2Data),
    .io_out_imm(mem_io_out_imm),
    .io_out_pcSrc(mem_io_out_pcSrc),
    .io_out_nextPC(mem_io_out_nextPC),
    .io_out_aluRes(mem_io_out_aluRes),
    .io_out_memData(mem_io_out_memData),
    .io_memRdEn(mem_io_memRdEn),
    .io_memRdAddr(mem_io_memRdAddr),
    .io_memRdData(mem_io_memRdData),
    .io_pcSrc(mem_io_pcSrc),
    .io_nextPC(mem_io_nextPC)
  );
  PipelineReg MemRegWb ( // @[Core.scala 19:24]
    .clock(MemRegWb_clock),
    .reset(MemRegWb_reset),
    .io_in_pc(MemRegWb_io_in_pc),
    .io_in_inst(MemRegWb_io_in_inst),
    .io_in_typeL(MemRegWb_io_in_typeL),
    .io_in_aluA(MemRegWb_io_in_aluA),
    .io_in_aluB(MemRegWb_io_in_aluB),
    .io_in_aluOp(MemRegWb_io_in_aluOp),
    .io_in_branch(MemRegWb_io_in_branch),
    .io_in_memtoReg(MemRegWb_io_in_memtoReg),
    .io_in_memWr(MemRegWb_io_in_memWr),
    .io_in_memOp(MemRegWb_io_in_memOp),
    .io_in_rdEn(MemRegWb_io_in_rdEn),
    .io_in_rdAddr(MemRegWb_io_in_rdAddr),
    .io_in_rs1Data(MemRegWb_io_in_rs1Data),
    .io_in_rs2Data(MemRegWb_io_in_rs2Data),
    .io_in_imm(MemRegWb_io_in_imm),
    .io_in_pcSrc(MemRegWb_io_in_pcSrc),
    .io_in_nextPC(MemRegWb_io_in_nextPC),
    .io_in_aluRes(MemRegWb_io_in_aluRes),
    .io_in_memData(MemRegWb_io_in_memData),
    .io_out_valid(MemRegWb_io_out_valid),
    .io_out_pc(MemRegWb_io_out_pc),
    .io_out_inst(MemRegWb_io_out_inst),
    .io_out_typeL(MemRegWb_io_out_typeL),
    .io_out_aluA(MemRegWb_io_out_aluA),
    .io_out_aluB(MemRegWb_io_out_aluB),
    .io_out_aluOp(MemRegWb_io_out_aluOp),
    .io_out_branch(MemRegWb_io_out_branch),
    .io_out_memtoReg(MemRegWb_io_out_memtoReg),
    .io_out_memWr(MemRegWb_io_out_memWr),
    .io_out_memOp(MemRegWb_io_out_memOp),
    .io_out_rdEn(MemRegWb_io_out_rdEn),
    .io_out_rdAddr(MemRegWb_io_out_rdAddr),
    .io_out_rs1Data(MemRegWb_io_out_rs1Data),
    .io_out_rs2Data(MemRegWb_io_out_rs2Data),
    .io_out_imm(MemRegWb_io_out_imm),
    .io_out_pcSrc(MemRegWb_io_out_pcSrc),
    .io_out_nextPC(MemRegWb_io_out_nextPC),
    .io_out_aluRes(MemRegWb_io_out_aluRes),
    .io_out_memData(MemRegWb_io_out_memData),
    .io_flush(MemRegWb_io_flush),
    .io_stall(MemRegWb_io_stall)
  );
  WriteBack wb ( // @[Core.scala 20:18]
    .io_in_valid(wb_io_in_valid),
    .io_in_pc(wb_io_in_pc),
    .io_in_inst(wb_io_in_inst),
    .io_in_memtoReg(wb_io_in_memtoReg),
    .io_in_rdEn(wb_io_in_rdEn),
    .io_in_rdAddr(wb_io_in_rdAddr),
    .io_in_aluRes(wb_io_in_aluRes),
    .io_in_memData(wb_io_in_memData),
    .io_pc(wb_io_pc),
    .io_inst(wb_io_inst),
    .io_rdEn(wb_io_rdEn),
    .io_rdAddr(wb_io_rdAddr),
    .io_rdData(wb_io_rdData),
    .io_wbRdEn(wb_io_wbRdEn),
    .io_wbRdAddr(wb_io_wbRdAddr),
    .io_wbRdData(wb_io_wbRdData),
    .io_ready_cmt(wb_io_ready_cmt)
  );
  DifftestInstrCommit dt_ic ( // @[Core.scala 81:21]
    .clock(dt_ic_clock),
    .coreid(dt_ic_coreid),
    .index(dt_ic_index),
    .valid(dt_ic_valid),
    .pc(dt_ic_pc),
    .instr(dt_ic_instr),
    .skip(dt_ic_skip),
    .isRVC(dt_ic_isRVC),
    .scFailed(dt_ic_scFailed),
    .wen(dt_ic_wen),
    .wdata(dt_ic_wdata),
    .wdest(dt_ic_wdest)
  );
  DifftestArchEvent dt_ae ( // @[Core.scala 95:21]
    .clock(dt_ae_clock),
    .coreid(dt_ae_coreid),
    .intrNO(dt_ae_intrNO),
    .cause(dt_ae_cause),
    .exceptionPC(dt_ae_exceptionPC),
    .exceptionInst(dt_ae_exceptionInst)
  );
  DifftestTrapEvent dt_te ( // @[Core.scala 111:21]
    .clock(dt_te_clock),
    .coreid(dt_te_coreid),
    .valid(dt_te_valid),
    .code(dt_te_code),
    .pc(dt_te_pc),
    .cycleCnt(dt_te_cycleCnt),
    .instrCnt(dt_te_instrCnt)
  );
  DifftestCSRState dt_cs ( // @[Core.scala 120:21]
    .clock(dt_cs_clock),
    .coreid(dt_cs_coreid),
    .priviledgeMode(dt_cs_priviledgeMode),
    .mstatus(dt_cs_mstatus),
    .sstatus(dt_cs_sstatus),
    .mepc(dt_cs_mepc),
    .sepc(dt_cs_sepc),
    .mtval(dt_cs_mtval),
    .stval(dt_cs_stval),
    .mtvec(dt_cs_mtvec),
    .stvec(dt_cs_stvec),
    .mcause(dt_cs_mcause),
    .scause(dt_cs_scause),
    .satp(dt_cs_satp),
    .mip(dt_cs_mip),
    .mie(dt_cs_mie),
    .mscratch(dt_cs_mscratch),
    .sscratch(dt_cs_sscratch),
    .mideleg(dt_cs_mideleg),
    .medeleg(dt_cs_medeleg)
  );
  assign io_imem_addr = fetch_io_imem_addr; // @[Core.scala 34:17]
  assign io_dmem_en = mem_io_dmem_en; // @[Core.scala 69:15]
  assign io_dmem_addr = mem_io_dmem_addr; // @[Core.scala 69:15]
  assign io_dmem_wdata = mem_io_dmem_wdata; // @[Core.scala 69:15]
  assign io_dmem_wmask = mem_io_dmem_wmask; // @[Core.scala 69:15]
  assign io_dmem_wen = mem_io_dmem_wen; // @[Core.scala 69:15]
  assign fetch_clock = clock;
  assign fetch_reset = reset;
  assign fetch_io_imem_rdata = io_imem_rdata; // @[Core.scala 34:17]
  assign fetch_io_pcSrc = mem_io_pcSrc; // @[Core.scala 35:18]
  assign fetch_io_nextPC = mem_io_nextPC; // @[Core.scala 36:19]
  assign fetch_io_stall = decode_io_bubbleId & ex_io_bubbleEx; // @[Core.scala 22:36]
  assign IfRegId_clock = clock;
  assign IfRegId_reset = reset;
  assign IfRegId_io_in_pc = fetch_io_out_pc; // @[Core.scala 39:17]
  assign IfRegId_io_in_inst = fetch_io_out_inst; // @[Core.scala 39:17]
  assign IfRegId_io_in_typeL = 1'h0; // @[Core.scala 39:17]
  assign IfRegId_io_in_aluA = 1'h0; // @[Core.scala 39:17]
  assign IfRegId_io_in_aluB = 2'h0; // @[Core.scala 39:17]
  assign IfRegId_io_in_aluOp = 4'h0; // @[Core.scala 39:17]
  assign IfRegId_io_in_branch = 3'h0; // @[Core.scala 39:17]
  assign IfRegId_io_in_memtoReg = 2'h0; // @[Core.scala 39:17]
  assign IfRegId_io_in_memWr = 1'h0; // @[Core.scala 39:17]
  assign IfRegId_io_in_memOp = 3'h0; // @[Core.scala 39:17]
  assign IfRegId_io_in_rdEn = 1'h0; // @[Core.scala 39:17]
  assign IfRegId_io_in_rdAddr = 5'h0; // @[Core.scala 39:17]
  assign IfRegId_io_in_rs1Data = 64'h0; // @[Core.scala 39:17]
  assign IfRegId_io_in_rs2Data = 64'h0; // @[Core.scala 39:17]
  assign IfRegId_io_in_imm = 64'h0; // @[Core.scala 39:17]
  assign IfRegId_io_in_pcSrc = 2'h0; // @[Core.scala 39:17]
  assign IfRegId_io_in_nextPC = 32'h0; // @[Core.scala 39:17]
  assign IfRegId_io_in_aluRes = 64'h0; // @[Core.scala 39:17]
  assign IfRegId_io_in_memData = 64'h0; // @[Core.scala 39:17]
  assign IfRegId_io_flush = 1'h0; // @[Core.scala 41:20]
  assign IfRegId_io_stall = decode_io_bubbleId & ex_io_bubbleEx; // @[Core.scala 22:36]
  assign decode_clock = clock;
  assign decode_reset = reset;
  assign decode_io_rdEn = wb_io_rdEn; // @[Core.scala 44:18]
  assign decode_io_rdAddr = wb_io_rdAddr; // @[Core.scala 45:20]
  assign decode_io_rdData = wb_io_rdData; // @[Core.scala 46:20]
  assign decode_io_in_pc = IfRegId_io_out_pc; // @[Core.scala 43:16]
  assign decode_io_in_inst = IfRegId_io_out_inst; // @[Core.scala 43:16]
  assign decode_io_exeRdEn = ex_io_exeRdEn; // @[Core.scala 48:21]
  assign decode_io_exeRdAddr = ex_io_exeRdAddr[4:0]; // @[Core.scala 49:23]
  assign decode_io_exeRdData = ex_io_exeRdData; // @[Core.scala 50:23]
  assign decode_io_memRdEn = mem_io_memRdEn; // @[Core.scala 51:21]
  assign decode_io_memRdAddr = mem_io_memRdAddr; // @[Core.scala 52:23]
  assign decode_io_memRdData = mem_io_memRdData; // @[Core.scala 53:23]
  assign decode_io_wbRdEn = wb_io_wbRdEn; // @[Core.scala 54:20]
  assign decode_io_wbRdAddr = wb_io_wbRdAddr; // @[Core.scala 55:22]
  assign decode_io_wbRdData = wb_io_wbRdData; // @[Core.scala 56:22]
  assign IdRegEx_clock = clock;
  assign IdRegEx_reset = reset;
  assign IdRegEx_io_in_pc = decode_io_out_pc; // @[Core.scala 58:17]
  assign IdRegEx_io_in_inst = decode_io_out_inst; // @[Core.scala 58:17]
  assign IdRegEx_io_in_typeL = decode_io_out_typeL; // @[Core.scala 58:17]
  assign IdRegEx_io_in_aluA = decode_io_out_aluA; // @[Core.scala 58:17]
  assign IdRegEx_io_in_aluB = decode_io_out_aluB; // @[Core.scala 58:17]
  assign IdRegEx_io_in_aluOp = decode_io_out_aluOp; // @[Core.scala 58:17]
  assign IdRegEx_io_in_branch = decode_io_out_branch; // @[Core.scala 58:17]
  assign IdRegEx_io_in_memtoReg = decode_io_out_memtoReg; // @[Core.scala 58:17]
  assign IdRegEx_io_in_memWr = decode_io_out_memWr; // @[Core.scala 58:17]
  assign IdRegEx_io_in_memOp = decode_io_out_memOp; // @[Core.scala 58:17]
  assign IdRegEx_io_in_rdEn = decode_io_out_rdEn; // @[Core.scala 58:17]
  assign IdRegEx_io_in_rdAddr = decode_io_out_rdAddr; // @[Core.scala 58:17]
  assign IdRegEx_io_in_rs1Data = decode_io_out_rs1Data; // @[Core.scala 58:17]
  assign IdRegEx_io_in_rs2Data = decode_io_out_rs2Data; // @[Core.scala 58:17]
  assign IdRegEx_io_in_imm = decode_io_out_imm; // @[Core.scala 58:17]
  assign IdRegEx_io_in_pcSrc = 2'h0; // @[Core.scala 58:17]
  assign IdRegEx_io_in_nextPC = 32'h0; // @[Core.scala 58:17]
  assign IdRegEx_io_in_aluRes = 64'h0; // @[Core.scala 58:17]
  assign IdRegEx_io_in_memData = 64'h0; // @[Core.scala 58:17]
  assign IdRegEx_io_flush = mem_io_pcSrc != 2'h0; // @[Core.scala 25:38]
  assign IdRegEx_io_stall = decode_io_bubbleId & ex_io_bubbleEx; // @[Core.scala 22:36]
  assign ex_io_in_pc = IdRegEx_io_out_pc; // @[Core.scala 62:12]
  assign ex_io_in_inst = IdRegEx_io_out_inst; // @[Core.scala 62:12]
  assign ex_io_in_typeL = IdRegEx_io_out_typeL; // @[Core.scala 62:12]
  assign ex_io_in_aluA = IdRegEx_io_out_aluA; // @[Core.scala 62:12]
  assign ex_io_in_aluB = IdRegEx_io_out_aluB; // @[Core.scala 62:12]
  assign ex_io_in_aluOp = IdRegEx_io_out_aluOp; // @[Core.scala 62:12]
  assign ex_io_in_branch = IdRegEx_io_out_branch; // @[Core.scala 62:12]
  assign ex_io_in_memtoReg = IdRegEx_io_out_memtoReg; // @[Core.scala 62:12]
  assign ex_io_in_memWr = IdRegEx_io_out_memWr; // @[Core.scala 62:12]
  assign ex_io_in_memOp = IdRegEx_io_out_memOp; // @[Core.scala 62:12]
  assign ex_io_in_rdEn = IdRegEx_io_out_rdEn; // @[Core.scala 62:12]
  assign ex_io_in_rdAddr = IdRegEx_io_out_rdAddr; // @[Core.scala 62:12]
  assign ex_io_in_rs1Data = IdRegEx_io_out_rs1Data; // @[Core.scala 62:12]
  assign ex_io_in_rs2Data = IdRegEx_io_out_rs2Data; // @[Core.scala 62:12]
  assign ex_io_in_imm = IdRegEx_io_out_imm; // @[Core.scala 62:12]
  assign ExRegMem_clock = clock;
  assign ExRegMem_reset = reset;
  assign ExRegMem_io_in_pc = ex_io_out_pc; // @[Core.scala 64:18]
  assign ExRegMem_io_in_inst = ex_io_out_inst; // @[Core.scala 64:18]
  assign ExRegMem_io_in_typeL = ex_io_out_typeL; // @[Core.scala 64:18]
  assign ExRegMem_io_in_aluA = ex_io_out_aluA; // @[Core.scala 64:18]
  assign ExRegMem_io_in_aluB = ex_io_out_aluB; // @[Core.scala 64:18]
  assign ExRegMem_io_in_aluOp = ex_io_out_aluOp; // @[Core.scala 64:18]
  assign ExRegMem_io_in_branch = ex_io_out_branch; // @[Core.scala 64:18]
  assign ExRegMem_io_in_memtoReg = ex_io_out_memtoReg; // @[Core.scala 64:18]
  assign ExRegMem_io_in_memWr = ex_io_out_memWr; // @[Core.scala 64:18]
  assign ExRegMem_io_in_memOp = ex_io_out_memOp; // @[Core.scala 64:18]
  assign ExRegMem_io_in_rdEn = ex_io_out_rdEn; // @[Core.scala 64:18]
  assign ExRegMem_io_in_rdAddr = ex_io_out_rdAddr; // @[Core.scala 64:18]
  assign ExRegMem_io_in_rs1Data = ex_io_out_rs1Data; // @[Core.scala 64:18]
  assign ExRegMem_io_in_rs2Data = ex_io_out_rs2Data; // @[Core.scala 64:18]
  assign ExRegMem_io_in_imm = ex_io_out_imm; // @[Core.scala 64:18]
  assign ExRegMem_io_in_pcSrc = ex_io_out_pcSrc; // @[Core.scala 64:18]
  assign ExRegMem_io_in_nextPC = ex_io_out_nextPC; // @[Core.scala 64:18]
  assign ExRegMem_io_in_aluRes = ex_io_out_aluRes; // @[Core.scala 64:18]
  assign ExRegMem_io_in_memData = 64'h0; // @[Core.scala 64:18]
  assign ExRegMem_io_flush = mem_io_pcSrc != 2'h0; // @[Core.scala 26:39]
  assign ExRegMem_io_stall = 1'h0; // @[Core.scala 65:21]
  assign mem_io_dmem_rdata = io_dmem_rdata; // @[Core.scala 69:15]
  assign mem_io_in_pc = ExRegMem_io_out_pc; // @[Core.scala 68:13]
  assign mem_io_in_inst = ExRegMem_io_out_inst; // @[Core.scala 68:13]
  assign mem_io_in_typeL = ExRegMem_io_out_typeL; // @[Core.scala 68:13]
  assign mem_io_in_aluA = ExRegMem_io_out_aluA; // @[Core.scala 68:13]
  assign mem_io_in_aluB = ExRegMem_io_out_aluB; // @[Core.scala 68:13]
  assign mem_io_in_aluOp = ExRegMem_io_out_aluOp; // @[Core.scala 68:13]
  assign mem_io_in_branch = ExRegMem_io_out_branch; // @[Core.scala 68:13]
  assign mem_io_in_memtoReg = ExRegMem_io_out_memtoReg; // @[Core.scala 68:13]
  assign mem_io_in_memWr = ExRegMem_io_out_memWr; // @[Core.scala 68:13]
  assign mem_io_in_memOp = ExRegMem_io_out_memOp; // @[Core.scala 68:13]
  assign mem_io_in_rdEn = ExRegMem_io_out_rdEn; // @[Core.scala 68:13]
  assign mem_io_in_rdAddr = ExRegMem_io_out_rdAddr; // @[Core.scala 68:13]
  assign mem_io_in_rs1Data = ExRegMem_io_out_rs1Data; // @[Core.scala 68:13]
  assign mem_io_in_rs2Data = ExRegMem_io_out_rs2Data; // @[Core.scala 68:13]
  assign mem_io_in_imm = ExRegMem_io_out_imm; // @[Core.scala 68:13]
  assign mem_io_in_pcSrc = ExRegMem_io_out_pcSrc; // @[Core.scala 68:13]
  assign mem_io_in_nextPC = ExRegMem_io_out_nextPC; // @[Core.scala 68:13]
  assign mem_io_in_aluRes = ExRegMem_io_out_aluRes; // @[Core.scala 68:13]
  assign MemRegWb_clock = clock;
  assign MemRegWb_reset = reset;
  assign MemRegWb_io_in_pc = mem_io_out_pc; // @[Core.scala 71:18]
  assign MemRegWb_io_in_inst = mem_io_out_inst; // @[Core.scala 71:18]
  assign MemRegWb_io_in_typeL = mem_io_out_typeL; // @[Core.scala 71:18]
  assign MemRegWb_io_in_aluA = mem_io_out_aluA; // @[Core.scala 71:18]
  assign MemRegWb_io_in_aluB = mem_io_out_aluB; // @[Core.scala 71:18]
  assign MemRegWb_io_in_aluOp = mem_io_out_aluOp; // @[Core.scala 71:18]
  assign MemRegWb_io_in_branch = mem_io_out_branch; // @[Core.scala 71:18]
  assign MemRegWb_io_in_memtoReg = mem_io_out_memtoReg; // @[Core.scala 71:18]
  assign MemRegWb_io_in_memWr = mem_io_out_memWr; // @[Core.scala 71:18]
  assign MemRegWb_io_in_memOp = mem_io_out_memOp; // @[Core.scala 71:18]
  assign MemRegWb_io_in_rdEn = mem_io_out_rdEn; // @[Core.scala 71:18]
  assign MemRegWb_io_in_rdAddr = mem_io_out_rdAddr; // @[Core.scala 71:18]
  assign MemRegWb_io_in_rs1Data = mem_io_out_rs1Data; // @[Core.scala 71:18]
  assign MemRegWb_io_in_rs2Data = mem_io_out_rs2Data; // @[Core.scala 71:18]
  assign MemRegWb_io_in_imm = mem_io_out_imm; // @[Core.scala 71:18]
  assign MemRegWb_io_in_pcSrc = mem_io_out_pcSrc; // @[Core.scala 71:18]
  assign MemRegWb_io_in_nextPC = mem_io_out_nextPC; // @[Core.scala 71:18]
  assign MemRegWb_io_in_aluRes = mem_io_out_aluRes; // @[Core.scala 71:18]
  assign MemRegWb_io_in_memData = mem_io_out_memData; // @[Core.scala 71:18]
  assign MemRegWb_io_flush = 1'h0; // @[Core.scala 73:21]
  assign MemRegWb_io_stall = 1'h0; // @[Core.scala 72:21]
  assign wb_io_in_valid = MemRegWb_io_out_valid; // @[Core.scala 75:12]
  assign wb_io_in_pc = MemRegWb_io_out_pc; // @[Core.scala 75:12]
  assign wb_io_in_inst = MemRegWb_io_out_inst; // @[Core.scala 75:12]
  assign wb_io_in_memtoReg = MemRegWb_io_out_memtoReg; // @[Core.scala 75:12]
  assign wb_io_in_rdEn = MemRegWb_io_out_rdEn; // @[Core.scala 75:12]
  assign wb_io_in_rdAddr = MemRegWb_io_out_rdAddr; // @[Core.scala 75:12]
  assign wb_io_in_aluRes = MemRegWb_io_out_aluRes; // @[Core.scala 75:12]
  assign wb_io_in_memData = MemRegWb_io_out_memData; // @[Core.scala 75:12]
  assign dt_ic_clock = clock; // @[Core.scala 82:21]
  assign dt_ic_coreid = 8'h0; // @[Core.scala 83:21]
  assign dt_ic_index = 8'h0; // @[Core.scala 84:21]
  assign dt_ic_valid = dt_ic_io_valid_REG; // @[Core.scala 85:21]
  assign dt_ic_pc = {{32'd0}, dt_ic_io_pc_REG}; // @[Core.scala 86:21]
  assign dt_ic_instr = dt_ic_io_instr_REG; // @[Core.scala 87:21]
  assign dt_ic_skip = 1'h0; // @[Core.scala 88:21]
  assign dt_ic_isRVC = 1'h0; // @[Core.scala 89:21]
  assign dt_ic_scFailed = 1'h0; // @[Core.scala 90:21]
  assign dt_ic_wen = dt_ic_io_wen_REG; // @[Core.scala 91:21]
  assign dt_ic_wdata = dt_ic_io_wdata_REG; // @[Core.scala 92:21]
  assign dt_ic_wdest = {{3'd0}, dt_ic_io_wdest_REG}; // @[Core.scala 93:21]
  assign dt_ae_clock = clock; // @[Core.scala 96:25]
  assign dt_ae_coreid = 8'h0; // @[Core.scala 97:25]
  assign dt_ae_intrNO = 32'h0; // @[Core.scala 98:25]
  assign dt_ae_cause = 32'h0; // @[Core.scala 99:25]
  assign dt_ae_exceptionPC = 64'h0; // @[Core.scala 100:25]
  assign dt_ae_exceptionInst = 32'h0;
  assign dt_te_clock = clock; // @[Core.scala 112:21]
  assign dt_te_coreid = 8'h0; // @[Core.scala 113:21]
  assign dt_te_valid = wb_io_inst == 32'h6b; // @[Core.scala 114:36]
  assign dt_te_code = rf_a0_0[2:0]; // @[Core.scala 115:29]
  assign dt_te_pc = {{32'd0}, wb_io_pc}; // @[Core.scala 116:21]
  assign dt_te_cycleCnt = cycle_cnt; // @[Core.scala 117:21]
  assign dt_te_instrCnt = instr_cnt; // @[Core.scala 118:21]
  assign dt_cs_clock = clock; // @[Core.scala 121:27]
  assign dt_cs_coreid = 8'h0; // @[Core.scala 122:27]
  assign dt_cs_priviledgeMode = 2'h3; // @[Core.scala 123:27]
  assign dt_cs_mstatus = 64'h0; // @[Core.scala 124:27]
  assign dt_cs_sstatus = 64'h0; // @[Core.scala 125:27]
  assign dt_cs_mepc = 64'h0; // @[Core.scala 126:27]
  assign dt_cs_sepc = 64'h0; // @[Core.scala 127:27]
  assign dt_cs_mtval = 64'h0; // @[Core.scala 128:27]
  assign dt_cs_stval = 64'h0; // @[Core.scala 129:27]
  assign dt_cs_mtvec = 64'h0; // @[Core.scala 130:27]
  assign dt_cs_stvec = 64'h0; // @[Core.scala 131:27]
  assign dt_cs_mcause = 64'h0; // @[Core.scala 132:27]
  assign dt_cs_scause = 64'h0; // @[Core.scala 133:27]
  assign dt_cs_satp = 64'h0; // @[Core.scala 134:27]
  assign dt_cs_mip = 64'h0; // @[Core.scala 135:27]
  assign dt_cs_mie = 64'h0; // @[Core.scala 136:27]
  assign dt_cs_mscratch = 64'h0; // @[Core.scala 137:27]
  assign dt_cs_sscratch = 64'h0; // @[Core.scala 138:27]
  assign dt_cs_mideleg = 64'h0; // @[Core.scala 139:27]
  assign dt_cs_medeleg = 64'h0; // @[Core.scala 140:27]
  always @(posedge clock) begin
    dt_ic_io_valid_REG <= wb_io_ready_cmt & ~stallEn; // @[Core.scala 79:31]
    dt_ic_io_pc_REG <= wb_io_pc; // @[Core.scala 86:31]
    dt_ic_io_instr_REG <= wb_io_inst; // @[Core.scala 87:31]
    dt_ic_io_wen_REG <= wb_io_rdEn; // @[Core.scala 91:31]
    dt_ic_io_wdata_REG <= wb_io_rdData; // @[Core.scala 92:31]
    dt_ic_io_wdest_REG <= wb_io_rdAddr; // @[Core.scala 93:31]
    if (reset) begin // @[Core.scala 102:26]
      cycle_cnt <= 64'h0; // @[Core.scala 102:26]
    end else begin
      cycle_cnt <= _cycle_cnt_T_1; // @[Core.scala 105:13]
    end
    if (reset) begin // @[Core.scala 103:26]
      instr_cnt <= 64'h0; // @[Core.scala 103:26]
    end else begin
      instr_cnt <= _instr_cnt_T_1; // @[Core.scala 106:13]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  dt_ic_io_valid_REG = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  dt_ic_io_pc_REG = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  dt_ic_io_instr_REG = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  dt_ic_io_wen_REG = _RAND_3[0:0];
  _RAND_4 = {2{`RANDOM}};
  dt_ic_io_wdata_REG = _RAND_4[63:0];
  _RAND_5 = {1{`RANDOM}};
  dt_ic_io_wdest_REG = _RAND_5[4:0];
  _RAND_6 = {2{`RANDOM}};
  cycle_cnt = _RAND_6[63:0];
  _RAND_7 = {2{`RANDOM}};
  instr_cnt = _RAND_7[63:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Ram2r1w(
  input         clock,
  input  [63:0] io_imem_addr,
  output [63:0] io_imem_rdata,
  input         io_dmem_en,
  input  [63:0] io_dmem_addr,
  output [63:0] io_dmem_rdata,
  input  [63:0] io_dmem_wdata,
  input  [63:0] io_dmem_wmask,
  input         io_dmem_wen
);
  wire  mem_clk; // @[Ram.scala 32:19]
  wire  mem_imem_en; // @[Ram.scala 32:19]
  wire [63:0] mem_imem_addr; // @[Ram.scala 32:19]
  wire [31:0] mem_imem_data; // @[Ram.scala 32:19]
  wire  mem_dmem_en; // @[Ram.scala 32:19]
  wire [63:0] mem_dmem_addr; // @[Ram.scala 32:19]
  wire [63:0] mem_dmem_rdata; // @[Ram.scala 32:19]
  wire [63:0] mem_dmem_wdata; // @[Ram.scala 32:19]
  wire [63:0] mem_dmem_wmask; // @[Ram.scala 32:19]
  wire  mem_dmem_wen; // @[Ram.scala 32:19]
  ram_2r1w mem ( // @[Ram.scala 32:19]
    .clk(mem_clk),
    .imem_en(mem_imem_en),
    .imem_addr(mem_imem_addr),
    .imem_data(mem_imem_data),
    .dmem_en(mem_dmem_en),
    .dmem_addr(mem_dmem_addr),
    .dmem_rdata(mem_dmem_rdata),
    .dmem_wdata(mem_dmem_wdata),
    .dmem_wmask(mem_dmem_wmask),
    .dmem_wen(mem_dmem_wen)
  );
  assign io_imem_rdata = {{32'd0}, mem_imem_data}; // @[Ram.scala 37:21]
  assign io_dmem_rdata = mem_dmem_rdata; // @[Ram.scala 41:21]
  assign mem_clk = clock; // @[Ram.scala 33:21]
  assign mem_imem_en = 1'h1; // @[Ram.scala 35:21]
  assign mem_imem_addr = io_imem_addr; // @[Ram.scala 36:21]
  assign mem_dmem_en = io_dmem_en; // @[Ram.scala 39:21]
  assign mem_dmem_addr = io_dmem_addr; // @[Ram.scala 40:21]
  assign mem_dmem_wdata = io_dmem_wdata; // @[Ram.scala 42:21]
  assign mem_dmem_wmask = io_dmem_wmask; // @[Ram.scala 43:21]
  assign mem_dmem_wen = io_dmem_wen; // @[Ram.scala 44:21]
endmodule
module SimTop(
  input         clock,
  input         reset,
  input  [63:0] io_logCtrl_log_begin,
  input  [63:0] io_logCtrl_log_end,
  input  [63:0] io_logCtrl_log_level,
  input         io_perfInfo_clean,
  input         io_perfInfo_dump,
  output        io_uart_out_valid,
  output [7:0]  io_uart_out_ch,
  output        io_uart_in_valid,
  input  [7:0]  io_uart_in_ch
);
  wire  core_clock; // @[SimTop.scala 17:20]
  wire  core_reset; // @[SimTop.scala 17:20]
  wire [63:0] core_io_imem_addr; // @[SimTop.scala 17:20]
  wire [63:0] core_io_imem_rdata; // @[SimTop.scala 17:20]
  wire  core_io_dmem_en; // @[SimTop.scala 17:20]
  wire [63:0] core_io_dmem_addr; // @[SimTop.scala 17:20]
  wire [63:0] core_io_dmem_rdata; // @[SimTop.scala 17:20]
  wire [63:0] core_io_dmem_wdata; // @[SimTop.scala 17:20]
  wire [63:0] core_io_dmem_wmask; // @[SimTop.scala 17:20]
  wire  core_io_dmem_wen; // @[SimTop.scala 17:20]
  wire  mem_clock; // @[SimTop.scala 19:19]
  wire [63:0] mem_io_imem_addr; // @[SimTop.scala 19:19]
  wire [63:0] mem_io_imem_rdata; // @[SimTop.scala 19:19]
  wire  mem_io_dmem_en; // @[SimTop.scala 19:19]
  wire [63:0] mem_io_dmem_addr; // @[SimTop.scala 19:19]
  wire [63:0] mem_io_dmem_rdata; // @[SimTop.scala 19:19]
  wire [63:0] mem_io_dmem_wdata; // @[SimTop.scala 19:19]
  wire [63:0] mem_io_dmem_wmask; // @[SimTop.scala 19:19]
  wire  mem_io_dmem_wen; // @[SimTop.scala 19:19]
  Core core ( // @[SimTop.scala 17:20]
    .clock(core_clock),
    .reset(core_reset),
    .io_imem_addr(core_io_imem_addr),
    .io_imem_rdata(core_io_imem_rdata),
    .io_dmem_en(core_io_dmem_en),
    .io_dmem_addr(core_io_dmem_addr),
    .io_dmem_rdata(core_io_dmem_rdata),
    .io_dmem_wdata(core_io_dmem_wdata),
    .io_dmem_wmask(core_io_dmem_wmask),
    .io_dmem_wen(core_io_dmem_wen)
  );
  Ram2r1w mem ( // @[SimTop.scala 19:19]
    .clock(mem_clock),
    .io_imem_addr(mem_io_imem_addr),
    .io_imem_rdata(mem_io_imem_rdata),
    .io_dmem_en(mem_io_dmem_en),
    .io_dmem_addr(mem_io_dmem_addr),
    .io_dmem_rdata(mem_io_dmem_rdata),
    .io_dmem_wdata(mem_io_dmem_wdata),
    .io_dmem_wmask(mem_io_dmem_wmask),
    .io_dmem_wen(mem_io_dmem_wen)
  );
  assign io_uart_out_valid = 1'h0; // @[SimTop.scala 24:21]
  assign io_uart_out_ch = 8'h0; // @[SimTop.scala 25:18]
  assign io_uart_in_valid = 1'h0; // @[SimTop.scala 26:20]
  assign core_clock = clock;
  assign core_reset = reset;
  assign core_io_imem_rdata = mem_io_imem_rdata; // @[SimTop.scala 21:15]
  assign core_io_dmem_rdata = mem_io_dmem_rdata; // @[SimTop.scala 22:15]
  assign mem_clock = clock;
  assign mem_io_imem_addr = core_io_imem_addr; // @[SimTop.scala 21:15]
  assign mem_io_dmem_en = core_io_dmem_en; // @[SimTop.scala 22:15]
  assign mem_io_dmem_addr = core_io_dmem_addr; // @[SimTop.scala 22:15]
  assign mem_io_dmem_wdata = core_io_dmem_wdata; // @[SimTop.scala 22:15]
  assign mem_io_dmem_wmask = core_io_dmem_wmask; // @[SimTop.scala 22:15]
  assign mem_io_dmem_wen = core_io_dmem_wen; // @[SimTop.scala 22:15]
endmodule
