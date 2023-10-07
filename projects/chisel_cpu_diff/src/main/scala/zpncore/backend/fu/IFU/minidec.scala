import chisel3._
import chisel3.util._
import Instructions._
import Constant._
import utils._
/**
  * inst 简单译码
  * 得到分支跳转指令，以及跳转参数
  */

object CFIType {
  def SZ = 2
  def apply() = UInt(SZ.W)
  def branch = 0.U
  def jump = 1.U
  def call = 2.U
  def ret = 3.U
}

abstract class minidecBundle extends Bundle with HasZpnCoreParameter
abstract class minidecModule extends Module with HasZpnCoreParameter

class minidecReq extends minidecBundle {
  // val addr = UInt(addrBits.W)
  val instruction = UInt(addrBits.W)
}

class minidecResp extends minidecBundle {
  val cfiType = CFIType()
  val imm = UInt(dataBits.W)
  // val rs1En = Bool()
  // val rs1Addr = UInt(5.W)
}

class minidec_BTB extends minidecModule {
  val io = IO(new Bundle {
    val req = Flipped(Valid(new minidecReq))
    val resp = Valid(new minidecResp)
  })
  def immGen(inst: UInt, cfiType: UInt) = {
    val imm = Mux(inst === JALR, Fill(52, inst(31)) ## inst(31,20),
                Mux(inst === JAL, Fill(43, inst(31)) ## inst(31) ## inst(19,12) ## inst(20) ## inst(30,21) ## 0.U(1.W),
                  Mux(cfiType === CFIType.branch, Fill(52, inst(31)) ## inst(31) ## inst(7) ## inst(30,25) ## inst(11,8) ## 0.U(1.W),
                    0.U)))
    imm
  }
  def cfiType(inst: UInt) = {
    val res = LookupTreeDefault(inst, 0.U, List(
      BEQ -> CFIType.branch,
      BNE -> CFIType.branch,
      BLT -> CFIType.branch,
      BGE -> CFIType.branch,
      BLTU -> CFIType.branch,
      BGEU -> CFIType.branch,
      JAL -> CFIType.jump,
      JALR -> CFIType.jump,
      ECALL -> CFIType.call,
      MRET -> CFIType.ret
    ))
    res
  }
  
  val cfiTypeRes = cfiType(io.req.bits.instruction)
  io.resp.valid := true.B
  io.resp.bits.cfiType := cfiTypeRes
  io.resp.bits.imm := immGen(io.req.bits.instruction, cfiTypeRes)
  // io.resp.bits.rs1En := 
  // io.resp.bits.rs1Addr :=
}


  class minidec extends Module {
    val io = IO(new Bundle {
      val inst = Input(UInt(WLEN.W))

      val rs1En = Output(Bool())
      val rs1Addr = Output(UInt(5.W))
      val bjp = Output(Bool())              // 跳转指令
      val jal = Output(Bool())              // pc + imm
      val jalr = Output(Bool())             // rs1 + imm
      val bxx = Output(Bool())              // pc + imm
      //TODO - Add RAS parameter
      val imm = Output(UInt(XLEN.W))
    })

    val inst = io.inst
    val jalr = inst === JALR
    val jal = inst === JAL
    val jxx = jal| jalr

    val beq = inst === BEQ
    val bne = inst === BNE
    val blt = inst === BLT
    val bge = inst === BGE
    val bltu = inst === BLTU
    val bgeu = inst === BGEU
    val bxx = (beq| bne| blt| bge| bltu| bgeu)

    val bjp = jxx| bxx
    val rs1En = (jalr| bxx)

    val rs1Addr = Mux(rs1En, inst(19, 15), 0.U(5.W))

    val immOp = WireInit(0.U(3.W))
    immOp := Mux(jal, 4.U,
               Mux(bxx, 3.U,
                Mux(jalr, 0.U,
                5.U)))               // 0.U
  
    val imm = Module(new ImmGen)
    imm.io.inst := io.inst
    imm.io.immOp := immOp

    io.rs1En := rs1En
    io.rs1Addr := rs1Addr
    io.bjp := bjp
    io.jal := jal
    io.jalr := jalr 
    io.bxx := bxx
    io.imm := imm.io.imm
  }


