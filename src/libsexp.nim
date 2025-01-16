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
    tagInt,
    tagFloat,
    tagString,
    tagAtom,
    tagBool,
    tagSymbol,
    tagList
  # Expressions are the base objects in Lisp
  Exp* = ref object
    case tag*: ExpTag
    of tagInt: valInt*: int
    of tagFloat: valFloat*: float
    of tagString: valString*: string
    of tagAtom: valAtom*: Atom
    of tagBool: valBool*: bool
    of tagSymbol: valSymbol*: Symbol
    of tagList: valList*: List
  List* = seq[Exp]

const tokTrue: string = ":true"
const tokFalse: string = ":false"
const tokOk: string = ":ok"
const tokErr: string = ":err"

# Construct cell, not used in parser
type Cons* = tuple[car: Exp, cdr: List]

# Convert a list to construct cell
proc toCons*(list: List): Cons =
  if len(list) < 1:
    return (car: Exp(tag: tNil), cdr: @[])
  elif len(list) == 1:
    return (car: list[0], cdr: @[])
  return (car: list[0], cdr: list[1..^1])

# Convert a construct cell to a list
proc toList*(cons: Cons): List =
  var nlist: List = cons.cdr
  nlist.insert(cons.car, 0)
  return nlist

# Allocate new list from variadic expressions
proc newList*(exps: varargs[Exp]): List =
  var list: List
  for exp in exps:
    list.add(exp)
  return list

proc encodeBool(b: bool): string =
  if b:
    return tokTrue
  return tokFalse

proc isNil(token: string): bool =
  if token == tokNil:
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
  # If string
  if isString(token):
    return Exp(tag: tString, vString: token)
  # If int
  try:
    return Exp(tag: tInt, vInt: strutils.parseInt(token))
  except:
    discard
  # If float
  try:
    return Exp(tag: tFloat, vFloat: strutils.parseFloat(token))
  except:
    discard
  # If atom or subtype
  if isAtom(token):
    # If boolean
    if token == tokTrue:
      return Exp(tag: tBool, vBool: true)
    elif token == tokFalse:
      return Exp(tag: tBool, vBool: false)
    # If nil
    if isNil(token):
      return Exp(tag: tNil)
    # Else atom
    return Exp(tag: tAtom, vAtom: Atom(token))
  # If nothing else, be a symbol
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
    return Exp(tag: tNil)
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
      ret.add(encodeBool(input.vBool))
    of tNil:
      discard
    of tSymbol:
      ret.add(input.vSymbol)
    of tList:
      let tmpret = strutils.join(sequtils.map(input.vList, encode), " ")
      ret.add("(" & tmpret & ")")
  return ret
