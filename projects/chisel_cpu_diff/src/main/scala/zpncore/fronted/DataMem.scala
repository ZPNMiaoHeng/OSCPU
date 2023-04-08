/**
  ** 内存使用第三期环境，访存指令需要进行8字节对齐处理
  ** memDone 默认为完成状态，只有触发访存指令时才会变为无效
  ** 
  */
import chisel3._
import chisel3.util._
import Constant._
import utils._

class DataMem extends Module {
  val io = IO(new Bundle {
//    val dmem = new RamIO 
    val dmem = new CoreData

    val IFDone = Input(Bool())
    val in = Input(new BUS_R)

    val out = Output(new BUS_R)
    val memRdData = Output(UInt(XLEN.W))
    val memDone = Output(Bool())

    val cmp_ren    = Output(Bool())
    val cmp_wen    = Output(Bool())
    val cmp_addr   = Output(UInt(64.W))
    val cmp_wdata  = Output(UInt(64.W))   // write data to clint reg
    val cmp_rdata  = Input(UInt(64.W))    // read data to clint reg
  })

  val memAddr =   io.in.aluRes
  val memtoReg =  io.in.memtoReg          // 01-> Load inst
  val memOP =     io.in.memOp
  val memWr =     io.in.memWr             // 1-> Store inst
  val memDataIn = io.in.rs2Data
  val alignBits = memAddr % 16.U
  val data_size = WireInit(0.U(2.W))

  val cmpWEn = (memWr === 1.U) && ((memAddr === MTIMECMP) || (memAddr === MTIME))           // Store inst -> mtime/mtimecmp //todo：不考虑
  val cmpREn = (memtoReg === 1.U) && ((memAddr === MTIMECMP) || (memAddr === MTIME))       // Load inst -> mtime/mtimecmp
  val dmemEn = (!(memAddr < "h8000_0000".U || memAddr > "h8800_0000".U)) &&                  // W/R memory space
                  ((memtoReg === "b01".U) || (memWr === 1.U))                                // Load/store
//*------------------------------------ AXI4 访存 --------------------------------------------------------
// ------------ 跳转到下一条指令时，dmemDone就false -------------------
  val dmemDone = RegInit(true.B)  //* 访存完成后dmemDone拉高，只有进入下一条inst时才进入总线访存；
  val inst = Reg(UInt(WLEN.W))
  inst := io.in.inst

  when (io.dmem.data_ready & io.IFDone) {    //* IF完成，更新级间寄存器，
    dmemDone := true.B
  } .elsewhen (io.dmem.data_valid & io.IFDone & inst =/= io.in.inst) {
    dmemDone := false.B
  }

//* ------------------------------------------------------ ----- Debug ----- 当访问mtimecmp，两个周期后暂停
//  val debug = RegNext(RegNext(memAddr === MTIMECMP)) 
//* ------------------------------------------------------ ----- Debug -----

  io.dmem.data_valid := !io.memDone
  io.dmem.data_addr := Mux(io.dmem.data_valid, memAddr, 0.U)
  io.dmem.data_write := memDataIn << alignBits * 8.U
  io.dmem.data_req := Mux(memWr === 1.U && !cmpWEn, REQ_WRITE, REQ_READ)
  io.dmem.data_size := data_size
  io.dmem.data_strb := Mux(io.in.typeL, 0.U,
    LookupTreeDefault(memOP, 0.U, List(
      "b000".U -> LookupTreeDefault(alignBits, "b0000_0001".U, List(                       // Sb
        1.U  -> "b0000_0010".U,
        2.U  -> "b0000_0100".U,
        3.U  -> "b0000_1000".U,
        4.U  -> "b0001_0000".U,
        5.U  -> "b0010_0000".U,
        6.U  -> "b0100_0000".U,
        7.U  -> "b1000_0000".U,

        9.U  -> "b0000_0010".U,
        10.U -> "b0000_0100".U,
        11.U -> "b0000_1000".U,
        12.U -> "b0001_0000".U,
        13.U -> "b0010_0000".U,
        14.U -> "b0100_0000".U,
        15.U -> "b1000_0000".U
    )),
      "b001".U -> LookupTreeDefault(alignBits,  "b0000_0011".U, List(                      // Sh
        2.U  -> "b0000_1100".U,
        4.U  -> "b0011_0000".U,
        6.U  -> "b1100_0000".U,
        10.U -> "b0000_1100".U,
        12.U -> "b0011_0000".U,
        14.U -> "b1100_0000".U
    )),
      "b010".U -> Mux(alignBits === 0.U || alignBits === 8.U , "b0000_1111".U, "b1111_0000".U),                  // Sw
      "b011".U -> "b1111_1111".U                                                           // Sd
  )))

//*------------------------------ Load 指令 ----------------------------------------------------------------  
  val dmemFire = io.dmem.data_valid && io.dmem.data_ready
  val rdata = RegInit(0.U(XLEN.W))
  when(dmemFire) {
    rdata := io.dmem.data_read
  } .elsewhen( cmpREn) {
    rdata := io.cmp_rdata
  }

  io.memDone := Mux(cmpREn || cmpWEn, true.B, 
                  Mux(inst =/= io.in.inst && dmemEn, false.B, dmemDone))
//*------------------------------------ ram 访存 ---------------------------------------------------------
/*
  io.dmem.en := !(memAddr < "h8000_0000".U || memAddr > "h8800_0000".U) &&
        ((memtoReg === "b01".U) || (memWr === 1.U))

  io.dmem.addr := memAddr
  io.dmem.wen := !(memAddr < "h8000_0000".U || memAddr > "h8800_0000".U) && (memWr === 1.U)
  val alignBits = memAddr % 8.U
  io.dmem.wdata := memDataIn << alignBits * 8.U

  io.dmem.wmask := LookupTreeDefault(memOP, 0.U, List(
    "b000".U -> LookupTreeDefault(alignBits, "h0000_0000_0000_00ff".U, List(                       // Sb
      1.U -> "h0000_0000_0000_ff00".U,
      2.U -> "h0000_0000_00ff_0000".U,
      3.U -> "h0000_0000_ff00_0000".U,
      4.U -> "h0000_00ff_0000_0000".U,
      5.U -> "h0000_ff00_0000_0000".U,
      6.U -> "h00ff_0000_0000_0000".U,
      7.U -> "hff00_0000_0000_0000".U
    )),
    "b001".U -> LookupTreeDefault(alignBits,  "h0000_0000_0000_ffff".U, List(                       // Sh
      2.U -> "h0000_0000_ffff_0000".U,
      4.U -> "h0000_ffff_0000_0000".U,
      6.U -> "hffff_0000_0000_0000".U
    )),
    "b010".U -> Mux(alignBits === 0.U, "h0000_0000_ffff_ffff".U, "hffff_ffff_0000_0000".U),         // Sw
    "b011".U -> "hffff_ffff_ffff_ffff".U                                                            // Sd
  ))

  val rdata = io.dmem.rdata >> alignBits * 8.U
*/  
//*-------------------------------------------------------------------------------------------------------
  val rData = LookupTreeDefault(memOP, 0.U, List(
    "b000".U -> SignExt(rdata(7 , 0), XLEN),        // b
    "b001".U -> SignExt(rdata(15, 0), XLEN),        // h
    "b010".U -> SignExt(rdata(31, 0), XLEN),        // w
    "b011".U -> rdata,                              // d
    "b100".U -> ZeroExt(rdata(7 , 0), XLEN),
    "b101".U -> ZeroExt(rdata(15, 0), XLEN),
    "b110".U -> ZeroExt(rdata(31, 0), XLEN)
  ))

  data_size := LookupTreeDefault(memOP, 0.U, List(  // L & D 指令类型
    "b000".U -> "b00".U, //b
    "b100".U -> "b00".U,
    "b001".U -> "b01".U, //h
    "b101".U -> "b01".U,
    "b011".U -> "b11".U, //d
    "b010".U -> "b10".U, //w
    "b110".U -> "b10".U
  ))

  val wData = Mux(memWr === 1.U, 0.U, rData)  //? load 指令才有效----可以改进,Mux加到下面

  val resW = SignExt(io.in.aluRes(31,0), 64)
  val memBPData = LookupTreeDefault(io.in.memtoReg, 0.U, List(
      ("b00".U) -> io.in.aluRes,
      ("b01".U) -> wData,
      ("b10".U) -> resW
  ))

  //*------------------------------------   Clint   --------------------------------------------------------
  io.cmp_wen := cmpWEn                        // Load inst -> mtime/mtimecmp
  io.cmp_ren := cmpREn
  io.cmp_addr := memAddr
  io.cmp_wdata := Mux(cmpWEn, io.dmem.data_write, 0.U)
//----------------------------------------------------------------
  val memValid = io.in.valid
  val memPC = io.in.pc
  val memInst = io.in.inst
  val memTypeL = io.in.typeL
  val memAluA = io.in.aluA
  val memAluB = io.in.aluB
  val memAluOp = io.in.aluOp
  val memBranch = io.in.branch
  val memMemtoReg = io.in.memtoReg
  val memMemWr = io.in.memWr
  val memMemOp = io.in.memOp
  val MemAddr = memAddr
  val memRdEn   = io.in.rdEn
  val memRdAddr = io.in.rdAddr
  val memRs1Data = io.in.rs1Data
  val memRs2Data = io.in.rs2Data
  val memImm = io.in.imm
  val memPCSrc = io.in.pcSrc
  val memNextPC = io.in.nextPC
  val memAluRes = io.in.aluRes
  val memData = wData
  val memCsrOp = io.in.csrOp
  val memTakenPre = io.in.takenPre
  val memTakenPrePC = io.in.takenPrePC

//----------------------------------------------------------------
  io.out.valid    := memValid
  io.out.pc       := memPC
  io.out.inst     := memInst
  io.out.typeL    := memTypeL
  io.out.aluA     := memAluA
  io.out.aluB     := memAluB
  io.out.aluOp    := memAluOp
  io.out.branch   := memBranch
  io.out.memtoReg := memMemtoReg
  io.out.memWr    := memMemWr
  io.out.memOp    := memMemOp
  io.out.memAddr  := MemAddr
  io.out.rdEn     := memRdEn
  io.out.rdAddr   := memRdAddr
  io.out.rs1Data  := memRs1Data
  io.out.rs2Data  := memRs2Data
  io.out.imm      := memImm
  io.out.pcSrc    := memPCSrc
  io.out.nextPC   := memNextPC
  io.out.aluRes   := memAluRes
  io.out.memData  := memData
  io.out.csrOp    := memCsrOp
  io.out.takenPre := memTakenPre
  io.out.takenPrePC := memTakenPrePC

  io.memRdData := memBPData
}
