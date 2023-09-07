import chisel3._
import chisel3.util._
import Constant._
import utils._

  class bht extends Module {
    val io = IO(new Bundle {
      val valid = Input(Bool())
      val fire = Input(Bool())
      val pc = Input(UInt(32.W)) //Current PC

      val jal = Input(Bool())
      val jalr = Input(Bool())
      val bxx = Input(Bool())
      val imm = Input(UInt(XLEN.W))
      val rs1Addr = Input(UInt(5.W))

      val rs1Data = Input(UInt(64.W))   //ret jump address
      val rs1x1Data = Input(UInt(64.W))
      val exeX1En = Input(Bool())
      val exeAluRes = Input(UInt(64.W))
      val memX1En = Input(Bool())
      val memAluRes = Input(UInt(64.W))
      val wbRdEn = Input(Bool())
      val wbRdAddr = Input(UInt(5.W))
      val wbRdData = Input(UInt(64.W))

      val takenValid = Input(Bool())    // predecte result
      val takenValidJalr = Input(Bool()) //TODO(jalr) connect
      val takenMiss = Input(Bool())     // 预测失败信号
      val exTakenPre = Input(Bool())
      val takenPC = Input(UInt(WLEN.W))
      val nextPC = Input(UInt(WLEN.W)) // 跳转指令跳转的地址

      val takenPre = Output(Bool())
      val takenPrePC = Output(UInt(32.W))
      val ready = Output(Bool())

      val coreEnd = Input(Bool())
    })

    val rs1x0 = (io.rs1Addr === 0.U(5.W))
    val rs1x1 = (io.rs1Addr === 1.U(5.W))
    val rs1xn = !(rs1x0 | rs1x1)
    val rs1x1Data = Mux(io.exeX1En, io.exeAluRes,          // EXE选择ALU计算后结果
                      Mux(io.memX1En, io.memAluRes,        // NEN选择输入结果
                        Mux(io.wbRdEn && io.wbRdAddr === 1.U, io.wbRdData,
                          io.rs1x1Data)))
    val op1 = Mux(io.bxx | io.jal, io.pc,
                Mux(io.jalr & rs1x0, 0.U(64.W),
                  Mux(io.jalr & rs1x1, rs1x1Data, io.rs1Data)))
    val op2 = io.imm
    val takenMiss = io.takenMiss

    val BhtWidth = 6 // 7
    val BhtSize = 64 //* 128
    val BhtAddrSize = log2Up(BhtSize) //* 6       // 7
    val PhtNum = 3                          // P0:CPHT P1:GHR P2:BHT
    val PhtSize = 64 // 128                       // 2^7=128
    // val PhtSize = 2 ^ BhtWidth           // 2^8=256
    val BTBSets = 64 // 128
    val BTBWays = 1
    val BTBTag =  6 // 7
    val BTBMeta = 32

    def defaultState() : UInt = 1.U (2.W)                      // 2bits start

    def fnvHash(data: UInt): UInt = {
      val prime = BigInt("16777619")
      var hash: UInt = 216613626.U
      for (i <- 0 until data.getWidth by 8) {
        val byte = data(i+7, i)
        hash = (hash ^ byte.asUInt()) * prime.U
      }
      hash
    }

    def xorHash(data: UInt): UInt = {
      val hash0 = data(0) ^ (data(6) ^ data(12))
      val hash1 = (data(7) ^ data(8)) ^ ((data(1) ^ data(13)))
      val hash2 = data(2) ^ (data(8) ^ data(9))
      val hash3 = data(3) ^ (data(9) ^ data(10))
      val hash4 = data(4) ^ (data(10) ^ data(11))
      val hash5 = data(5) ^ (data(11) ^ data(12))
      val hash6 = data(6) ^ (data(7) ^ data(8))
      hash6 ## hash5 ## hash4 ## hash3 ## hash2 ## hash1 ## hash0
    }

    def xorHash_126_WJH(data: UInt): UInt = {
      val hash0 = data(0) ^ (data(6) ^ data(10))
      val hash1 = (data(6) ^ data(7)) ^ ((data(1) ^ data(11)))
      val hash2 = data(2) ^ (data(8) ^ data(7))
      val hash3 = data(3) ^ (data(9) ^ data(8))
      val hash4 = data(4) ^ (data(10) ^ data(9))
      val hash5 = data(5) ^ (data(11) ^ data(10))
      hash5 ## hash4 ## hash3 ## hash2 ## hash1 ## hash0
    }

    def xorHash_126_MH(data: UInt): UInt = {
      val hash0 = data(0) ^ (data(6) ^ data(11))
      val hash1 = (data(6) ^ data(7)) ^ data(1)
      val hash2 = data(2) ^ (data(8) ^ data(7))
      val hash3 = data(3) ^ (data(9) ^ data(8))
      val hash4 = data(4) ^ (data(10) ^ data(9))
      val hash5 = data(5) ^ (data(11) ^ data(10))
      hash5 ## hash4 ## hash3 ## hash2 ## hash1 ## hash0
    }
/*
    def bhtAddr(pc: UInt) : UInt = xorHash(pc)
    def phtAddr(pc: UInt, regData: UInt) : UInt = xorHash(pc) ^ regData
    def btbAddr(pc: UInt) : UInt = xorHash(pc)
*/
/*
    def bhtAddr(pc: UInt) : UInt = fnvHash(pc)(5, 0)
    def phtAddr(pc: UInt, regData: UInt) : UInt = fnvHash(pc)(5, 0) ^ regData
    def btbAddr(pc: UInt) : UInt = fnvHash(pc)(5, 0)
*/

/*
    def bhtAddr(pc: UInt) : UInt = xorHash_126_WJH(pc(13, 2))
    def phtAddr(pc: UInt, regData: UInt) : UInt = xorHash_126_WJH(pc(13, 2)) ^ regData
    def btbAddr(pc: UInt) : UInt = xorHash_126_WJH(pc(13, 2))
   */

// /*
    def bhtAddr(pc: UInt) : UInt = xorHash_126_MH(pc(13, 2))
    def phtAddr(pc: UInt, regData: UInt) : UInt = xorHash_126_MH(pc(13, 2)) ^ regData
    def btbAddr(pc: UInt) : UInt = xorHash_126_MH(pc(13, 2))
  //  */
/*/
    def bhtAddr(pc: UInt) : UInt = pc(7,2)
    def phtAddr(pc: UInt, regData: UInt) : UInt = pc(7, 2) ^ regData
    def btbAddr(pc: UInt) : UInt = pc(7,2)
   */



    val ghr = RegInit(0.U(BhtWidth.W))
    val bht = RegInit(VecInit(Seq.fill(BhtSize)(0.U(BhtWidth.W))))  // 128 * 7 bits
    val pht = RegInit(VecInit(Seq.fill(PhtNum)(VecInit(Seq.fill(PhtSize)(defaultState())))))   // 3 * 128 * 2 (01) bits

    // val btbV = RegInit(VecInit(Seq.fill(BTBWays)(VecInit(Seq.fill(BTBSets)(false.B)))))   // 1 * 128 * 1 bits
    val btbV = RegInit(VecInit(Seq.fill(BTBSets)(false.B)))
    val btbTag = RegInit(VecInit(Seq.fill(BTBSets)(0.U(BTBTag.W))))
    val btbMeta = RegInit(VecInit(Seq.fill(BTBSets)(0.U(BTBMeta.W))))

    val btbCounter = RegInit(VecInit(Seq.fill(BTBSets)(0.U(BTBMeta.W))))
    val btbPC = RegInit(VecInit(Seq.fill(BTBSets)(0.U(BTBMeta.W))))     // 保存PC, 用以查看 冲突
    val hashCounter = RegInit(0.U(BTBMeta.W))
    // val btbTag = RegInit(VecInit(Seq.fill(BTBWays)(VecInit(Seq.fill(BTBSets)(0.U(BTBTag.W))))))   // 1 * 128 * 7 bits
    // val btbMeta = RegInit(VecInit(Seq.fill(BTBWays)(VecInit(Seq.fill(BTBSets)(0.U(BTBMeta.W))))))   // 1 * 128 * 32 bits

    val p1Addr   = phtAddr(io.pc, ghr)
    val bhtData  = bht(bhtAddr(io.pc))
    val pht0Data = pht(0)(p1Addr)
    val pht1Data = pht(1)(p1Addr)
    val pht2Data = pht(2)(phtAddr(io.pc, bhtData))
    val phtData  = Mux(pht0Data(1).asBool(), pht2Data, pht1Data)

//    val btbV
    // val reqTag = bhtAddr(io.pc)
    // val reqTag = xorHash_126_WJH(io.pc(13, 2))
    val reqTag = btbAddr(io.pc)
    val reqIndex = io.pc(9, 4)  // NOTE BTB index
    // val reqIndex = io.pc(8, 3)  // NOTE BTB index
    // val reqIndex = io.pc(12, 7)  // NOTE 
    // val reqIndex = io.pc(11, 6)  // NOTE BTB index
    // val reqIndex = io.pc(10, 5)  // NOTE BTB index

    // val reqIndex = btbAddr(io.pc)  // NOTE BTB index
    // val reqIndex = io.pc(10, 4)
    val btbHit = (io.bxx || io.jalr) && io.takenPre && btbV(reqIndex) && (btbTag(reqIndex) === reqTag)
    val reqAdd = btbMeta(reqIndex)

    // Output
    io.takenPre := Mux(io.valid,
                    Mux(io.jal | io.jalr, true.B,
                      Mux(io.bxx, phtData(1).asBool(), false.B)), false.B)
    // io.takenPrePC := Mux(io.valid && io.takenPre, op1 + op2, 0.U)
    io.takenPrePC := Mux(io.valid && io.takenPre,
                      Mux(btbHit, reqAdd, op1 + op2), 
                        0.U)
    io.ready := Mux(io.valid && io.bxx, RegNext(io.fire), io.fire)                 // 只有bxx指令才需要延迟一个周期,从2bits reg读取数据

    // update: bht ghr
    val bhtWAddr = bhtAddr(io.takenPC)
    val bhtWData = bht(bhtWAddr)

    // update pht
    val pht1WAddr = phtAddr(io.takenPC, ghr)
    val pht2WAddr = phtAddr(io.takenPC, bhtWData)   //NOTE:bhr
    val pht0WData = pht(0)(pht1WAddr)
    val pht1WData = pht(1)(pht1WAddr)
    val pht2WData = pht(2)(pht2WAddr)                   //NOTE:bhr
    
    val p1Suc = pht1WData(1).asBool() === io.exTakenPre
    val p2Suc = pht2WData(1).asBool() === io.exTakenPre
    val pht0Choice = p1Suc ## p2Suc

// update pht
    when(io.fire & io.takenValid ){                                              /*EX 反馈信息, 更新相对应的PHT*/
      pht(0)(pht1WAddr) := LookupTreeDefault(pht0WData, defaultState(), List(
        "b00".U -> Mux(pht0Choice === "b01".U, "b01".U, "b00".U),     // Stronngly taken
        "b01".U -> Mux(pht0Choice === "b01".U, "b10".U, 
                      Mux(pht0Choice === "b10".U, "b00".U, "b01".U)),     // Weakly taken
        "b10".U -> Mux(pht0Choice === "b10".U, "b01".U, 
                      Mux(pht0Choice === "b01".U, "b11".U, "b10".U)),     // Weakly not taken
        "b11".U -> Mux(pht0Choice === "b10".U, "b10".U, "b11".U)      // Strongly not takenaaa
      ))
    } 
    when(io.fire & io.takenValid ){                                              /*EX 反馈信息, 更新相对应的PHT*/
      pht(1)(pht1WAddr) := LookupTreeDefault(pht1WData, defaultState(), List(
        "b00".U -> Mux(takenMiss, "b01".U, "b00".U),     // Stronngly taken
        "b01".U -> Mux(takenMiss, "b10".U, "b00".U),     // Weakly taken
        "b10".U -> Mux(takenMiss, "b01".U, "b11".U),     // Weakly not taken
        "b11".U -> Mux(takenMiss, "b10".U, "b11".U)      // Strongly not takenaaa
      ))
    }
    when(io.fire & io.takenValid ){                                              /*EX 反馈信息, 更新相对应的PHT*/
      pht(2)(pht2WAddr) := LookupTreeDefault(pht2WData, defaultState(), List(
        "b00".U -> Mux(takenMiss, "b01".U, "b00".U),     // Stronngly taken
        "b01".U -> Mux(takenMiss, "b10".U, "b00".U),     // Weakly taken
        "b10".U -> Mux(takenMiss, "b01".U, "b11".U),     // Weakly not taken
        "b11".U -> Mux(takenMiss, "b10".U, "b11".U)      // Strongly not takenaaa
      ))
    }
    
    when(io.fire && io.takenValid) {
      bht(bhtWAddr) :=  bhtWData(BhtWidth-2, 0) ## io.exTakenPre
      ghr := ghr(BhtWidth-2, 0) ## io.exTakenPre
    }

// update btb
  // val upIndex = io.takenPC(11, 6)
  // val upIndex = io.takenPC(12, 7)
  // val upIndex = io.takenPC(8, 3)
  // val upIndex = io.takenPC(10, 5)
  val upIndex = io.takenPC(9, 4)
  // val upIndex = btbAddr(io.takenPC)
  // val upIndex = io.takenPC(10, 4)
  
  when(io.exTakenPre && io.fire && (io.takenValid || io.takenValidJalr)) {
  // when((io.takenValid || io.takenValidJalr)) {
    btbV(upIndex) := true.B
    btbTag(upIndex) := btbAddr(io.takenPC)
    // btbTag(upIndex) := bhtAddr(io.takenPC)
    btbMeta(upIndex) := io.nextPC
    // btbCounter(upIndex) := btbCounter(upIndex) + 1.U
    btbPC(upIndex) := io.takenPC
    when(io.takenPC =/= btbPC(upIndex)) {
      btbCounter(upIndex) := btbCounter(upIndex) + 1.U
      hashCounter := hashCounter + 1.U
    }
  }

  when(RegNext(io.coreEnd)) {
   printf("BTB hit\t%d\n", hashCounter)
   printf("%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t\n", btbCounter(0), btbCounter(1), btbCounter(2), btbCounter(3), btbCounter(4), btbCounter(5), btbCounter(6), btbCounter(7))
   printf("%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t\n", btbCounter(8), btbCounter(9), btbCounter(10), btbCounter(11), btbCounter(12), btbCounter(13), btbCounter(14), btbCounter(15))
   printf("%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t\n", btbCounter(16), btbCounter(17), btbCounter(18), btbCounter(19), btbCounter(20), btbCounter(21), btbCounter(22), btbCounter(23))
   printf("%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t\n", btbCounter(24), btbCounter(25), btbCounter(26), btbCounter(27), btbCounter(28), btbCounter(29), btbCounter(30), btbCounter(31))
   printf("%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t\n", btbCounter(32), btbCounter(33), btbCounter(34), btbCounter(35), btbCounter(36), btbCounter(37), btbCounter(38), btbCounter(39))
   printf("%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t\n", btbCounter(40), btbCounter(41), btbCounter(42), btbCounter(43), btbCounter(44), btbCounter(45), btbCounter(46), btbCounter(47))
   printf("%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t\n", btbCounter(48), btbCounter(49), btbCounter(50), btbCounter(51), btbCounter(52), btbCounter(53), btbCounter(54), btbCounter(55))
   printf("%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t\n", btbCounter(56), btbCounter(57), btbCounter(58), btbCounter(59), btbCounter(60), btbCounter(61), btbCounter(62), btbCounter(63))
  }
}