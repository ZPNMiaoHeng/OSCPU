import chisel3._ 
import chisel3.util._
import chisel3.experimental.FlatIO
import Constant._
import utils._
/**
 ** Execute operate include add/sub/Slt/Sltu/Xor/Or/And/Sll/Srl/Sra
 ** Improve: 1. Add module improve;  2. Shifter Module; 3.MUL and div
 ** Module improve: Sub->Add module
 */

 class ALU extends Module {
     val io = IO(new Bundle {
         val memtoReg = Input(UInt(2.W))
         val pc = Input(UInt(WLEN.W))

         val aluRes = Output(UInt(XLEN.W))
         val less   = Output(UInt(1.W))
         val zero   = Output(UInt(1.W))
     })
    val mul = Module(new Mul)
    val div = Module(new Div)

    val aluIO = FlatIO(Flipped(new AluIO))

    val Asrc = Mux(aluIO.ctrl.aluA === 0.U, aluIO.data.rData1, io.pc)                           //op1R

    val instW = io.memtoReg(1)
    val in1 = Mux(instW, (Mux(aluIO.ctrl.aluOp === "b1101".U, 
      SignExt(Asrc(31, 0), XLEN), ZeroExt(Asrc(31, 0), XLEN))),
        Asrc)

    val in2  = MuxLookup(aluIO.ctrl.aluB, 0.U, List(
      "b00".U -> aluIO.data.rData2,
      "b01".U -> aluIO.data.imm,
      "b10".U -> 4.U,
      "b11".U -> 0.U))                                                                                              //op2R

    mul.io.in.valid := aluIO.ctrl.aluOp === "b1110".U
    mul.io.in.bits(0) := in1
    mul.io.in.bits(1) := in2
    mul.io.out.ready := true.B    

    div.io.in.validD := aluIO.ctrl.aluOp === "b1100".U
    div.io.in.data1 := in1
    div.io.in.data2 := in2
    div.io.in.isW := instW
    div.io.in.sign := false.B
    div.io.in.flush := false.B

    val shamt = Mux(instW, in2(4, 0).asUInt(), in2(5, 0))
  
      val addRes = (in1 + in2).asUInt()
      val subRes = (in1 - in2).asUInt()
      val xorRes = (in1 ^ in2).asUInt
      val orRes  = (in1 | in2).asUInt
      val andRes = (in1 & in2).asUInt
      val sLRes    = ((in1 << shamt)(63, 0)).asUInt()
      val sRLRes   = (in1 >> shamt).asUInt()
      val sRARes   = (in1.asSInt() >> shamt).asUInt()

      val sLTRes   = (in1.asSInt() < in2.asSInt()).asUInt()
      val sLTURes  = (in1 < in2).asUInt()
      
      val remwRes  = (in1.asSInt % in2.asSInt).asUInt
      // val divRes   = (in1 / in2).asUInt
      // val divRes   = Cat(div.io.out.resH , div.io.out.resL)
      val divRes   = div.io.out.resH// , div.io.out.resL
      // val mulRes   = (in1 * in2).asUInt
      val mulRes =  mul.io.out.bits

      val aluResult = MuxLookup(aluIO.ctrl.aluOp, 0.U, 
       List(
       ("b0000".U) -> addRes,
       ("b1000".U) -> subRes,
       ("b1001".U) -> subRes,

       ("b0010".U) -> sLTRes,                // <<
       ("b1010".U) -> sLTURes,
       
       ("b0101".U) -> sRLRes,  //(in2 >> ashamt).asUInt(),
       ("b1101".U) -> sRARes,
       
       ("b0001".U) -> sLRes,
       ("b0011".U) -> in2 ,
       ("b1011".U) -> remwRes,
       
       ("b0100".U) -> xorRes,
       ("b1100".U) -> divRes,
       
       ("b0110".U) -> orRes,
       ("b1110".U) -> mulRes,
       
       ("b0111".U) -> andRes))

    io.less := Mux(aluIO.ctrl.aluOp(3) === 1.U, sLTURes, sLTRes)
    io.zero := (aluResult === 0.U)
    io.aluRes := Mux(instW, SignExt(aluResult(31, 0), XLEN), aluResult)
    }