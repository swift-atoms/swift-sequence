import Cardinal
import Ordinal
import Sequence
import Sequence_Test_Support
import Testing

extension Sequence.Difference {
    @Suite
    struct `Difference changes expose their payloads markers and descriptions` {
        @Suite struct `Difference change accessors preserve the selected case and payload` {}
        @Suite struct `No difference change boundary cases are defined` {}
        @Suite struct `No difference change integration cases are defined` {}
    }
}

extension Sequence.Difference.`Difference changes expose their payloads markers and descriptions`.`Difference change accessors preserve the selected case and payload` {
    @Test
    func `first element extracts value`() {
        #expect(Sequence.Difference.Change<String>.first("a").element == "a")
    }

    @Test
    func `second element extracts value`() {
        #expect(Sequence.Difference.Change<String>.second("b").element == "b")
    }

    @Test
    func `both element extracts value`() {
        #expect(Sequence.Difference.Change<String>.both("c").element == "c")
    }

    @Test
    func `first isChange returns true`() {
        #expect(Sequence.Difference.Change<String>.first("a").isChange)
    }

    @Test
    func `second isChange returns true`() {
        #expect(Sequence.Difference.Change<String>.second("b").isChange)
    }

    @Test
    func `both isChange returns false`() {
        #expect(!Sequence.Difference.Change<String>.both("c").isChange)
    }

    @Test
    func `first marker is minus`() {
        #expect(Sequence.Difference.Change<String>.first("a").marker == "-")
    }

    @Test
    func `second marker is plus`() {
        #expect(Sequence.Difference.Change<String>.second("b").marker == "+")
    }

    @Test
    func `both marker is space`() {
        #expect(Sequence.Difference.Change<String>.both("c").marker == " ")
    }

    @Test
    func `description includes case and value`() {
        #expect(Sequence.Difference.Change<String>.first("x").description == ".first(x)")
        #expect(Sequence.Difference.Change<String>.second("y").description == ".second(y)")
        #expect(Sequence.Difference.Change<String>.both("z").description == ".both(z)")
    }
}
