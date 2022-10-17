# nilean
Nim truthy operators that also work on nilable chains of dot expressions.

### Documentation
https://geekrelief.github.io/nilean


---
### Examples
---
```nim
doAssert !""
doAssert ?"Hello"

doAssert !seq[int](@[])
doAssert ?(@[10])

type
  A = ref object
    b: B
  B = ref object
    val: int

var a: A
if ?a.b: # not (a.isNil or a.b.isNil)
  a.b.val = 10
else:
  a = A(b: B(val: 20))
echo a.b.val
```