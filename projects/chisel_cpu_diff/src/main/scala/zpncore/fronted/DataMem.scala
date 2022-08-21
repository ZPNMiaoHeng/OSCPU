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
    val dmem = new CoreData                //!

    val in = Input(new BUS_R)
    val out = Output(new BUS_R)

//    val IFDone = Input(Bool())
    val memRdEn = Output(Bool())
    val memRdAddr = Output(UInt(5.W))
    val memRdData = Output(UInt(XLEN.W))

    val memDone = Output(Bool())
  })

  val memAddr =   io.in.aluRes
  val memtoReg =  io.in.memtoReg          // 01-> Load inst
  val memOP =     io.in.memOp
  val memWr =     io.in.memWr             // 1-> Store inst
  val memDataIn = io.in.rs2Data
//  val memAxi = RegInit(false.B)

//*------------------------------------ AXI4 访存 --------------------------------------------------------
  val LDInst = !(memAddr < "h8000_0000".U || memAddr > "h8800_0000".U) &&
       ((memtoReg === "b01".U) || (memWr === 1.U))                                      //? Load and store
  val  dmemEn = Mux(LDInst, true.B, false.B)

  io.dmem.data_valid := dmemEn
  val dmemFire = io.dmem.data_valid && io.dmem.data_ready
  val alignBits = memAddr % 8.U
  
  io.dmem.data_write := memDataIn << alignBits * 8.U
  io.dmem.data_req := Mux(memWr === 1.U, REQ_WRITE, REQ_READ)
  io.dmem.data_addr := memAddr
  io.dmem.data_size := SIZE_W                //!!!
  io.dmem.data_strb := LookupTreeDefault(memOP, 0.U, List(
    "b000".U -> LookupTreeDefault(alignBits, "b0000_0001".U, List(                       // Sb
      1.U -> "b0000_0010".U,
      2.U -> "b0000_0100".U,
      3.U -> "b0000_1000".U,
      4.U -> "b0001_0000".U,
      5.U -> "b0010_0000".U,
      6.U -> "b0100_0000".U,
      7.U -> "b1000_0000".U
    )),
    "b001".U -> LookupTreeDefault(alignBits,  "b0000_0011".U, List(                      // Sh
      2.U -> "b0000_1100".U,
      4.U -> "b0011_0000".U,
      6.U -> "b1100_0000".U
    )),
    "b010".U -> Mux(alignBits === 0.U, "b0000_1111".U, "b1111_0000".U),                  // Sw
    "b011".U -> "b1111_1111".U                                                           // Sd
  ))

//  val rdata = Mux(dmemFire, io.dmem.data_read >> alignBits * 8.U, 0.U)          //? 从总线上读回来的数据
  val rdata = Mux(dmemFire, io.dmem.data_read, 0.U)                               //* 从总线上读回来的数据已经对齐处理
  
  val memAxi = dmemEn && (!dmemFire)  // mem触发总线上访存
//  io.memDone := Mux(dmemEn, Mux(io.IFDone, RegNext(!memAxi), !memAxi), !memAxi)
//  io.memDone := Mux(io.IFDone, !memAxi, RegNext(!memAxi))
  io.memDone := !memAxi
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
    "b000".U -> SignExt(rdata(7 , 0), XLEN),
    "b001".U -> SignExt(rdata(15, 0), XLEN),
    "b010".U -> SignExt(rdata(31, 0), XLEN), 
    "b011".U -> rdata,
    "b100".U -> ZeroExt(rdata(7 , 0), XLEN),
    "b101".U -> ZeroExt(rdata(15, 0), XLEN),
    "b110".U -> ZeroExt(rdata(31, 0), XLEN)
  ))
  val wData = Mux(memWr === 1.U, 0.U, rData)

  val resW = SignExt(io.in.aluRes(31,0), 64)
  val memBPData = LookupTreeDefault(io.in.memtoReg, 0.U, List(
      ("b00".U) -> io.in.aluRes,
      ("b01".U) -> wData,
      ("b10".U) -> resW
  ))
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
  val memRdEn   = io.in.rdEn
  val memRdAddr = io.in.rdAddr
  val memRdData = 0.U
  val memRs1Data = io.in.rs1Data
  val memRs2Data = io.in.rs2Data
  val memImm = io.in.imm
  val memPCSrc = io.in.pcSrc
  val memNextPC = io.in.nextPC
  val memAluRes = io.in.aluRes
  val memData = wData

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
  io.out.rdEn     := memRdEn
  io.out.rdAddr   := memRdAddr
  io.out.rdData   := memRdData
  io.out.rs1Data  := memRs1Data
  io.out.rs2Data  := memRs2Data
  io.out.imm      := memImm
  io.out.pcSrc    := memPCSrc
  io.out.nextPC   := memNextPC
  io.out.aluRes   := memAluRes
  io.out.memData  := memData

  io.memRdEn := io.in.rdEn
  io.memRdAddr := memRdAddr
  io.memRdData := memBPData
}
