import Testing
import libsexp

@Test func testRosetta() throws {
    let input = "((data \"quoted data\" 123 4.5) (data (!@# (4.5) \"(more\" \"data)\")))"
    let ast = Decode(input)
    let output = Encode(ast)
    #expect(input == output)
}

@Test func testTypes() throws {
    var ast = Decode("")
    #expect(ast == libsexp.AtomErr)

    ast = Decode("()")
    #expect(ast == libsexp.Sexp.list([]))

    ast = Decode("\"Hello, world!\"")
    #expect(ast == libsexp.Sexp.quote("\"Hello, world!\""))

    ast = Decode("69")
    #expect(ast == libsexp.Sexp.number(69))

    ast = Decode("1.618")
    #expect(ast == libsexp.Sexp.float(1.618))

    ast = Decode(":ok")
    #expect(ast == libsexp.AtomOk)

    ast = Decode(":true")
    #expect(ast == Sexp.bool(true))

    ast = Decode(":false")
    #expect(ast == Sexp.bool(false))

    ast = Decode("eval")
    #expect(ast == libsexp.Sexp.symbol("eval"))
}