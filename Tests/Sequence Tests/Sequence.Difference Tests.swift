import Cardinal
import Ordinal
import Sequence
import Sequence_Test_Support
import Testing

extension Sequence.Difference {
    @Suite
    struct `Sequence differences preserve edit structure and minimal distance` {
        @Suite struct `Sequence differences identify insertions removals and unchanged elements` {}
        @Suite struct `Sequence differences preserve empty singleton and disjoint cases` {}
        @Suite struct `No sequence difference integration cases are defined` {}
    }
}

extension Sequence.Difference.`Sequence differences preserve edit structure and minimal distance`.`Sequence differences identify insertions removals and unchanged elements` {

    @Test
    func `core diff identical sequences produces all both`() {
        let old = ["a", "b", "c"]
        let new = ["a", "b", "c"]
        let steps = Sequence.Difference.diff(
            oldCount: Cardinal(UInt(old.count)),
            newCount: Cardinal(UInt(new.count)),
            equals: { old[Int(bitPattern: $0)] == new[Int(bitPattern: $1)] }
        )
        #expect(steps.collect() == [.both, .both, .both])
    }

    @Test
    func `A core sequence difference identifies one deleted element`() {
        let old = ["a", "b", "c"]
        let new = ["a", "c"]
        let steps = Sequence.Difference.diff(
            oldCount: Cardinal(UInt(old.count)),
            newCount: Cardinal(UInt(new.count)),
            equals: { old[Int(bitPattern: $0)] == new[Int(bitPattern: $1)] }
        )
        #expect(steps.collect() == [.both, .first, .both])
    }

    @Test
    func `A core sequence difference identifies one inserted element`() {
        let old = ["a", "c"]
        let new = ["a", "b", "c"]
        let steps = Sequence.Difference.diff(
            oldCount: Cardinal(UInt(old.count)),
            newCount: Cardinal(UInt(new.count)),
            equals: { old[Int(bitPattern: $0)] == new[Int(bitPattern: $1)] }
        )
        #expect(steps.collect() == [.both, .second, .both])
    }

    @Test
    func `A core sequence difference represents replacement as removal and insertion`() {
        let old = ["a", "b"]
        let new = ["a", "c"]
        let steps = Sequence.Difference.diff(
            oldCount: Cardinal(UInt(old.count)),
            newCount: Cardinal(UInt(new.count)),
            equals: { old[Int(bitPattern: $0)] == new[Int(bitPattern: $1)] }
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
            equals: { old[Int(bitPattern: $0)] == new[Int(bitPattern: $1)] }
        )
        let (removed, inserted) = steps.counts()
        #expect(removed >= 1)
        #expect(inserted >= 1)
    }

    @Test
    func `steps counts identical sequences reports zero`() {
        let values = ["a", "b"]
        let steps = Sequence.Difference.diff(
            oldCount: Cardinal(UInt(values.count)),
            newCount: Cardinal(UInt(values.count)),
            equals: { values[Int(bitPattern: $0)] == values[Int(bitPattern: $1)] }
        )
        let (removed, inserted) = steps.counts()
        #expect(removed == .zero)
        #expect(inserted == .zero)
    }

    @Test
    func `changes counts reports removed and inserted`() {
        let (removed, inserted) = Sequence.Difference.diff(["a", "b", "c"], ["a", "d"]).counts()
        #expect(removed >= 1)
        #expect(inserted >= 1)
    }

    @Test
    func `changes counts identical sequences reports zero`() {
        let (removed, inserted) = Sequence.Difference.diff(["x", "y"], ["x", "y"]).counts()
        #expect(removed == .zero)
        #expect(inserted == .zero)
    }

    @Test
    func `diff produces minimal edit distance`() {
        let changes = Sequence.Difference.diff(["a", "b", "c", "d"], ["a", "x", "c", "y"])
        let (removed, inserted) = changes.counts()

        #expect(removed == 2)
        #expect(inserted == 2)
    }
}

extension Sequence.Difference.`Sequence differences preserve edit structure and minimal distance`.`Sequence differences preserve empty singleton and disjoint cases` {
    @Test
    func `The core difference between empty sequences contains no steps`() {
        let steps = Sequence.Difference.diff(
            oldCount: .zero,
            newCount: .zero,
            equals: { _, _ in true }
        )
        #expect(steps.collect().isEmpty)
    }

    @Test
    func `old empty produces all second`() {
        let new = ["a", "b"]
        let steps = Sequence.Difference.diff(
            oldCount: .zero,
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
            newCount: .zero,
            equals: { _, _ in false }
        )
        #expect(steps.collect() == [.first, .first])
    }

    @Test
    func `The core difference between disjoint sequences removes and inserts every element`() {
        let (removed, inserted) = Sequence.Difference.diff(["a", "b", "c"], ["x", "y", "z"])
            .counts()
        #expect(removed == 3)
        #expect(inserted == 3)
    }

    @Test
    func `The core difference between equal singleton sequences preserves the shared element`() {
        let changes = Sequence.Difference.diff(["a"], ["a"])
        #expect(changes.collect() == [.both("a")])
    }

    @Test
    func `The core difference between distinct singleton sequences replaces the element`() {
        let changes = Sequence.Difference.diff(["a"], ["b"])
        let (removed, inserted) = changes.counts()
        #expect(removed == 1)
        #expect(inserted == 1)
    }

    @Test
    func `The sequence difference convenience method preserves two empty inputs`() {
        let empty: [String] = []
        let changes = Sequence.Difference.diff(empty, empty)
        #expect(changes.collect().isEmpty)
    }

    @Test
    func `The sequence difference convenience method inserts every new element`() {
        let changes = Sequence.Difference.diff([], ["a", "b"])
        #expect(changes.collect() == [.second("a"), .second("b")])
    }

    @Test
    func `The sequence difference convenience method removes every old element`() {
        let changes = Sequence.Difference.diff(["a", "b"], [])
        #expect(changes.collect() == [.first("a"), .first("b")])
    }
}
