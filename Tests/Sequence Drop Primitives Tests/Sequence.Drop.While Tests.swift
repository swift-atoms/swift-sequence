import Sequence_Primitives_Test_Support
import Testing

extension Sequence.Drop {
    @Suite
    struct `While Test` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Sequence.Drop.`While Test`.Unit {
    @Test
    func `drop while predicate holds`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let result = source.drop(while: { $0 < 3 }).collect()
        #expect(result == [3, 4, 5])
    }

    @Test
    func `drop while stops at first false`() {
        let source = Sequence.Fixture.Source([1, 2, 5, 1, 2])
        let result = source.drop(while: { $0 < 5 }).collect()
        #expect(result == [5, 1, 2])
    }
}

extension Sequence.Drop.`While Test`.`Edge Case` {
    @Test
    func `predicate never true keeps all elements`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.drop(while: { _ in false }).collect()
        #expect(result == [1, 2, 3])
    }

    @Test
    func `predicate always true drops all elements`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.drop(while: { _ in true }).collect()
        #expect(result.isEmpty)
    }

    @Test
    func `drop while on empty sequence`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.drop(while: { _ in true }).collect()
        #expect(result.isEmpty)
    }
}
