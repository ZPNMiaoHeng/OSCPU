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
//  val cacheWriteEn = WireInit(false.B)
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
  val valid_strb = Mux(reqOff(3), Cat(strbT, 0.U(64.W)), Cat(0.U(64.W), strbT))

  val valid_WData = WireInit(0.U(128.W))  // 写入cache line中数据
  val valid_BWEn  = WireInit(0.U(128.W))  // 写入cacheLine中掩码

//*------------------------------ DCache Machine --------------------------------
  switch(state) {
    is(s_IDLE) {
      when( cacheValid ) {
        state := s_CACHE_HIT
      }
    }
    is(s_CACHE_HIT) {             //* 判断是否命中Cache 0b001
      when ( cacheHitEn ) {
        when(in.data_req === REQ_READ) {
          state := s_IDLE
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
//      when( cacheWriteEn ) {    // Cache 写入完成信号：Load需要等总线访存结束后，延迟一个周期让其写入DCache；store待定
        state := s_CACHE_DONE
//      }
    }
    is(s_CACHE_DONE) {           //? 是否还需要一周期呢？直接放入写cache时对寄存器操作： 延迟一周期写入寄存器 0x110
      state := s_IDLE
    }
  }
//*----------------------------- control signals --------------------------------
  val sIDLEEn = state === s_IDLE
  cacheValid := in.data_valid

  // Cache Hit
  val sHitEn = state === s_CACHE_HIT
  val way0Hit = way0V(reqIndex) && (way0Tag(reqIndex) === reqTag)           // 两路组相连 Hit情况
  val way1Hit = way1V(reqIndex) && (way1Tag(reqIndex) === reqTag)
  cacheHitEn := (way0Hit || way1Hit )

  // Cache Miss and find cacheLine
  val ageWay0En = !cacheHitEn && (Mux(in.data_req === REQ_READ, way0Age(reqIndex) === 0.U, 
                    ((way0Tag(reqIndex) === reqTag) && (way0Age(reqIndex) === 1.U)) || ((way0Tag(reqIndex) === 0.U) && (way0Age(reqIndex) === 0.U ))
                    ))                //* 年龄替换算法 ++ 添加store age 处理
  val ageWay1En = !cacheHitEn && (Mux(in.data_req === REQ_READ, way1Age(reqIndex) === 0.U, 
                    ((way1Tag(reqIndex) === reqTag) && (way1Age(reqIndex) === 1.U)) || ((way1Tag(reqIndex) === 0.U) && (way1Age(reqIndex) === 0.U ))
                    ))                // 年龄替换算法
//  val ageWay1En = !cacheHitEn && (way1Age(reqIndex) === 0.U)                // 年龄替换算法
  
  cacheLineWay := Mux(cacheHitEn, Mux(way0Hit, 0.U, 1.U), Mux(ageWay0En, 0.U, 1.U))            // 0.U->way0, 1.U->way1, way0优先级更高  ++ 添加sd 命中情况下选择cacheLine
  cacheIndex   := Mux(cacheLineWay === 0.U, Cat(0.U(1.W), reqIndex), Cat(1.U(1.W), reqIndex))  // 确定最终cacheLine 地址
  /* Load 就可以直接读取指令，但store 需要写回到Cache中 */

  val sDirtyEn = state === s_CACHE_DIRTY                                    // 确定目标地址的cacheLine是否为脏，从而跳到不同状态下
  cacheDirtyEn := Mux(cacheLineWay === 0.U, (way0Dirty(reqIndex) === 1.U), (way1Dirty(reqIndex) === 1.U))

  val sWriteEn = state === s_AXI_WRITE          //* 将这个CacheLine中数据写到存储器中 -> 总线写请求
  
  val sReadEn  = state === s_AXI_READ           //* +从存储器中读取数据
  val axiRData = WireInit(0.U(128.W)) 
  axiRData := Mux(sReadEn && out.data_ready, out.data_read, 0.U)

  val sCacheWEn = (state === s_CACHE_WRITE)     //* 将总线读取数据拼接写入Cacheline中。
                                                //* 1. load缺失，从总线读取数据,需要等待总线完成信号；dirty === 0
                                                //* 2. store: 写入数据； dirty===1
                                                //! 需要等待从总线读取数据

  val valid_data = Mux(reqOff(3), cacheRData(127, 64), cacheRData(63, 0))
  val cacheWData = MuxLookup(in.data_size, 0.U, Array(
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

  // cache write data
  valid_WEn   := sCacheWEn //|| (sReadEn && out.data_ready)
  valid_WData := Mux(sReadEn, axiRData, Mux(in.data_req, cacheWData, out.data_read))
  valid_BWEn  := Mux(sReadEn, "hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff".U,  
                    Mux(in.data_req, valid_strb , "hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff".U))
//  cacheWriteEn := Mux(in.data_req, true.B       , out.data_ready)

//! Dirty 寄存器单独处理
  when(ageWay0En) {
    when(sCacheWEn && in.data_req) {            // store 
      way0Dirty(reqIndex) := 1.U
    } .elsewhen(sWriteEn && out.data_ready) {   // cache写入存储器完成后，dirty清0
      way0Dirty(reqIndex) := 0.U
    }
  } .elsewhen(ageWay1En) {
    when(sCacheWEn && in.data_req) {
      way1Dirty(reqIndex) := 1.U
    } .elsewhen(sWriteEn && out.data_ready) {
      way1Dirty(reqIndex) := 0.U
    }
  }

  when(ageWay0En && sCacheWEn) {                     //way0
    way0V(reqIndex) := true.B
    way0Tag(reqIndex) := reqTag
    way0Age(reqIndex) := 1.U  
    way1Age(reqIndex) := 0.U
  } .elsewhen(ageWay1En && sCacheWEn) {                           //way1
    way1V(reqIndex) := true.B
    way1Tag(reqIndex) := reqTag
    way0Age(reqIndex) := 0.U
    way1Age(reqIndex) := 1.U
  }

  val sDoneEn = state === s_CACHE_DONE                      //* 写入到存储器后，更新对应寄存器

  val hitEn = RegInit(false.B)
  hitEn := sHitEn && cacheHitEn
  val rData = Mux(hitEn, cacheRData,
                Mux(sDoneEn, out.data_read, 0.U))
  val rDataHL = Mux(reqOff(3), rData(127, 64), rData(63, 0))    // 选择对应的位置；

  in.data_ready := hitEn || sDoneEn           // Cache完成标志：miss 与 hit 两种情况  

  in.data_read :=  MuxLookup(in.data_size, 0.U, Array(                //? 位扩充？
    "b00".U -> MuxLookup(reqOff(2, 0), 0.U, Array(
                    "b000".U -> Cat(0.U, rDataHL( 7, 0)),
                    "b001".U -> Cat(0.U, rDataHL(15, 8)),
                    "b010".U -> Cat(0.U, rDataHL(23,16)),
                    "b011".U -> Cat(0.U, rDataHL(31,24)),
                    "b100".U -> Cat(0.U, rDataHL(39,32)),
                    "b101".U -> Cat(0.U, rDataHL(47,40)),
                    "b110".U -> Cat(0.U, rDataHL(55,48)),
                    "b111".U -> Cat(0.U, rDataHL(63,56)),
                )),
    "b01".U -> MuxLookup(reqOff(2, 1), 0.U, Array(
                    "b00".U -> Cat(0.U, rDataHL(15, 0)),
                    "b01".U -> Cat(0.U, rDataHL(31,16)),
                    "b10".U -> Cat(0.U, rDataHL(47,32)),
                    "b11".U -> Cat(0.U, rDataHL(63,48)),
                )),
    "b10".U -> MuxLookup(reqOff(2), 0.U, Array(
                    "b0".U -> Cat(0.U, rDataHL(31, 0)),
                    "b1".U -> Cat(0.U, rDataHL(63,32)),
                )),
    "b11".U -> rDataHL,
  ))

  val axiEn = sWriteEn || sReadEn 
  out.data_valid := axiEn 
  out.data_req   := Mux(sWriteEn, REQ_WRITE, REQ_READ)
  out.data_addr  := Cat(validAddr(31, 4), 0.U(4.W))             //+ 地址就需要变换，总线读写需要四字节对齐处理
  out.data_size  := Mux(axiEn   , SIZE_D        , 0.U)          //! dirty=1，将cacheLine写入存储器中，size先试试？？？
  out.data_strb  := Mux(sWriteEn, "b1111_1111".U, 0.U)          //+ 对应掩码写入128bits
  out.data_write := Mux(sWriteEn, cacheRData    , 0.U)          //+ 写入cacheline数据

//-------------------------------- DCache Data & instantiate Module --------------------------------
  val req = Module(new S011HD1P_X32Y2D128_BW)
  req.io.CLK := clock
  req.io.CEN := true.B
  //! 不足之处还未考虑store
  req.io.WEN := valid_WEn                                               //* 触发条件：未命中，存入DCache数据 ----> load 四字节对齐处理 128bits
  req.io.BWEN := valid_BWEn                                             //* Load 掩码全为有效；
  req.io.A := cacheIndex                                                //* 地址需要对应way进行修改；
  req.io.D := valid_WData                                               //* 总线上读取得128bits
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