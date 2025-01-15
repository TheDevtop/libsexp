# Libsexp

An S-Expression parser library, written in Nim.

Lisp and its innovative constructs, continue to inspire me.
The philosophy of combination and abstraction, as formulated in [SICP](https://web.mit.edu/6.001/6.037/sicp.pdf) left me wanting to write my own Lisp environment.
This repository is the first step in that direction.

I hope you may find use in this. 

### On usage

There are two important functions, **decode** and **encode**.

```nim
proc decode*(input: string): Exp
```
Decode takes an input string and outputs an S-Expression object.
If any error occurs, it throws an exception.

```nim
proc encode*(input: Exp): string
```
Encode takes an S-Expression object and returns a string that contains the S-Expression representation of the object.

### On type hierarchy

An S-Expression can be one of several types.

List types:
- List `()`, `(+ 1 2 3)`

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
