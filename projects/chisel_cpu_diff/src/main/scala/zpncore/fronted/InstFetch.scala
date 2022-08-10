import chisel3._
import chisel3.util._
import Constant._

class InstFetch extends Module {
  val io = IO(new Bundle {
    val imem = new RomIO

    val pcSrc = Input(UInt(2.W))
    val nextPC = Input(UInt(WLEN.W))
    val stall = Input(Bool())
//*    val pc = Output(UInt(WLEN.W))
//*    val inst = Output(UInt(WLEN.W))

    val out = Output(new BUS_R)
  })
  val pc = RegInit("h7fff_fff8".U(WLEN.W))

  val ifPC = Mux(io.stall, pc,
     Mux(io.pcSrc === 0.U, pc + 4.U ,io.nextPC))

    pc := ifPC                                                 // 更新pc寄存器, 保存pc值得篮子
    io.imem.en := ~io.stall                                    // stall -> 取指pc和addr暂停
    io.imem.addr := ifPC
    
  val ifInst = io.imem.rdata(31, 0)
//*  io.pc := pc
//*  io.inst := io.imem.rdata(31, 0)
//------------------- IF ----------------------------
  io.out.valid    := true.B //~io.stall || io.stall
  io.out.pc       := ifPC
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
