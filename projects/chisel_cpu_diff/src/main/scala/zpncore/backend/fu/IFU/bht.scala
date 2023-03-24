import chisel3._
import chisel3.util._
import Constant._
import utils._
/**
  * biomodal predictor
  *   size is 2KB;
  *   choose is 13bits, pc[15 : 3];
  */

  class bht extends Module {
    val io = IO(new Bundle {
      val pc = Input(UInt(32.W))

      val taken = Output(Bool())
    })

    val T = WireInit(false.B)
    val NT = WireInit(false.B)
    val prd = WireInit(0.U(13.W))
    prd := io.pc(15, 3)
    
    val SNTaken :: WNTaken :: WTAken :: STaken :: Nil = Enum(4)
    val state = RegInit(STaken)
    state := 
  }