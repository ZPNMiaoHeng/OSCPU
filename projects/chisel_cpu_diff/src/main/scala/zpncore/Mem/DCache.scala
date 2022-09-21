/**
  ** DCache: 
  ** 1. 两路组相连；way=2, wayDataSize = 2K, wayCacheLineNum = 128；
  ** 2. 年龄替换算法；写入cacheline为1，另一个清零。替换age=0的cacheline；
  ** 3. 阻塞式状态机：只有当前指令完成才能读取下一条；
  ** 4. 写回写分配策略，只有cacheLine发生改变时，才会通过总线写回；
  ** 5. 添加dirty寄存器：
  */

import chisel3._
import chisel3.util._

import Constant._
import utils._

class DCache extends Module {
  val io = IO(new Bundle {
    val dmem = Flipped(new CoreData)
    val out  = new AxiData
  })

  val in = io.dmem
  val out = io.out
  val cacheLineNum = 128

  val cacheRData = WireInit(0.U(128.W))     // 读 cacheLine
  val cacheHitEn = WireInit(false.B)
  val cacheLineWay = WireInit(false.B)
  val cacheDirtyEn = WireInit(false.B)
  val cacheIndex = WireInit(false.B)

  val way0V = RegInit(VecInit(Seq.fill(cacheLineNum)(false.B)))          //way0 and way1
  val way0Tag = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(21.W))))
  val way0Off = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(4.W))))
  val way0Age = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))
  val way0Dirty = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))

  val way1V = RegInit(VecInit(Seq.fill(cacheLineNum)(false.B)))
  val way1Tag = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(21.W))))
  val way1Off = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(4.W))))
  val way1Age = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))
  val way1Dirty = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))

  val s_IDLE :: s_CACHE_HIT :: s_CACHE_DIRTY :: s_AXI_WRITE :: s_CACHE_WRITE :: s_CACHE_DONE :: Nil = Enum(6)
  val state = RegInit(s_IDLE)
  
//*------------------------------------------------------------------
  val validAddr = in.data_addr
  val reqTag = validAddr(31,11)
  val reqIndex = validAddr(10, 4)
  val reqOff = validAddr(3, 0)

  val valid_WEn = in.data_req
  val valid_rdata = Mux(reqOff(3), cacheRData(127, 64), cacheRData(63, 0) ) //* cacheLine Data
  val valid_strb = LookupTreeDefault(in.data_strb, 0.U, List(
    "b0000_0001".U -> "h00000000000000ff".U,
    "b0000_0010".U -> "h000000000000ff00".U,
    "b0000_0100".U -> "h0000000000ff0000".U,
    "b0000_1000".U -> "h00000000ff000000".U,
    "b0001_0000".U -> "h000000ff00000000".U,
    "b0010_0000".U -> "h0000ff0000000000".U,
    "b0100_0000".U -> "h00ff000000000000".U,
    "b1000_0000".U -> "hff00000000000000".U,

    "b0000_0011".U -> "h000000000000ffff".U,
    "b0000_1100".U -> "h00000000ffff0000".U,
    "b0011_0000".U -> "h0000ffff00000000".U,
    "b1100_0000".U -> "hffff000000000000".U,
    
    "b0000_1111".U -> "h00000000ffffffff".U,
    "b1111_0000".U -> "hffffffff00000000".U,
    
    "b1111_1111".U -> "hffffffffffffffff".U   
  ))

  val valid_data  = Mux(reqOff(3), out.data_read(127,64), out.data_read(63, 0)) //*Axi
  val valid_wdata = MuxLookup(in.data_size, 0.U, Array(
    "b00".U -> MuxLookup(reqOff(2, 0), 0.U, Array(
                    "b000".U -> Cat(valid_data(63, 8), in.data_write( 7, 0)),
                    "b001".U -> Cat(valid_data(63,16), in.data_write(15, 8), valid_data( 7, 0)),
                    "b010".U -> Cat(valid_data(63,24), in.data_write(23,16), valid_data(15, 0)),
                    "b011".U -> Cat(valid_data(63,32), in.data_write(31,24), valid_data(23, 0)),
                    "b100".U -> Cat(valid_data(63,40), in.data_write(39,32), valid_data(31, 0)),
                    "b101".U -> Cat(valid_data(63,48), in.data_write(47,40), valid_data(39, 0)),
                    "b110".U -> Cat(valid_data(63,56), in.data_write(55,48), valid_data(47, 0)),
                    "b111".U -> Cat(in.data_write(63,56), valid_data(55, 0)),
                )),
    "b01".U -> MuxLookup(reqOff(2, 1), 0.U, Array(
                    "b00".U -> Cat(valid_data(63,16), in.data_write(15, 0)),
                    "b01".U -> Cat(valid_data(63,32), in.data_write(31,16), valid_data(15, 0)),
                    "b10".U -> Cat(valid_data(63,48), in.data_write(47,32), valid_data(31, 0)),
                    "b11".U -> Cat(in.data_write(63,48), valid_data(47, 0)),
                )),
    "b10".U -> MuxLookup(reqOff(2), 0.U, Array(
                    "b0".U -> Cat(valid_data(63,32), in.data_write(31, 0)),
                    "b1".U -> Cat(in.data_write(63,32), valid_data(31, 0)),
                )),
    "b11".U -> in.data_write,
  ))

  val data_read = MuxLookup(in.data_size, 0.U, Array(                //? 位扩充？
    "b00".U -> MuxLookup(reqOff(2, 0), 0.U, Array(
                    "b000".U -> Cat(0.U, valid_rdata( 7, 0)),
                    "b001".U -> Cat(0.U, valid_rdata(15, 8)),
                    "b010".U -> Cat(0.U, valid_rdata(23,16)),
                    "b011".U -> Cat(0.U, valid_rdata(31,24)),
                    "b100".U -> Cat(0.U, valid_rdata(39,32)),
                    "b101".U -> Cat(0.U, valid_rdata(47,40)),
                    "b110".U -> Cat(0.U, valid_rdata(55,48)),
                    "b111".U -> Cat(0.U, valid_rdata(63,56)),
                )),
    "b01".U -> MuxLookup(reqOff(2, 1), 0.U, Array(
                    "b00".U -> Cat(0.U, valid_rdata(15, 0)),
                    "b01".U -> Cat(0.U, valid_rdata(31,16)),
                    "b10".U -> Cat(0.U, valid_rdata(47,32)),
                    "b11".U -> Cat(0.U, valid_rdata(63,48)),
                )),
    "b10".U -> MuxLookup(reqOff(2), 0.U, Array(
                    "b0".U -> Cat(0.U, valid_rdata(31, 0)),
                    "b1".U -> Cat(0.U, valid_rdata(63,32)),
                )),
    "b11".U -> valid_rdata,
  ))
  
  val req = Module(new S011HD1P_X32Y2D128_BW)
  req.io.CLK := clock
  req.io.CEN := true.B
  req.io.WEN := valid_WEn
  req.io.BWEN := Mux(valid_WEn, valid_strb, 0.U)
  req.io.A := cacheIndex
  req.io.D := valid_wdata
  cacheRData := req.io.Q

//*------------------------------ DCache Machine --------------------------------
  switch(state) {
    is(s_IDLE) {
      when(in.data_valid) {
        state := s_CACHE_HIT
    }
  }
    is(s_CACHE_HIT) {
      when (cacheHitEn) {
        state := s_IDLE
      } .otherwise { 
        state := s_CACHE_DIRTY
    }
  }
    is(s_CACHE_DIRTY) {
      when( cacheDirtyEn) {
        state := s_AXI_WRITE
      } .otherwise {
        state := s_CACHE_WRITE
      }
    }
     is(s_AXI_WRITE) {
      when( out.data_ready) {      //*写入完成信号
        state := s_CACHE_WRITE
      }
    }
    is(s_CACHE_WRITE) {
      when( out.data_ready ) {     //* 读取完成信号
        state := s_CACHE_DONE
      }
    }
    is(s_CACHE_DONE) {
      state := s_IDLE
    }
  }

//*----------------------------- control signals --------------------------------
  val sIDLEEn = state === s_IDLE
  
  // Cache Hit
  val sHitEn = state === s_CACHE_HIT
  val way0Hit = way0V(reqIndex) && (way0Tag(reqIndex) === reqTag) && sHitEn // 两路组相连 Hit情况
  val way1Hit = way1V(reqIndex) && (way1Tag(reqIndex) === reqTag) && sHitEn
  cacheHitEn := (way0Hit || way1Hit ) && (state === s_CACHE_HIT)

  // Cache Miss and find cacheLine
  val ageWay0En = !cacheHitEn && (way0Age(reqIndex) === 0.U) && sHitEn      // 年龄替换算法
  val ageWay1En = !cacheHitEn && (way1Age(reqIndex) === 0.U) && sHitEn      // 年龄替换算法
  cacheLineWay := Mux(ageWay0En, 0.U, 1.U)                               // 0.U->way0, 1.U->way1, way0优先级更高
  
  val sDirtyEn = state === s_CACHE_DIRTY
 
  cacheDirtyEn := Mux(sDirtyEn, Mux(cacheLineWay === 0.U, 
        way0Dirty(reqIndex), way1Dirty(reqIndex)), 0.U)

  cacheIndex := Mux(cacheLineWay === 0.U, Cat(0.U(1.W), reqIndex), Cat(1.U(1.W), reqIndex))  // 最后确定好某个way

  val sWriteEn = state === s_AXI_WRITE      //* 将这个CacheLIne中数据写到存储器中 -> 总线写请求

  val sReadEn = state === s_CACHE_WRITE     //* 将存储器中对应位置写入到cacheLine中 -> 总线读请求
  val axiEn = sWriteEn || sReadEn

  out.data_valid := axiEn
  out.data_req := Mux(sWriteEn, REQ_WRITE, REQ_READ)
  out.data_addr := Mux(sWriteEn, 0.U, validAddr) //! 地址就需要变换，总线读写需要四字节对齐处理
  out.data_size := Mux(axiEn, SIZE_D, 0.U) //??!
  out.data_strb := Mux(sWriteEn, in.data_strb, 0.U)
  out.data_write := Mux(sWriteEn, cacheRData, 0.U)  //TODO: implement

  val sDoneEn = state === s_CACHE_DONE                      //* 写入到存储器后，更新对应寄存器
  way0Age(reqIndex) := Mux(ageWay0En && sDoneEn, 1.U, 0.U)  //* 年龄替换算法
  way1Age(reqIndex) := Mux(ageWay0En && sDoneEn, 0.U, 1.U)
  when(sDoneEn) {
    when(cacheLineWay) {                     //way0
      way0V(reqIndex) := true.B
      way0Tag(reqIndex) := reqTag
      way0Dirty(reqIndex) := 0.U             //? Load
    } .otherwise {                           //way1
      way1V(reqIndex) := true.B
      way1Tag(reqIndex) := reqTag
      way1Dirty(reqIndex) := 0.U             //? Load
    }
  }

  val rData = Mux(sHitEn, cacheRData,
                Mux(sDoneEn, out.data_read, 0.U))

  in.data_ready := sDoneEn || (sHitEn && cacheHitEn)            // Cache完成标志：miss 与 hit 两种情况
  in.data_read := data_read //?Mux(reqOff(3), rData(127, 64), rData(63, 0))

  class S011HD1P_X32Y2D128_BW extends BlackBox with HasBlackBoxResource {
    val io = IO(new Bundle {
      val Q   = Output(UInt(128.W))
      val CLK = Input(Clock())
      val CEN = Input(Bool())
      val WEN = Input(Bool())
      val BWEN = Input(UInt(128.W))
      val A   = Input(UInt(8.W))
      val D   = Input(UInt(128.W))
    })
    addResource("/vsrc/S011HD1P_X32Y2D128_BW.v")
 }
}