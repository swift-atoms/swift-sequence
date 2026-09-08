import Sequence
import Sequence_Test_Support
import Testing

extension Sequence {
    @Suite
    struct `Sequence filtering preserves matching elements in source order` {
        @Suite struct `Sequence filtering selects matches without reordering them` {}
        @Suite struct `Sequence filtering handles empty sources and predicates matching none or all` {}
        @Suite struct `No sequence filter integration cases are defined` {}
    }
}

extension Sequence.`Sequence filtering preserves matching elements in source order`.`Sequence filtering selects matches without reordering them` {
    @Test
    func `filter keeps matching elements`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5, 6])
        let result = source.filter { $0 % 2 == 0 }.collect()
        #expect(result == [2, 4, 6])
    }

    @Test
    func `filter preserves order`() {
        let source = Sequence.Fixture.Source([5, 3, 1, 4, 2])
        let result = source.filter { $0 > 2 }.collect()
        #expect(result == [5, 3, 4])
    }
}

extension Sequence.`Sequence filtering preserves matching elements in source order`.`Sequence filtering handles empty sources and predicates matching none or all` {
    @Test
    func `filter over empty sequence produces empty array`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.filter { $0 > 0 }.collect()
        #expect(result.isEmpty)
    }

    @Test
    func `An always matching sequence filter preserves every element`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.filter { _ in true }.collect()
        #expect(result == [1, 2, 3])
    }

    @Test
    func `A never matching sequence filter produces no elements`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.filter { _ in false }.collect()
        #expect(result.isEmpty)
    }
}
