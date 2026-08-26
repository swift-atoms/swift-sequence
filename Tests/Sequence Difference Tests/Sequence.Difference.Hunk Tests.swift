import Sequence_Test_Support
import Testing

extension Sequence.Difference.Hunk {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Sequence.Difference.Hunk.Test.Unit {
    @Test
    func `header formats standard hunk`() {
        let hunk = Sequence.Difference.Hunk(
            old: .init(start: 1, count: 3),
            new: .init(start: 1, count: 4),
            lines: []
        )
        #expect(hunk.header == "@@ -1,3 +1,4 @@")
    }

    @Test
    func `header formats larger positions`() {
        let hunk = Sequence.Difference.Hunk(
            old: .init(start: 10, count: 5),
            new: .init(start: 12, count: 7),
            lines: []
        )
        #expect(hunk.header == "@@ -10,5 +12,7 @@")
    }
}

extension Sequence.Difference.Hunk.Test.`Edge Case` {
    @Test
    func `header with zero counts`() {
        let hunk = Sequence.Difference.Hunk(
            old: .init(start: 1, count: 0),
            new: .init(start: 1, count: 0),
            lines: []
        )
        #expect(hunk.header == "@@ -1,0 +1,0 @@")
    }
}
