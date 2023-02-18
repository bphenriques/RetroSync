package com.bphenriques.retrosync.util

import cats.effect.IO
import cats.syntax.all._
import fs2.io.file.{Files, Path}
import io.circe.{Codec, parser}

object Decode {

  def decodeString[A: Codec](json: String): IO[A] =
    IO.fromEither(parser.parse(json))
      .flatMap(json => IO.fromEither(json.as[A]))

  def decodeFile[A: Codec](path: Path): IO[A] = {
    Files[IO]
      .readUtf8(path)
      .compile
      .string
      .flatMap(decodeString[A])
      .adaptError { case e => new RuntimeException(s"Error parsing file $path: ${e.getMessage}", e) }
  }
}
