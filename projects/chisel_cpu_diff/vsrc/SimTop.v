module InstFetch(
  input         clock,
  input         reset,
  output [63:0] io_imem_addr,
  input  [63:0] io_imem_rdata,
  input  [31:0] io_nextPC,
  output [31:0] io_pc,
  output [31:0] io_inst
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] pc; // @[InstFetch.scala 12:19]
  assign io_imem_addr = {{32'd0}, pc}; // @[InstFetch.scala 17:16]
  assign io_pc = pc; // @[InstFetch.scala 19:9]
  assign io_inst = io_imem_rdata[31:0]; // @[InstFetch.scala 20:27]
  always @(posedge clock) begin
    if (reset) begin // @[InstFetch.scala 12:19]
      pc <= 32'h7ffffffc; // @[InstFetch.scala 12:19]
    end else begin
      pc <= io_nextPC; // @[InstFetch.scala 14:6]
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
module RegFile(
  input         clock,
  input         reset,
  output [63:0] io_rs1Data,
  output [63:0] io_rs2Data,
  input  [63:0] io_rdData,
  input         io_ctrl_rs1En,
  input         io_ctrl_rs2En,
  input  [4:0]  io_ctrl_rs1Addr,
  input  [4:0]  io_ctrl_rs2Addr,
  input  [4:0]  io_ctrl_rdAddr,
  input         io_ctrl_rdEn,
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
  reg [63:0] rf__0; // @[RegFile.scala 14:19]
  reg [63:0] rf__1; // @[RegFile.scala 14:19]
  reg [63:0] rf__2; // @[RegFile.scala 14:19]
  reg [63:0] rf__3; // @[RegFile.scala 14:19]
  reg [63:0] rf__4; // @[RegFile.scala 14:19]
  reg [63:0] rf__5; // @[RegFile.scala 14:19]
  reg [63:0] rf__6; // @[RegFile.scala 14:19]
  reg [63:0] rf__7; // @[RegFile.scala 14:19]
  reg [63:0] rf__8; // @[RegFile.scala 14:19]
  reg [63:0] rf__9; // @[RegFile.scala 14:19]
  reg [63:0] rf__10; // @[RegFile.scala 14:19]
  reg [63:0] rf__11; // @[RegFile.scala 14:19]
  reg [63:0] rf__12; // @[RegFile.scala 14:19]
  reg [63:0] rf__13; // @[RegFile.scala 14:19]
  reg [63:0] rf__14; // @[RegFile.scala 14:19]
  reg [63:0] rf__15; // @[RegFile.scala 14:19]
  reg [63:0] rf__16; // @[RegFile.scala 14:19]
  reg [63:0] rf__17; // @[RegFile.scala 14:19]
  reg [63:0] rf__18; // @[RegFile.scala 14:19]
  reg [63:0] rf__19; // @[RegFile.scala 14:19]
  reg [63:0] rf__20; // @[RegFile.scala 14:19]
  reg [63:0] rf__21; // @[RegFile.scala 14:19]
  reg [63:0] rf__22; // @[RegFile.scala 14:19]
  reg [63:0] rf__23; // @[RegFile.scala 14:19]
  reg [63:0] rf__24; // @[RegFile.scala 14:19]
  reg [63:0] rf__25; // @[RegFile.scala 14:19]
  reg [63:0] rf__26; // @[RegFile.scala 14:19]
  reg [63:0] rf__27; // @[RegFile.scala 14:19]
  reg [63:0] rf__28; // @[RegFile.scala 14:19]
  reg [63:0] rf__29; // @[RegFile.scala 14:19]
  reg [63:0] rf__30; // @[RegFile.scala 14:19]
  reg [63:0] rf__31; // @[RegFile.scala 14:19]
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
    if (reset) begin // @[RegFile.scala 14:19]
      rf__0 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h0 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__0 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__1 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h1 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__1 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__2 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h2 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__2 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__3 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h3 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__3 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__4 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h4 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__4 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__5 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h5 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__5 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__6 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h6 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__6 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__7 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h7 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__7 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__8 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h8 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__8 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__9 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h9 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__9 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__10 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'ha == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__10 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__11 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'hb == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__11 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__12 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'hc == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__12 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__13 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'hd == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__13 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__14 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'he == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__14 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__15 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'hf == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__15 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__16 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h10 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__16 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__17 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h11 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__17 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__18 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h12 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__18 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__19 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h13 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__19 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__20 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h14 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__20 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__21 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h15 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__21 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__22 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h16 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__22 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__23 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h17 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__23 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__24 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h18 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__24 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__25 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h19 == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__25 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__26 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h1a == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__26 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__27 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h1b == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__27 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__28 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h1c == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__28 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__29 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h1d == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__29 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__30 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h1e == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__30 <= io_rdData; // @[RegFile.scala 17:24]
      end
    end
    if (reset) begin // @[RegFile.scala 14:19]
      rf__31 <= 64'h0; // @[RegFile.scala 14:19]
    end else if (io_ctrl_rdEn & io_ctrl_rdAddr != 5'h0) begin // @[RegFile.scala 16:51]
      if (5'h1f == io_ctrl_rdAddr) begin // @[RegFile.scala 17:24]
        rf__31 <= io_rdData; // @[RegFile.scala 17:24]
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
  output [2:0]  io_Branch,
  output [2:0]  io_immOp,
  output        io_aluCtr_aluA,
  output [1:0]  io_aluCtr_aluB,
  output [3:0]  io_aluCtr_aluOp,
  output [1:0]  io_memCtr_MemtoReg,
  output        io_memCtr_MemWr,
  output [2:0]  io_memCtr_MemOP,
  output        io_regCtrl_rs1En,
  output        io_regCtrl_rs2En,
  output [4:0]  io_regCtrl_rs1Addr,
  output [4:0]  io_regCtrl_rs2Addr,
  output [4:0]  io_regCtrl_rdAddr,
  output        io_regCtrl_rdEn
);
  wire [31:0] _instLui_T = io_inst & 32'h7f; // @[ContrGen.scala 23:26]
  wire  instLui = 32'h37 == _instLui_T; // @[ContrGen.scala 23:26]
  wire  instAuipc = 32'h17 == _instLui_T; // @[ContrGen.scala 24:26]
  wire  typeU = instLui | instAuipc; // @[ContrGen.scala 25:29]
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
  wire  instLwu = 32'h6003 == _instAddi_T; // @[ContrGen.scala 47:26]
  wire  instJal = 32'h6f == _instLui_T; // @[ContrGen.scala 53:26]
  wire  typeJ = instJal | instJalr; // @[ContrGen.scala 54:29]
  wire  instAdd = 32'h33 == _instSlliw_T; // @[ContrGen.scala 56:26]
  wire  instSub = 32'h40000033 == _instSlliw_T; // @[ContrGen.scala 57:26]
  wire  instSll = 32'h1033 == _instSlliw_T; // @[ContrGen.scala 58:26]
  wire  instSlt = 32'h2033 == _instSlliw_T; // @[ContrGen.scala 59:26]
  wire  instSltu = 32'h3033 == _instSlliw_T; // @[ContrGen.scala 60:26]
  wire  instXor = 32'h4033 == _instSlliw_T; // @[ContrGen.scala 61:26]
  wire  instSrl = 32'h5033 == _instSlliw_T; // @[ContrGen.scala 62:26]
  wire  instSra = 32'h40005033 == _instSlliw_T; // @[ContrGen.scala 63:26]
  wire  instOr = 32'h6033 == _instSlliw_T; // @[ContrGen.scala 64:26]
  wire  instAnd = 32'h7033 == _instSlliw_T; // @[ContrGen.scala 65:26]
  wire  instAddw = 32'h3b == _instSlliw_T; // @[ContrGen.scala 66:26]
  wire  instSubw = 32'h4000003b == _instSlliw_T; // @[ContrGen.scala 67:26]
  wire  instSllw = 32'h103b == _instSlliw_T; // @[ContrGen.scala 68:26]
  wire  instSrlw = 32'h503b == _instSlliw_T; // @[ContrGen.scala 69:26]
  wire  instSraw = 32'h4000503b == _instSlliw_T; // @[ContrGen.scala 70:26]
  wire  instMret = 32'h30200073 == io_inst; // @[ContrGen.scala 71:26]
  wire  aluRem = 32'h200603b == _instSlliw_T; // @[ContrGen.scala 72:26]
  wire  instDiv = 32'h2004033 == _instSlliw_T; // @[ContrGen.scala 73:26]
  wire  instDivw = 32'h200403b == _instSlliw_T; // @[ContrGen.scala 74:26]
  wire  instMul = 32'h2000033 == _instSlliw_T; // @[ContrGen.scala 75:26]
  wire  instMulw = 32'h200003b == _instSlliw_T; // @[ContrGen.scala 76:26]
  wire  _typeR_T_4 = instAdd | instSub | instSll | instSlt | instSltu | instXor; // @[ContrGen.scala 77:78]
  wire  _typeR_T_9 = _typeR_T_4 | instSrl | instSra | instOr | instAnd | instAddw; // @[ContrGen.scala 78:78]
  wire  _typeR_T_14 = _typeR_T_9 | instSubw | instSllw | instSrlw | instSraw | instMret; // @[ContrGen.scala 79:78]
  wire  typeR = _typeR_T_14 | aluRem | instDiv | instDivw | instMul | instMulw; // @[ContrGen.scala 80:78]
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
  wire  _typeS_T_1 = instSb | instSh | instSw; // @[ContrGen.scala 94:39]
  wire  typeS = instSb | instSh | instSw | instSd; // @[ContrGen.scala 94:49]
  wire  Ebreak = 32'h100073 == io_inst; // @[ContrGen.scala 96:27]
  wire  _typeW_T_3 = instAddw | instSubw | instSllw | instSlliw | instSraw; // @[ContrGen.scala 98:68]
  wire  _typeW_T_9 = _typeW_T_3 | instSrlw | instSrliw | instSraiw | instAddiw | aluRem | instDivw; // @[ContrGen.scala 99:76]
  wire  typeW = _typeW_T_9 | instMulw; // @[ContrGen.scala 100:14]
  wire  _io_aluCtr_aluB_T = typeR | typeB; // @[ContrGen.scala 106:12]
  wire [1:0] _io_aluCtr_aluB_T_1 = typeJ ? 2'h2 : 2'h1; // @[Mux.scala 101:16]
  wire  aluSub = instSub | instSubw; // @[ContrGen.scala 113:28]
  wire  aluSlt = instSlti | instSlt; // @[ContrGen.scala 114:29]
  wire  aluSltu = instSltiu | instSltu; // @[ContrGen.scala 115:29]
  wire  aluAnd = instAndi | instAnd; // @[ContrGen.scala 116:29]
  wire  aluOr = instOri | instOr; // @[ContrGen.scala 117:29]
  wire  aluXor = instXori | instXor; // @[ContrGen.scala 118:29]
  wire  aluSll = instSlli | instSlliw | instSll | instSllw; // @[ContrGen.scala 119:53]
  wire  aluSrl = instSrli | instSrliw | instSrl | instSrlw; // @[ContrGen.scala 120:53]
  wire  aluSra = instSrai | instSraiw | instSra | instSraw; // @[ContrGen.scala 121:53]
  wire  aluDiv = instDiv | instDivw; // @[ContrGen.scala 123:27]
  wire  aluMul = instMul | instMulw; // @[ContrGen.scala 124:27]
  wire  _io_aluCtr_aluOp_T_2 = aluSlt | instBlt | instBge; // @[ContrGen.scala 130:37]
  wire  _io_aluCtr_aluOp_T_6 = aluSltu | instBltu | instBgeu; // @[ContrGen.scala 132:40]
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
  wire  _io_Branch_T = instBlt | instBltu; // @[ContrGen.scala 148:20]
  wire  _io_Branch_T_1 = instBge | instBgeu; // @[ContrGen.scala 149:20]
  wire [2:0] _io_Branch_T_2 = _io_Branch_T_1 ? 3'h7 : 3'h0; // @[Mux.scala 101:16]
  wire [2:0] _io_Branch_T_3 = _io_Branch_T ? 3'h6 : _io_Branch_T_2; // @[Mux.scala 101:16]
  wire [2:0] _io_Branch_T_4 = instBne ? 3'h5 : _io_Branch_T_3; // @[Mux.scala 101:16]
  wire [2:0] _io_Branch_T_5 = instBeq ? 3'h4 : _io_Branch_T_4; // @[Mux.scala 101:16]
  wire [2:0] _io_Branch_T_6 = instJalr ? 3'h2 : _io_Branch_T_5; // @[Mux.scala 101:16]
  wire  wRegEn = ~(typeS | typeB | Ebreak); // @[ContrGen.scala 156:16]
  wire  _io_immOp_T_8 = instAddi | instAddiw | instSlti | instSltiu | instXori | instOri | instAndi | instSlli |
    instSlliw | instSrli; // @[ContrGen.scala 161:120]
  wire  _io_immOp_T_15 = _io_immOp_T_8 | instSrliw | instSrai | instSraiw | instJalr | instLb | instLh | instLw; // @[ContrGen.scala 162:92]
  wire  _io_immOp_T_19 = _io_immOp_T_15 | instLwu | instLd | instLbu | instLhu; // @[ContrGen.scala 163:57]
  wire  _io_immOp_T_20 = instAuipc | instLui; // @[ContrGen.scala 164:22]
  wire  _io_immOp_T_23 = instSd | instSb | instSw | instSh; // @[ContrGen.scala 165:39]
  wire [2:0] _io_immOp_T_29 = instJal ? 3'h4 : 3'h7; // @[Mux.scala 101:16]
  wire [2:0] _io_immOp_T_30 = typeB ? 3'h3 : _io_immOp_T_29; // @[Mux.scala 101:16]
  wire [2:0] _io_immOp_T_31 = _io_immOp_T_23 ? 3'h2 : _io_immOp_T_30; // @[Mux.scala 101:16]
  wire [2:0] _io_immOp_T_32 = _io_immOp_T_20 ? 3'h1 : _io_immOp_T_31; // @[Mux.scala 101:16]
  wire  _io_memCtr_MemtoReg_T_5 = instLb | instLh | instLw | instLwu | instLd | instLbu | instLhu; // @[ContrGen.scala 170:65]
  wire [1:0] _io_memCtr_MemtoReg_T_6 = typeW ? 2'h2 : 2'h0; // @[Mux.scala 101:16]
  wire  _io_memCtr_MemOP_T = instLb | instSb; // @[ContrGen.scala 176:19]
  wire  _io_memCtr_MemOP_T_1 = instLh | instSh; // @[ContrGen.scala 177:19]
  wire  _io_memCtr_MemOP_T_2 = instLw | instSw; // @[ContrGen.scala 178:19]
  wire  _io_memCtr_MemOP_T_3 = instLd | instSd; // @[ContrGen.scala 179:19]
  wire [2:0] _io_memCtr_MemOP_T_4 = instLwu ? 3'h6 : 3'h7; // @[Mux.scala 101:16]
  wire [2:0] _io_memCtr_MemOP_T_5 = instLhu ? 3'h5 : _io_memCtr_MemOP_T_4; // @[Mux.scala 101:16]
  wire [2:0] _io_memCtr_MemOP_T_6 = instLbu ? 3'h4 : _io_memCtr_MemOP_T_5; // @[Mux.scala 101:16]
  wire [2:0] _io_memCtr_MemOP_T_7 = _io_memCtr_MemOP_T_3 ? 3'h3 : _io_memCtr_MemOP_T_6; // @[Mux.scala 101:16]
  wire [2:0] _io_memCtr_MemOP_T_8 = _io_memCtr_MemOP_T_2 ? 3'h2 : _io_memCtr_MemOP_T_7; // @[Mux.scala 101:16]
  wire [2:0] _io_memCtr_MemOP_T_9 = _io_memCtr_MemOP_T_1 ? 3'h1 : _io_memCtr_MemOP_T_8; // @[Mux.scala 101:16]
  assign io_Branch = instJal ? 3'h1 : _io_Branch_T_6; // @[Mux.scala 101:16]
  assign io_immOp = _io_immOp_T_19 ? 3'h0 : _io_immOp_T_32; // @[Mux.scala 101:16]
  assign io_aluCtr_aluA = instAuipc | typeJ; // @[ContrGen.scala 103:35]
  assign io_aluCtr_aluB = _io_aluCtr_aluB_T ? 2'h0 : _io_aluCtr_aluB_T_1; // @[Mux.scala 101:16]
  assign io_aluCtr_aluOp = aluSub ? 4'h8 : _io_aluCtr_aluOp_T_19; // @[Mux.scala 101:16]
  assign io_memCtr_MemtoReg = _io_memCtr_MemtoReg_T_5 ? 2'h1 : _io_memCtr_MemtoReg_T_6; // @[Mux.scala 101:16]
  assign io_memCtr_MemWr = _typeS_T_1 | instSd; // @[ContrGen.scala 174:56]
  assign io_memCtr_MemOP = _io_memCtr_MemOP_T ? 3'h0 : _io_memCtr_MemOP_T_9; // @[Mux.scala 101:16]
  assign io_regCtrl_rs1En = ~(typeU | instJal); // @[ContrGen.scala 151:23]
  assign io_regCtrl_rs2En = _io_aluCtr_aluB_T | typeS; // @[ContrGen.scala 152:40]
  assign io_regCtrl_rs1Addr = Ebreak ? 5'ha : io_inst[19:15]; // @[ContrGen.scala 153:28]
  assign io_regCtrl_rs2Addr = io_inst[24:20]; // @[ContrGen.scala 154:29]
  assign io_regCtrl_rdAddr = wRegEn ? io_inst[11:7] : 5'h0; // @[ContrGen.scala 158:27]
  assign io_regCtrl_rdEn = ~(typeS | typeB | Ebreak); // @[ContrGen.scala 156:16]
endmodule
module Decode(
  input         clock,
  input         reset,
  input  [31:0] io_inst,
  input  [63:0] io_rdData,
  output [2:0]  io_Branch,
  output        io_aluIO_ctrl_aluA,
  output [1:0]  io_aluIO_ctrl_aluB,
  output [3:0]  io_aluIO_ctrl_aluOp,
  output [63:0] io_aluIO_data_rData1,
  output [63:0] io_aluIO_data_rData2,
  output [63:0] io_aluIO_data_imm,
  output [1:0]  io_memCtr_MemtoReg,
  output        io_memCtr_MemWr,
  output [2:0]  io_memCtr_MemOP,
  output [63:0] rf_10
);
  wire  regs_clock; // @[Decode.scala 23:20]
  wire  regs_reset; // @[Decode.scala 23:20]
  wire [63:0] regs_io_rs1Data; // @[Decode.scala 23:20]
  wire [63:0] regs_io_rs2Data; // @[Decode.scala 23:20]
  wire [63:0] regs_io_rdData; // @[Decode.scala 23:20]
  wire  regs_io_ctrl_rs1En; // @[Decode.scala 23:20]
  wire  regs_io_ctrl_rs2En; // @[Decode.scala 23:20]
  wire [4:0] regs_io_ctrl_rs1Addr; // @[Decode.scala 23:20]
  wire [4:0] regs_io_ctrl_rs2Addr; // @[Decode.scala 23:20]
  wire [4:0] regs_io_ctrl_rdAddr; // @[Decode.scala 23:20]
  wire  regs_io_ctrl_rdEn; // @[Decode.scala 23:20]
  wire [63:0] regs_rf_10; // @[Decode.scala 23:20]
  wire [31:0] imm_io_inst; // @[Decode.scala 24:20]
  wire [2:0] imm_io_immOp; // @[Decode.scala 24:20]
  wire [63:0] imm_io_imm; // @[Decode.scala 24:20]
  wire [31:0] con_io_inst; // @[Decode.scala 25:20]
  wire [2:0] con_io_Branch; // @[Decode.scala 25:20]
  wire [2:0] con_io_immOp; // @[Decode.scala 25:20]
  wire  con_io_aluCtr_aluA; // @[Decode.scala 25:20]
  wire [1:0] con_io_aluCtr_aluB; // @[Decode.scala 25:20]
  wire [3:0] con_io_aluCtr_aluOp; // @[Decode.scala 25:20]
  wire [1:0] con_io_memCtr_MemtoReg; // @[Decode.scala 25:20]
  wire  con_io_memCtr_MemWr; // @[Decode.scala 25:20]
  wire [2:0] con_io_memCtr_MemOP; // @[Decode.scala 25:20]
  wire  con_io_regCtrl_rs1En; // @[Decode.scala 25:20]
  wire  con_io_regCtrl_rs2En; // @[Decode.scala 25:20]
  wire [4:0] con_io_regCtrl_rs1Addr; // @[Decode.scala 25:20]
  wire [4:0] con_io_regCtrl_rs2Addr; // @[Decode.scala 25:20]
  wire [4:0] con_io_regCtrl_rdAddr; // @[Decode.scala 25:20]
  wire  con_io_regCtrl_rdEn; // @[Decode.scala 25:20]
  RegFile regs ( // @[Decode.scala 23:20]
    .clock(regs_clock),
    .reset(regs_reset),
    .io_rs1Data(regs_io_rs1Data),
    .io_rs2Data(regs_io_rs2Data),
    .io_rdData(regs_io_rdData),
    .io_ctrl_rs1En(regs_io_ctrl_rs1En),
    .io_ctrl_rs2En(regs_io_ctrl_rs2En),
    .io_ctrl_rs1Addr(regs_io_ctrl_rs1Addr),
    .io_ctrl_rs2Addr(regs_io_ctrl_rs2Addr),
    .io_ctrl_rdAddr(regs_io_ctrl_rdAddr),
    .io_ctrl_rdEn(regs_io_ctrl_rdEn),
    .rf_10(regs_rf_10)
  );
  ImmGen imm ( // @[Decode.scala 24:20]
    .io_inst(imm_io_inst),
    .io_immOp(imm_io_immOp),
    .io_imm(imm_io_imm)
  );
  ContrGen con ( // @[Decode.scala 25:20]
    .io_inst(con_io_inst),
    .io_Branch(con_io_Branch),
    .io_immOp(con_io_immOp),
    .io_aluCtr_aluA(con_io_aluCtr_aluA),
    .io_aluCtr_aluB(con_io_aluCtr_aluB),
    .io_aluCtr_aluOp(con_io_aluCtr_aluOp),
    .io_memCtr_MemtoReg(con_io_memCtr_MemtoReg),
    .io_memCtr_MemWr(con_io_memCtr_MemWr),
    .io_memCtr_MemOP(con_io_memCtr_MemOP),
    .io_regCtrl_rs1En(con_io_regCtrl_rs1En),
    .io_regCtrl_rs2En(con_io_regCtrl_rs2En),
    .io_regCtrl_rs1Addr(con_io_regCtrl_rs1Addr),
    .io_regCtrl_rs2Addr(con_io_regCtrl_rs2Addr),
    .io_regCtrl_rdAddr(con_io_regCtrl_rdAddr),
    .io_regCtrl_rdEn(con_io_regCtrl_rdEn)
  );
  assign io_Branch = con_io_Branch; // @[Decode.scala 40:15]
  assign io_aluIO_ctrl_aluA = con_io_aluCtr_aluA; // @[Decode.scala 35:17]
  assign io_aluIO_ctrl_aluB = con_io_aluCtr_aluB; // @[Decode.scala 35:17]
  assign io_aluIO_ctrl_aluOp = con_io_aluCtr_aluOp; // @[Decode.scala 35:17]
  assign io_aluIO_data_rData1 = regs_io_rs1Data; // @[Decode.scala 36:24]
  assign io_aluIO_data_rData2 = regs_io_rs2Data; // @[Decode.scala 37:24]
  assign io_aluIO_data_imm = imm_io_imm; // @[Decode.scala 38:21]
  assign io_memCtr_MemtoReg = con_io_memCtr_MemtoReg; // @[Decode.scala 34:13]
  assign io_memCtr_MemWr = con_io_memCtr_MemWr; // @[Decode.scala 34:13]
  assign io_memCtr_MemOP = con_io_memCtr_MemOP; // @[Decode.scala 34:13]
  assign rf_10 = regs_rf_10;
  assign regs_clock = clock;
  assign regs_reset = reset;
  assign regs_io_rdData = io_rdData; // @[Decode.scala 28:18]
  assign regs_io_ctrl_rs1En = con_io_regCtrl_rs1En; // @[Decode.scala 27:16]
  assign regs_io_ctrl_rs2En = con_io_regCtrl_rs2En; // @[Decode.scala 27:16]
  assign regs_io_ctrl_rs1Addr = con_io_regCtrl_rs1Addr; // @[Decode.scala 27:16]
  assign regs_io_ctrl_rs2Addr = con_io_regCtrl_rs2Addr; // @[Decode.scala 27:16]
  assign regs_io_ctrl_rdAddr = con_io_regCtrl_rdAddr; // @[Decode.scala 27:16]
  assign regs_io_ctrl_rdEn = con_io_regCtrl_rdEn; // @[Decode.scala 27:16]
  assign imm_io_inst = io_inst; // @[Decode.scala 30:15]
  assign imm_io_immOp = con_io_immOp; // @[Decode.scala 31:16]
  assign con_io_inst = io_inst; // @[Decode.scala 32:15]
endmodule
module ALU(
  input  [1:0]  io_MemtoReg,
  input  [31:0] io_PC,
  output [63:0] io_Result,
  output        io_Less,
  output        io_Zero,
  input         ctrl_aluA,
  input  [1:0]  ctrl_aluB,
  input  [3:0]  ctrl_aluOp,
  input  [63:0] data_rData1,
  input  [63:0] data_rData2,
  input  [63:0] data_imm
);
  wire [63:0] Asrc = ~ctrl_aluA ? data_rData1 : {{32'd0}, io_PC}; // @[ALU.scala 21:20]
  wire [31:0] _in1_T_4 = Asrc[31] ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [63:0] _in1_T_6 = {_in1_T_4,Asrc[31:0]}; // @[Cat.scala 31:58]
  wire [63:0] _in1_T_9 = {32'h0,Asrc[31:0]}; // @[Cat.scala 31:58]
  wire [63:0] _in1_T_10 = ctrl_aluOp == 4'hd ? _in1_T_6 : _in1_T_9; // @[ALU.scala 22:39]
  wire [63:0] in1 = io_MemtoReg[1] ? _in1_T_10 : Asrc; // @[ALU.scala 22:18]
  wire [63:0] _in2_T_1 = 2'h1 == ctrl_aluB ? data_imm : data_rData2; // @[Mux.scala 81:58]
  wire [63:0] _in2_T_3 = 2'h2 == ctrl_aluB ? 64'h4 : _in2_T_1; // @[Mux.scala 81:58]
  wire [63:0] in2 = 2'h3 == ctrl_aluB ? 64'h0 : _in2_T_3; // @[Mux.scala 81:58]
  wire [5:0] shamt = io_MemtoReg[1] ? {{1'd0}, in2[4:0]} : in2[5:0]; // @[ALU.scala 31:20]
  wire [63:0] addRes = in1 + in2; // @[ALU.scala 33:25]
  wire [63:0] subRes = in1 - in2; // @[ALU.scala 34:25]
  wire [63:0] xorRes = in1 ^ in2; // @[ALU.scala 35:25]
  wire [63:0] orRes = in1 | in2; // @[ALU.scala 36:25]
  wire [63:0] andRes = in1 & in2; // @[ALU.scala 37:25]
  wire [126:0] _GEN_0 = {{63'd0}, in1}; // @[ALU.scala 38:28]
  wire [126:0] _sLRes_T = _GEN_0 << shamt; // @[ALU.scala 38:28]
  wire [63:0] sLRes = _sLRes_T[63:0]; // @[ALU.scala 38:37]
  wire [63:0] sRLRes = in1 >> shamt; // @[ALU.scala 39:27]
  wire [63:0] _sRARes_T = io_MemtoReg[1] ? _in1_T_10 : Asrc; // @[ALU.scala 40:33]
  wire [63:0] sRARes = $signed(_sRARes_T) >>> shamt; // @[ALU.scala 40:52]
  wire [63:0] _sLTRes_T_1 = 2'h3 == ctrl_aluB ? 64'h0 : _in2_T_3; // @[ALU.scala 42:48]
  wire  sLTRes = $signed(_sRARes_T) < $signed(_sLTRes_T_1); // @[ALU.scala 42:36]
  wire  sLTURes = in1 < in2; // @[ALU.scala 43:27]
  wire [63:0] remwRes = $signed(_sRARes_T) % $signed(_sLTRes_T_1); // @[ALU.scala 45:48]
  wire [63:0] divRes = in1 / in2; // @[ALU.scala 46:27]
  wire [127:0] mulRes = in1 * in2; // @[ALU.scala 47:27]
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
  wire [31:0] _io_Result_T_4 = aluResult[31] ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [63:0] _io_Result_T_6 = {_io_Result_T_4,aluResult[31:0]}; // @[Cat.scala 31:58]
  wire [127:0] _io_Result_T_7 = io_MemtoReg[1] ? {{64'd0}, _io_Result_T_6} : aluResult; // @[ALU.scala 76:21]
  assign io_Result = _io_Result_T_7[63:0]; // @[ALU.scala 76:15]
  assign io_Less = ctrl_aluOp[3] ? sLTURes : sLTRes; // @[ALU.scala 73:19]
  assign io_Zero = aluResult == 128'h0; // @[ALU.scala 75:27]
endmodule
module DataMem(
  input  [63:0] io_Addr,
  input  [63:0] io_DataIn,
  input  [1:0]  io_memCtr_MemtoReg,
  input         io_memCtr_MemWr,
  input  [2:0]  io_memCtr_MemOP,
  output        io_dmem_en,
  output [63:0] io_dmem_addr,
  input  [63:0] io_dmem_rdata,
  output [63:0] io_dmem_wdata,
  output [63:0] io_dmem_wmask,
  output        io_dmem_wen,
  output [63:0] io_rdData
);
  wire  _io_dmem_en_T_3 = ~(io_Addr < 64'h80000000 | io_Addr > 64'h88000000); // @[DataMem.scala 20:17]
  wire  _io_dmem_en_T_6 = io_memCtr_MemtoReg == 2'h1 | io_memCtr_MemWr; // @[DataMem.scala 21:42]
  wire [63:0] _GEN_0 = io_Addr % 64'h8; // @[DataMem.scala 24:27]
  wire [3:0] alignBits = _GEN_0[3:0]; // @[DataMem.scala 24:27]
  wire [7:0] _io_dmem_wdata_T = alignBits * 4'h8; // @[DataMem.scala 25:43]
  wire [318:0] _GEN_1 = {{255'd0}, io_DataIn}; // @[DataMem.scala 25:30]
  wire [318:0] _io_dmem_wdata_T_1 = _GEN_1 << _io_dmem_wdata_T; // @[DataMem.scala 25:30]
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
  wire [63:0] _io_dmem_wmask_T_21 = alignBits == 4'h0 ? 64'hffffffff : 64'hffffffff00000000; // @[DataMem.scala 41:20]
  wire [63:0] _io_dmem_wmask_T_23 = 3'h0 == io_memCtr_MemOP ? _io_dmem_wmask_T_13 : 64'h0; // @[Mux.scala 81:58]
  wire [63:0] _io_dmem_wmask_T_25 = 3'h1 == io_memCtr_MemOP ? _io_dmem_wmask_T_19 : _io_dmem_wmask_T_23; // @[Mux.scala 81:58]
  wire [63:0] _io_dmem_wmask_T_27 = 3'h2 == io_memCtr_MemOP ? _io_dmem_wmask_T_21 : _io_dmem_wmask_T_25; // @[Mux.scala 81:58]
  wire [63:0] rdata = io_dmem_rdata >> _io_dmem_wdata_T; // @[DataMem.scala 45:29]
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
  wire [63:0] _rData_T_19 = 3'h0 == io_memCtr_MemOP ? _rData_T_3 : 64'h0; // @[Mux.scala 81:58]
  wire [63:0] _rData_T_21 = 3'h1 == io_memCtr_MemOP ? _rData_T_7 : _rData_T_19; // @[Mux.scala 81:58]
  wire [63:0] _rData_T_23 = 3'h2 == io_memCtr_MemOP ? _rData_T_11 : _rData_T_21; // @[Mux.scala 81:58]
  wire [63:0] _rData_T_25 = 3'h3 == io_memCtr_MemOP ? rdata : _rData_T_23; // @[Mux.scala 81:58]
  wire [63:0] _rData_T_27 = 3'h4 == io_memCtr_MemOP ? _rData_T_13 : _rData_T_25; // @[Mux.scala 81:58]
  wire [63:0] _rData_T_29 = 3'h5 == io_memCtr_MemOP ? _rData_T_15 : _rData_T_27; // @[Mux.scala 81:58]
  wire [63:0] rData = 3'h6 == io_memCtr_MemOP ? _rData_T_17 : _rData_T_29; // @[Mux.scala 81:58]
  assign io_dmem_en = ~(io_Addr < 64'h80000000 | io_Addr > 64'h88000000) & _io_dmem_en_T_6; // @[DataMem.scala 20:73]
  assign io_dmem_addr = io_Addr; // @[DataMem.scala 22:16]
  assign io_dmem_wdata = _io_dmem_wdata_T_1[63:0]; // @[DataMem.scala 25:17]
  assign io_dmem_wmask = 3'h3 == io_memCtr_MemOP ? 64'hffffffffffffffff : _io_dmem_wmask_T_27; // @[Mux.scala 81:58]
  assign io_dmem_wen = _io_dmem_en_T_3 & io_memCtr_MemWr; // @[DataMem.scala 23:74]
  assign io_rdData = io_memCtr_MemWr ? 64'h0 : rData; // @[DataMem.scala 55:19]
endmodule
module NextPC(
  input  [31:0] io_PC,
  input  [63:0] io_Imm,
  input  [63:0] io_Rs1,
  input  [2:0]  io_Branch,
  input         io_Less,
  input         io_Zero,
  output [31:0] io_NextPC
);
  wire  less = io_Branch == 3'h7 ? ~io_Less : io_Less; // @[NextPC.scala 21:17]
  wire [3:0] _PCsrc_T_1 = {io_Branch,io_Zero}; // @[NextPC.scala 24:43]
  wire [3:0] _PCsrc_T_7 = {io_Branch,less}; // @[NextPC.scala 25:20]
  wire  _PCsrc_T_8 = _PCsrc_T_7 == 4'hc; // @[NextPC.scala 25:28]
  wire  _PCsrc_T_9 = io_Branch == 3'h0 | _PCsrc_T_1 == 4'h8 | _PCsrc_T_1 == 4'hb | _PCsrc_T_8; // @[NextPC.scala 24:109]
  wire  _PCsrc_T_12 = _PCsrc_T_9 | _PCsrc_T_7 == 4'he; // @[NextPC.scala 25:43]
  wire  _PCsrc_T_21 = _PCsrc_T_7 == 4'hd; // @[NextPC.scala 27:28]
  wire  _PCsrc_T_22 = io_Branch == 3'h1 | _PCsrc_T_1 == 4'h9 | _PCsrc_T_1 == 4'ha | _PCsrc_T_21; // @[NextPC.scala 26:108]
  wire  _PCsrc_T_25 = _PCsrc_T_22 | _PCsrc_T_7 == 4'hf; // @[NextPC.scala 27:43]
  wire  _PCsrc_T_26 = io_Branch == 3'h2; // @[NextPC.scala 28:16]
  wire [1:0] _PCsrc_T_27 = _PCsrc_T_26 ? 2'h3 : 2'h1; // @[Mux.scala 101:16]
  wire [1:0] _PCsrc_T_28 = _PCsrc_T_25 ? 2'h2 : _PCsrc_T_27; // @[Mux.scala 101:16]
  wire [1:0] PCsrc = _PCsrc_T_12 ? 2'h0 : _PCsrc_T_28; // @[Mux.scala 101:16]
  wire [31:0] _io_NextPC_T_1 = io_PC + 32'h4; // @[NextPC.scala 32:23]
  wire [63:0] _GEN_0 = {{32'd0}, io_PC}; // @[NextPC.scala 33:23]
  wire [63:0] _io_NextPC_T_3 = _GEN_0 + io_Imm; // @[NextPC.scala 33:23]
  wire [63:0] _io_NextPC_T_5 = io_Rs1 + io_Imm; // @[NextPC.scala 34:24]
  wire [31:0] _io_NextPC_T_7 = 2'h0 == PCsrc ? _io_NextPC_T_1 : 32'h80000000; // @[Mux.scala 81:58]
  wire [63:0] _io_NextPC_T_9 = 2'h2 == PCsrc ? _io_NextPC_T_3 : {{32'd0}, _io_NextPC_T_7}; // @[Mux.scala 81:58]
  wire [63:0] _io_NextPC_T_11 = 2'h3 == PCsrc ? _io_NextPC_T_5 : _io_NextPC_T_9; // @[Mux.scala 81:58]
  assign io_NextPC = _io_NextPC_T_11[31:0]; // @[NextPC.scala 31:13]
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
  reg [63:0] _RAND_3;
  reg [63:0] _RAND_4;
  reg [63:0] _RAND_5;
  reg [63:0] _RAND_6;
`endif // RANDOMIZE_REG_INIT
  wire  fetch_clock; // @[Core.scala 12:21]
  wire  fetch_reset; // @[Core.scala 12:21]
  wire [63:0] fetch_io_imem_addr; // @[Core.scala 12:21]
  wire [63:0] fetch_io_imem_rdata; // @[Core.scala 12:21]
  wire [31:0] fetch_io_nextPC; // @[Core.scala 12:21]
  wire [31:0] fetch_io_pc; // @[Core.scala 12:21]
  wire [31:0] fetch_io_inst; // @[Core.scala 12:21]
  wire  decode_clock; // @[Core.scala 13:22]
  wire  decode_reset; // @[Core.scala 13:22]
  wire [31:0] decode_io_inst; // @[Core.scala 13:22]
  wire [63:0] decode_io_rdData; // @[Core.scala 13:22]
  wire [2:0] decode_io_Branch; // @[Core.scala 13:22]
  wire  decode_io_aluIO_ctrl_aluA; // @[Core.scala 13:22]
  wire [1:0] decode_io_aluIO_ctrl_aluB; // @[Core.scala 13:22]
  wire [3:0] decode_io_aluIO_ctrl_aluOp; // @[Core.scala 13:22]
  wire [63:0] decode_io_aluIO_data_rData1; // @[Core.scala 13:22]
  wire [63:0] decode_io_aluIO_data_rData2; // @[Core.scala 13:22]
  wire [63:0] decode_io_aluIO_data_imm; // @[Core.scala 13:22]
  wire [1:0] decode_io_memCtr_MemtoReg; // @[Core.scala 13:22]
  wire  decode_io_memCtr_MemWr; // @[Core.scala 13:22]
  wire [2:0] decode_io_memCtr_MemOP; // @[Core.scala 13:22]
  wire [63:0] decode_rf_10; // @[Core.scala 13:22]
  wire [1:0] alu_io_MemtoReg; // @[Core.scala 14:23]
  wire [31:0] alu_io_PC; // @[Core.scala 14:23]
  wire [63:0] alu_io_Result; // @[Core.scala 14:23]
  wire  alu_io_Less; // @[Core.scala 14:23]
  wire  alu_io_Zero; // @[Core.scala 14:23]
  wire  alu_ctrl_aluA; // @[Core.scala 14:23]
  wire [1:0] alu_ctrl_aluB; // @[Core.scala 14:23]
  wire [3:0] alu_ctrl_aluOp; // @[Core.scala 14:23]
  wire [63:0] alu_data_rData1; // @[Core.scala 14:23]
  wire [63:0] alu_data_rData2; // @[Core.scala 14:23]
  wire [63:0] alu_data_imm; // @[Core.scala 14:23]
  wire [63:0] dataMem_io_Addr; // @[Core.scala 15:23]
  wire [63:0] dataMem_io_DataIn; // @[Core.scala 15:23]
  wire [1:0] dataMem_io_memCtr_MemtoReg; // @[Core.scala 15:23]
  wire  dataMem_io_memCtr_MemWr; // @[Core.scala 15:23]
  wire [2:0] dataMem_io_memCtr_MemOP; // @[Core.scala 15:23]
  wire  dataMem_io_dmem_en; // @[Core.scala 15:23]
  wire [63:0] dataMem_io_dmem_addr; // @[Core.scala 15:23]
  wire [63:0] dataMem_io_dmem_rdata; // @[Core.scala 15:23]
  wire [63:0] dataMem_io_dmem_wdata; // @[Core.scala 15:23]
  wire [63:0] dataMem_io_dmem_wmask; // @[Core.scala 15:23]
  wire  dataMem_io_dmem_wen; // @[Core.scala 15:23]
  wire [63:0] dataMem_io_rdData; // @[Core.scala 15:23]
  wire [31:0] nextpc_io_PC; // @[Core.scala 16:23]
  wire [63:0] nextpc_io_Imm; // @[Core.scala 16:23]
  wire [63:0] nextpc_io_Rs1; // @[Core.scala 16:23]
  wire [2:0] nextpc_io_Branch; // @[Core.scala 16:23]
  wire  nextpc_io_Less; // @[Core.scala 16:23]
  wire  nextpc_io_Zero; // @[Core.scala 16:23]
  wire [31:0] nextpc_io_NextPC; // @[Core.scala 16:23]
  wire  dt_ic_clock; // @[Core.scala 52:21]
  wire [7:0] dt_ic_coreid; // @[Core.scala 52:21]
  wire [7:0] dt_ic_index; // @[Core.scala 52:21]
  wire  dt_ic_valid; // @[Core.scala 52:21]
  wire [63:0] dt_ic_pc; // @[Core.scala 52:21]
  wire [31:0] dt_ic_instr; // @[Core.scala 52:21]
  wire  dt_ic_skip; // @[Core.scala 52:21]
  wire  dt_ic_isRVC; // @[Core.scala 52:21]
  wire  dt_ic_scFailed; // @[Core.scala 52:21]
  wire  dt_ic_wen; // @[Core.scala 52:21]
  wire [63:0] dt_ic_wdata; // @[Core.scala 52:21]
  wire [7:0] dt_ic_wdest; // @[Core.scala 52:21]
  wire  dt_ae_clock; // @[Core.scala 66:21]
  wire [7:0] dt_ae_coreid; // @[Core.scala 66:21]
  wire [31:0] dt_ae_intrNO; // @[Core.scala 66:21]
  wire [31:0] dt_ae_cause; // @[Core.scala 66:21]
  wire [63:0] dt_ae_exceptionPC; // @[Core.scala 66:21]
  wire [31:0] dt_ae_exceptionInst; // @[Core.scala 66:21]
  wire  dt_te_clock; // @[Core.scala 82:21]
  wire [7:0] dt_te_coreid; // @[Core.scala 82:21]
  wire  dt_te_valid; // @[Core.scala 82:21]
  wire [2:0] dt_te_code; // @[Core.scala 82:21]
  wire [63:0] dt_te_pc; // @[Core.scala 82:21]
  wire [63:0] dt_te_cycleCnt; // @[Core.scala 82:21]
  wire [63:0] dt_te_instrCnt; // @[Core.scala 82:21]
  wire  dt_cs_clock; // @[Core.scala 91:21]
  wire [7:0] dt_cs_coreid; // @[Core.scala 91:21]
  wire [1:0] dt_cs_priviledgeMode; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mstatus; // @[Core.scala 91:21]
  wire [63:0] dt_cs_sstatus; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mepc; // @[Core.scala 91:21]
  wire [63:0] dt_cs_sepc; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mtval; // @[Core.scala 91:21]
  wire [63:0] dt_cs_stval; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mtvec; // @[Core.scala 91:21]
  wire [63:0] dt_cs_stvec; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mcause; // @[Core.scala 91:21]
  wire [63:0] dt_cs_scause; // @[Core.scala 91:21]
  wire [63:0] dt_cs_satp; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mip; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mie; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mscratch; // @[Core.scala 91:21]
  wire [63:0] dt_cs_sscratch; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mideleg; // @[Core.scala 91:21]
  wire [63:0] dt_cs_medeleg; // @[Core.scala 91:21]
  wire  InstResW_signBit = alu_io_Result[31]; // @[BitUtils.scala 18:20]
  wire [31:0] _InstResW_T_2 = InstResW_signBit ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [63:0] InstResW = {_InstResW_T_2,alu_io_Result[31:0]}; // @[Cat.scala 31:58]
  wire [63:0] _wData_T_1 = 2'h0 == decode_io_memCtr_MemtoReg ? alu_io_Result : 64'h0; // @[Mux.scala 81:58]
  wire [63:0] _wData_T_3 = 2'h1 == decode_io_memCtr_MemtoReg ? dataMem_io_rdData : _wData_T_1; // @[Mux.scala 81:58]
  reg [31:0] dt_ic_io_pc_REG; // @[Core.scala 57:31]
  reg [31:0] dt_ic_io_instr_REG; // @[Core.scala 58:31]
  reg  dt_ic_io_wen_REG; // @[Core.scala 62:31]
  reg [63:0] dt_ic_io_wdata_REG; // @[Core.scala 63:31]
  reg [63:0] dt_ic_io_wdest_REG; // @[Core.scala 64:31]
  reg [63:0] cycle_cnt; // @[Core.scala 73:26]
  reg [63:0] instr_cnt; // @[Core.scala 74:26]
  wire [63:0] _cycle_cnt_T_1 = cycle_cnt + 64'h1; // @[Core.scala 76:26]
  wire [63:0] _instr_cnt_T_1 = instr_cnt + 64'h1; // @[Core.scala 77:26]
  wire [63:0] rf_a0_0 = decode_rf_10;
  InstFetch fetch ( // @[Core.scala 12:21]
    .clock(fetch_clock),
    .reset(fetch_reset),
    .io_imem_addr(fetch_io_imem_addr),
    .io_imem_rdata(fetch_io_imem_rdata),
    .io_nextPC(fetch_io_nextPC),
    .io_pc(fetch_io_pc),
    .io_inst(fetch_io_inst)
  );
  Decode decode ( // @[Core.scala 13:22]
    .clock(decode_clock),
    .reset(decode_reset),
    .io_inst(decode_io_inst),
    .io_rdData(decode_io_rdData),
    .io_Branch(decode_io_Branch),
    .io_aluIO_ctrl_aluA(decode_io_aluIO_ctrl_aluA),
    .io_aluIO_ctrl_aluB(decode_io_aluIO_ctrl_aluB),
    .io_aluIO_ctrl_aluOp(decode_io_aluIO_ctrl_aluOp),
    .io_aluIO_data_rData1(decode_io_aluIO_data_rData1),
    .io_aluIO_data_rData2(decode_io_aluIO_data_rData2),
    .io_aluIO_data_imm(decode_io_aluIO_data_imm),
    .io_memCtr_MemtoReg(decode_io_memCtr_MemtoReg),
    .io_memCtr_MemWr(decode_io_memCtr_MemWr),
    .io_memCtr_MemOP(decode_io_memCtr_MemOP),
    .rf_10(decode_rf_10)
  );
  ALU alu ( // @[Core.scala 14:23]
    .io_MemtoReg(alu_io_MemtoReg),
    .io_PC(alu_io_PC),
    .io_Result(alu_io_Result),
    .io_Less(alu_io_Less),
    .io_Zero(alu_io_Zero),
    .ctrl_aluA(alu_ctrl_aluA),
    .ctrl_aluB(alu_ctrl_aluB),
    .ctrl_aluOp(alu_ctrl_aluOp),
    .data_rData1(alu_data_rData1),
    .data_rData2(alu_data_rData2),
    .data_imm(alu_data_imm)
  );
  DataMem dataMem ( // @[Core.scala 15:23]
    .io_Addr(dataMem_io_Addr),
    .io_DataIn(dataMem_io_DataIn),
    .io_memCtr_MemtoReg(dataMem_io_memCtr_MemtoReg),
    .io_memCtr_MemWr(dataMem_io_memCtr_MemWr),
    .io_memCtr_MemOP(dataMem_io_memCtr_MemOP),
    .io_dmem_en(dataMem_io_dmem_en),
    .io_dmem_addr(dataMem_io_dmem_addr),
    .io_dmem_rdata(dataMem_io_dmem_rdata),
    .io_dmem_wdata(dataMem_io_dmem_wdata),
    .io_dmem_wmask(dataMem_io_dmem_wmask),
    .io_dmem_wen(dataMem_io_dmem_wen),
    .io_rdData(dataMem_io_rdData)
  );
  NextPC nextpc ( // @[Core.scala 16:23]
    .io_PC(nextpc_io_PC),
    .io_Imm(nextpc_io_Imm),
    .io_Rs1(nextpc_io_Rs1),
    .io_Branch(nextpc_io_Branch),
    .io_Less(nextpc_io_Less),
    .io_Zero(nextpc_io_Zero),
    .io_NextPC(nextpc_io_NextPC)
  );
  DifftestInstrCommit dt_ic ( // @[Core.scala 52:21]
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
  DifftestArchEvent dt_ae ( // @[Core.scala 66:21]
    .clock(dt_ae_clock),
    .coreid(dt_ae_coreid),
    .intrNO(dt_ae_intrNO),
    .cause(dt_ae_cause),
    .exceptionPC(dt_ae_exceptionPC),
    .exceptionInst(dt_ae_exceptionInst)
  );
  DifftestTrapEvent dt_te ( // @[Core.scala 82:21]
    .clock(dt_te_clock),
    .coreid(dt_te_coreid),
    .valid(dt_te_valid),
    .code(dt_te_code),
    .pc(dt_te_pc),
    .cycleCnt(dt_te_cycleCnt),
    .instrCnt(dt_te_instrCnt)
  );
  DifftestCSRState dt_cs ( // @[Core.scala 91:21]
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
  assign io_imem_addr = fetch_io_imem_addr; // @[Core.scala 27:17]
  assign io_dmem_en = dataMem_io_dmem_en; // @[Core.scala 40:19]
  assign io_dmem_addr = dataMem_io_dmem_addr; // @[Core.scala 40:19]
  assign io_dmem_wdata = dataMem_io_dmem_wdata; // @[Core.scala 40:19]
  assign io_dmem_wmask = dataMem_io_dmem_wmask; // @[Core.scala 40:19]
  assign io_dmem_wen = dataMem_io_dmem_wen; // @[Core.scala 40:19]
  assign fetch_clock = clock;
  assign fetch_reset = reset;
  assign fetch_io_imem_rdata = io_imem_rdata; // @[Core.scala 27:17]
  assign fetch_io_nextPC = nextpc_io_NextPC; // @[Core.scala 28:19]
  assign decode_clock = clock;
  assign decode_reset = reset;
  assign decode_io_inst = fetch_io_inst; // @[Core.scala 30:18]
  assign decode_io_rdData = 2'h2 == decode_io_memCtr_MemtoReg ? InstResW : _wData_T_3; // @[Mux.scala 81:58]
  assign alu_io_MemtoReg = decode_io_memCtr_MemtoReg; // @[Core.scala 35:19]
  assign alu_io_PC = fetch_io_pc; // @[Core.scala 33:13]
  assign alu_ctrl_aluA = decode_io_aluIO_ctrl_aluA; // @[Core.scala 34:13]
  assign alu_ctrl_aluB = decode_io_aluIO_ctrl_aluB; // @[Core.scala 34:13]
  assign alu_ctrl_aluOp = decode_io_aluIO_ctrl_aluOp; // @[Core.scala 34:13]
  assign alu_data_rData1 = decode_io_aluIO_data_rData1; // @[Core.scala 34:13]
  assign alu_data_rData2 = decode_io_aluIO_data_rData2; // @[Core.scala 34:13]
  assign alu_data_imm = decode_io_aluIO_data_imm; // @[Core.scala 34:13]
  assign dataMem_io_Addr = alu_io_Result; // @[Core.scala 37:21]
  assign dataMem_io_DataIn = decode_io_aluIO_data_rData2; // @[Core.scala 38:21]
  assign dataMem_io_memCtr_MemtoReg = decode_io_memCtr_MemtoReg; // @[Core.scala 39:21]
  assign dataMem_io_memCtr_MemWr = decode_io_memCtr_MemWr; // @[Core.scala 39:21]
  assign dataMem_io_memCtr_MemOP = decode_io_memCtr_MemOP; // @[Core.scala 39:21]
  assign dataMem_io_dmem_rdata = io_dmem_rdata; // @[Core.scala 40:19]
  assign nextpc_io_PC = fetch_io_pc; // @[Core.scala 42:20]
  assign nextpc_io_Imm = decode_io_aluIO_data_imm; // @[Core.scala 43:20]
  assign nextpc_io_Rs1 = decode_io_aluIO_data_rData1; // @[Core.scala 44:20]
  assign nextpc_io_Branch = decode_io_Branch; // @[Core.scala 45:20]
  assign nextpc_io_Less = alu_io_Less; // @[Core.scala 46:20]
  assign nextpc_io_Zero = alu_io_Zero; // @[Core.scala 47:20]
  assign dt_ic_clock = clock; // @[Core.scala 53:21]
  assign dt_ic_coreid = 8'h0; // @[Core.scala 54:21]
  assign dt_ic_index = 8'h0; // @[Core.scala 55:21]
  assign dt_ic_valid = 1'h1; // @[Core.scala 56:21]
  assign dt_ic_pc = {{32'd0}, dt_ic_io_pc_REG}; // @[Core.scala 57:21]
  assign dt_ic_instr = dt_ic_io_instr_REG; // @[Core.scala 58:21]
  assign dt_ic_skip = 1'h0; // @[Core.scala 59:21]
  assign dt_ic_isRVC = 1'h0; // @[Core.scala 60:21]
  assign dt_ic_scFailed = 1'h0; // @[Core.scala 61:21]
  assign dt_ic_wen = dt_ic_io_wen_REG; // @[Core.scala 62:21]
  assign dt_ic_wdata = dt_ic_io_wdata_REG; // @[Core.scala 63:21]
  assign dt_ic_wdest = dt_ic_io_wdest_REG[7:0]; // @[Core.scala 64:21]
  assign dt_ae_clock = clock; // @[Core.scala 67:25]
  assign dt_ae_coreid = 8'h0; // @[Core.scala 68:25]
  assign dt_ae_intrNO = 32'h0; // @[Core.scala 69:25]
  assign dt_ae_cause = 32'h0; // @[Core.scala 70:25]
  assign dt_ae_exceptionPC = 64'h0; // @[Core.scala 71:25]
  assign dt_ae_exceptionInst = 32'h0;
  assign dt_te_clock = clock; // @[Core.scala 83:21]
  assign dt_te_coreid = 8'h0; // @[Core.scala 84:21]
  assign dt_te_valid = fetch_io_inst == 32'h6b; // @[Core.scala 85:39]
  assign dt_te_code = rf_a0_0[2:0]; // @[Core.scala 86:29]
  assign dt_te_pc = {{32'd0}, fetch_io_pc}; // @[Core.scala 87:21]
  assign dt_te_cycleCnt = cycle_cnt; // @[Core.scala 88:21]
  assign dt_te_instrCnt = instr_cnt; // @[Core.scala 89:21]
  assign dt_cs_clock = clock; // @[Core.scala 92:27]
  assign dt_cs_coreid = 8'h0; // @[Core.scala 93:27]
  assign dt_cs_priviledgeMode = 2'h3; // @[Core.scala 94:27]
  assign dt_cs_mstatus = 64'h0; // @[Core.scala 95:27]
  assign dt_cs_sstatus = 64'h0; // @[Core.scala 96:27]
  assign dt_cs_mepc = 64'h0; // @[Core.scala 97:27]
  assign dt_cs_sepc = 64'h0; // @[Core.scala 98:27]
  assign dt_cs_mtval = 64'h0; // @[Core.scala 99:27]
  assign dt_cs_stval = 64'h0; // @[Core.scala 100:27]
  assign dt_cs_mtvec = 64'h0; // @[Core.scala 101:27]
  assign dt_cs_stvec = 64'h0; // @[Core.scala 102:27]
  assign dt_cs_mcause = 64'h0; // @[Core.scala 103:27]
  assign dt_cs_scause = 64'h0; // @[Core.scala 104:27]
  assign dt_cs_satp = 64'h0; // @[Core.scala 105:27]
  assign dt_cs_mip = 64'h0; // @[Core.scala 106:27]
  assign dt_cs_mie = 64'h0; // @[Core.scala 107:27]
  assign dt_cs_mscratch = 64'h0; // @[Core.scala 108:27]
  assign dt_cs_sscratch = 64'h0; // @[Core.scala 109:27]
  assign dt_cs_mideleg = 64'h0; // @[Core.scala 110:27]
  assign dt_cs_medeleg = 64'h0; // @[Core.scala 111:27]
  always @(posedge clock) begin
    dt_ic_io_pc_REG <= fetch_io_pc; // @[Core.scala 57:31]
    dt_ic_io_instr_REG <= fetch_io_inst; // @[Core.scala 58:31]
    dt_ic_io_wen_REG <= dataMem_io_dmem_wen; // @[Core.scala 62:31]
    dt_ic_io_wdata_REG <= dataMem_io_dmem_wdata; // @[Core.scala 63:31]
    dt_ic_io_wdest_REG <= dataMem_io_dmem_addr; // @[Core.scala 64:31]
    if (reset) begin // @[Core.scala 73:26]
      cycle_cnt <= 64'h0; // @[Core.scala 73:26]
    end else begin
      cycle_cnt <= _cycle_cnt_T_1; // @[Core.scala 76:13]
    end
    if (reset) begin // @[Core.scala 74:26]
      instr_cnt <= 64'h0; // @[Core.scala 74:26]
    end else begin
      instr_cnt <= _instr_cnt_T_1; // @[Core.scala 77:13]
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
  _RAND_4 = {2{`RANDOM}};
  dt_ic_io_wdest_REG = _RAND_4[63:0];
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
  output [63:0] io_imem_rdata,
  input         io_dmem_en,
  input  [63:0] io_dmem_addr,
  output [63:0] io_dmem_rdata,
  input  [63:0] io_dmem_wdata,
  input  [63:0] io_dmem_wmask,
  input         io_dmem_wen
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
  assign io_dmem_rdata = mem_dmem_rdata; // @[Ram.scala 44:21]
  assign mem_clk = clock; // @[Ram.scala 38:21]
  assign mem_imem_en = 1'h1; // @[Ram.scala 39:21]
  assign mem_imem_addr = io_imem_addr; // @[Ram.scala 40:21]
  assign mem_dmem_en = io_dmem_en; // @[Ram.scala 42:21]
  assign mem_dmem_addr = io_dmem_addr; // @[Ram.scala 43:21]
  assign mem_dmem_wdata = io_dmem_wdata; // @[Ram.scala 45:21]
  assign mem_dmem_wmask = io_dmem_wmask; // @[Ram.scala 46:21]
  assign mem_dmem_wen = io_dmem_wen; // @[Ram.scala 47:21]
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
  wire  core_io_dmem_en; // @[SimTop.scala 12:20]
  wire [63:0] core_io_dmem_addr; // @[SimTop.scala 12:20]
  wire [63:0] core_io_dmem_rdata; // @[SimTop.scala 12:20]
  wire [63:0] core_io_dmem_wdata; // @[SimTop.scala 12:20]
  wire [63:0] core_io_dmem_wmask; // @[SimTop.scala 12:20]
  wire  core_io_dmem_wen; // @[SimTop.scala 12:20]
  wire  mem_clock; // @[SimTop.scala 14:19]
  wire [63:0] mem_io_imem_addr; // @[SimTop.scala 14:19]
  wire [63:0] mem_io_imem_rdata; // @[SimTop.scala 14:19]
  wire  mem_io_dmem_en; // @[SimTop.scala 14:19]
  wire [63:0] mem_io_dmem_addr; // @[SimTop.scala 14:19]
  wire [63:0] mem_io_dmem_rdata; // @[SimTop.scala 14:19]
  wire [63:0] mem_io_dmem_wdata; // @[SimTop.scala 14:19]
  wire [63:0] mem_io_dmem_wmask; // @[SimTop.scala 14:19]
  wire  mem_io_dmem_wen; // @[SimTop.scala 14:19]
  Core core ( // @[SimTop.scala 12:20]
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
  Ram2r1w mem ( // @[SimTop.scala 14:19]
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
  assign io_uart_out_valid = 1'h0; // @[SimTop.scala 18:21]
  assign io_uart_out_ch = 8'h0; // @[SimTop.scala 19:18]
  assign io_uart_in_valid = 1'h0; // @[SimTop.scala 20:20]
  assign core_clock = clock;
  assign core_reset = reset;
  assign core_io_imem_rdata = mem_io_imem_rdata; // @[SimTop.scala 15:15]
  assign core_io_dmem_rdata = mem_io_dmem_rdata; // @[SimTop.scala 16:15]
  assign mem_clock = clock;
  assign mem_io_imem_addr = core_io_imem_addr; // @[SimTop.scala 15:15]
  assign mem_io_dmem_en = core_io_dmem_en; // @[SimTop.scala 16:15]
  assign mem_io_dmem_addr = core_io_dmem_addr; // @[SimTop.scala 16:15]
  assign mem_io_dmem_wdata = core_io_dmem_wdata; // @[SimTop.scala 16:15]
  assign mem_io_dmem_wmask = core_io_dmem_wmask; // @[SimTop.scala 16:15]
  assign mem_io_dmem_wen = core_io_dmem_wen; // @[SimTop.scala 16:15]
endmodule
