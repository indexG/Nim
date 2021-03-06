discard """
  cmd: '''nim cpp --newruntime --threads:on $file'''
  output: '''(field: "value")
Indeed
axc
(v: 10)
0  new: 0'''
"""

import core / allocators
import system / ansi_c

import tables

type
  Node = ref object
    field: string

# bug #11807
import os
putEnv("HEAPTRASHING", "Indeed")

proc main =
  var w = newTable[string, owned Node]()
  w["key"] = Node(field: "value")
  echo w["key"][]
  echo getEnv("HEAPTRASHING")

  # bug #11891
  var x = "abc"
  x[1] = 'x'
  echo x

main()

# bug #11745

type
  Foo = object
    bar: seq[int]

var x = [Foo()]

# bug #11563
type
  MyTypeType = enum
    Zero, One
  MyType = object
    case kind: MyTypeType
    of Zero:
      s*: seq[MyType]
    of One:
      x*: int
var t: MyType

# bug #11254
proc test(p: owned proc()) =
  let x = (proc())p

test(proc() = discard)

# bug #10689

type
  O = object
    v: int

proc `=sink`(d: var O, s: O) =
  d.v = s.v

proc selfAssign =
  var o = O(v: 10)
  o = o
  echo o

selfAssign()

# bug #11833
type FooAt = object

proc testWrongAt() =
  var x = @[@[FooAt()]]

testWrongAt()

let (a, d) = allocCounters()
discard cprintf("%ld  new: %ld\n", a - unpairedEnvAllocs() - d, allocs)

#-------------------------------------------------
type
  Table[A, B] = object
    x: seq[(A, B)]


proc toTable[A,B](p: sink openArray[(A, B)]): Table[A, B] = 
  for zz in mitems(p):
    result.x.add move(zz)


let table = {"a": new(int)}.toTable()
