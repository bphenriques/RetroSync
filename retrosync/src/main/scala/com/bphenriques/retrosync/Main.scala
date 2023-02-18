package com.bphenriques.retrosync

import cats.syntax.all._
import cats.effect.{ExitCode, IO, IOApp}

object Main extends IOApp {

  import sys.process._

  override def run(args: List[String]): IO[ExitCode] = {
    IO.println("Hello World") >>
      IO("ls /etc".!!).flatMap { files => // This is blocking but can't do in the current version
        files.split('\n').toList.traverse(IO.println)
      }.as(ExitCode.Success)
  }
}
   // rclone.bisync(Path("."), Path("."), Path("."))
