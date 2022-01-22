# Package

version       = "0.1.0"
author        = "geekrelief"
description   = "Helpers for truthy and nil checking"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.7.1"

task gendoc, "generate docs":
  exec "nim doc ./src/nillean.nim"
  exec "cp ./src/htmldocs/nillean.html ./src/htmldocs/geekrelief.github.io/nillean/index.html"