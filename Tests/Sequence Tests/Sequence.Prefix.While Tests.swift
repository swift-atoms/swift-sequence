import Cardinal
import Sequence
import Sequence_Test_Support
import Testing

extension Sequence.Prefix {
    @Suite
    struct `Predicate prefixes retain the matching leading sequence elements` {
        @Suite struct `Predicate prefixes stop at the first nonmatching element` {}
        @Suite struct `Predicate prefixes preserve empty and uniformly matching cases` {}
        @Suite struct `No sequence predicate prefix integration cases are defined` {}
    }
}

extension Sequence.Prefix.`Predicate prefixes retain the matching leading sequence elements`.`Predicate prefixes stop at the first nonmatching element` {
    @Test
    func `A predicate prefix retains the leading matching elements`() {
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

extension Sequence.Prefix.`Predicate prefixes retain the matching leading sequence elements`.`Predicate prefixes preserve empty and uniformly matching cases` {
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
    func `Taking a predicate prefix preserves an empty sequence`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.prefix(while: { _ in true }).collect()
        #expect(result.isEmpty)
    }
}
