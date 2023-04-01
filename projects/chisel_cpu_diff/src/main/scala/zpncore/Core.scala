import chisel3._
import chisel3.util.experimental._
import Instructions._
import Constant._
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
  val intr = WB.io.time_int
  val intr_no = Mux(intr, 7.U, 0.U)
  val exceptionPC = Mux(intr, Mux(WB.io.pc =/= 0.U, WB.io.pc,
                                Mux(MEM.io.out.pc =/= 0.U, MEM.io.out.pc,
                                  Mux(EX.io.out.pc =/= 0.U, EX.io.out.pc,
                                    Mux(ID.io.out.pc =/= 0.U, ID.io.out.pc,
                                      IF.io.out.pc)))), 0.U)
// EX阶段L型指令与ID阶段指令发生数据冒险--暂停IF/ID与取指，flush ID/EX
  val EXLHitID = ID.io.bubbleId && (EX.io.bubbleEx)              //切换指令时，此信号一周期无效

// EX阶段csr型指令与ID阶段s指令发生数据冒险--暂停IF两周期，/ID与取指，从而在ID与WB插入两个nop，最后由ID/WB bypass返回
  val EXSHitID = ID.io.sBubbleEx && (EX.io.out.csrOp =/= 0.U)     //csr在EX与ID冲突 
  val MEMSHitID = ID.io.sBubbleMem && (MEM.io.out.csrOp =/= 0.U)  // csrMEM冲突 
  val EXSHitIDEn = EXSHitID || MEMSHitID
//* ----------------------------------------------------------------
  val ecallEn = WB.io.csrOp_WB(3) === 1.U || intr  //ecall/mret/time
  val flushIfIdEn  = ecallEn || intr || EX.io.takenMiss
  val flushIdExEn  = Mux(ecallEn, true.B, IF.io.IFDone & (EX.io.takenMiss || EXLHitID || EXSHitIDEn))                      // 预测失败冲刷
  val flushExMemEn = ecallEn
  val flushMemWbEn = ecallEn

//* ------------------------------------------------------------------
// 流水线暂停：IF总线取指未完成、MEM总线访问未完成、发生访存指令数据冒险

  // val stallIfIdEn =  !IF.io.IFDone || ((EXLHitID || EXSHitIDEn ) && !intr)  //排除发生load数据冲突时遇到时钟中断情况：时钟中断>数据冲突
  // val stallIdExEn =  !IF.io.IFDone
  // val stallExMemEn = !IF.io.IFDone
  // val stallMemWbEn = !IF.io.IFDone

  val stallIfIdEn =  !IF.io.IFDone || !MEM.io.memDone || ((EXLHitID || EXSHitIDEn ) && !intr)  //排除发生load数据冲突时遇到时钟中断情况：时钟中断>数据冲突
  val stallIdExEn =  !IF.io.IFDone || !MEM.io.memDone
  val stallExMemEn = !IF.io.IFDone || !MEM.io.memDone
  val stallMemWbEn = !IF.io.IFDone || !MEM.io.memDone
//------------------- IF --------------------------------
//  IF.io.imem <> io.imem

  io.imem.inst_valid := IF.io.imem.inst_valid
  io.imem.inst_req := IF.io.imem.inst_req                                // request signals:1 -> true
  io.imem.inst_addr := IF.io.imem.inst_addr
  io.imem.inst_size := IF.io.imem.inst_size

  IF.io.imem.inst_read := io.imem.inst_read
  IF.io.imem.inst_ready := io.imem.inst_ready
  
  IF.io.takenValid := EX.io.takenValid
  IF.io.takenMiss := EX.io.takenMiss
  IF.io.nextPC := EX.io.out.nextPC                    // 时钟中断、异常跳转PC / 分支预测失败后pC

  IF.io.preRs1Data := ID.io.preRs1Data
  IF.io.preRs1x1Data := ID.io.preRs1x1Data

  IF.io.stall := EXLHitID || !MEM.io.memDone || EXSHitIDEn //! EX 优先级大于MEM
  IF.io.exc := WB.io.exc
  IF.io.intr := intr

  IfRegId.io.in <> IF.io.out
  IfRegId.io.stall := stallIfIdEn
  IfRegId.io.flush := flushIfIdEn
//------------------- ID --------------------------------
  ID.io.in <> IfRegId.io.out
  ID.io.rdEn := WB.io.wbRdEn
  ID.io.rdAddr := WB.io.wbRdAddr
  ID.io.rdData := WB.io.wbRdData

  ID.io.preRs1En := IF.io.preRs1En
  ID.io.preRs1Addr := IF.io.preRs1Addr
//* Bypass
  ID.io.exeRdEn := EX.io.out.rdEn
  ID.io.exeRdAddr := EX.io.out.rdAddr
  ID.io.exeRdData := EX.io.exeRdData

  ID.io.memRdEn := MEM.io.out.rdEn
  ID.io.memRdAddr := MEM.io.out.rdAddr
  ID.io.memRdData := MEM.io.memRdData

  ID.io.wbRdEn := WB.io.wbRdEn
  ID.io.wbRdAddr := WB.io.wbRdAddr
  ID.io.wbRdData := WB.io.wbRdData

  IdRegEx.io.in <> ID.io.out
  IdRegEx.io.stall := stallIdExEn
  IdRegEx.io.flush := flushIdExEn
//------------------- EX --------------------------------
  EX.io.in <> IdRegEx.io.out
  EX.io.exc := WB.io.exc
  EX.io.csrOp := WB.io.csrOp_WB
  EX.io.mepc := WB.io.mepc
  EX.io.mtvec := WB.io.mtvec
  EX.io.time_int := WB.io.time_int

  ExRegMem.io.in <> EX.io.out
  ExRegMem.io.stall := stallExMemEn
  ExRegMem.io.flush := flushExMemEn
//------------------- MEM -------------------------------
  MEM.io.in <> ExRegMem.io.out
  MEM.io.dmem <> io.dmem
  MEM.io.IFDone := IF.io.IFDone
  MEM.io.cmp_rdata := WB.io.cmp_rdata     // 写回mtime/mtimecmp

  MemRegWb.io.in <> MEM.io.out
  MemRegWb.io.stall := stallMemWbEn
  MemRegWb.io.flush := flushMemWbEn
//------------------- WB ---------------------------------
  WB.io.in <> MemRegWb.io.out
  WB.io.IFDone := IF.io.IFDone
  WB.io.memDone := MEM.io.memDone
  WB.io.pc_intr := exceptionPC
  WB.io.cmp_ren := MEM.io.cmp_ren
  WB.io.cmp_wen := MEM.io.cmp_wen
  WB.io.cmp_addr := MEM.io.cmp_addr
  WB.io.cmp_wdata := MEM.io.cmp_wdata

  /* ----- Difftest ------------------------------ */
  val valid = WB.io.ready_cmt && IF.io.IFDone && MEM.io.memDone

  val rf_a0 = WireInit(0.U(64.W))
  BoringUtils.addSink(rf_a0, "rf_a0")

  when (WB.io.inst === MY_INST && valid) {
    printf("%c", rf_a0)
  }

  val req_clint = (WB.io.mem_addr === MTIMECMP || WB.io.mem_addr === MTIME) &&
                  (WB.io.memtoReg === 1.U || WB.io.memWr === 1.U)
  val skip = WB.io.inst === MY_INST || (WB.io.inst(31, 20) === Csrs.mcycle && WB.io.csrOp_WB =/=0.U) || req_clint

  val dt_ic = Module(new DifftestInstrCommit)
  dt_ic.io.clock    := clock
  dt_ic.io.coreid   := 0.U
  dt_ic.io.index    := 0.U
  dt_ic.io.valid    := RegNext(valid)
  dt_ic.io.pc       := RegNext(WB.io.pc)
  dt_ic.io.instr    := RegNext(WB.io.inst)
  dt_ic.io.skip     := RegNext(skip)           // 是否需要跳过本条指令；
  dt_ic.io.isRVC    := false.B                 // 是否是C扩展16位指令;
  dt_ic.io.scFailed := false.B                 // A扩展sc指令是否失败;
  dt_ic.io.wen      := RegNext(WB.io.wbRdEn)
  dt_ic.io.wdata    := RegNext(WB.io.wbRdData)
  dt_ic.io.wdest    := RegNext(WB.io.wbRdAddr)

  val dt_ae = Module(new DifftestArchEvent)
  dt_ae.io.clock        := clock
  dt_ae.io.coreid       := 0.U
  dt_ae.io.intrNO       := RegNext(intr_no)       // 外部中断使用
  dt_ae.io.cause        := 0.U
  dt_ae.io.exceptionPC  := RegNext(exceptionPC)   // 外部中断PC

  val cycle_cnt = RegInit(0.U(64.W))
  val instr_cnt = RegInit(0.U(64.W))

  cycle_cnt := cycle_cnt + 1.U
  instr_cnt := instr_cnt + valid

  val dt_te = Module(new DifftestTrapEvent)
  dt_te.io.clock    := clock
  dt_te.io.coreid   := 0.U
  dt_te.io.valid    := (WB.io.inst === "h0000006b".U)  // 0x6b是NEMU中定义的HALT指令
  dt_te.io.code     := rf_a0(2, 0)                     // 读取a0的值判断程序是否正确执行并退出
  dt_te.io.pc       := WB.io.pc
  dt_te.io.cycleCnt := cycle_cnt                       // cycle计数器
  dt_te.io.instrCnt := instr_cnt                       // 指令计数器
}
