import Cardinal
import Ordinal
import Sequence
import Testing

extension Sequence.Difference {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Sequence.Difference.Test.Unit {

    @Test
    func `core diff identical sequences produces all both`() {
        let old = ["a", "b", "c"]
        let new = ["a", "b", "c"]
        let steps = Sequence.Difference.diff(
            oldCount: Cardinal(UInt(old.count)),
            newCount: Cardinal(UInt(new.count)),
            equals: { old[Int(clamping: $0.rawValue)] == new[Int(clamping: $1.rawValue)] }
        )
        #expect(steps.collect() == [.both, .both, .both])
    }

    @Test
    func `core diff single deletion`() {
        let old = ["a", "b", "c"]
        let new = ["a", "c"]
        let steps = Sequence.Difference.diff(
            oldCount: Cardinal(UInt(old.count)),
            newCount: Cardinal(UInt(new.count)),
            equals: { old[Int(clamping: $0.rawValue)] == new[Int(clamping: $1.rawValue)] }
        )
        #expect(steps.collect() == [.both, .first, .both])
    }

    @Test
    func `core diff single insertion`() {
        let old = ["a", "c"]
        let new = ["a", "b", "c"]
        let steps = Sequence.Difference.diff(
            oldCount: Cardinal(UInt(old.count)),
            newCount: Cardinal(UInt(new.count)),
            equals: { old[Int(clamping: $0.rawValue)] == new[Int(clamping: $1.rawValue)] }
        )
        #expect(steps.collect() == [.both, .second, .both])
    }

    @Test
    func `core diff replacement`() {
        let old = ["a", "b"]
        let new = ["a", "c"]
        let steps = Sequence.Difference.diff(
            oldCount: Cardinal(UInt(old.count)),
            newCount: Cardinal(UInt(new.count)),
            equals: { old[Int(clamping: $0.rawValue)] == new[Int(clamping: $1.rawValue)] }
        )
        #expect(steps.collect() == [.both, .first, .second])
    }

    @Test
    func `diff annotates elements correctly for deletion`() {
        let changes = Sequence.Difference.diff(["a", "b", "c"], ["a", "c"])
        let result = changes.collect()
        #expect(result == [.both("a"), .first("b"), .both("c")])
    }

    @Test
    func `diff annotates elements correctly for insertion`() {
        let changes = Sequence.Difference.diff(["a", "c"], ["a", "b", "c"])
        let result = changes.collect()
        #expect(result == [.both("a"), .second("b"), .both("c")])
    }

    @Test
    func `diff annotates elements correctly for replacement`() {
        let changes = Sequence.Difference.diff(["a", "b"], ["a", "c"])
        let result = changes.collect()
        #expect(result == [.both("a"), .first("b"), .second("c")])
    }

    @Test
    func `steps counts reports removed and inserted`() {
        let old = ["a", "b", "c"]
        let new = ["a", "d"]
        let steps = Sequence.Difference.diff(
            oldCount: Cardinal(UInt(old.count)),
            newCount: Cardinal(UInt(new.count)),
            equals: { old[Int(clamping: $0.rawValue)] == new[Int(clamping: $1.rawValue)] }
        )
        let (removed, inserted) = steps.counts()
        #expect(removed >= Cardinal(1))
        #expect(inserted >= Cardinal(1))
    }

    @Test
    func `steps counts identical sequences reports zero`() {
        let values = ["a", "b"]
        let steps = Sequence.Difference.diff(
            oldCount: Cardinal(UInt(values.count)),
            newCount: Cardinal(UInt(values.count)),
            equals: {
                values[Int(clamping: $0.rawValue)] == values[Int(clamping: $1.rawValue)]
            }
        )
        let (removed, inserted) = steps.counts()
        #expect(removed == Cardinal(0))
        #expect(inserted == Cardinal(0))
    }

    @Test
    func `changes counts reports removed and inserted`() {
        let (removed, inserted) = Sequence.Difference.diff(["a", "b", "c"], ["a", "d"]).counts()
        #expect(removed >= Cardinal(1))
        #expect(inserted >= Cardinal(1))
    }

    @Test
    func `changes counts identical sequences reports zero`() {
        let (removed, inserted) = Sequence.Difference.diff(["x", "y"], ["x", "y"]).counts()
        #expect(removed == Cardinal(0))
        #expect(inserted == Cardinal(0))
    }

    @Test
    func `diff produces minimal edit distance`() {
        let changes = Sequence.Difference.diff(["a", "b", "c", "d"], ["a", "x", "c", "y"])
        let (removed, inserted) = changes.counts()

        #expect(removed == Cardinal(2))
        #expect(inserted == Cardinal(2))
    }
}

extension Sequence.Difference.Test.`Edge Case` {
    @Test
    func `both empty sequences`() {
        let steps = Sequence.Difference.diff(
            oldCount: Cardinal(0),
            newCount: Cardinal(0),
            equals: { _, _ in true }
        )
        #expect(steps.collect().isEmpty)
    }

    @Test
    func `old empty produces all second`() {
        let new = ["a", "b"]
        let steps = Sequence.Difference.diff(
            oldCount: Cardinal(0),
            newCount: Cardinal(UInt(new.count)),
            equals: { _, _ in false }
        )
        #expect(steps.collect() == [.second, .second])
    }

    @Test
    func `new empty produces all first`() {
        let old = ["a", "b"]
        let steps = Sequence.Difference.diff(
            oldCount: Cardinal(UInt(old.count)),
            newCount: Cardinal(0),
            equals: { _, _ in false }
        )
        #expect(steps.collect() == [.first, .first])
    }

    @Test
    func `completely different sequences`() {
        let (removed, inserted) = Sequence.Difference.diff(["a", "b", "c"], ["x", "y", "z"])
            .counts()
        #expect(removed == Cardinal(3))
        #expect(inserted == Cardinal(3))
    }

    @Test
    func `single element identical`() {
        let changes = Sequence.Difference.diff(["a"], ["a"])
        #expect(changes.collect() == [.both("a")])
    }

    @Test
    func `single element different`() {
        let changes = Sequence.Difference.diff(["a"], ["b"])
        let (removed, inserted) = changes.counts()
        #expect(removed == Cardinal(1))
        #expect(inserted == Cardinal(1))
    }

    @Test
    func `convenience diff empty sequences`() {
        let empty: [String] = []
        let changes = Sequence.Difference.diff(empty, empty)
        #expect(changes.collect().isEmpty)
    }

    @Test
    func `convenience diff from empty to non-empty`() {
        let changes = Sequence.Difference.diff([], ["a", "b"])
        #expect(changes.collect() == [.second("a"), .second("b")])
    }

    @Test
    func `convenience diff from non-empty to empty`() {
        let changes = Sequence.Difference.diff(["a", "b"], [])
        #expect(changes.collect() == [.first("a"), .first("b")])
    }
}
