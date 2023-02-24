import chisel3._
import chisel3.util._
import chisel3.util.experimental._
import Constant._
import utils._

class CLINT extends Module {
  val io = IO(new Bundle {
    val mstatus = Input(UInt(64.W))
//    val mip = Input(UInt(64.W))
    val mie = Input(UInt(64.W))

    val clintEn = Output(Bool())
  })

  val mtime = RegInit(UInt(64.W), 0.U)
  val mtimecmp = RegInit(UInt(64.W), 0.U)

//  mtime = mtime + 1.U
  io.clintEn := (io.mstatus(3)  && io.mie(7) && (mtime >= mtimecmp))
}