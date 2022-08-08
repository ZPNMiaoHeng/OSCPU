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
  val decode = Module(new Decode)
  val alu     = Module(new ALU)
  val dataMem = Module(new DataMem)
  val nextpc  = Module(new NextPC)

  val wb = Module(new WriteBack)
//------------------- IF --------------------------------
  fetch.io.imem <> io.imem
  fetch.io.nextPC := nextpc.io.nextPC

//------------------- ID --------------------------------
  decode.io.inst := fetch.io.inst
  decode.io.rdData := wb.io.wData

//------------------- EX --------------------------------
  alu.io.pc := fetch.io.pc
  alu.aluIO <> decode.io.aluIO
  alu.io.memtoReg := decode.io.memCtr.memtoReg

  nextpc.io.pc := fetch.io.pc
  nextpc.io.imm := decode.io.aluIO.data.imm
  nextpc.io.rs1Data := decode.io.aluIO.data.rData1
  nextpc.io.branch := decode.io.branch
  nextpc.io.less   := alu.io.less
  nextpc.io.zero   := alu.io.zero

//------------------- MEM -------------------------------
  dataMem.io.memAddr := alu.io.aluRes
  dataMem.io.memDataIn := decode.io.aluIO.data.rData2
  dataMem.io.memCtr <> decode.io.memCtr
  dataMem.io.dmem <> io.dmem

//------------------- WB ---------------------------------
  wb.io.memtoReg := decode.io.memCtr.memtoReg
  wb.io.aluRes := alu.io.aluRes
  wb.io.memData := dataMem.io.rdData

  /* ----- Difftest ------------------------------ */

  val dt_ic = Module(new DifftestInstrCommit)
  dt_ic.io.clock    := clock
  dt_ic.io.coreid   := 0.U
  dt_ic.io.index    := 0.U
  dt_ic.io.valid    := true.B
  dt_ic.io.pc       := RegNext(fetch.io.pc)
  dt_ic.io.instr    := RegNext(fetch.io.inst)
  dt_ic.io.skip     := false.B
  dt_ic.io.isRVC    := false.B
  dt_ic.io.scFailed := false.B
  dt_ic.io.wen      := RegNext(dataMem.io.dmem.wen)
  dt_ic.io.wdata    := RegNext(dataMem.io.dmem.wdata)
  dt_ic.io.wdest    := RegNext(dataMem.io.dmem.addr)

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
  dt_te.io.valid    := (fetch.io.inst === "h0000006b".U)
  dt_te.io.code     := rf_a0(2, 0)
  dt_te.io.pc       := fetch.io.pc
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
