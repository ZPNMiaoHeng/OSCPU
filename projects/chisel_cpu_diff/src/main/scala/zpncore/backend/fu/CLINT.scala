import chisel3._
import chisel3.util._
import chisel3.util.experimental._
import Constant._
import utils._

class CLINT extends Module {
  val io = IO(new Bundle {
    val mstatus = Input(UInt(64.W))
    val mie = Input(UInt(64.W))
    val IFDone = Input(Bool())
    val clintEnW = Input(Bool())      // 流水线中的clint 信号

    val cmp_ren    = Input(Bool())
    val cmp_wen    = Input(Bool())
    val cmp_addr   = Input(UInt(64.W))
    val cmp_wdata  = Input(UInt(64.W))
    val cmp_rdata  = Output(UInt(64.W))

    val clintEn = Output(Bool())
  })

  val mtime = RegInit(UInt(64.W), 0.U)
  val mtimecmp = RegInit(UInt(64.W), 0.U)

  mtime := mtime + 1.U
  when (io.cmp_wen) {
    mtimecmp := io.cmp_wdata
  }
  io.clintEn := ((io.mstatus(3) === 1.U) && (io.mie(7)===1.U) 
                  && (mtime >= mtimecmp)) && io.IFDone && io.clintEnW
  io.cmp_rdata := Mux(io.cmp_ren, 
                    Mux(io.cmp_addr === MTIME, 
                      mtime, mtimecmp), 0.U)
}