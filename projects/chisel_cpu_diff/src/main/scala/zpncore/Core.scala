import chisel3._
import chisel3.util.experimental._
import Instructions._
import difftest._
import utils._

class Core extends Module {
  val io = IO(new Bundle {
    val imem = new CoreInst
    val dmem = new CoreData
//    val imem = new RomIO
//    val dmem = new RamIO
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
  val EXLHitID = Mux(!ExRegMem.io.instChange, ID.io.bubbleId && EX.io.bubbleEx, false.B) //切换指令时，此信号一周期无效

//* ----------------------------------------------------------------
  val ecallEn = WB.io.csrOp_WB(3) === 1.U //|| WB.io.clintEn)  //ecall/mret/time
  val flushIfIdEn  = false.B
  val flushIdExEn  = Mux(ecallEn, true.B,
                      Mux(IF.io.IFDone, 
                        Mux(EX.io.pcSrc =/= 0.U || EXLHitID,
                          true.B, false.B),
                            false.B))
  val flushExMemEn = ecallEn
  val flushMemWbEn = ecallEn

//* ------------------------------------------------------------------
// 流水线暂停：IF总线取指未完成、MEM总线访问未完成、发生访存指令数据冒险

  val stallIfIdEn =  !IF.io.IFDone || EXLHitID
  val stallIdExEn =  !IF.io.IFDone
  val stallExMemEn = !IF.io.IFDone
  val stallMemWbEn = !IF.io.IFDone

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
  IF.io.stall := EXLHitID || !MEM.io.memDone //! EX 优先级大于MEM
  IF.io.memDone := MEM.io.memDone
  IF.io.csrOp_WB := WB.io.csrOp_WB

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
//  EX.io.csrRAddr := WB.io.csrRAddr //!
  EX.io.csrOp := WB.io.csrOp_WB
  EX.io.mepc := WB.io.mepc
  EX.io.mtvec := WB.io.mtvec
  EX.io.clintEn := WB.io.clintEn

  ExRegMem.io.in <> EX.io.out
  ExRegMem.io.stall := stallExMemEn
  ExRegMem.io.flush := flushExMemEn
//------------------- MEM -------------------------------
  MEM.io.in <> ExRegMem.io.out
  MEM.io.dmem <> io.dmem
  MEM.io.IFReady := io.imem.inst_ready
  MEM.io.cmp_rdata := WB.io.cmp_rdata

  MemRegWb.io.in <> MEM.io.out
  MemRegWb.io.stall := stallMemWbEn
  MemRegWb.io.flush := flushMemWbEn
//------------------- WB ---------------------------------
  WB.io.in <> MemRegWb.io.out
  WB.io.IFDone := IF.io.IFDone
  WB.io.cmp_ren := MEM.io.cmp_ren
  WB.io.cmp_wen := MEM.io.cmp_wen
  WB.io.cmp_addr := MEM.io.cmp_addr
  WB.io.cmp_wdata := MEM.io.cmp_wdata

  /* ----- Difftest ------------------------------ */
//  val mem_valid = RegNext(MEM.io.memAxi)
  val valid = WB.io.ready_cmt && IF.io.IFDone && MEM.io.memDone

  val rf_a0 = WireInit(0.U(64.W))
  BoringUtils.addSink(rf_a0, "rf_a0")

  when (WB.io.inst === MY_INST && valid) {
    printf("%c", rf_a0)
  }

  val req_clint = (WB.io.cmp_ren || WB.io.cmp_wen)
  val skip = WB.io.inst === MY_INST ||
              (WB.io.inst(31, 20) === Csrs.mcycle && WB.io.csrOp =/=0.U)

  val dt_ic = Module(new DifftestInstrCommit)
  dt_ic.io.clock    := clock
  dt_ic.io.coreid   := 0.U
  dt_ic.io.index    := 0.U
  dt_ic.io.valid    := RegNext(valid)
  dt_ic.io.pc       := RegNext(WB.io.pc)
  dt_ic.io.instr    := RegNext(WB.io.inst)
  dt_ic.io.skip     := RegNext(skip)
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
  instr_cnt := instr_cnt + valid

  val dt_te = Module(new DifftestTrapEvent)
  dt_te.io.clock    := clock
  dt_te.io.coreid   := 0.U
  dt_te.io.valid    := (WB.io.inst === "h0000006b".U)
  dt_te.io.code     := rf_a0(2, 0)
  dt_te.io.pc       := WB.io.pc
  dt_te.io.cycleCnt := cycle_cnt
  dt_te.io.instrCnt := instr_cnt
/*
  val dt_cs = Module(new DifftestCSRState)
  dt_cs.io.clock          := clock
  dt_cs.io.coreid         := 0.U
  dt_cs.io.priviledgeMode := 3.U  // Machine mode
  dt_cs.io.mstatus        := WB.io.mstatus
  dt_cs.io.sstatus        := WB.io.mstatus & "h80000003000de122".U
  dt_cs.io.mepc           := WB.io.mepc
  dt_cs.io.sepc           := 0.U
  dt_cs.io.mtval          := 0.U
  dt_cs.io.stval          := 0.U
  dt_cs.io.mtvec          := RegNext(WB.io.mtvec)
  dt_cs.io.stvec          := 0.U
  dt_cs.io.mcause         := WB.io.mcause
  dt_cs.io.scause         := 0.U
  dt_cs.io.satp           := 0.U
  dt_cs.io.mip            := 0.U
  dt_cs.io.mie            := WB.io.mie
  dt_cs.io.mscratch       := WB.io.mscratch
  dt_cs.io.sscratch       := 0.U
  dt_cs.io.mideleg        := 0.U
  dt_cs.io.medeleg        := 0.U
*/
}
