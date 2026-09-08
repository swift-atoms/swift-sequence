import Cardinal
import Ordinal
import Sequence
import Sequence_Test_Support
import Testing

extension Sequence.Difference.Hunk {
    @Suite
    struct `Difference hunk descriptions preserve line positions and counts` {
        @Suite struct `Difference hunk headers format ordinary and larger positions` {}
        @Suite struct `Difference hunk headers preserve zero line counts` {}
        @Suite struct `No difference hunk header integration cases are defined` {}
    }
}

extension Sequence.Difference.Hunk.`Difference hunk descriptions preserve line positions and counts`.`Difference hunk headers format ordinary and larger positions` {
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

extension Sequence.Difference.Hunk.`Difference hunk descriptions preserve line positions and counts`.`Difference hunk headers preserve zero line counts` {
    @Test
    func `A difference hunk header formats zero line counts`() {
        let hunk = Sequence.Difference.Hunk(
            old: .init(start: 1, count: 0),
            new: .init(start: 1, count: 0),
            lines: []
        )
        #expect(hunk.header == "@@ -1,0 +1,0 @@")
    }
}
