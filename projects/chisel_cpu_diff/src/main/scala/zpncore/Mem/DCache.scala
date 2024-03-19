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

  val cacheRData   = WireInit(0.U(128.W))     // 读 cacheLine
  val cacheValid   = WireInit(false.B)
  val cacheHitEn   = WireInit(false.B)
  val cacheLineWay = WireInit(false.B)
  val cacheDirtyEn = WireInit(false.B)
  val cacheIndex   = WireInit(0.U(8.W))

  val way0V     = RegInit(VecInit(Seq.fill(cacheLineNum)(false.B)))          //way0 and way1
  val way0Tag   = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(21.W))))
  val way0Off   = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(4.W))))
  val way0Age   = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))
  val way0Dirty = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))

  val way1V     = RegInit(VecInit(Seq.fill(cacheLineNum)(false.B)))
  val way1Tag   = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(21.W))))
  val way1Off   = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(4.W))))
  val way1Age   = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))
  val way1Dirty = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))

  val s_IDLE :: s_CACHE_HIT :: s_CACHE_DIRTY :: s_AXI_WRITE :: s_AXI_READ :: s_CACHE_WRITE :: s_CACHE_DONE :: Nil = Enum(7)
  val state = RegInit(s_IDLE)
  
//*-------------------------- signal define  ----------------------------------------
  val validAddr = in.data_addr
  val reqTag   = validAddr(31, 11)                                           //  对应正确地址，发生写缺失时，需要被替换
  val reqIndex = validAddr(10, 4 )                                           //  选择对应CacheLine
  val reqOff   = validAddr(3 , 0 )                                           //  选择cacheLine Date 位置

  val valid_WEn = WireInit(0.U(1.W))                                         // in.data_req
  val strbT = LookupTreeDefault(in.data_strb, 0.U, List(                     // 对应 64bits下存储位置，掩码转换
    "b0000_0001".U -> "h00000000000000ff".U,  //sb
    "b0000_0010".U -> "h000000000000ff00".U,
    "b0000_0100".U -> "h0000000000ff0000".U,
    "b0000_1000".U -> "h00000000ff000000".U,
    "b0001_0000".U -> "h000000ff00000000".U,
    "b0010_0000".U -> "h0000ff0000000000".U,
    "b0100_0000".U -> "h00ff000000000000".U,
    "b1000_0000".U -> "hff00000000000000".U,
    "b0000_0011".U -> "h000000000000ffff".U,  //sh
    "b0000_1100".U -> "h00000000ffff0000".U,
    "b0011_0000".U -> "h0000ffff00000000".U,
    "b1100_0000".U -> "hffff000000000000".U,
    "b0000_1111".U -> "h00000000ffffffff".U,  //sw
    "b1111_0000".U -> "hffffffff00000000".U,
    "b1111_1111".U -> "hffffffffffffffff".U   //sd
  ))
  // val valid_strb  = Mux(reqOff(3), Cat(strbT, 0.U(64.W)), Cat(0.U(64.W), strbT))
  val valid_strb  = Mux(reqOff(3), Cat(in.data_strb, 0.U(8.W)), Cat(0.U(8.W), in.data_strb))
  val valid_WData = WireInit(0.U(128.W))  // 写入cache line中数据
  val valid_BWEn  = WireInit(0.U(128.W))  // 写入cacheLine中掩码

//*------------------------------ DCache Machine --------------------------------
  switch(state) {
    is(s_IDLE) {
      when( cacheValid) {
        state := s_CACHE_HIT
      }
    }
    is(s_CACHE_HIT) {             //* 判断是否命中Cache 0b001
      when ( cacheHitEn ) {
        when(in.data_req === REQ_READ) {
          state := s_CACHE_DONE
        } .otherwise {
          state := s_CACHE_WRITE  // store 命中后进入写cacheline状态
        }
      } .otherwise { 
        state := s_CACHE_DIRTY
      }
    }
    is(s_CACHE_DIRTY) {          //* 当cache未命中时，年龄算法选出的 way对应的 CacheLine Dity 是否有效 0b010
      when( cacheDirtyEn ) {
        state := s_AXI_WRITE  
      } .otherwise {
        state := s_AXI_READ
      }
    }
    is(s_AXI_WRITE) {            //* 选中的Cacheline为dirty，AXI写回 0x011
      when( out.data_ready ) {   // 总线写 完成信号
        state := s_AXI_READ
      }
    }
    is(s_AXI_READ) {            //* 从存储器中读取数据放入对应cacheline中 0x100
      when( out.data_ready) {   // 总线读 完成信号
        state := s_CACHE_WRITE
      }
    }
    is(s_CACHE_WRITE) {         //* 对cacheline 写操作 0x101
        state := s_CACHE_DONE
    }
    is(s_CACHE_DONE) {
      state := s_IDLE
    }
  }
//*----------------------------- control signals --------------------------------
  val sIDLEEn = (state === s_IDLE)
  cacheValid := in.data_valid

  // Cache Hit
  val sHitEn = state === s_CACHE_HIT
  val way0Hit = way0V(reqIndex) && (way0Tag(reqIndex) === reqTag)
  val way1Hit = way1V(reqIndex) && (way1Tag(reqIndex) === reqTag)
  cacheHitEn := (way0Hit || way1Hit )

  // Cache Miss and find cacheLine
  val ageWay0En = !cacheHitEn && (way0Age(reqIndex) === 0.U)
  val ageWay1En = !cacheHitEn && (way1Age(reqIndex) === 0.U)

  cacheLineWay := Mux(cacheHitEn, Mux(way0Hit, 0.U, 1.U), Mux(ageWay0En, 0.U, 1.U))            // 0.U->way0, 1.U->way1, way0优先级更高 / 添加store,命中情况下选择cacheLine
  cacheIndex   := Mux(cacheLineWay === 0.U, Cat(0.U(1.W), reqIndex), Cat(1.U(1.W), reqIndex))  // 确定最终cacheLine 写入地址

  val sDirtyEn = state === s_CACHE_DIRTY                                    // 确定目标地址的cacheLine是否为脏，从而跳到不同状态下
  cacheDirtyEn := Mux(cacheLineWay === 0.U, way0Dirty(reqIndex), way1Dirty(reqIndex))

  val sWriteEn = state === s_AXI_WRITE          //* 将这个CacheLine中数据写到存储器中 -> 总线写请求
  
  val sReadEn  = state === s_AXI_READ           //* 从存储器中读取数据

  val sCacheWEn = (state === s_CACHE_WRITE)     //* 将总线读取数据拼接写入Cacheline中。
                                                //* 1. load缺失，从总线读取数据,需要等待总线完成信号；dirty === 0
                                                //* 2. store: 写入数据； dirty===1

// Store 存入数据
  val valid_data = Mux(reqOff(3), cacheRData(127, 64), cacheRData(63, 0))
  val inDataWT   = Mux(reqOff(3), in.data_write(127, 64), in.data_write(63, 0))
  val cacheWDataT = MuxLookup(in.data_size, 0.U, Array(
    "b00".U -> MuxLookup(reqOff(2, 0), 0.U, Array(
                    "b000".U -> Cat(valid_data(63, 8), inDataWT( 7, 0)),
                    "b001".U -> Cat(valid_data(63,16), inDataWT(15, 8), valid_data( 7, 0)),
                    "b010".U -> Cat(valid_data(63,24), inDataWT(23,16), valid_data(15, 0)),
                    "b011".U -> Cat(valid_data(63,32), inDataWT(31,24), valid_data(23, 0)),
                    "b100".U -> Cat(valid_data(63,40), inDataWT(39,32), valid_data(31, 0)),
                    "b101".U -> Cat(valid_data(63,48), inDataWT(47,40), valid_data(39, 0)),
                    "b110".U -> Cat(valid_data(63,56), inDataWT(55,48), valid_data(47, 0)),
                    "b111".U -> Cat(inDataWT(63,56), valid_data(55, 0)),
                )),
    "b01".U -> MuxLookup(reqOff(2, 1), 0.U, Array(
                    "b00".U -> Cat(valid_data(63,16), inDataWT(15, 0)),
                    "b01".U -> Cat(valid_data(63,32), inDataWT(31,16), valid_data(15, 0)),
                    "b10".U -> Cat(valid_data(63,48), inDataWT(47,32), valid_data(31, 0)),
                    "b11".U -> Cat(inDataWT(63,48), valid_data(47, 0)),
                )),
    "b10".U -> MuxLookup(reqOff(2), 0.U, Array(
                    "b0".U -> Cat(valid_data(63,32), inDataWT(31, 0)),
                    "b1".U -> Cat(inDataWT(63,32), valid_data(31, 0)),
                )),
    "b11".U -> inDataWT,
  ))
  val cacheWData = Mux(reqOff(3), Cat(cacheWDataT, 0.U(64.W)), Cat(0.U(64.W), cacheWDataT))

  // cache write data
  valid_WEn   := sCacheWEn || (sReadEn && out.data_ready)
  valid_WData := Mux(sReadEn && out.data_ready, out.data_read,       // Axi Read Data
                  Mux(in.data_req, cacheWData , out.data_read))      // store/load inst
  // valid_BWEn  := Mux(sReadEn && out.data_ready, "hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff".U,
                  // Mux(in.data_req, valid_strb , "hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff".U))
  valid_BWEn  := Mux(sReadEn && out.data_ready, "hffff_ffff".U,
                  Mux(in.data_req, valid_strb , "hffff_ffff".U))

//*------------------- update reg ----------------------------------------------------------------
  when(ageWay0En || way0Hit) {
    when(sCacheWEn && in.data_req) {            // store 
      way0Dirty(reqIndex) := 1.U
    } .elsewhen(sWriteEn && out.data_ready) {   // cache写入存储器完成后，dirty清0
      way0Dirty(reqIndex) := 0.U
    }
  } .elsewhen(ageWay1En || way1Hit) {
    when(sCacheWEn && in.data_req) {
      way1Dirty(reqIndex) := 1.U
    } .elsewhen(sWriteEn && out.data_ready) {
      way1Dirty(reqIndex) := 0.U
    }
  }

  val sDoneEn = state === s_CACHE_DONE 

  when(ageWay0En && sDoneEn) {                     //way0
    way0V(reqIndex) := true.B
    way0Tag(reqIndex) := reqTag
    way0Age(reqIndex) := 1.U  
    way1Age(reqIndex) := 0.U
  } .elsewhen(ageWay1En && sDoneEn) {              //way1
    way1V(reqIndex) := true.B
    way1Tag(reqIndex) := reqTag
    way0Age(reqIndex) := 0.U
    way1Age(reqIndex) := 1.U
  }
//*------------------------ Output Data ----------------------------------------       
  val hitEn = RegInit(false.B)
  hitEn := sHitEn && cacheHitEn
  val rData = Mux(hitEn, cacheRData,
                Mux(sDoneEn, out.data_read, 0.U))
  val rDataHL = Mux(reqOff(3), rData(127, 64), rData(63, 0))

  in.data_ready := Mux(in.data_req, sDoneEn,  hitEn || sDoneEn)           // Cache完成标志：miss 与 hit 两种情况  
  in.data_read :=  MuxLookup(in.data_size, 0.U, Array(                    //? 位扩充？
    "b00".U -> MuxLookup(reqOff(2, 0), 0.U, Array(
      "b000".U -> rDataHL( 7, 0),
      "b001".U -> rDataHL(15, 8),
      "b010".U -> rDataHL(23,16),
      "b011".U -> rDataHL(31,24),
      "b100".U -> rDataHL(39,32),
      "b101".U -> rDataHL(47,40),
      "b110".U -> rDataHL(55,48),
      "b111".U -> rDataHL(63,56),
    )),
    "b01".U -> MuxLookup(reqOff(2, 1), 0.U, Array(
      "b00".U -> rDataHL(15, 0),
      "b01".U -> rDataHL(31,16),
      "b10".U -> rDataHL(47,32),
      "b11".U -> rDataHL(63,48),
    )),
    "b10".U -> MuxLookup(reqOff(2), 0.U, Array(
      "b0".U -> rDataHL(31, 0),
      "b1".U -> rDataHL(63,32),
    )),
    "b11".U -> rDataHL,
  ))

//-------------------------------- AXI IO  --------------------------------
  val axiEn = sWriteEn || sReadEn 
  out.data_valid := axiEn 
  out.data_req   := Mux(sWriteEn, REQ_WRITE, REQ_READ)
  out.data_addr  := Mux(sWriteEn, 
                      Mux(cacheLineWay === 0.U, Cat(way0Tag(reqIndex), reqIndex ,0.U(4.W)), Cat(way1Tag(reqIndex), reqIndex ,0.U(4.W))), 
                        Cat(validAddr(31, 4), 0.U(4.W)))         // 地址四字节对齐
  out.data_size  := Mux(axiEn   , SIZE_D        , 0.U)
  out.data_strb  := Mux(sWriteEn, "b1111_1111".U, 0.U)          // 对应掩码写入128bits
  out.data_write := Mux(sWriteEn, cacheRData    , 0.U)          // 写入cacheline数据

//-------------------------------- DCache Data & instantiate Module --------------------------------
  val req = Module(new S011HD1P_X32Y2D128_BW)
  req.io.CLK := clock
  req.io.CEN := true.B
  req.io.WEN := valid_WEn
  req.io.BWEN := valid_BWEn
  req.io.A := cacheIndex
  req.io.D := valid_WData
  cacheRData := req.io.Q

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