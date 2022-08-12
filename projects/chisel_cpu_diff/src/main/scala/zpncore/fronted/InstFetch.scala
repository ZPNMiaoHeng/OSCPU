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
    val IFDone = Output(Bool())                       //* 只有取指信号有效，后面流水级才能运行，否则处于暂停状态
  })
  val pc = RegInit("h8000_0000".U(WLEN.W))
//  val pc = RegInit("h7fff_fff8".U(WLEN.W))
  val IFDone = RegInit(false.B)
  val inst = RegInit(0.U(XLEN.W))

  io.imem.inst_valid := ~io.stall                     //* 暂停时，IF valid无效
  val fire = io.imem.inst_valid && io.imem.inst_ready //* 握手成功，从总线上取出数据
  IFDone := Mux(fire, true.B, false.B)                //* 取指完成标志

  val ifPC = Mux(fire, 
              Mux(io.pcSrc === 0.U, 
                Mux(io.stall, pc, pc + 4.U),
                  io.nextPC),
                    pc)
  val ifInst = Mux(fire, io.imem.inst_read, inst)

  pc := ifPC                                          //* 更新pc/inst寄存器, 保存pc值到“篮子”
  inst := ifInst

  io.imem.inst_req := REQ_READ                    //!false.B
  io.imem.inst_addr := pc.asUInt()
  io.imem.inst_size := SIZE_W
  io.IFDone := IFDone

//------------------- IF ----------------------------
  io.out.valid    := true.B       //~io.stall || io.stall
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
