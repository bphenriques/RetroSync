import scala.scalanative.build._

val catsEffectV = "3.4.6"
val catsV = "2.9.0"
val circeV = "0.14.4"
val fs2V = "3.6.1"
val munitCatsEffectV = "1.0.7"
val munitV = "0.7.29"

Global / onChangedBuildSource := ReloadOnSourceChanges

inThisBuild(
  List(
    scalaVersion := "2.13.8",
    organization := "com.bphenriques.retrosync",
    organizationName := "bphenriques",
    version := "latest",
    javacOptions ++= Seq("-source", "17", "-target", "17"),
    resolvers ++= Seq(
      "confluent-release" at "https://packages.confluent.io/maven/",
      "jitpack" at "https://jitpack.io",
    )
  )
)

lazy val baseTestDependencies = Seq(
  "org.scalameta" %% "munit" % munitV,
  "org.typelevel" %% "munit-cats-effect-3" % munitCatsEffectV
)

lazy val root = project.in(file("."))
  .enablePlugins(ScalaNativePlugin)
  .settings(
    name                := "retro-sync",
    libraryDependencies ++= Seq(
      "co.fs2" %%% "fs2-core" % fs2V,
      "co.fs2" %%% "fs2-io" % fs2V,
      "org.typelevel" %%% "cats-effect" % catsEffectV,
      "org.typelevel" %%% "cats-core" % catsV,
      "io.circe" %%% "circe-core" % circeV,
      "io.circe" %%% "circe-generic" % circeV,
      "io.circe" %%% "circe-parser" % circeV,
    ) ++ baseTestDependencies.map(_ % "test"),
    scalacOptions -= "-Xfatal-warnings", // enable all options from sbt-tpolecat except fatal warnings

    // set to Debug for compilation details (Info is default)
    logLevel := Level.Info,

    nativeConfig ~= { c =>
      c.withLTO(LTO.none) // thin
        .withMode(Mode.debug) // releaseFast
        .withGC(GC.immix) // commix
    }
  )
