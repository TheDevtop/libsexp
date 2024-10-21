/*
    S-Expression parser in Swift
    Written by Thijs Haker
*/

public enum Sexp : Equatable, Sendable {
    // List type
    case list([Sexp])

    // Value types
    case quote(String)
    case number(Int)
    case float(Float)

    // Symbol types
    case atom(String)
    case bool(Bool)
    case symbol(String)
}

// Ok and error atoms
public let AtomOk: Sexp = Sexp.atom(":ok")
public let AtomErr: Sexp = Sexp.atom(":err")

// Boolean tokens: String -> Atom -> Bool
private let tokTrue: String = ":true"
private let tokFalse: String = ":false"

/// Generate a list with valid tokens
private func lex(_ input: String) -> [String] {
    guard let lexer: Regex<AnyRegexOutput> = try? Regex(#"(\(|\)|\"[^\"]*\"|'[^']*'|[^\s()]+)"#) else {
        return [":err"]
    }
    let matches = input.matches(of: lexer)
    return matches.map { match in String(input[match.range])}
}

/// Check if atom
private func isAtom(_ token: String) -> Bool {
    if token.count > 1 && token.starts(with: ":") {
        return true
    }
    return false
}

/// Parse and decode symbol and atom types
private func parseSymbol(_ token: String) -> Sexp {
    // Check if atom
    if isAtom(token) {
        // Check if boolean
        if token == tokTrue {
            return Sexp.bool(true)
        } else if token == tokFalse {
            return Sexp.bool(false)
        }
        return Sexp.atom(token)
    }
    return Sexp.symbol(token)
}

/// Parse and decode value types
private func parseValue(_ token: String) -> Sexp {
    if token.starts(with: "\"") || token.starts(with: "\'"){
        return Sexp.quote(token)
    }
    if let ret: Int = Int(token) {
        return Sexp.number(ret)
    }
    if let ret: Float = Float(token) {
        return Sexp.float(ret)
    }
    return parseSymbol(token)
}

/// Decode string to S-expression
public func Decode(_ input: String) -> Sexp {
    let tokens: [String] = lex(input)

    var stack: [[Sexp]] = []
    var ret: [Sexp] = []

    for tok: String in tokens {
        switch tok {
            case "(":
            stack.append(ret)
            ret = []
            case ")":
            guard var pret: [Sexp] = stack.popLast() else {
                return AtomErr
            }
            pret.append(Sexp.list(ret))
            ret = pret
            default:
            ret.append(parseValue(tok))
        }
    }
    if ret.count == 0 {
        return AtomErr
    }
    return ret[0]
}

/// (Re)encode S-expression to string
public func Encode(_ exp: Sexp) -> String {
    switch exp {
    case .list(let l):
        let s: String = l.map { Sexp in Encode(Sexp) }.joined(separator: " ")
        return "(\(s))"
    
    case .quote(let q):
        return "\(q)"
    
    case .number(let n):
        return "\(n)"
    
    case .float(let f):
        return "\(f)"
    
    case .symbol(let s):
        return "\(s)"
    
    case .atom(let a):
        return "\(a)"
    
    case .bool(let b):
        switch b {
        case true:
            return tokTrue
        case false:
            return tokFalse
        }
    }
}
