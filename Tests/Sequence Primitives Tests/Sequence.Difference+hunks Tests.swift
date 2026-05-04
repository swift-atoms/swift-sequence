import Sequence_Primitives_Test_Support
import Testing

private typealias Diff = Sequence.Difference
private typealias Change = Sequence.Difference.Change<String>

@Suite("Sequence.Difference.Changes+hunks")
struct SequenceDifferenceHunksTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension SequenceDifferenceHunksTests.Unit {
    @Test
    func `single change produces one hunk`() {
        let changes = Diff.diff(
            ["line1", "line2", "line3"],
            ["line1", "changed", "line3"]
        )
        let result = changes.hunks()
        #expect(result.count == 1)
    }

    @Test
    func `hunk contains correct patch mark`() {
        let changes = Diff.diff(
            ["line1", "line2", "line3"],
            ["line1", "changed", "line3"]
        )
        let result = changes.hunks()
        #expect(result[0].patchMark.hasPrefix("@@"))
        #expect(result[0].patchMark.hasSuffix("@@"))
    }

    @Test
    func `hunk lines include context and changes`() {
        let changes = Diff.diff(
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
        // 10 lines with changes at positions 1 and 9 — more than 2*contextLines apart
        var old = (1...10).map { "line\($0)" }
        var new = old
        new[0] = "changed1"
        new[9] = "changed10"

        let changes = Diff.diff(old, new)
        let hunks = changes.hunks(contextLines: 1)
        #expect(hunks.count == 2)
    }

    @Test
    func `adjacent changes merge into single hunk`() {
        var old = (1...10).map { "line\($0)" }
        var new = old
        new[0] = "changed1"
        new[1] = "changed2"

        let changes = Diff.diff(old, new)
        let hunks = changes.hunks()
        #expect(hunks.count == 1)
    }

    @Test
    func `custom context lines respected`() {
        var old = (1...20).map { "line\($0)" }
        var new = old
        new[0] = "changed1"
        new[19] = "changed20"

        let hunksSmall = Diff.diff(old, new).hunks(contextLines: 1)
        let hunksLarge = Diff.diff(old, new).hunks(contextLines: 10)

        // Small context: distant changes should split
        #expect(hunksSmall.count == 2)
        // Large context: distant changes should merge
        #expect(hunksLarge.count == 1)
    }

    @Test
    func `hunk counts track removals and insertions`() {
        let changes = Diff.diff(
            ["a", "b", "c"],
            ["a", "x", "y", "c"]
        )
        let hunks = changes.hunks()
        #expect(hunks.count == 1)
        #expect(hunks[0].oldCount >= 1)
        #expect(hunks[0].newCount >= 1)
    }
}

// MARK: - EdgeCase

extension SequenceDifferenceHunksTests.EdgeCase {
    @Test
    func `identical sequences produce no hunks`() {
        let changes = Diff.diff(["a", "b", "c"], ["a", "b", "c"])
        #expect(changes.hunks().isEmpty)
    }

    @Test
    func `all changes produce one hunk`() {
        let changes = Diff.diff(["a", "b"], ["x", "y"])
        let hunks = changes.hunks()
        #expect(hunks.count == 1)
    }

    @Test
    func `empty sequences produce no hunks`() {
        let empty: [String] = []
        let changes = Diff.diff(empty, empty)
        #expect(changes.hunks().isEmpty)
    }

    @Test
    func `pure insertion produces one hunk`() {
        let changes = Diff.diff([], ["a", "b", "c"])
        let hunks = changes.hunks()
        #expect(hunks.count == 1)
        #expect(hunks[0].lines.count == 3)
    }

    @Test
    func `pure deletion produces one hunk`() {
        let changes = Diff.diff(["a", "b", "c"], [])
        let hunks = changes.hunks()
        #expect(hunks.count == 1)
        #expect(hunks[0].lines.count == 3)
    }
}
