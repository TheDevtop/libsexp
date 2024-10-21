/*
    S-Expression library by Thijs Haker
    Parser
*/

/// Generate a list with valid tokens
private func lex(_ input: String) -> [String] {
    guard let lexer: Regex<AnyRegexOutput> = try? Regex(#"(\(|\)|\"[^\"]*\"|'[^']*'|[^\s()]+)"#) else {
        // Will be parsed as error atom
        return [":err"]
    }
    let matches = input.matches(of: lexer)
    return matches.map { match in String(input[match.range])}
}

/// Parse and decode value types
private func parseValue(_ token: String) -> Sexp {
    if isQuote(token){
        return Sexp.Quote(token)
    }
    if let ret: Int = Int(token) {
        return Sexp.Number(ret)
    }
    if let ret: Float = Float(token) {
        return Sexp.Float(ret)
    }
    if isAtom(token) {
        if token == tokTrue {
            return Sexp.Bool(true)
        } else if token == tokFalse {
            return Sexp.Bool(false)
        }
        return Sexp.Atom(token)
    }
    return Sexp.Symbol(token)
}

/// Decode string to S-Expression
public func Decode(_ input: String) -> Sexp {
    let tokens: [String] = lex(input)

    var stack: [List] = []
    var ret: List = []

    for tok: String in tokens {
        switch tok {
            case "(":
            stack.append(ret)
            ret = []
            case ")":
            guard var pret: List = stack.popLast() else {
                return AtomErr
            }
            pret.append(Sexp.List(ret))
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

/// (Re)encode S-Expression to string
public func Encode(_ exp: Sexp) -> String {
    switch exp {
    case .List(let l):
        let s: String = l.map { Sexp in Encode(Sexp) }.joined(separator: " ")
        return "(\(s))"
    
    case .Quote(let q):
        return "\(q)"
    
    case .Number(let n):
        return "\(n)"
    
    case .Float(let f):
        return "\(f)"
    
    case .Symbol(let s):
        return "\(s)"
    
    case .Atom(let a):
        return "\(a)"
    
    case .Bool(let b):
        switch b {
        case true:
            return tokTrue
        case false:
            return tokFalse
        }
    }
}
