import unittest
import libsexp

# Simple tests

test "Test empty input/nil":
  const input = ""
  let exp = decode(input)
  check exp.tag == tagNil

test "Test int, float":
  const input = "(42 3.14)"
  let output = libsexp.decode(input)
  check output.valList[0].tag == tagInt and output.valList[1].tag == tagFloat

test "Test string":
  const input = "\"Hello, world!\""
  let exp = libsexp.decode(input)
  check exp.tag == tagString and exp.valString == input

test "Test keyword":
  const input = "#test"
  let exp: Exp = libsexp.decode(input)
  check exp.tag == tagKeyword and exp.valKeyword == input

test "Test boolean":
  const input = "(#true #false)"
  let exp = libsexp.decode(input)
  let
    rtrue = exp.valList[0]
    rfalse = exp.valList[1]
  check rtrue.valBool == true and rfalse.valBool == false 

test "Test mapQuotes() and unmapQuotes()":
  check mapQuotes("1 2 3") == "\"1 2 3\"" and unmapQuotes("\"3 2 1\"") == "3 2 1"

test "Test empty list":
  const input = "()"
  let exp = libsexp.decode(input)
  check exp.tag == tagList and exp.valList.len() == 0

# Complex tests

test "Test rosetta":
  echo("More info: https://rosettacode.org/wiki/S-expressions")
  const input = "((data \"quoted data\" 123 4.5) (data (!@# (4.5) \"(more\" \"data)\")))"
  let exp = decode(input)
  let output = encode(exp)
  check input == output

test "Test encode()":
  let input: Exp = Exp(tag: tagList, valList: @[Exp(tag: tagSymbol, valSymbol: "foo"),
      Exp(tag: tagSymbol, valSymbol: "bar")])
  let result: string = "(foo bar)"
  check libsexp.encode(input) == result

test "Test encode(), decode()":
  const iresult = "(foo (bar \"baz\") (:ok :true) 3.14 42)"
  let exp = libsexp.decode(iresult)
  let oresult = libsexp.encode(exp)
  check iresult == oresult

test "Test newList()":
  let input: List = newList(Exp(tag: tagInt, valInt: 1), Exp(tag: tagInt, valInt: 2),
      Exp(tag: tagInt, valInt: 3))
  let output = encode(Exp(tag: tagList, valList: input))
  check output == "(1 2 3)"

test "Test list.toCons()":
  let exp = decode("(foo bar baz)")
  let mcons: Cons = exp.valList.toCons()
  check mcons.car.valSymbol == "foo" and len(mcons.cdr) == 2

test "Test cons.toList()":
  let mcons: Cons = (Exp(tag: tagSymbol, valSymbol: "nine"), @[Exp(tag: tagInt, valInt: 9)])
  let mlist: List = mcons.toList()
  let output: string = encode(Exp(tag: tagList, valList: mlist))
  check output == "(nine 9)"

test "Test list.isConsistent()":
  let
    clist = decode("(1 2 3 4)")
    ilist = decode("(1 #true 3 4)")
  check isConsistent(clist.valList, tagInt) == true and isConsistent(ilist.valList, tagInt) == false
