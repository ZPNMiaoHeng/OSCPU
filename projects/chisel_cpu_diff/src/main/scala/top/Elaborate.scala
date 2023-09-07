//package zpncore

import chisel3._
import chisel3.stage._

object Elaborate extends App {
  def parseArgs(info: String,args: Array[String]):String = {
      var value = "";
      for(arg <- args){
          if(arg.startsWith(info + "=") == true){
              value = arg;
          }
      }
      require(value != "");
      value.substring(info.length + 1);
  }

    val top = parseArgs("TopModule", args)

  if(top == "ALU") {
    (new ChiselStage).execute(args, Seq(
      ChiselGeneratorAnnotation(() => new ALU())))
  } else if(top == "Decode") {
    println("------------------- Generate Decode.v ---------------- ")
    (new ChiselStage).execute(args, Seq(
      ChiselGeneratorAnnotation(() => new Decode())))
  } else if(top == "Core") {
    println("------------------- Generate Core.v ---------------- ")
    (new ChiselStage).execute(args, Seq(
      ChiselGeneratorAnnotation(() => new Core())))
  } else if(top == "InstFetch") {
    println("------------------- InstFetch.v---------------- ")
    (new ChiselStage).execute(args, Seq(
      ChiselGeneratorAnnotation(() => new InstFetch())))
  }  else if(top == "SimTop") {
    println("------------------- SimTop.v---------------- ")
    (new ChiselStage).execute(args, Seq(
      ChiselGeneratorAnnotation(() => new SimTop())))
  } 
  /*
    else if(top == "Axi") {
    println("--------Axi.v---------------- ")
    (new ChiselStage).execute(args, Seq(
      ChiselGeneratorAnnotation(() => new Axi())))
  }*/ else if (top == "Div") {
    println("--------Div---------------- ")
    (new ChiselStage).execute(args, Seq(
      ChiselGeneratorAnnotation(() => new Div())))
  } else if (top == "Booth") {
    println("--------Booth---------------- ")
    (new ChiselStage).execute(args, Seq(
      ChiselGeneratorAnnotation(() => new Booth())))
  } else if (top == "Walloc") {
    println("--------Walloc---------------- ")
    (new ChiselStage).execute(args, Seq(
      ChiselGeneratorAnnotation(() => new Wallace())))
  } else if (top == "Mul") {
    println("--------Mul---------------- ")
    (new ChiselStage).execute(args, Seq(
      ChiselGeneratorAnnotation(() => new Mul())))
  } else if (top == "RegFile") {
    println("--------RegFile---------------- ")
    (new ChiselStage).execute(args, Seq(
      ChiselGeneratorAnnotation(() => new RegFile())))
  } else if (top == "DataMem") {
    println("--------DataMem---------------- ")
    (new ChiselStage).execute(args, Seq(
      ChiselGeneratorAnnotation(() => new DataMem())))
  } else if (top == "NextPC") {
    println("--------NextPC---------------- ")
    (new ChiselStage).execute(args, Seq(
      ChiselGeneratorAnnotation(() => new NextPC())))
  } else if (top == "ContrGen") {
    println("--------ContrGen---------------- ")
    (new ChiselStage).execute(args, Seq(
      ChiselGeneratorAnnotation(() => new ContrGen())))
  }

}
