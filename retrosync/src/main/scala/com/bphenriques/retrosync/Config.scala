package com.bphenriques.retrosync

import cats.effect.IO
import com.bphenriques.retrosync.model.Codecs.locationConfigCodec
import com.bphenriques.retrosync.util.Decode
import fs2.io.file.{Files, Path}

object TargetedLocations {
  def read(directory: Path): IO[Map[String, Config.Location]] =
    Files[IO]
      .walk(directory)
      .evalFilter(Files[IO].isRegularFile)
      .filter(_.extName == ".json")
      .evalMap { file =>
        Decode.decodeFile[Config.Location](file).map { location =>
          val id = file.fileName.toString.replace(".json", "")
          id -> location
        }
      }
      .compile
      .toList
      .map(_.toMap)
}

object Config {
  case class Location(from: Path, to: Path)
}
