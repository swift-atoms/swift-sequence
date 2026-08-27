import Cardinal
import Ordinal
import Sequence
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
            old: .init(start: Ordinal(1), count: Cardinal(3)),
            new: .init(start: Ordinal(1), count: Cardinal(4)),
            lines: []
        )
        #expect(hunk.header == "@@ -1,3 +1,4 @@")
    }

    @Test
    func `header formats larger positions`() {
        let hunk = Sequence.Difference.Hunk(
            old: .init(start: Ordinal(10), count: Cardinal(5)),
            new: .init(start: Ordinal(12), count: Cardinal(7)),
            lines: []
        )
        #expect(hunk.header == "@@ -10,5 +12,7 @@")
    }
}

extension Sequence.Difference.Hunk.Test.`Edge Case` {
    @Test
    func `header with zero counts`() {
        let hunk = Sequence.Difference.Hunk(
            old: .init(start: Ordinal(1), count: Cardinal(0)),
            new: .init(start: Ordinal(1), count: Cardinal(0)),
            lines: []
        )
        #expect(hunk.header == "@@ -1,0 +1,0 @@")
    }
}
