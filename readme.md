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
- Nil
- String `"Hello, world!"`
- Int `42`, `-69`
- Float `4.20`
- Keywords `#foobar`, `#error`
- Boolean (subtype of keyword) `#true` or `#false`
- Symbol `+`, `foobar`, `write-file`

The order in which there are listed, is the order in which they are parsed.
Thus there is a hierarchy of types, which determines the output of the decode function.

### On keywords

Keywords are different from symbols, in that keywords won't evaluate to anything.
The symbol `foo` may evaluate to a procedure, a number, or even an keyword.
The keyword `#foo` will always resolve to `#foo`.

There are two special keywords:
- Boolean true `#true`
- Boolean false `#false`

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
