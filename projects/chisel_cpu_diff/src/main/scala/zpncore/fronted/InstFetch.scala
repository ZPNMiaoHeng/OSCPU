import chisel3._
import chisel3.util._
import Constant._
/**
  ** 将ram中RomIo接口换成Axi取指接口
  ** 添加握手信号
  */


class InstFetch extends Module {
  val io = IO(new Bundle {
    val imem = new RomIO

    val nextPC = Input(UInt(WLEN.W))
//*    val pc = Output(UInt(WLEN.W))
//*    val inst = Output(UInt(WLEN.W))

    val out = Output(new BUS_R)
  })
  val pc = RegInit("h7fff_fffc".U(WLEN.W))
  pc := io.nextPC

  io.imem.en := true.B
  io.imem.addr := pc.asUInt()
  val ifPC = io.pc
  val ifInst = io.inst
//*  io.pc := pc
//*  io.inst := io.imem.rdata(31, 0)
//------------------- IF ----------------------------
  io.out.valid    := true.B
  io.out.pc       := ifPC
  io.out.inst     := ifInst
  io.out.aluA     := 0.U
  io.out.aluB     := 0.U
  io.out.aluOp    := 0.U
  io.out.branch   := 0.U
  io.out.memtoReg := 0.U
  io.out.memWr    := 0.U
  io.out.memOp    := 0.U
  io.out.rs1Data  := 0.U
  io.out.rs2Data  := 0.U
  io.out.imm      := 0.U
//  io.out.nextPC   := 0.U
  io.out.aluRes   := 0.U
  io.out.wData    := 0.U
}
