# Package

version       = "0.2.1"
author        = "geekrelief"
description   = "Helpers for truthy and nil checking"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.0"

task gendoc, "generate docs":
  exec "nim doc ./src/nilean.nim"
  exec "cp ./src/htmldocs/nilean.html ./src/htmldocs/geekrelief.github.io/nilean/index.html"