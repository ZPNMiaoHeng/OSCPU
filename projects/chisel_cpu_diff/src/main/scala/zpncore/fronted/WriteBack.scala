import chisel3._
import chisel3.util._
import Constant._
import utils._

class WriteBack extends Module {
    val io = IO(new Bundle {
        val in = Input(new BUS_R)
        val IFDone = Input(Bool())
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

        val exc = Output(Bool())

        val memtoReg = Output(UInt(2.W))
        val memWr = Output(UInt(1.W))
        val mem_addr = Output(UInt(32.W))
        val time_int = Output(Bool())

        val intr = Output(Bool())
        val intr_no = Output(UInt(32.W))


        val mstatus = Output(UInt(64.W))
        val mie = Output(UInt(64.W))
        val csrOp_WB = Output(UInt(4.W))

    })

    val csr = Module(new CSR)

    csr.io.pc := Mux(clint.io.time_int, io.pc_intr, io.in.pc)
    csr.io.inst := io.in.inst
    csr.io.IFDone := io.IFDone
    csr.io.rs1Data := io.in.rs1Data
    csr.io.csrOp := Mux(io.in.intr, 0.U, io.in.csrOp)
    csr.io.rAddr := io.in.inst(31, 20)
    csr.io.intr := io.in.intr
//    csr.io.intr := clint.io.time_int

  val resW = SignExt(io.in.aluRes(31,0), 64)

  val rdData = LookupTreeDefault(io.in.memtoReg, 0.U, List(
      ("b00".U) -> io.in.aluRes,
      ("b01".U) -> io.in.memData,
      ("b10".U) -> resW
  ))

  io.pc := io.in.pc
  io.inst := io.in.inst
//  io.ready_cmt := io.in.inst =/= 0.U && io.in.valid && !io.in.intr
//  io.ready_cmt := io.in.inst =/= 0.U && io.in.valid && !clint.io.time_int

//  io.wbRdEn := Mux(clint.io.time_int, 0.U, io.in.rdEn)               //?中断时 数据写回寄存器嘛？
//  io.wbRdEn := Mux(io.in.intr, 0.U, io.in.rdEn)                    //?中断时 数据写回寄存器嘛？
  io.wbRdEn := Mux(io.IFDone, io.in.rdEn, false.B)                  //?中断时 数据写回寄存器嘛？
  io.wbRdAddr := Mux(io.IFDone, Mux(clint.io.time_int, 0.U, io.in.rdAddr), 0.U)  // time interrupt writeback 0 reg
  io.wbRdData := Mux(io.IFDone, Mux(io.in.csrOp === 0.U, rdData, csr.io.rData), 0.U)

  io.ready_cmt := io.in.inst =/= 0.U &&                            // nop
                    !clint.io.time_int &&                          // interrupt
                      (Mux(io.in.rdEn, io.IFDone, io.in.valid))    // wb

  io.mepc := csr.io.mepc
  io.mtvec := csr.io.mtvec
  io.mstatus := csr.io.mstatus
  io.mie := csr.io.mie
  io.csrOp_WB := io.in.csrOp


  io.cmp_rdata := clint.io.cmp_rdata

  io.memtoReg := io.in.memtoReg
  io.memWr := io.in.memWr
  io.mem_addr := io.in.memAddr
  io.exc := (io.in.csrOp(3) === 1.U || clint.io.time_int)    // 异常/中断 pc跳转

  io.time_int := clint.io.time_int 
  io.intr := clint.io.time_int // io.in.intr                   //+
  io.intr_no := 7.U
}
  