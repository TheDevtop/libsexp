# Libsexp

An S-Expression parser library, written in Swift.

I am inspired by Lisp, and wanted to write a parser in a strongly-typed language.
So I did. 

### On usage

There are two important functions, **decode** and **encode**.

```swift
public func Decode(_ input: String) -> Sexp
```
Decode takes in a string and outputs an S-Expression object.
If any error occurs, it returns an S-Expression containing the `:error` atom.

```swift
public func Encode(_ exp: Sexp) -> String
```
Encode takes an S-Expression object and returns a string that contains the S-Expression representation of the object.

### On type hierarchy

An S-Expression can be one of several types.

List types:
- List `()`

Value types:
- Quote `"Cited string"`, `'Quoted string'`
- Number `42`, `-69`
- Float `4.20`

Symbol types:
- Atom (based on Elixir atoms) `:err`, `:foobar`
- Boolean `:true` or `:false`
- Symbol `+`, `foobar`, `write-file`

The order in which there are listed, is the order in which they are parsed.
Thus there is a hierarchy of types, which determines the output of the decode function.

### On atoms

Atoms are different from symbols, in that atoms won't evaluate to anything.
The symbol `foo` may evaluate to a procedure, a number, or even an atom.
The atom `:foo` will always resolve to `:foo`.

There are also two special atoms: `:ok` and `:err`.
These atoms perform the same function as the [result](https://doc.rust-lang.org/std/result/) type in Rust.
