package com.bphenriques.retrosync.model

import cats.syntax.all._
import com.bphenriques.retrosync.Config
import fs2.io.file.Path
import io.circe.syntax.EncoderOps
import io.circe.{Codec, Decoder, Encoder, Json}

object Codecs {

  implicit lazy val pathCodec: Codec[Path] = {
    val d: Decoder[Path] = Decoder.decodeString.map(Path.apply)
    val e: Encoder[Path] = path => Encoder.encodeString(path.toString)

    Codec.from(d, e)
  }

  implicit lazy val locationConfigCodec: Codec[Config.Location] = {
    val fromLabel = "from"
    val toLabel = "to"

    val d: Decoder[Config.Location] = (
      Decoder[Path].at(fromLabel),
      Decoder[Path].at(toLabel),
    ).mapN(Config.Location.apply)

    val e: Encoder[Config.Location] = config =>
      Json
        .obj(
          fromLabel -> config.from.asJson,
          toLabel -> config.to.asJson,
        )

    Codec.from(d, e)
  }
}
