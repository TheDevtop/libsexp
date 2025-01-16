# Libsexp

An S-Expression parser library, written in Nim.

### On usage

There are two important functions, **decode** and **encode**.

```nim
proc decode*(input: string): Exp
```
Decode takes an input string and outputs an S-Expression object.
If any error occurs, it returns an error.

```nim
proc encode*(input: Exp): string
```
Encode takes an S-Expression object and returns a string that contains the S-Expression representation of that object.

### On type hierarchy

An S-Expression can be one of several types.

List types:
- List `()`, `(+ 1 2 3)`, `(+ 2 (* 3 4))`

Value types:
- String `"Hello, world!"`
- Int `42`, `-69`
- Float `4.20`
- Atom (also known as keywords) `:err`, `:foobar`
- Boolean (subtype of atom) `:true` or `:false`
- Symbol `+`, `foobar`, `write-file`

The order in which there are listed, is the order in which they are parsed.
Thus there is a hierarchy of types, which determines the output of the decode function.

### On atoms

Atoms are different from symbols, in that atoms won't evaluate to anything.
The symbol `foo` may evaluate to a procedure, a number, or even an atom.
The atom `:foo` will always resolve to `:foo`.

There are four special atoms:
- Boolean true `:true`
- Boolean false `:false`
- Operational ok `:ok`
- Operational error `:err`

You can create operational values with the following functions:

```nim
proc newOk*(exp: Exp): Exp
```
The newOk function takes as input any expression and returns `(:ok exp)`.

```nim
proc newError*(mesg: string): Exp
```
The newError function takes in an error messages and returns `(:err "Message content")`.

### On cons

```nim
type Cons* = tuple[car: Exp, cdr: List]
```
Cons or construct cells are the abstraction used to deconstruct a list to its component parts.
Namely car and cdr, which I use to get the procedure and operand symbols. 
For convenience there are conversion functions.

```nim
proc toCons*(list: List): Cons
```
This function takes in a list and returns a construct cell.

```nim
proc toList*(cons: Cons): List
```
While this functions takes in a construct cell, and return its combination as a list.
