import Sequence
import Sequence_Test_Support
import Testing

extension Sequence {
    @Suite
    struct `Sequence mapping transforms elements while preserving order` {
        @Suite struct `Sequence mapping preserves transformations result types and identity` {}
        @Suite struct `Sequence mapping handles empty and singleton sources` {}
        @Suite struct `No sequence mapping integration cases are defined` {}
    }
}

extension Sequence.`Sequence mapping transforms elements while preserving order`.`Sequence mapping preserves transformations result types and identity` {
    @Test
    func `map transforms each element`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let result = source.map { $0 * 2 }.collect()
        #expect(result == [2, 4, 6, 8, 10])
    }

    @Test
    func `map changes element type`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.map { String($0) }.collect()
        #expect(result == ["1", "2", "3"])
    }

    @Test
    func `identity map preserves elements`() {
        let source = Sequence.Fixture.Source([10, 20, 30])
        let result = source.map { $0 }.collect()
        #expect(result == [10, 20, 30])
    }
}

extension Sequence.`Sequence mapping transforms elements while preserving order`.`Sequence mapping handles empty and singleton sources` {
    @Test
    func `map over empty sequence produces empty array`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.map { $0 * 2 }.collect()
        #expect(result.isEmpty)
    }

    @Test
    func `Mapping a singleton sequence transforms its sole element`() {
        let source = Sequence.Fixture.Source([42])
        let result = source.map { $0 + 1 }.collect()
        #expect(result == [43])
    }
}
