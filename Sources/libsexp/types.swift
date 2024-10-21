/*
    S-Expression library by Thijs Haker
    Types and constraints
*/

/// The list type
public typealias List = [Sexp]

/// Symbolic expression
public enum Sexp : Equatable, Sendable {
    // List type
    case List(List)

    // Value types
    case Quote(String)
    case Number(Int)
    case Float(Float)
    case Atom(String)
    case Bool(Bool)
    case Symbol(String)
}

// Ok and error atoms
public let AtomOk: Sexp = Sexp.Atom(":ok")
public let AtomErr: Sexp = Sexp.Atom(":err")

// Boolean tokens: String -> Atom -> Bool
let tokTrue: String = ":true"
let tokFalse: String = ":false"

/// Check if quote
func isQuote(_ token: String) -> Bool {
    if token.starts(with: "\"") || token.starts(with: "\'"){
        return true
    }
    return false
}

/// Check if atom
func isAtom(_ token: String) -> Bool {
    if token.count > 1 && token.starts(with: ":") {
        return true
    }
    return false
}
