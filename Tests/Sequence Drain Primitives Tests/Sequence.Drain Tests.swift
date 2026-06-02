import Sequence_Primitives_Test_Support
import Testing

extension Sequence.Drain {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

// MARK: - Unit

extension Sequence.Drain.Test.Unit {
    @Test
    func `drain visits all elements and empties source`() {
        var source = Sequence.Fixture.Drainable.Source([1, 2, 3, 4, 5])
        var visited: [Int] = []
        source.drain { visited.append($0) }
        #expect(visited == [1, 2, 3, 4, 5])
    }

    @Test
    func `drain transfers ownership of elements`() {
        var source = Sequence.Fixture.Drainable.Source([10, 20, 30])
        var sum = 0
        source.drain { sum += $0 }
        #expect(sum == 60)
    }
}

// MARK: - Edge Case

extension Sequence.Drain.Test.`Edge Case` {
    @Test
    func `drain on empty source does nothing`() {
        var source = Sequence.Fixture.Drainable.Source<Int>([])
        var count = 0
        source.drain { _ in count += 1 }
        #expect(count == 0)
    }
}
