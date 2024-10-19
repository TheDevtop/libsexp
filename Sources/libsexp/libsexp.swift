/*
    S-Expression parser in Swift
    Written by Thijs Haker
*/

public enum Sexp {
    // List type
    case list([Sexp])

    // Atom types
    case quote(String)
    case number(Int)
    case float(Float)
    case symbol(String)
}

/// Generate a list with valid tokens
private func lex(_ input: String) -> [String] {
    guard let lexer = try? Regex(#"([\(\)]|\"[^\"]*\"|[^\s\(\)]+)"#) else {
        return ["(", ")"]
    }
    let matches = input.matches(of: lexer)
    return matches.map { match in String(input[match.range])}
}

/// Parse and decode atom types
private func parseAtom(_ token: String) -> Sexp {
    if token.contains("\"") {
        return Sexp.quote(token)
    }
    if let ret: Int = Int(token) {
        return Sexp.number(ret)
    }
    if let ret: Float = Float(token) {
        return Sexp.float(ret)
    }
    return Sexp.symbol(token)
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
                return Sexp.list(ret)
            }
            pret.append(Sexp.list(ret))
            ret = pret
            default:
            ret.append(parseAtom(tok))
        }
    }
    if ret.count == 0 {
        return Sexp.list(ret)
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
    }
}
