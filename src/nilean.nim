## :Author: Don-Duong Quach
## :License: MIT
## :Version: 0.2.1
##
## `Source <https://github.com/geekrelief/nilean>`_
##
## Implements operators ``!``, checks for falsiness, and ``?``, truthiness, on various types, including dot expression chains.
##
##
runnableExamples:
  type
    A = object
      b: ptr B
      s: seq[ptr C]
      p: proc():int
      r: R
      cs: cstring
      pp: pointer
    B = object
      foo: float
    C = object
      bar: bool
      r: R
    R = ref object
      val: int

  var va = A()
  var a = va.addr
  var b = cast[ptr B](alloc(sizeof(B)))
  b.foo = 100f

  doAssert ?a
  doAssert !a.b

  ifIt a:
    it.b = b

  doAssert ?a.b

  doAssert !a.s

  var c = cast[ptr C](alloc(sizeof(C)))
  c.bar = true
  a.s = @[c]
  doAssert ?a.s
  doAssert ?a.s[0]

  var p:proc():int
  doAssert !p
  p = proc():int = 1
  doAssert ?p

  doAssert !a.p
  a.p = p
  doAssert ?a.p

  var r:R
  doAssert !r
  doAssert !a.r
  
  doAssert !a.s[0].r
  c.r = R()

  doAssert ?a.s[0].r

  doAssert !a.cs
  a.cs = cstring"Hello"
  doAssert ?a.cs

  doAssert !a.pp
  a.pp = cast[pointer](a.s[0].addr)
  doAssert ?a.pp

# Implementation
import std/[ macros, math, tables ]

# helpers for truthy checking
template `?`*(x): untyped =
  not !x

template `!`*(x: SomeOrdinal | char ): untyped =
  ord(x) == 0

template `!`*(x: SomeFloat): untyped =
  x.isNaN or x == 0f

template `!`*(x: string): untyped =
  x.len == 0

template `!`*[T](x: seq[T]): untyped =
  x.len == 0

template ifIt*(x, body): untyped =
  let it {.inject.} = x
  if ?x:
    body

proc parseParts(x: NimNode): seq[NimNode]

proc parseDotExpr(x: NimNode): seq[NimNode] =
  result.add parseParts(x[0])
  result.add x

proc parseBracketExpr(x: NimNode): seq[NimNode] =
  result.add parseParts(x[0])
  result.add x

proc parseParts(x: NimNode): seq[NimNode] =
  result.add case x.kind:
    of nnkBracketExpr: parseBracketExpr(x)
    of nnkDotExpr: parseDotExpr(x)
    of nnkHiddenDeref: parseParts(x[0])
    else: @[x]

proc isNilable(x:NimNode): bool =
  if x.kind == nnkHiddenDeref: return true

  var t = getType(x)
  case t.kind:
  of nnkBracketExpr:
    case t[0].strVal:
    of "ref", "ptr", "proc": true
    else: false
  of nnkHiddenDeref: true
  of nnkSym:
    case t.strVal:
    of "pointer", "cstring": true
    else: false
  else: false

macro `!`*(x: ptr | ref | pointer | cstring | proc): untyped =
  var parts = parseParts(x)
  var nilables:seq[NimNode]
  for p in parts:
    if isNilable(p):
      nilables.add p
      if result.kind == nnkEmpty:
        result = newCall("isNil", p)
      else:
        result = newTree(nnkInfix, ident("or"), result, newCall("isNil", p))