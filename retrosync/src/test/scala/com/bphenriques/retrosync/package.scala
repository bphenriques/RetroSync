package com.bphenriques

import fs2.io.file.Path

package object converter {
  def resourcePath(dir: String): Path = Path(
    getClass.getClassLoader.getResource(dir).getPath
  )
}
