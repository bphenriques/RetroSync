package com.bphenriques.retrosync

import cats.effect.IO
import com.bphenriques.converter.resourcePath
import fs2.io.file.{Files, Path}
import munit.CatsEffectSuite

class ConfigTest extends CatsEffectSuite {

  test("It parses a config") {
    TargetedLocations.read(resourcePath("known-locations")).assertEquals(
      Map(
        "gb" -> Config.Location(Path("gb-from-path"), Path("gb-to-path")),
        "gbc" -> Config.Location(Path("gbc-from-path"), Path("gbc-to-path"))
      )
    )
  }

  private def writeConfig(yaml: String, target: Path): IO[Unit] =
    fs2
      .Stream[IO, String](yaml)
      .through(fs2.text.utf8.encode)
      .through(Files[IO].writeAll(target))
      .compile
      .drain
}
