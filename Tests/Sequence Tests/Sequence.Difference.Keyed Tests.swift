import Ordinal
import Sequence
import Testing

enum `Sequence.Difference.Keyed Tests` {}

extension `Sequence.Difference.Keyed Tests` {
    @Suite struct `Keyed differences reuse matching elements and move as few as possible` {}
}

extension `Sequence.Difference.Keyed Tests`.`Keyed differences reuse matching elements and move as few as possible` {

    static func o(_ value: UInt) -> Ordinal { Ordinal(value) }

    @Test
    func `identical keys keep every element`() {
        let difference = Sequence.Difference.Keyed(old: [1, 2, 3], new: [1, 2, 3])
        #expect(difference.placements == [.kept(Self.o(0)), .kept(Self.o(1)), .kept(Self.o(2))])
        #expect(difference.removed.isEmpty)
    }

    @Test
    func `moving the last element to the front moves only that element`() {
        let difference = Sequence.Difference.Keyed(old: [1, 2, 3], new: [3, 1, 2])
        #expect(difference.placements == [.moved(Self.o(2)), .kept(Self.o(0)), .kept(Self.o(1))])
    }

    @Test
    func `swapping two of many moves two`() {
        let old = Array(1...6)
        let new = [1, 5, 3, 4, 2, 6]
        let moved = Sequence.Difference.Keyed(old: old, new: new).placements.filter {
            if case .moved = $0 { true } else { false }
        }
        #expect(moved.count == 2)
    }

    @Test
    func `new keys are inserted and missing keys removed`() {
        let difference = Sequence.Difference.Keyed(old: [1, 2, 3], new: [3, 4])
        #expect(difference.placements == [.kept(Self.o(2)), .inserted])
        #expect(difference.removed == [Self.o(0), Self.o(1)])
    }

    @Test
    func `elements without a key match by position among unkeyed elements`() {
        let difference = Sequence.Difference.Keyed(old: [nil, 7, nil], new: [nil, nil, 7])
        let sources = difference.placements.map { placement -> Ordinal? in
            switch placement {
            case .inserted: nil
            case .kept(let source), .moved(let source): source
            }
        }
        let moves = difference.placements.filter { if case .moved = $0 { true } else { false } }
        #expect(sources == [Self.o(0), Self.o(2), Self.o(1)])
        #expect(moves.count == 1)
        #expect(difference.removed.isEmpty)
    }

    @Test
    func `an incompatible match is replaced`() {
        let difference = Sequence.Difference.Keyed(old: [1, 2], new: [1, 2]) { old, _ in
            old != Self.o(1)
        }
        #expect(difference.placements == [.kept(Self.o(0)), .inserted])
        #expect(difference.removed == [Self.o(1)])
    }

    @Test
    func `a repeated key reuses each old element once`() {
        let difference = Sequence.Difference.Keyed(old: [5, 5], new: [5, 5, 5])
        #expect(difference.placements == [.kept(Self.o(0)), .kept(Self.o(1)), .inserted])
    }
}

enum `Sequence.Increasing Tests` {}

extension `Sequence.Increasing Tests` {
    @Suite struct `The longest increasing subsequence is found and absent elements are skipped` {}
}

extension `Sequence.Increasing Tests`.`The longest increasing subsequence is found and absent elements are skipped` {

    @Test
    func `a sorted sequence is all members`() {
        #expect(Sequence.Increasing.longest([1, 2, 3]) == [true, true, true])
    }

    @Test
    func `one out of place element is left out`() {
        #expect(Sequence.Increasing.longest([3, 1, 2]) == [false, true, true])
    }

    @Test
    func `absent elements are never members`() {
        let members = Sequence.Increasing.longest([1, nil, 0, 2])
        #expect(members[1] == false)
        #expect(members[3])
        #expect(members.filter { $0 }.count == 2)
    }

    @Test
    func `the result is as long as the longest increasing run`() {
        let members = Sequence.Increasing.longest([5, 1, 6, 2, 7, 3, 8, 4])
        #expect(members.filter { $0 }.count == 4)
    }
}
