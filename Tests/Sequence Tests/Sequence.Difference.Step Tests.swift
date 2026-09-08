import Cardinal
import Ordinal
import Sequence
import Sequence_Test_Support
import Testing

extension Sequence.Difference.Step {
    @Suite
    struct `Difference steps expose change status and edit markers` {
        @Suite struct `Difference step predicates and markers distinguish edit cases` {}
        @Suite struct `No difference step boundary cases are defined` {}
        @Suite struct `No difference step integration cases are defined` {}
    }
}

extension Sequence.Difference.Step.`Difference steps expose change status and edit markers`.`Difference step predicates and markers distinguish edit cases` {
    @Test
    func `first isChange returns true`() {
        #expect(Sequence.Difference.Step.first.isChange)
    }

    @Test
    func `second isChange returns true`() {
        #expect(Sequence.Difference.Step.second.isChange)
    }

    @Test
    func `both isChange returns false`() {
        #expect(!Sequence.Difference.Step.both.isChange)
    }

    @Test
    func `first marker is minus`() {
        #expect(Sequence.Difference.Step.first.marker == "-")
    }

    @Test
    func `second marker is plus`() {
        #expect(Sequence.Difference.Step.second.marker == "+")
    }

    @Test
    func `both marker is space`() {
        #expect(Sequence.Difference.Step.both.marker == " ")
    }
}
