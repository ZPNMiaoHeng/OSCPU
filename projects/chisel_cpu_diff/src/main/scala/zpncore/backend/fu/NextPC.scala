import chisel3._
import chisel3.util._
import Constant._
import utils._
/**
  ** 可以将PC+4移除
  *
  */
class NextPC extends Module {
  val io = IO(new Bundle {
    val pc     = Input(UInt(WLEN.W))
    val imm    = Input(UInt(XLEN.W))
    val rs1Data    = Input(UInt(XLEN.W))

    val branch = Input(UInt(3.W))
    val less   = Input(UInt(1.W))
    val zero   = Input(UInt(1.W))
    val csrOp = Input(UInt(4.W))
    val mepc  = Input(UInt(64.W))
    val mtvec = Input(UInt(64.W))

    val nextPC = Output(UInt(WLEN.W))
    val pcSrc = Output(UInt(2.W))
  })

  val less = Mux(io.branch === "b111".U, ~io.less, io.less)

  val pcSrc = MuxCase("b01".U, Array(
    (io.branch === "b000".U || (io.branch ## io.zero === "b1000".U) || (io.branch ## io.zero === "b1011".U) ||
        (io.branch ## less === "b1100".U) || (io.branch ## less === "b1110".U)) -> "b00".U,                       // PC + 4
    (io.branch === "b001".U || (io.branch ## io.zero === "b1001".U) ||(io.branch ## io.zero === "b1010".U) ||
        (io.branch ## less === "b1101".U) || (io.branch ## less === "b1111".U)) -> "b10".U,                       // PC  + imm
    (io.branch === "b010".U)                                                    -> "b11".U                        // rs1 + imm
  ))

  io.nextPC := Mux(io.csrOp(3) === 1.U, 
    Mux(io.csrOp(0) === 0.U, io.mtvec(31, 2) << 2.U , io.mepc),  // ecall, mret
    LookupTreeDefault(pcSrc, "h8000_0000".U, List(
      "b00".U -> (io.pc +  4.U   ),
      "b10".U -> (io.pc + io.imm ),
      "b11".U -> (io.rs1Data + io.imm)
    ))
  )
  io.pcSrc := pcSrc
}
