#[
  S-Expression library by Thijs Haker
  Types, encoder, decoder
]#

from regex import nil
from std/strutils import nil
from std/sequtils import nil

# Expression tags
type ExpTag* = enum
  tagNil,
  tagInt,
  tagFloat,
  tagString,
  tagKeyword,
  tagBool,
  tagSymbol,
  tagList

type
  # Keywords evaluate to themselves
  Keyword* = string

  # Symbol can evaluate to anything
  Symbol* = string

  # Expression is the base type
  Exp* = ref object
    case tag*: ExpTag
    of tagNil: discard
    of tagInt: valInt*: int
    of tagFloat: valFloat*: float
    of tagString: valString*: string
    of tagKeyword: valKeyword*: Keyword
    of tagBool: valBool*: bool
    of tagSymbol: valSymbol*: Symbol
    of tagList: valList*: List

  # List is an ordered collection of expressions
  List* = seq[Exp]

# Construct cell
type Cons* = tuple[car: Exp, cdr: List]

const
  tokTrue: string = "#true"
  tokFalse: string = "#false"

# Convert a list to construct cell
proc toCons*(list: List): Cons =
  if len(list) < 1:
    return (car: Exp(tag: tagNil), cdr: @[])
  elif len(list) == 1:
    return (car: list[0], cdr: @[])
  return (car: list[0], cdr: list[1..^1])

# Convert a construct cell to a list
proc toList*(cons: Cons): List =
  var nlist: List = cons.cdr
  nlist.insert(cons.car, 0)
  return nlist

# Check if list only contains item with specified tag
proc isConsistent*(list: List, tag: ExpTag): bool =
  for exp in list:
    if exp.tag != tag:
      return false
  return true

# Check if string
proc isString(token: string): bool =
  if strutils.startsWith(token, "\"") and strutils.endsWith(token, "\""):
    return true
  return false

# Check if keyword
proc isKeyword(token: string): bool =
  if strutils.startsWith(token, "#"):
    return true
  return false

# Map quotes onto string
proc mapQuotes*(input: string): string =
  if isString(input):
    return input
  return "\""&input&"\""

# Unmap quotes from string
proc unmapQuotes*(input: string): string =
  if not isString(input):
    return input
  return strutils.strip(s = input, chars = {'"'})

# Allocate new list from variadic expressions
proc newList*(exps: varargs[Exp]): List =
  var list: List
  for exp in exps:
    list.add(exp)
  return list

# Match input with s-expression regex, return matching tokens
proc lex(input: string): seq[string] =
  # Compiled regular expression
  const crex: regex.Regex2 = regex.re2("(\"[^\"]*\"|\\(|\\)|\"|[^\\s()\"]+)")
  var tokens: seq[string]

  for match in regex.findAll(input, crex):
    tokens.add(input[regex.group(match, 0)])
  return tokens

# Parse tokens that are not list tokens
proc parseValue(token: string): Exp =
  # If string
  if isString(token):
    return Exp(tag: tagString, valString: token)
  # If int
  try:
    return Exp(tag: tagInt, valInt: strutils.parseInt(token))
  except:
    discard
  # If float
  try:
    return Exp(tag: tagFloat, valFloat: strutils.parseFloat(token))
  except:
    discard
  # If keyword or subtype
  if isKeyword(token):
    # If boolean
    if token == tokTrue:
      return Exp(tag: tagBool, valBool: true)
    elif token == tokFalse:
      return Exp(tag: tagBool, valBool: false)
    # Else keyword
    return Exp(tag: tagKeyword, valKeyword: Keyword(token))
  # If nothing else, be a symbol
  return Exp(tag: tagSymbol, valSymbol: Symbol(token))

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
      var prevret: List = stack.pop()
      prevret.add(Exp(tag: tagList, valList: ret))
      ret = prevret
    else:
      ret.add(parseValue(tok))

  # If nothing was parsed, return nil expression
  if ret.len() == 0:
    return Exp(tag: tagNil)
  return ret[0]

# Decode strings to s-expressions
proc decode*(input: string): Exp = parse(lex(input))

# Encode s-expressions to strings
proc encode*(input: Exp): string =
  var ret: string
  case input.tag:
    of tagNil:
      discard
    of tagInt:
      ret.addInt(input.valInt)
    of tagFloat:
      ret.addFloat(input.valFloat)
    of tagString:
      ret.add(input.valString)
    of tagKeyword:
      ret.add(input.valKeyword)
    of tagBool:
      if input.valBool:
        ret.add(tokTrue)
      else:
        ret.add(tokFalse)
    of tagSymbol:
      ret.add(input.valSymbol)
    of tagList:
      let subret = strutils.join(sequtils.map(input.valList, encode), " ")
      ret.add("(" & subret & ")")
  return ret
