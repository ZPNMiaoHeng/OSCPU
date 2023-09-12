import chisel3._
import chisel3.util._

import Constant._
/* 可以采用DecoupledIO 添加握手信号  */
//--------------------------- ContrIO -----------------------------------
// class preDebug extends Bundle {
  // val jal = Output(Bool())
  // val jal = Output(Bool())
  // val jalr =
// }
class RegCtrlIO extends Bundle {
  val rs1En = Output(Bool())
  val rs2En = Output(Bool())
  val rs1Addr = Output(UInt(5.W))
  val rs2Addr = Output(UInt(5.W))
//  val rdAddr = Output(UInt(5.W))
//  val rdEn = Output(Bool())
}

class AluCtr extends Bundle {
  val aluA = Output(UInt(1.W))
  val aluB = Output(UInt(2.W))
  val aluOp = Output(UInt(4.W))
}

class MemCtr extends Bundle {
  val memtoReg = Output(UInt(2.W))
  val memWr = Output(UInt(1.W))
  val memOP = Output(UInt(3.W))
}

class DataSrcIO extends Bundle {
  val rData1 = Output(UInt(64.W))
  val rData2 = Output(UInt(64.W))
  val imm = Output(UInt(64.W))
}

class AluIO extends Bundle {
  val ctrl = new AluCtr
  val data = new DataSrcIO
}
//--------------------------- RamIO -----------------------------------
class RomIO extends Bundle {
  val en = Output(Bool())
  val addr = Output(UInt(64.W))
  val rdata = Input(UInt(64.W))
}

class RamIO extends RomIO {
  val wdata = Output(UInt(64.W))
  val wmask = Output(UInt(64.W))
  val wen = Output(Bool())
}
//--------------------------- AxiIO ------------------------------
/* Inst */
class INSTIO extends Bundle {
  val inst_valid  = Output(Bool())
  val inst_ready  = Input(Bool())
  val inst_req    = Output(Bool())                                     // request signals:1 -> true
  val inst_addr   = Output(UInt(AxiAddrWidth.W))   
  val inst_size   = Output(UInt(2.W))                                 // ???
}

class AxiInst extends INSTIO {
  val inst_read   = Input(UInt(RW_DATA_WIDTH.W))
}

class CoreInst extends INSTIO {
  val inst_read   = Input(UInt(32.W))
}
/* Data */
class DATAIO extends Bundle {
  val data_valid  = Output(Bool())
  val data_ready  = Input(Bool())
  val data_req    = Output(Bool())
  val data_addr   = Output(UInt(AxiAddrWidth.W))           // 32 bytes
  val data_size   = Output(UInt(2.W))                      //???
  val data_strb   = Output(UInt(8.W))                      //???写请求选通信号，表示哪些写请求数据的哪些字节为有效数据
}

class AxiData extends DATAIO   {
  val data_read   = Input(UInt(RW_DATA_WIDTH.W))           // 128
  val data_write  = Output(UInt(RW_DATA_WIDTH.W)) 
}

class CoreData extends DATAIO   {
  val data_read   = Input(UInt(AxiDataWidth.W))           // 64
  val data_write  = Output(UInt(RW_DATA_WIDTH.W))//(AxiDataWidth.W)) 
}
/** ID */
trait AxiIdUser extends Bundle   {
  // val id = Output(UInt(AxiIdWidth.W))
  // val user = Output(UInt(AxiUserWidth.W))
}

class AxiLiteA extends Bundle   {
  val addr = Output(UInt(AxiAddrWidth.W))
  // val prot = Output(UInt(3.W))
}

class AxiA extends AxiLiteA with AxiIdUser {
  val len = Output(UInt(8.W))
  val size = Output(UInt(3.W))
  val burst = Output(UInt(2.W))
  // val lock = Output(Bool())
  val cache = Output(UInt(4.W))
  // val qos = Output(UInt(4.W))                                        // ???
}

class AxiLiteW extends Bundle   {
  val data = Output(UInt(AxiDataWidth.W))
  val strb = Output(UInt((AxiDataWidth / 8).W))   // 64/8
}

class AxiW extends AxiLiteW {
  val last = Output(Bool())
}

class AxiLiteB extends Bundle {
  val resp = Output(UInt(2.W))
}

class AxiB extends AxiLiteB with AxiIdUser   { }

class AxiLiteR extends Bundle   {
  val resp = Output(UInt(2.W))
  val data = Output(UInt(AxiDataWidth.W))
}

class AxiR extends AxiLiteR with AxiIdUser {
  val last = Output(Bool())
}

class AxiLiteIO extends Bundle {
  val aw = Decoupled(new AxiLiteA)
  val w = Decoupled(new AxiLiteW)
  val b = Flipped(Decoupled(new AxiLiteB))
  val ar = Decoupled(new AxiLiteA)
  val r = Flipped(Decoupled(new AxiLiteR))
}

class AxiIO extends Bundle {
  val aw = Decoupled(new AxiA)
  val w = Decoupled(new AxiW)
  val b = Flipped(Decoupled(new AxiB))
  val ar = Decoupled(new AxiA)
  val r = Flipped(Decoupled(new AxiR))
}


