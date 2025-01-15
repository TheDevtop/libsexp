import unittest
import libsexp

test "Test rosetta":
  echo("More info: https://rosettacode.org/wiki/S-expressions")
  const input = "((data \"quoted data\" 123 4.5) (data (!@# (4.5) \"(more\" \"data)\")))"
  let exp = decode(input)
  let output = encode(exp)
  check input == output

test "Test encode()":
  let input: Exp = Exp(tag: tList, vList: @[Exp(tag: tSymbol, vSymbol: "foo"), Exp(tag: tSymbol, vSymbol: "bar")])
  let result: string = "(foo bar)"
  check libsexp.encode(input) == result

test "Test encode(), decode()":
  const iresult = "(foo (bar \"baz\") (:ok :true) 3.14 42)"
  let exp = libsexp.decode(iresult)
  let oresult = libsexp.encode(exp)
  check iresult == oresult

test "Test string":
  const input = "\"Hello, world!\""
  let exp = libsexp.decode(input)
  check exp.tag == tString and exp.vString == input

test "Test atom":
  const input = ":ok"
  let exp = libsexp.decode(input)
  check exp.tag == tAtom and exp.vAtom == input

test "Test newAtom()":
  let okAtom: Atom = newAtom("ok")
  check okAtom == ":ok"

test "Test empty list":
  const input = "()"
  let exp = libsexp.decode(input)
  check exp.tag == tList and exp.vList.len() == 0

test "Test newList()":
  let input: List = newList(Exp(tag: tInt, vInt: 1), Exp(tag: tInt, vInt: 2), Exp(tag: tInt, vInt: 3))
  let output = encode(Exp(tag: tList, vList: input))
  check output == "(1 2 3)"

test "Test int/float":
  const input = "(42 3.14)"
  let output = libsexp.decode(input)
  check output.vList[0].tag == tInt and output.vList[1].tag == tFloat

test "Test car(), cdr()":
  const input = "(foo bar baz)"
  let exp = decode(input)
  let ecar = car(exp.vList)
  let ecdr = cdr(exp.vList)
  check ecar.vSymbol == "foo" and ecdr[1].vSymbol == "baz"
