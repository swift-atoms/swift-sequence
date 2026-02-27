import Testing
import Sequence_Primitives_Test_Support

private typealias Change = Sequence.Difference.Change<String>

@Suite("Sequence.Difference.Change")
struct SequenceDifferenceChangeTests {
    @Suite struct Unit {}
}

// MARK: - Unit

extension SequenceDifferenceChangeTests.Unit {
    @Test
    func `first element extracts value`() {
        #expect(Change.first("a").element == "a")
    }

    @Test
    func `second element extracts value`() {
        #expect(Change.second("b").element == "b")
    }

    @Test
    func `both element extracts value`() {
        #expect(Change.both("c").element == "c")
    }

    @Test
    func `first isChange returns true`() {
        #expect(Change.first("a").isChange)
    }

    @Test
    func `second isChange returns true`() {
        #expect(Change.second("b").isChange)
    }

    @Test
    func `both isChange returns false`() {
        #expect(!Change.both("c").isChange)
    }

    @Test
    func `first marker is minus`() {
        #expect(Change.first("a").marker == "-")
    }

    @Test
    func `second marker is plus`() {
        #expect(Change.second("b").marker == "+")
    }

    @Test
    func `both marker is space`() {
        #expect(Change.both("c").marker == " ")
    }

    @Test
    func `description includes case and value`() {
        #expect(Change.first("x").description == ".first(x)")
        #expect(Change.second("y").description == ".second(y)")
        #expect(Change.both("z").description == ".both(z)")
    }
}
