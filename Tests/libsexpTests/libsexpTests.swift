import Testing
import libsexp

@Test func testRosetta() throws {
    let input = "((data \"quoted data\" 123 4.5) (data (!@# (4.5) \"(more\" \"data)\")))"
    let ast = Decode(input)
    let output = Encode(ast)
    #expect(input == output)
}

@Test func testAst() throws {
    let ast: Sexp = Sexp.List([
        Sexp.Symbol("+"),
        Sexp.Number(32),
        Sexp.List([
            Sexp.Symbol("*"),
            Sexp.Number(16),
            Sexp.Number(8)
        ])
    ])
    #expect(ast == Decode("(+ 32 (* 16 8))"))
}

@Test func testTypes() throws {
    var ast = Decode("")
    #expect(ast == libsexp.AtomErr)

    ast = Decode("()")
    #expect(ast == libsexp.Sexp.List([]))

    ast = Decode("\"Hello, world!\"")
    #expect(ast == libsexp.Sexp.Quote("\"Hello, world!\""))

     ast = Decode("'Cite your sources'")
    #expect(ast == libsexp.Sexp.Quote("'Cite your sources'"))

    ast = Decode("69")
    #expect(ast == libsexp.Sexp.Number(69))

    ast = Decode("1.618")
    #expect(ast == libsexp.Sexp.Float(1.618))

    ast = Decode(":ok")
    #expect(ast == libsexp.AtomOk)

    ast = Decode(":true")
    #expect(ast == Sexp.Bool(true))

    ast = Decode(":false")
    #expect(ast == Sexp.Bool(false))

    ast = Decode(":")
    #expect(ast != Sexp.Atom(":"))

    ast = Decode("eval")
    #expect(ast == libsexp.Sexp.Symbol("eval"))
}