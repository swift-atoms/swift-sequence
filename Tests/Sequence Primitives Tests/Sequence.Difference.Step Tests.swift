import Sequence_Primitives_Test_Support
import Testing

private typealias Step = Sequence.Difference.Step

@Suite("Sequence.Difference.Step")
struct SequenceDifferenceStepTests {
    @Suite struct Unit {}
}

// MARK: - Unit

extension SequenceDifferenceStepTests.Unit {
    @Test
    func `first isChange returns true`() {
        #expect(Step.first.isChange)
    }

    @Test
    func `second isChange returns true`() {
        #expect(Step.second.isChange)
    }

    @Test
    func `both isChange returns false`() {
        #expect(!Step.both.isChange)
    }

    @Test
    func `first marker is minus`() {
        #expect(Step.first.marker == "-")
    }

    @Test
    func `second marker is plus`() {
        #expect(Step.second.marker == "+")
    }

    @Test
    func `both marker is space`() {
        #expect(Step.both.marker == " ")
    }
}
