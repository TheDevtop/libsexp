import Testing
import libsexp

@Test func testRosetta() throws {
    let input = "((data \"quoted data\" 123 4.5) (data (!@# (4.5) \"(more\" \"data)\")))"
    let ast = Decode(input)
    let output = Encode(ast)
    #expect(input == output)
}