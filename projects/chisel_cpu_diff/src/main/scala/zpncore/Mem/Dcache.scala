/**
  ** DCache: 
  ** 1. 两路组相连；way=2, wayDataSize = 2K, wayCacheLineNum = 128；
  ** 2. 年龄替换算法；写入cacheline为1，另一个清零。替换age=0的cacheline；
  ** 3. 阻塞式状态机：只有当前指令完成才能读取下一条；
  ** 4. 写回写分配策略，只有cacheLine发生改变时，才会通过总线写回；
  ** 5. 添加dirty寄存器：
  */

<<<<<<< HEAD
=======

>>>>>>> 84e80d7e5c9617f4b0f9144a9a80bafc9697887a
import chisel3._
import chisel3.util._

import Constant._
import utils._

class DCache extends Module {
  val io = IO(new Bundle {
    val imem = Flipped(new CoreInst)
    val out  = new AxiInst
  })

  val in = io.imem
  val out = io.out
  val cacheLineNum = 128
//  val cacheWData = RegInit(0.U(128.W))    //* 写 cacheLine
//  val cacheRData = WireInit(0.U(128.W))    //* 读 cacheLine
//  val cacheWEn = WireInit(false.B)
//  val fillCacheDone = WireInit(false.B)
//way0 and way1
  val way0Tag = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(21.W))))
  val way0V = RegInit(VecInit(Seq.fill(cacheLineNum)(false.B)))
  val way0Off = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(4.W))))
  val way0Age = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))
  val way0Dirty = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))

  val way1Tag = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(21.W))))
  val way1V = RegInit(VecInit(Seq.fill(cacheLineNum)(false.B)))
  val way1Off = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(4.W))))
  val way1Age = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))
  val way1Dirty = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))
  
  val s_IDLE :: s_READ_CACHE :: s_AXI_FILL :: s_FILL_CACHE :: Nil = Enum(4)  //! 需要再加上写的状态，参考riscv-mini
  val state = RegInit(s_IDLE)

}
