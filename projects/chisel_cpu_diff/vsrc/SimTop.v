module InstFetch(
  input         clock,
  input         reset,
  output [63:0] io_imem_addr,
  input  [63:0] io_imem_rdata,
  output [31:0] io_pc,
  output [31:0] io_inst
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
`endif // RANDOMIZE_REG_INIT
  reg  pc_en; // @[InstFetch.scala 11:22]
  reg [31:0] pc; // @[InstFetch.scala 14:19]
  wire [31:0] _pc_T_1 = pc + 32'h4; // @[InstFetch.scala 15:12]
  assign io_imem_addr = {{32'd0}, pc}; // @[InstFetch.scala 18:16]
  assign io_pc = pc_en ? pc : 32'h0; // @[InstFetch.scala 20:15]
  assign io_inst = pc_en ? io_imem_rdata[31:0] : 32'h0; // @[InstFetch.scala 21:17]
  always @(posedge clock) begin
    if (reset) begin // @[InstFetch.scala 11:22]
      pc_en <= 1'h0; // @[InstFetch.scala 11:22]
    end else begin
      pc_en <= 1'h1; // @[InstFetch.scala 12:9]
    end
    if (reset) begin // @[InstFetch.scala 14:19]
      pc <= 32'h80000000; // @[InstFetch.scala 14:19]
    end else begin
      pc <= _pc_T_1; // @[InstFetch.scala 15:6]
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
  pc_en = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  pc = _RAND_1[31:0];
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
  wire [63:0] immType_0 = {_immType_0_T_2,io_inst[31:20]}; // @[ImmGen.scala 18:41]
  wire [31:0] _immType_1_T_2 = io_inst[31] ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [63:0] immType_1 = {_immType_1_T_2,io_inst[31:12],12'h0}; // @[ImmGen.scala 19:59]
  wire [63:0] immType_2 = {_immType_0_T_2,io_inst[31:25],io_inst[11:7]}; // @[ImmGen.scala 20:59]
  wire [64:0] _immType_3_T_11 = {_immType_0_T_2,io_inst[31],io_inst[7],io_inst[30:25],io_inst[11:8],1'h0}; // @[ImmGen.scala 21:113]
  wire [42:0] _immType_4_T_2 = io_inst[31] ? 43'h7ffffffffff : 43'h0; // @[Bitwise.scala 74:12]
  wire [63:0] immType_4 = {_immType_4_T_2,io_inst[31],io_inst[19:12],io_inst[20],io_inst[30:21],1'h0}; // @[ImmGen.scala 22:113]
  wire [63:0] _GEN_1 = 3'h1 == io_immOp ? immType_1 : immType_0; // @[ImmGen.scala 24:{10,10}]
  wire [63:0] _GEN_2 = 3'h2 == io_immOp ? immType_2 : _GEN_1; // @[ImmGen.scala 24:{10,10}]
  wire [63:0] immType_3 = _immType_3_T_11[63:0]; // @[ImmGen.scala 16:21 21:16]
  wire [63:0] _GEN_3 = 3'h3 == io_immOp ? immType_3 : _GEN_2; // @[ImmGen.scala 24:{10,10}]
  assign io_imm = 3'h4 == io_immOp ? immType_4 : _GEN_3; // @[ImmGen.scala 24:{10,10}]
endmodule
module ContrGen(
  input  [31:0] io_inst,
  output [2:0]  io_immOp,
  output [3:0]  io_aluCtr_aluOp
);
  wire [31:0] _instLui_T = io_inst & 32'h7f; // @[ContrGen.scala 23:26]
  wire  instLui = 32'h37 == _instLui_T; // @[ContrGen.scala 23:26]
  wire  instAuipc = 32'h17 == _instLui_T; // @[ContrGen.scala 24:26]
  wire [31:0] _instAddi_T = io_inst & 32'h707f; // @[ContrGen.scala 27:26]
  wire  instAddi = 32'h13 == _instAddi_T; // @[ContrGen.scala 27:26]
  wire  instAndi = 32'h7013 == _instAddi_T; // @[ContrGen.scala 28:26]
  wire  instXori = 32'h4013 == _instAddi_T; // @[ContrGen.scala 29:26]
  wire  instOri = 32'h6013 == _instAddi_T; // @[ContrGen.scala 30:26]
  wire [31:0] _instSlli_T = io_inst & 32'hfc00707f; // @[ContrGen.scala 31:26]
  wire  instSlli = 32'h1013 == _instSlli_T; // @[ContrGen.scala 31:26]
  wire  instSrli = 32'h5013 == _instSlli_T; // @[ContrGen.scala 32:26]
  wire  instSrai = 32'h40005013 == _instSlli_T; // @[ContrGen.scala 33:26]
  wire  instSlti = 32'h2013 == _instAddi_T; // @[ContrGen.scala 34:26]
  wire  instSltiu = 32'h3013 == _instAddi_T; // @[ContrGen.scala 35:26]
  wire  instAddiw = 32'h1b == _instAddi_T; // @[ContrGen.scala 36:26]
  wire [31:0] _instSlliw_T = io_inst & 32'hfe00707f; // @[ContrGen.scala 37:26]
  wire  instSlliw = 32'h101b == _instSlliw_T; // @[ContrGen.scala 37:26]
  wire  instSrliw = 32'h501b == _instSlliw_T; // @[ContrGen.scala 38:26]
  wire  instSraiw = 32'h4000501b == _instSlliw_T; // @[ContrGen.scala 39:26]
  wire  instJalr = 32'h67 == _instAddi_T; // @[ContrGen.scala 40:26]
  wire  instLb = 32'h3 == _instAddi_T; // @[ContrGen.scala 41:26]
  wire  instLh = 32'h1003 == _instAddi_T; // @[ContrGen.scala 42:26]
  wire  instLw = 32'h2003 == _instAddi_T; // @[ContrGen.scala 43:26]
  wire  instLd = 32'h3003 == _instAddi_T; // @[ContrGen.scala 44:26]
  wire  instLbu = 32'h4003 == _instAddi_T; // @[ContrGen.scala 45:26]
  wire  instLhu = 32'h5003 == _instAddi_T; // @[ContrGen.scala 46:26]
  wire  instJal = 32'h6f == _instLui_T; // @[ContrGen.scala 53:26]
  wire  instSub = 32'h40000033 == _instSlliw_T; // @[ContrGen.scala 57:26]
  wire  instSll = 32'h1033 == _instSlliw_T; // @[ContrGen.scala 58:26]
  wire  instSlt = 32'h2033 == _instSlliw_T; // @[ContrGen.scala 59:26]
  wire  instSltu = 32'h3033 == _instSlliw_T; // @[ContrGen.scala 60:26]
  wire  instXor = 32'h4033 == _instSlliw_T; // @[ContrGen.scala 61:26]
  wire  instSrl = 32'h5033 == _instSlliw_T; // @[ContrGen.scala 62:26]
  wire  instSra = 32'h40005033 == _instSlliw_T; // @[ContrGen.scala 63:26]
  wire  instOr = 32'h6033 == _instSlliw_T; // @[ContrGen.scala 64:26]
  wire  instAnd = 32'h7033 == _instSlliw_T; // @[ContrGen.scala 65:26]
  wire  instSubw = 32'h4000003b == _instSlliw_T; // @[ContrGen.scala 67:26]
  wire  instSllw = 32'h103b == _instSlliw_T; // @[ContrGen.scala 68:26]
  wire  instSrlw = 32'h503b == _instSlliw_T; // @[ContrGen.scala 69:26]
  wire  instSraw = 32'h4000503b == _instSlliw_T; // @[ContrGen.scala 70:26]
  wire  aluRem = 32'h200603b == _instSlliw_T; // @[ContrGen.scala 72:26]
  wire  instDiv = 32'h2004033 == _instSlliw_T; // @[ContrGen.scala 73:26]
  wire  instDivw = 32'h200403b == _instSlliw_T; // @[ContrGen.scala 74:26]
  wire  instMul = 32'h2000033 == _instSlliw_T; // @[ContrGen.scala 75:26]
  wire  instMulw = 32'h200003b == _instSlliw_T; // @[ContrGen.scala 76:26]
  wire  instBeq = 32'h63 == _instAddi_T; // @[ContrGen.scala 82:27]
  wire  instBne = 32'h1063 == _instAddi_T; // @[ContrGen.scala 83:27]
  wire  instBlt = 32'h4063 == _instAddi_T; // @[ContrGen.scala 84:27]
  wire  instBge = 32'h5063 == _instAddi_T; // @[ContrGen.scala 85:27]
  wire  instBltu = 32'h6063 == _instAddi_T; // @[ContrGen.scala 86:27]
  wire  instBgeu = 32'h7063 == _instAddi_T; // @[ContrGen.scala 87:27]
  wire  _typeB_T = instBeq | instBne; // @[ContrGen.scala 88:30]
  wire  typeB = instBeq | instBne | instBlt | instBge | instBltu | instBgeu; // @[ContrGen.scala 88:74]
  wire  instSb = 32'h23 == _instAddi_T; // @[ContrGen.scala 90:27]
  wire  instSh = 32'h1023 == _instAddi_T; // @[ContrGen.scala 91:27]
  wire  instSw = 32'h2023 == _instAddi_T; // @[ContrGen.scala 92:27]
  wire  instSd = 32'h3023 == _instAddi_T; // @[ContrGen.scala 93:27]
  wire  aluSub = instSub | instSubw; // @[ContrGen.scala 114:28]
  wire  aluSlt = instSlti | instSlt; // @[ContrGen.scala 115:29]
  wire  aluSltu = instSltiu | instSltu; // @[ContrGen.scala 116:29]
  wire  aluAnd = instAndi | instAnd; // @[ContrGen.scala 117:29]
  wire  aluOr = instOri | instOr; // @[ContrGen.scala 118:29]
  wire  aluXor = instXori | instXor; // @[ContrGen.scala 119:29]
  wire  aluSll = instSlli | instSlliw | instSll | instSllw; // @[ContrGen.scala 120:53]
  wire  aluSrl = instSrli | instSrliw | instSrl | instSrlw; // @[ContrGen.scala 121:53]
  wire  aluSra = instSrai | instSraiw | instSra | instSraw; // @[ContrGen.scala 122:53]
  wire  aluDiv = instDiv | instDivw; // @[ContrGen.scala 124:27]
  wire  aluMul = instMul | instMulw; // @[ContrGen.scala 125:27]
  wire  _io_aluCtr_aluOp_T_2 = aluSlt | instBlt | instBge; // @[ContrGen.scala 131:37]
  wire  _io_aluCtr_aluOp_T_6 = aluSltu | instBltu | instBgeu; // @[ContrGen.scala 133:40]
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
  wire  _io_immOp_T_8 = instAddi | instAddiw | instSlti | instSltiu | instXori | instOri | instAndi | instSlli |
    instSlliw | instSrli; // @[ContrGen.scala 193:120]
  wire  _io_immOp_T_18 = _io_immOp_T_8 | instSrliw | instSrai | instSraiw | instJalr | instLb | instLh | instLw | instLd
     | instLbu | instLhu; // @[ContrGen.scala 194:125]
  wire  _io_immOp_T_19 = instAuipc | instLui; // @[ContrGen.scala 195:22]
  wire  _io_immOp_T_22 = instSd | instSb | instSw | instSh; // @[ContrGen.scala 196:39]
  wire [2:0] _io_immOp_T_28 = instJal ? 3'h4 : 3'h7; // @[Mux.scala 101:16]
  wire [2:0] _io_immOp_T_29 = typeB ? 3'h3 : _io_immOp_T_28; // @[Mux.scala 101:16]
  wire [2:0] _io_immOp_T_30 = _io_immOp_T_22 ? 3'h2 : _io_immOp_T_29; // @[Mux.scala 101:16]
  wire [2:0] _io_immOp_T_31 = _io_immOp_T_19 ? 3'h1 : _io_immOp_T_30; // @[Mux.scala 101:16]
  assign io_immOp = _io_immOp_T_18 ? 3'h0 : _io_immOp_T_31; // @[Mux.scala 101:16]
  assign io_aluCtr_aluOp = aluSub ? 4'h8 : _io_aluCtr_aluOp_T_19; // @[Mux.scala 101:16]
endmodule
module Decode(
  input  [31:0] io_inst,
  output [4:0]  io_rs1_addr,
  output        io_rs1_en,
  output [4:0]  io_rd_addr,
  output        io_rd_en,
  output [4:0]  io_opcode,
  output [63:0] io_imm
);
  wire [31:0] imm_io_inst; // @[Decode.scala 19:20]
  wire [2:0] imm_io_immOp; // @[Decode.scala 19:20]
  wire [63:0] imm_io_imm; // @[Decode.scala 19:20]
  wire [31:0] con_io_inst; // @[Decode.scala 20:20]
  wire [2:0] con_io_immOp; // @[Decode.scala 20:20]
  wire [3:0] con_io_aluCtr_aluOp; // @[Decode.scala 20:20]
  wire [31:0] _T = io_inst & 32'h707f; // @[Decode.scala 45:14]
  ImmGen imm ( // @[Decode.scala 19:20]
    .io_inst(imm_io_inst),
    .io_immOp(imm_io_immOp),
    .io_imm(imm_io_imm)
  );
  ContrGen con ( // @[Decode.scala 20:20]
    .io_inst(con_io_inst),
    .io_immOp(con_io_immOp),
    .io_aluCtr_aluOp(con_io_aluCtr_aluOp)
  );
  assign io_rs1_addr = io_inst[19:15]; // @[Decode.scala 37:22]
  assign io_rs1_en = 32'h13 == _T; // @[Decode.scala 45:14]
  assign io_rd_addr = io_inst[11:7]; // @[Decode.scala 39:21]
  assign io_rd_en = 32'h13 == _T; // @[Decode.scala 45:14]
  assign io_opcode = {{1'd0}, con_io_aluCtr_aluOp}; // @[Decode.scala 51:13]
  assign io_imm = imm_io_imm; // @[Decode.scala 26:10]
  assign imm_io_inst = io_inst; // @[Decode.scala 21:15]
  assign imm_io_immOp = con_io_immOp; // @[Decode.scala 22:16]
  assign con_io_inst = io_inst; // @[Decode.scala 24:15]
endmodule
module RegFile(
  input         clock,
  input         reset,
  input  [4:0]  io_rs1_addr,
  output [63:0] io_rs1_data,
  input  [4:0]  io_rd_addr,
  input  [63:0] io_rd_data,
  input         io_rd_en,
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
  wire  dt_ar_clock; // @[RegFile.scala 25:21]
  wire [7:0] dt_ar_coreid; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_0; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_1; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_2; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_3; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_4; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_5; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_6; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_7; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_8; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_9; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_10; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_11; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_12; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_13; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_14; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_15; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_16; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_17; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_18; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_19; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_20; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_21; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_22; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_23; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_24; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_25; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_26; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_27; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_28; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_29; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_30; // @[RegFile.scala 25:21]
  wire [63:0] dt_ar_gpr_31; // @[RegFile.scala 25:21]
  reg [63:0] rf__0; // @[RegFile.scala 16:19]
  reg [63:0] rf__1; // @[RegFile.scala 16:19]
  reg [63:0] rf__2; // @[RegFile.scala 16:19]
  reg [63:0] rf__3; // @[RegFile.scala 16:19]
  reg [63:0] rf__4; // @[RegFile.scala 16:19]
  reg [63:0] rf__5; // @[RegFile.scala 16:19]
  reg [63:0] rf__6; // @[RegFile.scala 16:19]
  reg [63:0] rf__7; // @[RegFile.scala 16:19]
  reg [63:0] rf__8; // @[RegFile.scala 16:19]
  reg [63:0] rf__9; // @[RegFile.scala 16:19]
  reg [63:0] rf__10; // @[RegFile.scala 16:19]
  reg [63:0] rf__11; // @[RegFile.scala 16:19]
  reg [63:0] rf__12; // @[RegFile.scala 16:19]
  reg [63:0] rf__13; // @[RegFile.scala 16:19]
  reg [63:0] rf__14; // @[RegFile.scala 16:19]
  reg [63:0] rf__15; // @[RegFile.scala 16:19]
  reg [63:0] rf__16; // @[RegFile.scala 16:19]
  reg [63:0] rf__17; // @[RegFile.scala 16:19]
  reg [63:0] rf__18; // @[RegFile.scala 16:19]
  reg [63:0] rf__19; // @[RegFile.scala 16:19]
  reg [63:0] rf__20; // @[RegFile.scala 16:19]
  reg [63:0] rf__21; // @[RegFile.scala 16:19]
  reg [63:0] rf__22; // @[RegFile.scala 16:19]
  reg [63:0] rf__23; // @[RegFile.scala 16:19]
  reg [63:0] rf__24; // @[RegFile.scala 16:19]
  reg [63:0] rf__25; // @[RegFile.scala 16:19]
  reg [63:0] rf__26; // @[RegFile.scala 16:19]
  reg [63:0] rf__27; // @[RegFile.scala 16:19]
  reg [63:0] rf__28; // @[RegFile.scala 16:19]
  reg [63:0] rf__29; // @[RegFile.scala 16:19]
  reg [63:0] rf__30; // @[RegFile.scala 16:19]
  reg [63:0] rf__31; // @[RegFile.scala 16:19]
  wire [63:0] _GEN_65 = 5'h1 == io_rs1_addr ? rf__1 : rf__0; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_66 = 5'h2 == io_rs1_addr ? rf__2 : _GEN_65; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_67 = 5'h3 == io_rs1_addr ? rf__3 : _GEN_66; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_68 = 5'h4 == io_rs1_addr ? rf__4 : _GEN_67; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_69 = 5'h5 == io_rs1_addr ? rf__5 : _GEN_68; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_70 = 5'h6 == io_rs1_addr ? rf__6 : _GEN_69; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_71 = 5'h7 == io_rs1_addr ? rf__7 : _GEN_70; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_72 = 5'h8 == io_rs1_addr ? rf__8 : _GEN_71; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_73 = 5'h9 == io_rs1_addr ? rf__9 : _GEN_72; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_74 = 5'ha == io_rs1_addr ? rf__10 : _GEN_73; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_75 = 5'hb == io_rs1_addr ? rf__11 : _GEN_74; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_76 = 5'hc == io_rs1_addr ? rf__12 : _GEN_75; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_77 = 5'hd == io_rs1_addr ? rf__13 : _GEN_76; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_78 = 5'he == io_rs1_addr ? rf__14 : _GEN_77; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_79 = 5'hf == io_rs1_addr ? rf__15 : _GEN_78; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_80 = 5'h10 == io_rs1_addr ? rf__16 : _GEN_79; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_81 = 5'h11 == io_rs1_addr ? rf__17 : _GEN_80; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_82 = 5'h12 == io_rs1_addr ? rf__18 : _GEN_81; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_83 = 5'h13 == io_rs1_addr ? rf__19 : _GEN_82; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_84 = 5'h14 == io_rs1_addr ? rf__20 : _GEN_83; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_85 = 5'h15 == io_rs1_addr ? rf__21 : _GEN_84; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_86 = 5'h16 == io_rs1_addr ? rf__22 : _GEN_85; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_87 = 5'h17 == io_rs1_addr ? rf__23 : _GEN_86; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_88 = 5'h18 == io_rs1_addr ? rf__24 : _GEN_87; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_89 = 5'h19 == io_rs1_addr ? rf__25 : _GEN_88; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_90 = 5'h1a == io_rs1_addr ? rf__26 : _GEN_89; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_91 = 5'h1b == io_rs1_addr ? rf__27 : _GEN_90; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_92 = 5'h1c == io_rs1_addr ? rf__28 : _GEN_91; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_93 = 5'h1d == io_rs1_addr ? rf__29 : _GEN_92; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_94 = 5'h1e == io_rs1_addr ? rf__30 : _GEN_93; // @[RegFile.scala 22:{21,21}]
  wire [63:0] _GEN_95 = 5'h1f == io_rs1_addr ? rf__31 : _GEN_94; // @[RegFile.scala 22:{21,21}]
  DifftestArchIntRegState dt_ar ( // @[RegFile.scala 25:21]
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
  assign io_rs1_data = io_rs1_addr != 5'h0 ? _GEN_95 : 64'h0; // @[RegFile.scala 22:21]
  assign rf_10 = rf__10;
  assign dt_ar_clock = clock; // @[RegFile.scala 26:19]
  assign dt_ar_coreid = 8'h0; // @[RegFile.scala 27:19]
  assign dt_ar_gpr_0 = rf__0; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_1 = rf__1; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_2 = rf__2; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_3 = rf__3; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_4 = rf__4; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_5 = rf__5; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_6 = rf__6; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_7 = rf__7; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_8 = rf__8; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_9 = rf__9; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_10 = rf__10; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_11 = rf__11; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_12 = rf__12; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_13 = rf__13; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_14 = rf__14; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_15 = rf__15; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_16 = rf__16; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_17 = rf__17; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_18 = rf__18; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_19 = rf__19; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_20 = rf__20; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_21 = rf__21; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_22 = rf__22; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_23 = rf__23; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_24 = rf__24; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_25 = rf__25; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_26 = rf__26; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_27 = rf__27; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_28 = rf__28; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_29 = rf__29; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_30 = rf__30; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_31 = rf__31; // @[RegFile.scala 28:19]
  always @(posedge clock) begin
    if (reset) begin // @[RegFile.scala 16:19]
      rf__0 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h0 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__0 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__1 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h1 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__1 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__2 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h2 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__2 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__3 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h3 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__3 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__4 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h4 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__4 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__5 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h5 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__5 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__6 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h6 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__6 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__7 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h7 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__7 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__8 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h8 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__8 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__9 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h9 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__9 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__10 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'ha == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__10 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__11 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'hb == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__11 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__12 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'hc == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__12 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__13 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'hd == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__13 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__14 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'he == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__14 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__15 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'hf == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__15 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__16 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h10 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__16 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__17 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h11 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__17 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__18 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h12 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__18 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__19 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h13 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__19 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__20 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h14 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__20 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__21 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h15 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__21 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__22 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h16 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__22 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__23 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h17 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__23 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__24 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h18 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__24 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__25 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h19 == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__25 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__26 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h1a == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__26 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__27 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h1b == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__27 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__28 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h1c == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__28 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__29 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h1d == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__29 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__30 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h1e == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__30 <= io_rd_data; // @[RegFile.scala 19:20]
      end
    end
    if (reset) begin // @[RegFile.scala 16:19]
      rf__31 <= 64'h0; // @[RegFile.scala 16:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 18:43]
      if (5'h1f == io_rd_addr) begin // @[RegFile.scala 19:20]
        rf__31 <= io_rd_data; // @[RegFile.scala 19:20]
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
module Execution(
  input  [7:0]  io_opcode,
  input  [63:0] io_in1,
  input  [63:0] io_in2,
  output [63:0] io_out
);
  wire [63:0] _io_out_T_1 = io_in1 + io_in2; // @[Execution.scala 17:22]
  assign io_out = io_opcode == 8'h0 ? _io_out_T_1 : 64'h0; // @[Execution.scala 13:10 16:28 17:12]
endmodule
module Core(
  input         clock,
  input         reset,
  output [63:0] io_imem_addr,
  input  [63:0] io_imem_rdata
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [63:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [63:0] _RAND_5;
  reg [63:0] _RAND_6;
`endif // RANDOMIZE_REG_INIT
  wire  fetch_clock; // @[Core.scala 11:21]
  wire  fetch_reset; // @[Core.scala 11:21]
  wire [63:0] fetch_io_imem_addr; // @[Core.scala 11:21]
  wire [63:0] fetch_io_imem_rdata; // @[Core.scala 11:21]
  wire [31:0] fetch_io_pc; // @[Core.scala 11:21]
  wire [31:0] fetch_io_inst; // @[Core.scala 11:21]
  wire [31:0] decode_io_inst; // @[Core.scala 14:22]
  wire [4:0] decode_io_rs1_addr; // @[Core.scala 14:22]
  wire  decode_io_rs1_en; // @[Core.scala 14:22]
  wire [4:0] decode_io_rd_addr; // @[Core.scala 14:22]
  wire  decode_io_rd_en; // @[Core.scala 14:22]
  wire [4:0] decode_io_opcode; // @[Core.scala 14:22]
  wire [63:0] decode_io_imm; // @[Core.scala 14:22]
  wire  rf_clock; // @[Core.scala 17:18]
  wire  rf_reset; // @[Core.scala 17:18]
  wire [4:0] rf_io_rs1_addr; // @[Core.scala 17:18]
  wire [63:0] rf_io_rs1_data; // @[Core.scala 17:18]
  wire [4:0] rf_io_rd_addr; // @[Core.scala 17:18]
  wire [63:0] rf_io_rd_data; // @[Core.scala 17:18]
  wire  rf_io_rd_en; // @[Core.scala 17:18]
  wire [63:0] rf_rf_10; // @[Core.scala 17:18]
  wire [7:0] execution_io_opcode; // @[Core.scala 23:25]
  wire [63:0] execution_io_in1; // @[Core.scala 23:25]
  wire [63:0] execution_io_in2; // @[Core.scala 23:25]
  wire [63:0] execution_io_out; // @[Core.scala 23:25]
  wire  dt_ic_clock; // @[Core.scala 33:21]
  wire [7:0] dt_ic_coreid; // @[Core.scala 33:21]
  wire [7:0] dt_ic_index; // @[Core.scala 33:21]
  wire  dt_ic_valid; // @[Core.scala 33:21]
  wire [63:0] dt_ic_pc; // @[Core.scala 33:21]
  wire [31:0] dt_ic_instr; // @[Core.scala 33:21]
  wire  dt_ic_skip; // @[Core.scala 33:21]
  wire  dt_ic_isRVC; // @[Core.scala 33:21]
  wire  dt_ic_scFailed; // @[Core.scala 33:21]
  wire  dt_ic_wen; // @[Core.scala 33:21]
  wire [63:0] dt_ic_wdata; // @[Core.scala 33:21]
  wire [7:0] dt_ic_wdest; // @[Core.scala 33:21]
  wire  dt_ae_clock; // @[Core.scala 47:21]
  wire [7:0] dt_ae_coreid; // @[Core.scala 47:21]
  wire [31:0] dt_ae_intrNO; // @[Core.scala 47:21]
  wire [31:0] dt_ae_cause; // @[Core.scala 47:21]
  wire [63:0] dt_ae_exceptionPC; // @[Core.scala 47:21]
  wire [31:0] dt_ae_exceptionInst; // @[Core.scala 47:21]
  wire  dt_te_clock; // @[Core.scala 63:21]
  wire [7:0] dt_te_coreid; // @[Core.scala 63:21]
  wire  dt_te_valid; // @[Core.scala 63:21]
  wire [2:0] dt_te_code; // @[Core.scala 63:21]
  wire [63:0] dt_te_pc; // @[Core.scala 63:21]
  wire [63:0] dt_te_cycleCnt; // @[Core.scala 63:21]
  wire [63:0] dt_te_instrCnt; // @[Core.scala 63:21]
  wire  dt_cs_clock; // @[Core.scala 72:21]
  wire [7:0] dt_cs_coreid; // @[Core.scala 72:21]
  wire [1:0] dt_cs_priviledgeMode; // @[Core.scala 72:21]
  wire [63:0] dt_cs_mstatus; // @[Core.scala 72:21]
  wire [63:0] dt_cs_sstatus; // @[Core.scala 72:21]
  wire [63:0] dt_cs_mepc; // @[Core.scala 72:21]
  wire [63:0] dt_cs_sepc; // @[Core.scala 72:21]
  wire [63:0] dt_cs_mtval; // @[Core.scala 72:21]
  wire [63:0] dt_cs_stval; // @[Core.scala 72:21]
  wire [63:0] dt_cs_mtvec; // @[Core.scala 72:21]
  wire [63:0] dt_cs_stvec; // @[Core.scala 72:21]
  wire [63:0] dt_cs_mcause; // @[Core.scala 72:21]
  wire [63:0] dt_cs_scause; // @[Core.scala 72:21]
  wire [63:0] dt_cs_satp; // @[Core.scala 72:21]
  wire [63:0] dt_cs_mip; // @[Core.scala 72:21]
  wire [63:0] dt_cs_mie; // @[Core.scala 72:21]
  wire [63:0] dt_cs_mscratch; // @[Core.scala 72:21]
  wire [63:0] dt_cs_sscratch; // @[Core.scala 72:21]
  wire [63:0] dt_cs_mideleg; // @[Core.scala 72:21]
  wire [63:0] dt_cs_medeleg; // @[Core.scala 72:21]
  reg [31:0] dt_ic_io_pc_REG; // @[Core.scala 38:31]
  reg [31:0] dt_ic_io_instr_REG; // @[Core.scala 39:31]
  reg  dt_ic_io_wen_REG; // @[Core.scala 43:31]
  reg [63:0] dt_ic_io_wdata_REG; // @[Core.scala 44:31]
  reg [4:0] dt_ic_io_wdest_REG; // @[Core.scala 45:31]
  reg [63:0] cycle_cnt; // @[Core.scala 54:26]
  reg [63:0] instr_cnt; // @[Core.scala 55:26]
  wire [63:0] _cycle_cnt_T_1 = cycle_cnt + 64'h1; // @[Core.scala 57:26]
  wire [63:0] _instr_cnt_T_1 = instr_cnt + 64'h1; // @[Core.scala 58:26]
  wire [63:0] rf_a0_0 = rf_rf_10;
  InstFetch fetch ( // @[Core.scala 11:21]
    .clock(fetch_clock),
    .reset(fetch_reset),
    .io_imem_addr(fetch_io_imem_addr),
    .io_imem_rdata(fetch_io_imem_rdata),
    .io_pc(fetch_io_pc),
    .io_inst(fetch_io_inst)
  );
  Decode decode ( // @[Core.scala 14:22]
    .io_inst(decode_io_inst),
    .io_rs1_addr(decode_io_rs1_addr),
    .io_rs1_en(decode_io_rs1_en),
    .io_rd_addr(decode_io_rd_addr),
    .io_rd_en(decode_io_rd_en),
    .io_opcode(decode_io_opcode),
    .io_imm(decode_io_imm)
  );
  RegFile rf ( // @[Core.scala 17:18]
    .clock(rf_clock),
    .reset(rf_reset),
    .io_rs1_addr(rf_io_rs1_addr),
    .io_rs1_data(rf_io_rs1_data),
    .io_rd_addr(rf_io_rd_addr),
    .io_rd_data(rf_io_rd_data),
    .io_rd_en(rf_io_rd_en),
    .rf_10(rf_rf_10)
  );
  Execution execution ( // @[Core.scala 23:25]
    .io_opcode(execution_io_opcode),
    .io_in1(execution_io_in1),
    .io_in2(execution_io_in2),
    .io_out(execution_io_out)
  );
  DifftestInstrCommit dt_ic ( // @[Core.scala 33:21]
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
  DifftestArchEvent dt_ae ( // @[Core.scala 47:21]
    .clock(dt_ae_clock),
    .coreid(dt_ae_coreid),
    .intrNO(dt_ae_intrNO),
    .cause(dt_ae_cause),
    .exceptionPC(dt_ae_exceptionPC),
    .exceptionInst(dt_ae_exceptionInst)
  );
  DifftestTrapEvent dt_te ( // @[Core.scala 63:21]
    .clock(dt_te_clock),
    .coreid(dt_te_coreid),
    .valid(dt_te_valid),
    .code(dt_te_code),
    .pc(dt_te_pc),
    .cycleCnt(dt_te_cycleCnt),
    .instrCnt(dt_te_instrCnt)
  );
  DifftestCSRState dt_cs ( // @[Core.scala 72:21]
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
  assign io_imem_addr = fetch_io_imem_addr; // @[Core.scala 12:17]
  assign fetch_clock = clock;
  assign fetch_reset = reset;
  assign fetch_io_imem_rdata = io_imem_rdata; // @[Core.scala 12:17]
  assign decode_io_inst = fetch_io_inst; // @[Core.scala 15:18]
  assign rf_clock = clock;
  assign rf_reset = reset;
  assign rf_io_rs1_addr = decode_io_rs1_addr; // @[Core.scala 18:18]
  assign rf_io_rd_addr = decode_io_rd_addr; // @[Core.scala 20:17]
  assign rf_io_rd_data = execution_io_out; // @[Core.scala 29:17]
  assign rf_io_rd_en = decode_io_rd_en; // @[Core.scala 21:15]
  assign execution_io_opcode = {{3'd0}, decode_io_opcode}; // @[Core.scala 24:23]
  assign execution_io_in1 = decode_io_rs1_en ? rf_io_rs1_data : 64'h0; // @[Core.scala 25:26]
  assign execution_io_in2 = decode_io_imm; // @[Core.scala 26:26]
  assign dt_ic_clock = clock; // @[Core.scala 34:21]
  assign dt_ic_coreid = 8'h0; // @[Core.scala 35:21]
  assign dt_ic_index = 8'h0; // @[Core.scala 36:21]
  assign dt_ic_valid = 1'h1; // @[Core.scala 37:21]
  assign dt_ic_pc = {{32'd0}, dt_ic_io_pc_REG}; // @[Core.scala 38:21]
  assign dt_ic_instr = dt_ic_io_instr_REG; // @[Core.scala 39:21]
  assign dt_ic_skip = 1'h0; // @[Core.scala 40:21]
  assign dt_ic_isRVC = 1'h0; // @[Core.scala 41:21]
  assign dt_ic_scFailed = 1'h0; // @[Core.scala 42:21]
  assign dt_ic_wen = dt_ic_io_wen_REG; // @[Core.scala 43:21]
  assign dt_ic_wdata = dt_ic_io_wdata_REG; // @[Core.scala 44:21]
  assign dt_ic_wdest = {{3'd0}, dt_ic_io_wdest_REG}; // @[Core.scala 45:21]
  assign dt_ae_clock = clock; // @[Core.scala 48:25]
  assign dt_ae_coreid = 8'h0; // @[Core.scala 49:25]
  assign dt_ae_intrNO = 32'h0; // @[Core.scala 50:25]
  assign dt_ae_cause = 32'h0; // @[Core.scala 51:25]
  assign dt_ae_exceptionPC = 64'h0; // @[Core.scala 52:25]
  assign dt_ae_exceptionInst = 32'h0;
  assign dt_te_clock = clock; // @[Core.scala 64:21]
  assign dt_te_coreid = 8'h0; // @[Core.scala 65:21]
  assign dt_te_valid = fetch_io_inst == 32'h6b; // @[Core.scala 66:39]
  assign dt_te_code = rf_a0_0[2:0]; // @[Core.scala 67:29]
  assign dt_te_pc = {{32'd0}, fetch_io_pc}; // @[Core.scala 68:21]
  assign dt_te_cycleCnt = cycle_cnt; // @[Core.scala 69:21]
  assign dt_te_instrCnt = instr_cnt; // @[Core.scala 70:21]
  assign dt_cs_clock = clock; // @[Core.scala 73:27]
  assign dt_cs_coreid = 8'h0; // @[Core.scala 74:27]
  assign dt_cs_priviledgeMode = 2'h3; // @[Core.scala 75:27]
  assign dt_cs_mstatus = 64'h0; // @[Core.scala 76:27]
  assign dt_cs_sstatus = 64'h0; // @[Core.scala 77:27]
  assign dt_cs_mepc = 64'h0; // @[Core.scala 78:27]
  assign dt_cs_sepc = 64'h0; // @[Core.scala 79:27]
  assign dt_cs_mtval = 64'h0; // @[Core.scala 80:27]
  assign dt_cs_stval = 64'h0; // @[Core.scala 81:27]
  assign dt_cs_mtvec = 64'h0; // @[Core.scala 82:27]
  assign dt_cs_stvec = 64'h0; // @[Core.scala 83:27]
  assign dt_cs_mcause = 64'h0; // @[Core.scala 84:27]
  assign dt_cs_scause = 64'h0; // @[Core.scala 85:27]
  assign dt_cs_satp = 64'h0; // @[Core.scala 86:27]
  assign dt_cs_mip = 64'h0; // @[Core.scala 87:27]
  assign dt_cs_mie = 64'h0; // @[Core.scala 88:27]
  assign dt_cs_mscratch = 64'h0; // @[Core.scala 89:27]
  assign dt_cs_sscratch = 64'h0; // @[Core.scala 90:27]
  assign dt_cs_mideleg = 64'h0; // @[Core.scala 91:27]
  assign dt_cs_medeleg = 64'h0; // @[Core.scala 92:27]
  always @(posedge clock) begin
    dt_ic_io_pc_REG <= fetch_io_pc; // @[Core.scala 38:31]
    dt_ic_io_instr_REG <= fetch_io_inst; // @[Core.scala 39:31]
    dt_ic_io_wen_REG <= decode_io_rd_en; // @[Core.scala 43:31]
    dt_ic_io_wdata_REG <= execution_io_out; // @[Core.scala 44:31]
    dt_ic_io_wdest_REG <= decode_io_rd_addr; // @[Core.scala 45:31]
    if (reset) begin // @[Core.scala 54:26]
      cycle_cnt <= 64'h0; // @[Core.scala 54:26]
    end else begin
      cycle_cnt <= _cycle_cnt_T_1; // @[Core.scala 57:13]
    end
    if (reset) begin // @[Core.scala 55:26]
      instr_cnt <= 64'h0; // @[Core.scala 55:26]
    end else begin
      instr_cnt <= _instr_cnt_T_1; // @[Core.scala 58:13]
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
  dt_ic_io_pc_REG = _RAND_0[31:0];
  _RAND_1 = {1{`RANDOM}};
  dt_ic_io_instr_REG = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  dt_ic_io_wen_REG = _RAND_2[0:0];
  _RAND_3 = {2{`RANDOM}};
  dt_ic_io_wdata_REG = _RAND_3[63:0];
  _RAND_4 = {1{`RANDOM}};
  dt_ic_io_wdest_REG = _RAND_4[4:0];
  _RAND_5 = {2{`RANDOM}};
  cycle_cnt = _RAND_5[63:0];
  _RAND_6 = {2{`RANDOM}};
  instr_cnt = _RAND_6[63:0];
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
  output [63:0] io_imem_rdata
);
  wire  mem_clk; // @[Ram.scala 37:19]
  wire  mem_imem_en; // @[Ram.scala 37:19]
  wire [63:0] mem_imem_addr; // @[Ram.scala 37:19]
  wire [31:0] mem_imem_data; // @[Ram.scala 37:19]
  wire  mem_dmem_en; // @[Ram.scala 37:19]
  wire [63:0] mem_dmem_addr; // @[Ram.scala 37:19]
  wire [63:0] mem_dmem_rdata; // @[Ram.scala 37:19]
  wire [63:0] mem_dmem_wdata; // @[Ram.scala 37:19]
  wire [63:0] mem_dmem_wmask; // @[Ram.scala 37:19]
  wire  mem_dmem_wen; // @[Ram.scala 37:19]
  ram_2r1w mem ( // @[Ram.scala 37:19]
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
  assign io_imem_rdata = {{32'd0}, mem_imem_data}; // @[Ram.scala 41:21]
  assign mem_clk = clock; // @[Ram.scala 38:21]
  assign mem_imem_en = 1'h1; // @[Ram.scala 39:21]
  assign mem_imem_addr = io_imem_addr; // @[Ram.scala 40:21]
  assign mem_dmem_en = 1'h0; // @[Ram.scala 42:21]
  assign mem_dmem_addr = 64'h0; // @[Ram.scala 43:21]
  assign mem_dmem_wdata = 64'h0; // @[Ram.scala 45:21]
  assign mem_dmem_wmask = 64'h0; // @[Ram.scala 46:21]
  assign mem_dmem_wen = 1'h0; // @[Ram.scala 47:21]
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
  wire  core_clock; // @[SimTop.scala 12:20]
  wire  core_reset; // @[SimTop.scala 12:20]
  wire [63:0] core_io_imem_addr; // @[SimTop.scala 12:20]
  wire [63:0] core_io_imem_rdata; // @[SimTop.scala 12:20]
  wire  mem_clock; // @[SimTop.scala 14:19]
  wire [63:0] mem_io_imem_addr; // @[SimTop.scala 14:19]
  wire [63:0] mem_io_imem_rdata; // @[SimTop.scala 14:19]
  Core core ( // @[SimTop.scala 12:20]
    .clock(core_clock),
    .reset(core_reset),
    .io_imem_addr(core_io_imem_addr),
    .io_imem_rdata(core_io_imem_rdata)
  );
  Ram2r1w mem ( // @[SimTop.scala 14:19]
    .clock(mem_clock),
    .io_imem_addr(mem_io_imem_addr),
    .io_imem_rdata(mem_io_imem_rdata)
  );
  assign io_uart_out_valid = 1'h0; // @[SimTop.scala 18:21]
  assign io_uart_out_ch = 8'h0; // @[SimTop.scala 19:18]
  assign io_uart_in_valid = 1'h0; // @[SimTop.scala 20:20]
  assign core_clock = clock;
  assign core_reset = reset;
  assign core_io_imem_rdata = mem_io_imem_rdata; // @[SimTop.scala 15:15]
  assign mem_clock = clock;
  assign mem_io_imem_addr = core_io_imem_addr; // @[SimTop.scala 15:15]
endmodule
