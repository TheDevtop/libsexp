#[
  S-Expression library by Thijs Haker
  Types, encoder, decoder
]#

from regex import nil
from std/strutils import nil
from std/sequtils import nil

type
  # Atom and symbol types
  Atom* = string
  Symbol* = string
  # Type tags
  ExpTag* = enum
    tInt,
    tFloat,
    tString,
    tAtom,
    tBool,
    tSymbol,
    tList
  # Expressions are the base objects in Lisp
  Exp* = ref object
    case tag*: ExpTag
    of tInt: vInt*: int
    of tFloat: vFloat*: float
    of tString: vString*: string
    of tAtom: vAtom*: Atom
    of tBool: vBool*: bool
    of tSymbol: vSymbol*: Symbol
    of tList: vList*: List
  List* = seq[Exp]

const tokTrue: string = ":true"
const tokFalse: string = ":false"

# Get the first element of a list
proc car*(list: List): Exp =
  if len(list) < 1:
    return Exp(tag: tList, vList: @[])
  return list[0]

# Get the rest elements of the list
proc cdr*(list: List): List =
  if len(list) < 2:
    return @[]
  return list[1..^1]

# Allocate new atom
proc newAtom*(token: string): Atom = ":"&token

# Allocate new list from variadic expressions
proc newList*(exps: varargs[Exp]): List =
  var list: List
  for exp in exps:
    list.add(exp)
  return list

proc boolToken(b: bool): string =
  if b:
    return tokTrue
  return tokFalse

proc isBool(token: string): bool =
  if token == tokTrue or token == tokFalse:
    return true
  return false

proc isString(token: string): bool =
  if strutils.startsWith(token, "\"") and strutils.endsWith(token, "\""):
    return true
  return false

proc isAtom(token: string): bool =
  if token.len > 1 and strutils.startsWith(token, ":"):
    return true
  return false

# Match input with s-expression regex, return matching tokens
proc lex(input: string): seq[string] =
  const crex: regex.Regex2 = regex.re2("(\"[^\"]*\"|\\(|\\)|\"|[^\\s()\"]+)")
  var tokens: seq[string]

  for match in regex.findAll(input, crex):
    tokens.add(input[regex.group(match, 0)])
  return tokens

# Parse tokens that are not list tokens
proc parseValue(token: string): Exp =
  if isString(token):
    return Exp(tag: tString, vString: token)
  try:
    return Exp(tag: tInt, vInt: strutils.parseInt(token))
  except:
    discard
  try:
    return Exp(tag: tFloat, vFloat: strutils.parseFloat(token))
  except:
    discard
  if isAtom(token):
    if token == tokTrue:
      return Exp(tag: tBool, vBool: true)
    elif token == tokFalse:
      return Exp(tag: tBool, vBool: false)
    else:
      return Exp(tag: tAtom, vAtom: Atom(token))
  return Exp(tag: tSymbol, vSymbol: Symbol(token))

# Constructs expression from tokens
proc parse(tokens: seq[string]): Exp =
  var ret: List
  var stack: seq[List]

  for tok in tokens:
    case tok:
    of "(":
      stack.add(ret)
      ret = @[]
    of ")":
      var tmpret = stack.pop()
      tmpret.add(Exp(tag: tList, vList: ret))
      ret = tmpret
    else:
      ret.add(parseValue(tok))

  if ret.len() == 0:
    return Exp(tag: tList, vList: @[])
  return ret[0]

# Decode strings to s-expressions
proc decode*(input: string): Exp = parse(lex(input))

# Encode s-expressions to strings
proc encode*(input: Exp): string =
  var ret: string
  case input.tag:
    of tInt:
      ret.addInt(input.vInt)
    of tFloat:
      ret.addFloat(input.vFloat)
    of tString:
      ret.add(input.vString)
    of tAtom:
      ret.add(input.vAtom)
    of tBool:
      ret.add(boolToken(input.vBool))
    of tSymbol:
      ret.add(input.vSymbol)
    of tList:
      let tmpret = strutils.join(sequtils.map(input.vList, encode), " ")
      ret.add("(" & tmpret & ")")
  return ret
