import Sequence_Primitives_Test_Support
import Testing

extension Sequence.Difference.Step {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Sequence.Difference.Step.Test.Unit {
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
