import Sequence_Primitives_Test_Support
import Testing

private typealias Diff = Sequence.Difference
private typealias Step = Sequence.Difference.Step

@Suite("Sequence.Difference")
struct SequenceDifferenceTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension SequenceDifferenceTests.Unit {

    // MARK: Core closure-based diff

    @Test
    func `core diff identical sequences produces all both`() {
        let old = ["a", "b", "c"]
        let new = ["a", "b", "c"]
        let steps = Diff.diff(
            oldCount: try! Cardinal(old.count),
            newCount: try! Cardinal(new.count),
            equals: { old[Int(bitPattern: $0)] == new[Int(bitPattern: $1)] }
        )
        #expect(steps.collect() == [.both, .both, .both])
    }

    @Test
    func `core diff single deletion`() {
        let old = ["a", "b", "c"]
        let new = ["a", "c"]
        let steps = Diff.diff(
            oldCount: try! Cardinal(old.count),
            newCount: try! Cardinal(new.count),
            equals: { old[Int(bitPattern: $0)] == new[Int(bitPattern: $1)] }
        )
        #expect(steps.collect() == [.both, .first, .both])
    }

    @Test
    func `core diff single insertion`() {
        let old = ["a", "c"]
        let new = ["a", "b", "c"]
        let steps = Diff.diff(
            oldCount: try! Cardinal(old.count),
            newCount: try! Cardinal(new.count),
            equals: { old[Int(bitPattern: $0)] == new[Int(bitPattern: $1)] }
        )
        #expect(steps.collect() == [.both, .second, .both])
    }

    @Test
    func `core diff replacement`() {
        let old = ["a", "b"]
        let new = ["a", "c"]
        let steps = Diff.diff(
            oldCount: try! Cardinal(old.count),
            newCount: try! Cardinal(new.count),
            equals: { old[Int(bitPattern: $0)] == new[Int(bitPattern: $1)] }
        )
        #expect(steps.collect() == [.both, .first, .second])
    }

    // MARK: Convenience array-based diff

    @Test
    func `diff annotates elements correctly for deletion`() {
        let changes = Diff.diff(["a", "b", "c"], ["a", "c"])
        let result = changes.collect()
        #expect(result == [.both("a"), .first("b"), .both("c")])
    }

    @Test
    func `diff annotates elements correctly for insertion`() {
        let changes = Diff.diff(["a", "c"], ["a", "b", "c"])
        let result = changes.collect()
        #expect(result == [.both("a"), .second("b"), .both("c")])
    }

    @Test
    func `diff annotates elements correctly for replacement`() {
        let changes = Diff.diff(["a", "b"], ["a", "c"])
        let result = changes.collect()
        #expect(result == [.both("a"), .first("b"), .second("c")])
    }

    // MARK: Steps.counts()

    @Test
    func `steps counts reports removed and inserted`() {
        let old = ["a", "b", "c"]
        let new = ["a", "d"]
        let steps = Diff.diff(
            oldCount: try! Cardinal(old.count),
            newCount: try! Cardinal(new.count),
            equals: { old[Int(bitPattern: $0)] == new[Int(bitPattern: $1)] }
        )
        let (removed, inserted) = steps.counts()
        #expect(removed >= 1)
        #expect(inserted >= 1)
    }

    @Test
    func `steps counts identical sequences reports zero`() {
        let values = ["a", "b"]
        let steps = Diff.diff(
            oldCount: try! Cardinal(values.count),
            newCount: try! Cardinal(values.count),
            equals: { values[Int(bitPattern: $0)] == values[Int(bitPattern: $1)] }
        )
        let (removed, inserted) = steps.counts()
        #expect(removed == .zero)
        #expect(inserted == .zero)
    }

    // MARK: Changes.counts()

    @Test
    func `changes counts reports removed and inserted`() {
        let (removed, inserted) = Diff.diff(["a", "b", "c"], ["a", "d"]).counts()
        #expect(removed >= 1)
        #expect(inserted >= 1)
    }

    @Test
    func `changes counts identical sequences reports zero`() {
        let (removed, inserted) = Diff.diff(["x", "y"], ["x", "y"]).counts()
        #expect(removed == .zero)
        #expect(inserted == .zero)
    }

    // MARK: Minimality

    @Test
    func `diff produces minimal edit distance`() {
        let changes = Diff.diff(["a", "b", "c", "d"], ["a", "x", "c", "y"])
        let (removed, inserted) = changes.counts()
        // Minimum: remove "b" and "d", insert "x" and "y" → 2 removals, 2 insertions
        #expect(removed == 2)
        #expect(inserted == 2)
    }
}

// MARK: - EdgeCase

extension SequenceDifferenceTests.EdgeCase {
    @Test
    func `both empty sequences`() {
        let steps = Diff.diff(
            oldCount: .zero,
            newCount: .zero,
            equals: { _, _ in true }
        )
        #expect(steps.collect().isEmpty)
    }

    @Test
    func `old empty produces all second`() {
        let new = ["a", "b"]
        let steps = Diff.diff(
            oldCount: .zero,
            newCount: try! Cardinal(new.count),
            equals: { _, _ in false }
        )
        #expect(steps.collect() == [.second, .second])
    }

    @Test
    func `new empty produces all first`() {
        let old = ["a", "b"]
        let steps = Diff.diff(
            oldCount: try! Cardinal(old.count),
            newCount: .zero,
            equals: { _, _ in false }
        )
        #expect(steps.collect() == [.first, .first])
    }

    @Test
    func `completely different sequences`() {
        let (removed, inserted) = Diff.diff(["a", "b", "c"], ["x", "y", "z"]).counts()
        #expect(removed == 3)
        #expect(inserted == 3)
    }

    @Test
    func `single element identical`() {
        let changes = Diff.diff(["a"], ["a"])
        #expect(changes.collect() == [.both("a")])
    }

    @Test
    func `single element different`() {
        let changes = Diff.diff(["a"], ["b"])
        let (removed, inserted) = changes.counts()
        #expect(removed == 1)
        #expect(inserted == 1)
    }

    @Test
    func `convenience diff empty sequences`() {
        let empty: [String] = []
        let changes = Diff.diff(empty, empty)
        #expect(changes.collect().isEmpty)
    }

    @Test
    func `convenience diff from empty to non-empty`() {
        let changes = Diff.diff([], ["a", "b"])
        #expect(changes.collect() == [.second("a"), .second("b")])
    }

    @Test
    func `convenience diff from non-empty to empty`() {
        let changes = Diff.diff(["a", "b"], [])
        #expect(changes.collect() == [.first("a"), .first("b")])
    }
}
