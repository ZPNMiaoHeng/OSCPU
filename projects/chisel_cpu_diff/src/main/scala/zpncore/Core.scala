import chisel3._
import chisel3.util.experimental._
import difftest._
import utils._

class Core extends Module {
  val io = IO(new Bundle {
    val imem = new RomIO  
    val dmem = new RamIO
  })
  
  val fetch = Module(new InstFetch)
  val IfRegId = Module(new PipelineReg)
  val decode = Module(new Decode)
  val IdRegEx = Module(new PipelineReg)
  val ex = Module(new Execution)
  val ExRegMem = Module(new PipelineReg)
  val mem = Module(new DataMem)
  val MemRegWb = Module(new PipelineReg)
  val wb = Module(new WriteBack)

  val stallEn = decode.io.bubbleId && ex.io.bubbleEx
//* ----------------------------------------------------------------
  val flushIfIdEn = false.B
  val flushIdExEn = Mux(mem.io.pcSrc =/= 0.U, true.B, false.B)
  val flushExMemEn = Mux(mem.io.pcSrc =/= 0.U, true.B, false.B)
  val flushMemWbEn = false.B

  val stallIfIdEn = stallEn
  val stallIdExEn = stallEn
  val stallExMemEn = false.B
  val stallMemWbEn = false.B
//------------------- IF --------------------------------
  fetch.io.imem <> io.imem
  fetch.io.pcSrc := mem.io.pcSrc
  fetch.io.nextPC := mem.io.nextPC       //! 分支预测
  fetch.io.stall := stallEn

  IfRegId.io.in <> fetch.io.out
  IfRegId.io.stall := stallIfIdEn
  IfRegId.io.flush := flushIfIdEn
//------------------- ID --------------------------------
  decode.io.in <> IfRegId.io.out
  decode.io.rdEn := wb.io.rdEn
  decode.io.rdAddr := wb.io.rdAddr
  decode.io.rdData := wb.io.rdData
//* Bypass
  decode.io.exeRdEn := ex.io.exeRdEn
  decode.io.exeRdAddr := ex.io.exeRdAddr
  decode.io.exeRdData := ex.io.exeRdData
  decode.io.memRdEn := mem.io.memRdEn
  decode.io.memRdAddr := mem.io.memRdAddr
  decode.io.memRdData := mem.io.memRdData
  decode.io.wbRdEn := wb.io.wbRdEn
  decode.io.wbRdAddr := wb.io.wbRdAddr
  decode.io.wbRdData := wb.io.wbRdData

  IdRegEx.io.in <> decode.io.out
  IdRegEx.io.stall := stallIdExEn
  IdRegEx.io.flush := flushIdExEn
//------------------- EX --------------------------------
  ex.io.in <> IdRegEx.io.out

  ExRegMem.io.in <> ex.io.out
  ExRegMem.io.stall := stallExMemEn
  ExRegMem.io.flush := flushExMemEn
//------------------- MEM -------------------------------
  mem.io.in <> ExRegMem.io.out
  mem.io.dmem <> io.dmem

  MemRegWb.io.in <> mem.io.out
  MemRegWb.io.stall := stallMemWbEn
  MemRegWb.io.flush := flushMemWbEn
//------------------- WB ---------------------------------
  wb.io.in <> MemRegWb.io.out


  /* ----- Difftest ------------------------------ */
  val valid = wb.io.ready_cmt && !stallEn

  val dt_ic = Module(new DifftestInstrCommit)
  dt_ic.io.clock    := clock
  dt_ic.io.coreid   := 0.U
  dt_ic.io.index    := 0.U
  dt_ic.io.valid    := RegNext(valid)
  dt_ic.io.pc       := RegNext(wb.io.pc)
  dt_ic.io.instr    := RegNext(wb.io.inst)
  dt_ic.io.skip     := false.B
  dt_ic.io.isRVC    := false.B
  dt_ic.io.scFailed := false.B
  dt_ic.io.wen      := RegNext(wb.io.rdEn)
  dt_ic.io.wdata    := RegNext(wb.io.rdData)
  dt_ic.io.wdest    := RegNext(wb.io.rdAddr)

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
  dt_te.io.valid    := (wb.io.inst === "h0000006b".U)
  dt_te.io.code     := rf_a0(2, 0)
  dt_te.io.pc       := wb.io.pc
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
