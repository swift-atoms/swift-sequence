import Sequence
import Sequence_Test_Support
import Testing

extension Sequence.Drain {
    @Suite
    struct `Sequence draining transfers elements and empties its source` {
        @Suite struct `Sequence draining visits every element and transfers ownership` {}
        @Suite struct `Draining an empty sequence leaves it empty` {}
        @Suite struct `No sequence drain integration cases are defined` {}
    }
}

extension Sequence.Drain.`Sequence draining transfers elements and empties its source`.`Sequence draining visits every element and transfers ownership` {
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

extension Sequence.Drain.`Sequence draining transfers elements and empties its source`.`Draining an empty sequence leaves it empty` {
    @Test
    func `drain on empty source does nothing`() {
        var source = Sequence.Fixture.Drainable.Source<Int>([])
        var count = 0
        source.drain { _ in count += 1 }
        #expect(count == 0)
    }
}
