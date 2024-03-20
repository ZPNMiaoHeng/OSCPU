/**
  ** Date 8/21
  ** 设计思路：
  ** 1. 从0x8000_0000开始取指，等握手成功取到指令；
  ** 2. 暂停状态，将IF模块内一切暂停，IFDone拉高；
  **   a. 暂停触发：访存指令数据冒险，MEM模块触发总线访存；
  ** 3. IFDone无效（未完成取指）暂停流水线一切。
    ****************************************************************
  ** Modified: stall有效时，valid拉低不再去读取指令，IFDone拉高
    ****************************************************************
  *! BUG:第一次fire时，但memDone低电平，导致只能第二次握手才有效
  */

import chisel3._
import chisel3.util._
import Constant._
import javax.swing.plaf.metal.MetalTreeUI

class InstFetch extends Module {
  val io = IO(new Bundle {
    val imem = new CoreInst

    val takenValid = Input(Bool())
    val takenValidJalr = Input(Bool()) //TODO(jalr) connect
    val takenMiss = Input(Bool())
    val exTakenPre = Input(Bool())
    val takenPC =Input(UInt(WLEN.W))
    val nextPC = Input(UInt(WLEN.W))

    val stall = Input(Bool())
    val exc = Input(Bool())
    val intr = Input(Bool())

    val out = Output(new BUS_R)
    val IFDone = Output(Bool())

    val preRs1En = Output(Bool())
    val preRs1Addr = Output(UInt(5.W))
    val preRs1Data = Input(UInt(64.W))
    val preRs1x1Data = Input(UInt(64.W))
    
    val exeX1En = Input(Bool())
    val exeAluRes = Input(UInt(64.W))
    val memX1En = Input(Bool())
    val memAluRes = Input(UInt(64.W))
    val wbRdEn = Input(Bool())
    val wbRdAddr = Input(UInt(5.W))
    val wbRdData = Input(UInt(64.W))

    val coreEnd = Input(Bool())
  })
  val minidec = Module(new minidec)
  val bht = Module(new bht)

  val pc = RegInit("h8000_0000".U(WLEN.W))
  val inst = RegInit(0.U(WLEN.W))
  
  val waterRegExeX1En = RegInit(false.B)
  val waterRegExeAluRes = RegInit(0.U(64.W))
  waterRegExeX1En := io.exeX1En
  waterRegExeAluRes := io.exeAluRes

//* --------------------- AXI -----------------------------
  io.imem.inst_valid := !io.stall
  io.imem.inst_req := REQ_READ
  io.imem.inst_addr := pc.asUInt()
  io.imem.inst_size := SIZE_W

  val fire = io.imem.inst_valid && io.imem.inst_ready
  val ifIntr = io.intr
  val bhtDone = bht.io.ready

  val ifInst = Mux(fire && !io.stall, io.imem.inst_read, inst)             //* stall，fire拉高，但inst也不能更
  val ifPcEn = bhtDone && !io.stall && !ifIntr
  val ifPC = Mux(ifPcEn,                         // 更新下一周期地址 :中断信号打一拍，防止下一周期pc+4
                Mux(io.exc | io.takenMiss, io.nextPC,
                  Mux(bht.io.takenPre & minidec.io.bjp, bht.io.takenPrePC, pc + 4.U)),
                Mux(io.intr, io.nextPC, pc)
              )
  pc := ifPC
  inst := ifInst

  io.IFDone := Mux(io.stall, true.B, bhtDone)   // stall:让外部流水线运转
// --------------------------------------------------
  minidec.io.inst := ifInst

  bht.io.pc := pc
  bht.io.valid := minidec.io.bjp                                 // 只有跳转指令时才工作
  bht.io.fire := fire
  bht.io.jal := minidec.io.jal
  bht.io.jalr := minidec.io.jalr
  bht.io.bxx := minidec.io.bxx
  bht.io.imm := minidec.io.imm
  bht.io.rs1Addr := minidec.io.rs1Addr

  bht.io.takenValid := io.takenValid
  bht.io.takenValidJalr := io.takenValidJalr
  bht.io.takenMiss := io.takenMiss
  bht.io.exTakenPre := io.exTakenPre
  bht.io.takenPC := io.takenPC
  bht.io.nextPC := io.nextPC
  bht.io.rs1Data := io.preRs1Data
  bht.io.rs1x1Data := io.preRs1x1Data
  bht.io.exeX1En := waterRegExeX1En // io.exeX1En
  bht.io.exeAluRes := waterRegExeAluRes //  io.exeAluRes
  bht.io.memX1En := io.memX1En
  bht.io.memAluRes := io.memAluRes
  bht.io.wbRdEn := io.wbRdEn
  bht.io.wbRdAddr := io.wbRdAddr
  bht.io.wbRdData := io.wbRdData

  bht.io.coreEnd := io.coreEnd

  io.preRs1En := minidec.io.rs1En
  io.preRs1Addr := minidec.io.rs1Addr

  val plInst = Mux(minidec.io.bxx, inst, io.imem.inst_read)
//------------------- IF ----------------------------
  io.out.valid    := bhtDone
  io.out.pc       := pc
  io.out.inst     := plInst
  io.out.typeL    := false.B
  io.out.aluA     := 0.U
  io.out.aluB     := 0.U
  io.out.aluOp    := 0.U
  io.out.branch   := 0.U
  io.out.memtoReg := 0.U
  io.out.memWr    := 0.U
  io.out.memOp    := 0.U
  io.out.memAddr  := 0.U
  io.out.rdEn     := false.B
  io.out.rdAddr   := 0.U
  io.out.rs1Data  := 0.U
  io.out.rs2Data  := 0.U
  io.out.imm      := 0.U
  io.out.pcSrc    := 0.U
  io.out.nextPC   := 0.U
  io.out.aluRes   := 0.U
  io.out.memData  := 0.U

  io.out.csrOp := 0.U
  io.out.takenPre := bht.io.takenPre
  io.out.takenPrePC := bht.io.takenPrePC
}

