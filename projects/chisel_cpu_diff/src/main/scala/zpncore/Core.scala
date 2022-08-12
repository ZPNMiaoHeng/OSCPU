import chisel3._
import chisel3.util.experimental._
import difftest._
import utils._

class Core extends Module {
  val io = IO(new Bundle {
    val imem = new CoreInst
//    val imem = new RomIO
    val dmem = new RamIO
  })
  
  val IF = Module(new InstFetch)
  val IfRegId = Module(new PipelineReg)
  val ID = Module(new Decode)
  val IdRegEx = Module(new PipelineReg)
  val EX = Module(new Execution)
  val ExRegMem = Module(new PipelineReg)
  val MEM = Module(new DataMem)
  val MemRegWb = Module(new PipelineReg)
  val WB = Module(new WriteBack)
//*-----------------------------------------------------------------
// EX阶段L型指令与ID阶段指令发生数据冒险--暂停IF/ID与取指，flush ID/EX
  val EXLHitID = ID.io.bubbleId && EX.io.bubbleEx
// 判断IF是否从总线上取出指令（IF结束），若未完成，暂停流水线
  val AXIIFDone = !IF.io.IFDone

//* ----------------------------------------------------------------
  val flushIfIdEn = false.B
  val flushIdExEn = Mux(EX.io.pcSrc =/= 0.U, true.B, false.B) || EXLHitID
  val flushExMemEn = false.B
  val flushMemWbEn = false.B

  val stallIfIdEn = EXLHitID || AXIIFDone
  val stallIdExEn = AXIIFDone
  val stallExMemEn = AXIIFDone
  val stallMemWbEn = AXIIFDone
//------------------- IF --------------------------------
//  IF.io.imem <> io.imem

  io.imem.inst_valid := IF.io.imem.inst_valid
  io.imem.inst_req := IF.io.imem.inst_req                                // request signals:1 -> true
  io.imem.inst_addr := IF.io.imem.inst_addr
  io.imem.inst_size := IF.io.imem.inst_size

  IF.io.imem.inst_read := io.imem.inst_read
  IF.io.imem.inst_ready := io.imem.inst_ready
  
  IF.io.pcSrc := EX.io.pcSrc
  IF.io.nextPC := EX.io.nextPC
  IF.io.stall := EXLHitID

  IfRegId.io.in <> IF.io.out
  IfRegId.io.stall := stallIfIdEn
  IfRegId.io.flush := flushIfIdEn
//------------------- ID --------------------------------
  ID.io.in <> IfRegId.io.out
  ID.io.rdEn := WB.io.rdEn
  ID.io.rdAddr := WB.io.rdAddr
  ID.io.rdData := WB.io.rdData
//* Bypass
  ID.io.exeRdEn := EX.io.exeRdEn
  ID.io.exeRdAddr := EX.io.exeRdAddr
  ID.io.exeRdData := EX.io.exeRdData
  ID.io.memRdEn := MEM.io.memRdEn
  ID.io.memRdAddr := MEM.io.memRdAddr
  ID.io.memRdData := MEM.io.memRdData
  ID.io.wbRdEn := WB.io.wbRdEn
  ID.io.wbRdAddr := WB.io.wbRdAddr
  ID.io.wbRdData := WB.io.wbRdData

  IdRegEx.io.in <> ID.io.out
  IdRegEx.io.stall := stallIdExEn
  IdRegEx.io.flush := flushIdExEn
//------------------- EX --------------------------------
  EX.io.in <> IdRegEx.io.out

  ExRegMem.io.in <> EX.io.out
  ExRegMem.io.stall := stallExMemEn
  ExRegMem.io.flush := flushExMemEn
//------------------- MEM -------------------------------
  MEM.io.in <> ExRegMem.io.out
  MEM.io.dmem <> io.dmem

  MemRegWb.io.in <> MEM.io.out
  MemRegWb.io.stall := stallMemWbEn
  MemRegWb.io.flush := flushMemWbEn
//------------------- WB ---------------------------------
  WB.io.in <> MemRegWb.io.out

  /* ----- Difftest ------------------------------ */
  val valid = WB.io.ready_cmt   // && !stallEn

  val dt_ic = Module(new DifftestInstrCommit)
  dt_ic.io.clock    := clock
  dt_ic.io.coreid   := 0.U
  dt_ic.io.index    := 0.U
  dt_ic.io.valid    := RegNext(valid)
  dt_ic.io.pc       := RegNext(WB.io.pc)
  dt_ic.io.instr    := RegNext(WB.io.inst)
  dt_ic.io.skip     := false.B
  dt_ic.io.isRVC    := false.B
  dt_ic.io.scFailed := false.B
  dt_ic.io.wen      := RegNext(WB.io.rdEn)
  dt_ic.io.wdata    := RegNext(WB.io.rdData)
  dt_ic.io.wdest    := RegNext(WB.io.rdAddr)

  val dt_ae = Module(new DifftestArchEvent)
  dt_ae.io.clock        := clock
  dt_ae.io.coreid       := 0.U
  dt_ae.io.intrNO       := 0.U
  dt_ae.io.cause        := 0.U
  dt_ae.io.exceptionPC  := 0.U

  val cycle_cnt = RegInit(0.U(64.W))
  val instr_cnt = RegInit(0.U(64.W))

  cycle_cnt := cycle_cnt + 1.U
  instr_cnt := instr_cnt + 1.U

  val rf_a0 = WireInit(0.U(64.W))
  BoringUtils.addSink(rf_a0, "rf_a0")

  val dt_te = Module(new DifftestTrapEvent)
  dt_te.io.clock    := clock
  dt_te.io.coreid   := 0.U
  dt_te.io.valid    := (WB.io.inst === "h0000006b".U)
  dt_te.io.code     := rf_a0(2, 0)
  dt_te.io.pc       := WB.io.pc
  dt_te.io.cycleCnt := cycle_cnt
  dt_te.io.instrCnt := instr_cnt

  val dt_cs = Module(new DifftestCSRState)
  dt_cs.io.clock          := clock
  dt_cs.io.coreid         := 0.U
  dt_cs.io.priviledgeMode := 3.U  // Machine mode
  dt_cs.io.mstatus        := 0.U
  dt_cs.io.sstatus        := 0.U
  dt_cs.io.mepc           := 0.U
  dt_cs.io.sepc           := 0.U
  dt_cs.io.mtval          := 0.U
  dt_cs.io.stval          := 0.U
  dt_cs.io.mtvec          := 0.U
  dt_cs.io.stvec          := 0.U
  dt_cs.io.mcause         := 0.U
  dt_cs.io.scause         := 0.U
  dt_cs.io.satp           := 0.U
  dt_cs.io.mip            := 0.U
  dt_cs.io.mie            := 0.U
  dt_cs.io.mscratch       := 0.U
  dt_cs.io.sscratch       := 0.U
  dt_cs.io.mideleg        := 0.U
  dt_cs.io.medeleg        := 0.U
}
