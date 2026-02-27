import Testing
import Sequence_Primitives_Test_Support

private typealias Hunk = Sequence.Difference.Hunk

@Suite("Sequence.Difference.Hunk")
struct SequenceDifferenceHunkTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension SequenceDifferenceHunkTests.Unit {
    @Test
    func `patchMark formats standard hunk`() {
        let hunk = Hunk(
            oldStart: 1, oldCount: 3,
            newStart: 1, newCount: 4,
            lines: []
        )
        #expect(hunk.patchMark == "@@ -1,3 +1,4 @@")
    }

    @Test
    func `patchMark formats larger positions`() {
        let hunk = Hunk(
            oldStart: 10, oldCount: 5,
            newStart: 12, newCount: 7,
            lines: []
        )
        #expect(hunk.patchMark == "@@ -10,5 +12,7 @@")
    }
}

// MARK: - EdgeCase

extension SequenceDifferenceHunkTests.EdgeCase {
    @Test
    func `patchMark with zero counts`() {
        let hunk = Hunk(
            oldStart: 1, oldCount: 0,
            newStart: 1, newCount: 0,
            lines: []
        )
        #expect(hunk.patchMark == "@@ -1,0 +1,0 @@")
    }
}
