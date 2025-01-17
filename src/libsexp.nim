#[
  S-Expression library by Thijs Haker
  Types, encoder, decoder
]#

from regex import nil
from std/strutils import nil
from std/sequtils import nil

type
  # Atoms evaluate to themselves
  Atom* = string
  # Symbol can evaluate to anything
  Symbol* = string
  # Type tags, makes expression possible
  ExpTag* = enum
    tagInt,
    tagFloat,
    tagString,
    tagAtom,
    tagBool,
    tagSymbol,
    tagList
  # Expression is the base type
  Exp* = ref object
    case tag*: ExpTag
    of tagInt: valInt*: int
    of tagFloat: valFloat*: float
    of tagString: valString*: string
    of tagAtom: valAtom*: Atom
    of tagBool: valBool*: bool
    of tagSymbol: valSymbol*: Symbol
    of tagList: valList*: List
  # List is an ordered collection of expressions
  List* = seq[Exp]

const tokTrue: string = ":true"
const tokFalse: string = ":false"
const tokOk: string = ":ok"
const tokErr: string = ":err"

# Operational atoms
const AtomOk*: Atom = tokOk
const AtomErr*: Atom = tokErr

# Construct cell
type Cons* = tuple[car: Exp, cdr: List]

# Convert a list to construct cell
proc toCons*(list: List): Cons =
  if len(list) < 1:
    return (car: Exp(tag: tagAtom, valAtom: AtomErr), cdr: @[])
  elif len(list) == 1:
    return (car: list[0], cdr: @[])
  return (car: list[0], cdr: list[1..^1])

# Convert a construct cell to a list
proc toList*(cons: Cons): List =
  var nlist: List = cons.cdr
  nlist.insert(cons.car, 0)
  return nlist

proc isString(token: string): bool =
  if strutils.startsWith(token, "\"") and strutils.endsWith(token, "\""):
    return true
  return false

proc isAtom(token: string): bool =
  if token.len > 1 and strutils.startsWith(token, ":"):
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

# Allocate message -> (:err "Something went wrong")
proc newMessage*(atom: Atom, mesg: string): Exp = Exp(tag: tagList, valList: @[Exp(tag: tagAtom, valAtom: atom), Exp(tag: tagString, valString: mapQuotes(mesg))])

# Allocate result -> (:ok 10), (:err :false)
proc newResult*(atom: Atom, exp: Exp): Exp = Exp(tag: tagList, valList: @[Exp(tag: tagAtom, valAtom: atom), exp])

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
  # If atom or subtype
  if isAtom(token):
    # If boolean
    if token == tokTrue:
      return Exp(tag: tagBool, valBool: true)
    elif token == tokFalse:
      return Exp(tag: tagBool, valBool: false)
    # Else atom
    return Exp(tag: tagAtom, valAtom: Atom(token))
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
      var tmpret = stack.pop()
      tmpret.add(Exp(tag: tagList, valList: ret))
      ret = tmpret
    else:
      ret.add(parseValue(tok))
  
  # If nothing was parsed, return error
  if ret.len() == 0:
    return newMessage(AtomErr, "Parsed empty input string")
  return ret[0]

# Decode strings to s-expressions
proc decode*(input: string): Exp = parse(lex(input))

# Encode s-expressions to strings
proc encode*(input: Exp): string =
  var ret: string
  case input.tag:
    of tagInt:
      ret.addInt(input.valInt)
    of tagFloat:
      ret.addFloat(input.valFloat)
    of tagString:
      ret.add(input.valString)
    of tagAtom:
      ret.add(input.valAtom)
    of tagBool:
      if input.valBool:
        ret.add(tokTrue)
      else:
        ret.add(tokFalse)
    of tagSymbol:
      ret.add(input.valSymbol)
    of tagList:
      let tmpret = strutils.join(sequtils.map(input.valList, encode), " ")
      ret.add("(" & tmpret & ")")
  return ret
