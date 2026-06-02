import Sequence_Primitives_Test_Support
import Testing

extension Sequence.Prefix {
    @Suite
    struct `While Test` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

// MARK: - Unit

extension Sequence.Prefix.`While Test`.Unit {
    @Test
    func `prefix while predicate holds`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let result = source.prefix(while: { $0 < 4 }).collect()
        #expect(result == [1, 2, 3])
    }

    @Test
    func `prefix while stops at first false`() {
        let source = Sequence.Fixture.Source([2, 4, 6, 1, 8])
        let result = source.prefix(while: { $0 % 2 == 0 }).collect()
        #expect(result == [2, 4, 6])
    }
}

// MARK: - Edge Case

extension Sequence.Prefix.`While Test`.`Edge Case` {
    @Test
    func `predicate always true takes all elements`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.prefix(while: { _ in true }).collect()
        #expect(result == [1, 2, 3])
    }

    @Test
    func `predicate never true takes no elements`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.prefix(while: { _ in false }).collect()
        #expect(result.isEmpty)
    }

    @Test
    func `prefix while on empty sequence`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.prefix(while: { _ in true }).collect()
        #expect(result.isEmpty)
    }
}
