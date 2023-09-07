import chisel3._
import chisel3.util.experimental._
// import difftest._
import Constant._
import javax.swing.InputMap
import javax.swing.plaf.metal.MetalTreeUI

class RegFile extends Module {
  val io = IO(new Bundle {
    val rs1Data = Output(UInt(XLEN.W))
    val rs2Data = Output(UInt(XLEN.W))
    val rdEn = Input(Bool())
    val rdAddr = Input(UInt(WLEN.W))
    val rdData = Input(UInt(XLEN.W))
    val preRs1En = Input(Bool())
    val preRs1Addr = Input(UInt(5.W))

    val preRs1Data = Output(UInt(64.W))
    val preRs1x1Data = Output(UInt(64.W))

    val ctrl = Flipped(new RegCtrlIO)
  })

  val rf = RegInit(VecInit(Seq.fill(32)(0.U(64.W))))

  when (io.rdEn && (io.rdAddr =/= 0.U)) {
    rf(io.rdAddr) := io.rdData
  }

  io.rs1Data := Mux((io.ctrl.rs1Addr =/= 0.U && io.ctrl.rs1En), rf(io.ctrl.rs1Addr), 0.U)
  io.rs2Data := Mux((io.ctrl.rs2Addr =/= 0.U && io.ctrl.rs2En), rf(io.ctrl.rs2Addr), 0.U)

  io.preRs1x1Data := rf(1.U(5.W))
  io.preRs1Data := Mux((io.preRs1En && io.preRs1Addr =/= 0.U && io.preRs1Addr =/= 1.U), rf(io.preRs1Addr), 0.U)

  // val dt_ar = Module(new DifftestArchIntRegState)
  // dt_ar.io.clock  := clock
  // dt_ar.io.coreid := 0.U
  // dt_ar.io.gpr    := rf

  BoringUtils.addSource(rf(10), "rf_a0")
}
