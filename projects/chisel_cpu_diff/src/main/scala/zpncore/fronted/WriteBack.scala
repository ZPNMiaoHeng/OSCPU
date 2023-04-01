import chisel3._
import chisel3.util._
import Constant._
import utils._
import javax.swing.InputMap

class WriteBack extends Module {
    val io = IO(new Bundle {
        val in = Input(new BUS_R)
        val IFDone = Input(Bool())
        val memDone = Input(Bool())
        val pc_intr = Input(UInt(WLEN.W))

        val pc   = Output(UInt(32.W))
        val inst = Output(UInt(32.W))
     
        val wbRdEn   = Output(Bool())
        val wbRdAddr = Output(UInt(5.W))
        val wbRdData = Output(UInt(64.W))
     
        val ready_cmt = Output(Bool())
        val csrOp_WB = Output(UInt(4.W))

        val mepc = Output(UInt(64.W))
        val mtvec = Output(UInt(64.W))

        val cmp_ren   = Input(Bool())
        val cmp_wen   = Input(Bool())
        val cmp_addr  = Input(UInt(64.W))
        val cmp_wdata = Input(UInt(64.W))
        val cmp_rdata = Output(UInt(64.W))

        val exc = Output(Bool())

        val memtoReg = Output(UInt(2.W))
        val memWr = Output(UInt(1.W))
        val mem_addr = Output(UInt(32.W))
        val time_int = Output(Bool())
    })

    val csr = Module(new CSR)
    val clint = Module(new CLINT)

    val csrEn = io.IFDone & io.memDone

    csr.io.pc := Mux(clint.io.time_int, io.pc_intr, io.in.pc)
    csr.io.inst := io.in.inst
    csr.io.csrEn := csrEn
    csr.io.rs1Data := io.in.rs1Data
    csr.io.csrOp := io.in.csrOp
    csr.io.rAddr := io.in.inst(31, 20)
    csr.io.intr := clint.io.time_int

    clint.io.mstatus := csr.io.mstatus
    clint.io.mie := csr.io.mie
    clint.io.csrEn := csrEn

    clint.io.cmp_ren := io.cmp_ren
    clint.io.cmp_wen := io.cmp_wen
    clint.io.cmp_addr := io.cmp_addr
    clint.io.cmp_wdata := io.cmp_wdata

  val resW = SignExt(io.in.aluRes(31,0), 64)

  val rdData = LookupTreeDefault(io.in.memtoReg, 0.U, List(
      ("b00".U) -> io.in.aluRes,
      ("b01".U) -> io.in.memData,
      ("b10".U) -> resW
  ))

  io.pc := io.in.pc
  io.inst := io.in.inst

  io.wbRdEn := Mux(csrEn, io.in.rdEn, false.B)
  io.wbRdAddr := Mux(csrEn, Mux(clint.io.time_int, 0.U, io.in.rdAddr), 0.U)  // time interrupt writeback 0 reg
  io.wbRdData := Mux(csrEn, Mux(io.in.csrOp === 0.U, rdData, csr.io.rData), 0.U)

  io.ready_cmt := io.in.inst =/= 0.U &&                            // nop
                    !clint.io.time_int &&                          // interrupt
                      (Mux(csrEn, io.IFDone, io.in.valid))    // wb

  io.mepc    := csr.io.mepc
  io.mtvec   := csr.io.mtvec
  io.csrOp_WB := io.in.csrOp
  io.cmp_rdata := clint.io.cmp_rdata

  io.memtoReg := io.in.memtoReg
  io.memWr := io.in.memWr
  io.mem_addr := io.in.memAddr
  io.exc := (io.in.csrOp(3) === 1.U || clint.io.time_int)    // 异常/中断 pc跳转

  io.time_int := clint.io.time_int 
}
  