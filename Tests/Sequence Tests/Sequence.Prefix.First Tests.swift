import Cardinal
import Sequence
import Sequence_Test_Support
import Testing

extension Sequence.Prefix {
    @Suite
    struct `Sequence prefixes retain at most the requested leading count` {
        @Suite struct `Count based prefixes retain the requested leading elements` {}
        @Suite struct `Count based prefixes preserve zero empty and oversized cases` {}
        @Suite struct `No sequence count prefix integration cases are defined` {}
    }
}

extension Sequence.Prefix.`Sequence prefixes retain at most the requested leading count`.`Count based prefixes retain the requested leading elements` {
    @Test
    func `A count based sequence prefix retains the requested leading elements`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let result = source.prefix(first: Cardinal(3)).collect()
        #expect(result == [1, 2, 3])
    }

    @Test
    func `Taking a sequence prefix of one retains only the first element`() {
        let source = Sequence.Fixture.Source([10, 20, 30])
        let result = source.prefix(first: .one).collect()
        #expect(result == [10])
    }
}

extension Sequence.Prefix.`Sequence prefixes retain at most the requested leading count`.`Count based prefixes preserve zero empty and oversized cases` {
    @Test
    func `prefix zero elements returns empty`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.prefix(first: .zero).collect()
        #expect(result.isEmpty)
    }

    @Test
    func `prefix more than count returns all`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.prefix(first: Cardinal(10)).collect()
        #expect(result == [1, 2, 3])
    }

    @Test
    func `Taking a count based prefix preserves an empty sequence`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.prefix(first: Cardinal(5)).collect()
        #expect(result.isEmpty)
    }

    @Test
    func `prefix exactly count returns all`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.prefix(first: Cardinal(3)).collect()
        #expect(result == [1, 2, 3])
    }
}
