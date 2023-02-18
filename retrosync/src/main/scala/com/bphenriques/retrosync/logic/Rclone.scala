package com.bphenriques.retrosync.logic

import cats.effect.IO
import cats.syntax.all._
import fs2.io.file.Path

import scala.sys.process._

object rclone {
  def bisync(from: Path, to: Path, filterFile: Path): IO[Unit] = {
    IO.println("Hello World!")
  }
}
