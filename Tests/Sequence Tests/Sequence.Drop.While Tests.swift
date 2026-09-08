import Cardinal
import Sequence
import Sequence_Test_Support
import Testing

extension Sequence.Drop {
    @Suite
    struct `Predicate dropping removes the matching prefix of a sequence` {
        @Suite struct `Predicate dropping stops at the first nonmatching element` {}
        @Suite struct `Predicate dropping preserves empty and uniformly matching cases` {}
        @Suite struct `No sequence predicate drop integration cases are defined` {}
    }
}

extension Sequence.Drop.`Predicate dropping removes the matching prefix of a sequence`.`Predicate dropping stops at the first nonmatching element` {
    @Test
    func `Predicate dropping removes the leading matching elements`() {
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

extension Sequence.Drop.`Predicate dropping removes the matching prefix of a sequence`.`Predicate dropping preserves empty and uniformly matching cases` {
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
    func `Predicate dropping preserves an empty sequence`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.drop(while: { _ in true }).collect()
        #expect(result.isEmpty)
    }
}
