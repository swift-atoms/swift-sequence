import Cardinal
import Sequence
import Sequence_Test_Support
import Testing

extension Sequence.Drop {
    @Suite
    struct `Dropping sequence elements removes at most the requested leading count` {
        @Suite struct `Count based dropping removes the requested leading elements` {}
        @Suite struct `Count based dropping preserves zero empty and oversized cases` {}
        @Suite struct `No sequence count drop integration cases are defined` {}
    }
}

extension Sequence.Drop.`Dropping sequence elements removes at most the requested leading count`.`Count based dropping removes the requested leading elements` {
    @Test
    func `Count based sequence dropping removes the requested prefix`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let result = source.drop(first: Cardinal(2)).collect()
        #expect(result == [3, 4, 5])
    }

    @Test
    func `Dropping one sequence element removes only the first element`() {
        let source = Sequence.Fixture.Source([10, 20, 30])
        let result = source.drop(first: .one).collect()
        #expect(result == [20, 30])
    }
}

extension Sequence.Drop.`Dropping sequence elements removes at most the requested leading count`.`Count based dropping preserves zero empty and oversized cases` {
    @Test
    func `drop zero elements returns all`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.drop(first: .zero).collect()
        #expect(result == [1, 2, 3])
    }

    @Test
    func `drop more than count returns empty`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.drop(first: Cardinal(10)).collect()
        #expect(result.isEmpty)
    }

    @Test
    func `Count based dropping preserves an empty sequence`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.drop(first: Cardinal(5)).collect()
        #expect(result.isEmpty)
    }

    @Test
    func `drop exactly count returns empty`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.drop(first: Cardinal(3)).collect()
        #expect(result.isEmpty)
    }
}
