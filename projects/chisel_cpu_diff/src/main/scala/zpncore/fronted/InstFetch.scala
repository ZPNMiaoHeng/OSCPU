/**
  ** Date 8/22
  ** Modified:
  **  1. 将"IF未完成阻塞流水线"改为"未完成那一周期指令不进行对比"；
  **  2. 暂停状态下指令、pc不变，对比有效；
  */

import chisel3._
import chisel3.util._
import Constant._

class InstFetch extends Module {
  val io = IO(new Bundle {
    val imem = new CoreInst

    val pcSrc = Input(UInt(2.W))
    val nextPC = Input(UInt(WLEN.W))
    val stall = Input(Bool())

    val out = Output(new BUS_R)

//    val IFDone = Output(Bool())                       //* 有效时才取到指令。后面流水级才能运行，否则处于暂停状态
  })
  val stall = io.stall
  val pc = RegInit("h8000_0000".U(WLEN.W))            //* nextPC = 0x8000_0000,可以取到正确指令
  val inst = RegInit(0.U(WLEN.W))

  io.imem.inst_valid := !stall
  io.imem.inst_req := REQ_READ
  io.imem.inst_addr := pc.asUInt()
  io.imem.inst_size := SIZE_W
  
  val fire = io.imem.inst_valid && io.imem.inst_ready //* 握手成功，从总线上取出指令
// 握手成功，从总线上取到指令，更新寄存器PC与inst
  val ifInst = Mux(fire && (!stall), io.imem.inst_read, inst)
  val ifPC = Mux(RegNext(fire),
              Mux(io.pcSrc === 0.U, 
                Mux(stall, pc, pc + 4.U),
                  io.nextPC),
                    pc)
  pc := ifPC                                          //* 更新pc/inst寄存器值,并保持当前寄存器状态 
  inst := ifInst
/*
  val ifStall = RegInit(false.B)
  val ifValid = RegInit(false.B)
  when (ifValid && stall) {
    ifStall := true.B
  }.elsewhen (!stall) {
    ifStall := false.B
  }
  when (fire && !stall) {
    ifValid := true.B
  }.otherwise {
    ifValid := false.B
  }
*/
//  io.IFDone := fire                                   //* fire有效，取到inst，取指阶段完成
//------------------- IF ----------------------------
  io.out.valid    := fire || stall //(ifValid || ifStall)
  io.out.pc       := ifPC                             //* pc需要打一拍等待ifinst取指
  io.out.inst     := ifInst
  io.out.typeL    := false.B
  io.out.aluA     := 0.U
  io.out.aluB     := 0.U
  io.out.aluOp    := 0.U
  io.out.branch   := 0.U
  io.out.memtoReg := 0.U
  io.out.memWr    := 0.U
  io.out.memOp    := 0.U
  io.out.rdEn     := false.B
  io.out.rdAddr   := 0.U
  io.out.rdData   := 0.U
  io.out.rs1Data  := 0.U
  io.out.rs2Data  := 0.U
  io.out.imm      := 0.U
  io.out.pcSrc    := 0.U
  io.out.nextPC   := 0.U
  io.out.aluRes   := 0.U
  io.out.memData  := 0.U
}
