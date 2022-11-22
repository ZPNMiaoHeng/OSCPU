import chisel3._
import chisel3.util._
import chisel3.util.experimental._
import difftest._
import Constant._

class Csr extends Module {
  val io = IO(new Bundle {
    
  })
  val mstatus   = RegInit(UInt(64.W), "h00001800".U) // Machine Mode
  val mtvec     = RegInit(UInt(64.W), 0.U) // Machine Trap-Vector Base-Address Register
  val mepc      = RegInit(UInt(64.W), 0.U)
  val mcause    = RegInit(UInt(64.W), 0.U)
}