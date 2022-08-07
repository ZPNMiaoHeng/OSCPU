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
  
  val fetch = Module(new InstFetch)
  val decode = Module(new Decode)
  val alu     = Module(new ALU)
  val dataMem = Module(new DataMem)
  val nextpc  = Module(new NextPC)

  val MemtoReg = decode.io.memCtr.MemtoReg
  val InstResW = SignExt(alu.io.Result(31,0), 64)
  val wData = LookupTreeDefault(MemtoReg, 0.U, List(
      ("b00".U) -> alu.io.Result,
      ("b01".U) -> dataMem.io.rdData,
      ("b10".U) -> InstResW
  ))
  val wEna = dataMem.io.dmem.wen && fetch.io.fetchDone
//------------------- Fetch------------------------------
  fetch.io.imem <> io.imem
  fetch.io.nextPC := nextpc.io.NextPC
//------------------- Decode-----------------------------
  decode.io.inst := fetch.io.inst
  decode.io.rdData := wData
  decode.io.fetchDone := fetch.io.fetchDone
//------------------- ALU--------------------------------
  alu.io.PC := fetch.io.pc
  alu.aluIO <> decode.io.aluIO
  alu.io.MemtoReg := decode.io.memCtr.MemtoReg
//------------------- DataMem----------------------------
  dataMem.io.Addr   := alu.io.Result
  dataMem.io.DataIn := decode.io.aluIO.data.rData2
  dataMem.io.memCtr <> decode.io.memCtr
  dataMem.io.dmem <> io.dmem
//-------------------NextPC------------------------------
  nextpc.io.PC     := fetch.io.pc
  nextpc.io.Imm    := decode.io.aluIO.data.imm
  nextpc.io.Rs1    := decode.io.aluIO.data.rData1
  nextpc.io.Branch := decode.io.Branch
  nextpc.io.Less   := alu.io.Less
  nextpc.io.Zero   := alu.io.Zero

  /* ----- Difftest ------------------------------ */

  val dt_ic = Module(new DifftestInstrCommit)
  dt_ic.io.clock    := clock
  dt_ic.io.coreid   := 0.U
  dt_ic.io.index    := 0.U
  dt_ic.io.valid    := RegNext(fetch.io.fetchDone) // true.B
  dt_ic.io.pc       := RegNext(fetch.io.pc)
  dt_ic.io.instr    := RegNext(fetch.io.inst)
  dt_ic.io.skip     := false.B
  dt_ic.io.isRVC    := false.B
  dt_ic.io.scFailed := false.B
  dt_ic.io.wen      := RegNext(dataMem.io.dmem.wen)       //RegNext(wEna)   
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
