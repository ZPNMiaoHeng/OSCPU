import chisel3._
import chisel3.util._
import Constant._
import utils._
/**
  * Branch -> nextPC
  *
  */
class NextPC extends Module {
  val io = IO(new Bundle {
    val PC     = Input(UInt(WLEN.W))
    val Imm    = Input(UInt(XLEN.W))
    val Rs1    = Input(UInt(XLEN.W))

    val Branch = Input(UInt(3.W))
    val Less   = Input(UInt(1.W))
    val Zero   = Input(UInt(1.W))

    val NextPC = Output(UInt(WLEN.W))
  })

  val less = Mux(io.Branch === "b111".U, ~io.Less, io.Less)

  val PCsrc = MuxCase("b01".U, Array(
    (io.Branch === "b000".U || (io.Branch ## io.Zero === "b1000".U) || (io.Branch ## io.Zero === "b1011".U) ||
        (io.Branch ## less === "b1100".U) || (io.Branch ## less === "b1110".U)) -> "b00".U,                       // PC + 4
    (io.Branch === "b001".U || (io.Branch ## io.Zero === "b1001".U) ||(io.Branch ## io.Zero === "b1010".U) ||
        (io.Branch ## less === "b1101".U) || (io.Branch ## less === "b1111".U)) -> "b10".U,                       // PC  + imm
    (io.Branch === "b010".U)                                                    -> "b11".U                        // rs1 + imm
  ))

  io.NextPC := LookupTreeDefault(PCsrc, "h8000_0000".U, List(
    "b00".U -> (io.PC +  4.U   ),
    "b10".U -> (io.PC + io.Imm ),
    "b11".U -> (io.Rs1 + io.Imm)
  ))
  
}
