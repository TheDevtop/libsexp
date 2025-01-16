# Libsexp

An S-Expression parser library, written in Nim.

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
- Nil (subtype of atom) `:nil`
- Symbol `+`, `foobar`, `write-file`

The order in which there are listed, is the order in which they are parsed.
Thus there is a hierarchy of types, which determines the output of the decode function.

### On atoms

Atoms are different from symbols, in that atoms won't evaluate to anything.
The symbol `foo` may evaluate to a procedure, a number, or even an atom.
The atom `:foo` will always resolve to `:foo`.

There are three special atoms:
- Boolean true `:true`
- Boolean false `:false`
- Nil `:nil`
