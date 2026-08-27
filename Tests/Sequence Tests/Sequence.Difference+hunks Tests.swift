import Cardinal
import Sequence
import Testing

extension Sequence.Difference {
    @Suite
    struct `Hunks Test` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Sequence.Difference.`Hunks Test`.Unit {
    @Test
    func `single change produces one hunk`() {
        let changes = Sequence.Difference.diff(
            ["line1", "line2", "line3"],
            ["line1", "changed", "line3"]
        )
        let result = changes.hunks()
        #expect(result.count == 1)
    }

    @Test
    func `hunk contains correct header`() {
        let changes = Sequence.Difference.diff(
            ["line1", "line2", "line3"],
            ["line1", "changed", "line3"]
        )
        let result = changes.hunks()
        #expect(result[0].header.hasPrefix("@@"))
        #expect(result[0].header.hasSuffix("@@"))
    }

    @Test
    func `hunk lines include context and changes`() {
        let changes = Sequence.Difference.diff(
            ["a", "b", "c"],
            ["a", "x", "c"]
        )
        let hunks = changes.hunks()
        #expect(hunks.count == 1)

        let lines = hunks[0].lines
        #expect(lines.contains(.both("a")))
        #expect(lines.contains(.first("b")))
        #expect(lines.contains(.second("x")))
        #expect(lines.contains(.both("c")))
    }

    @Test
    func `distant changes produce multiple hunks`() {

        let old = (1...10).map { "line\($0)" }
        var new = old
        new[0] = "changed1"
        new[9] = "changed10"

        let changes = Sequence.Difference.diff(old, new)
        let hunks = changes.hunks(contextLines: Cardinal(1))
        #expect(hunks.count == 2)
    }

    @Test
    func `adjacent changes merge into single hunk`() {
        let old = (1...10).map { "line\($0)" }
        var new = old
        new[0] = "changed1"
        new[1] = "changed2"

        let changes = Sequence.Difference.diff(old, new)
        let hunks = changes.hunks()
        #expect(hunks.count == 1)
    }

    @Test
    func `custom context lines respected`() {
        let old = (1...20).map { "line\($0)" }
        var new = old
        new[0] = "changed1"
        new[19] = "changed20"

        let hunksSmall = Sequence.Difference.diff(old, new).hunks(contextLines: Cardinal(1))
        let hunksLarge = Sequence.Difference.diff(old, new).hunks(contextLines: Cardinal(10))

        #expect(hunksSmall.count == 2)

        #expect(hunksLarge.count == 1)
    }

    @Test
    func `hunk counts track removals and insertions`() {
        let changes = Sequence.Difference.diff(
            ["a", "b", "c"],
            ["a", "x", "y", "c"]
        )
        let hunks = changes.hunks()
        #expect(hunks.count == 1)
        #expect(hunks[0].old.count >= Cardinal(1))
        #expect(hunks[0].new.count >= Cardinal(1))
    }
}

extension Sequence.Difference.`Hunks Test`.`Edge Case` {
    @Test
    func `identical sequences produce no hunks`() {
        let changes = Sequence.Difference.diff(["a", "b", "c"], ["a", "b", "c"])
        #expect(changes.hunks().isEmpty)
    }

    @Test
    func `all changes produce one hunk`() {
        let changes = Sequence.Difference.diff(["a", "b"], ["x", "y"])
        let hunks = changes.hunks()
        #expect(hunks.count == 1)
    }

    @Test
    func `empty sequences produce no hunks`() {
        let empty: [String] = []
        let changes = Sequence.Difference.diff(empty, empty)
        #expect(changes.hunks().isEmpty)
    }

    @Test
    func `pure insertion produces one hunk`() {
        let changes = Sequence.Difference.diff([], ["a", "b", "c"])
        let hunks = changes.hunks()
        #expect(hunks.count == 1)
        #expect(hunks[0].lines.count == 3)
    }

    @Test
    func `pure deletion produces one hunk`() {
        let changes = Sequence.Difference.diff(["a", "b", "c"], [])
        let hunks = changes.hunks()
        #expect(hunks.count == 1)
        #expect(hunks[0].lines.count == 3)
    }

    @Test
    func `two hunks split at the context boundary carry no duplicated context`() {

        let old = ["line1", "c1", "c2", "c3", "c4", "c5", "c6", "line8"]
        var new = old
        new[0] = "changed1"
        new[7] = "changed8"

        let hunks = Sequence.Difference.diff(old, new).hunks(contextLines: Cardinal(3))
        #expect(hunks.count == 2)

        let first = hunks[0].lines
        #expect(
            first == [
                .first("line1"), .second("changed1"),
                .both("c1"), .both("c2"), .both("c3"),
            ]
        )

        let second = hunks[1].lines
        #expect(
            second == [
                .both("c4"), .both("c5"), .both("c6"),
                .first("line8"), .second("changed8"),
            ]
        )
        #expect(second.filter { $0 == .both("c6") }.count == 1)

        #expect(hunks[1].old.count == Cardinal(4))
        #expect(hunks[1].new.count == Cardinal(4))
    }
}
