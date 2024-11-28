import unittest

import nilean
import std/[math, tables, sugar]
test "SomeInteger":
  check !0 == true
  check ?0 == false
  check !1 == false
  check ?1 == true
  check ?1'u8 == true

test "SomeFloat":
  check !(0f/0f) == true
  check ?(0f/0f) == false

  check !1f == false
  check ?1f == true

test "Enum":
  type Directions = enum
    None
    North
    East
    South
    West
  
  check !None
  check ?East

test "Char / String / Seq":
  check ?'a'
  check !'\0'

  check !""
  check ?"Hello"

  check !seq[int](@[])
  check ?(@[10])

type
  A = object
    b: ptr B
    s: seq[ptr C]
    p: proc():int
    cs: cstring
    pp: pointer
  B = object
    foo: float
  C = object
    bar: bool
  R = ref object # with arc, shouldn't alloc and mix ref object, just use pointers instead
    val: int

test "Nilable":
  var va = A()
  var a = va.addr
  var b = cast[ptr B](alloc(sizeof(B)))
  b.foo = 100f

  check ?a
  check !a.b
  a.b = b
  check ?a.b

  check !a.s

  var c = cast[ptr C](alloc(sizeof(C)))
  c.bar = true

  a.s = @[c]
  check ?a.s

  var p:proc():int
  check !p
  p = proc():int = 1
  check ?p

  check !a.p
  a.p = p
  check ?a.p

  var r:R
  check !r
  r = R()
  check ?r
  
  check !a.cs
  a.cs = cstring"Hello"
  check ?a.cs

  check !a.pp
  a.pp = cast[pointer](a.b)
  check ?a.pp

test "It":
  var a = cast[ptr A](alloc(sizeof(A)))

  ifIt a:
    it.b = cast[ptr B](alloc(sizeof(B)))

  check ?a.b
