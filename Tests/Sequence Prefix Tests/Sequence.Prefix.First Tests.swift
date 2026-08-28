import Sequence_Test_Support
import Testing

extension Sequence.Prefix {
    @Suite
    struct `First Test` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Sequence.Prefix.`First Test`.Unit {
    @Test
    func `prefix first N elements`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let result = source.prefix(first: Cardinal(3)).collect()
        #expect(result == [1, 2, 3])
    }

    @Test
    func `prefix first 1 element`() {
        let source = Sequence.Fixture.Source([10, 20, 30])
        let result = source.prefix(first: .one).collect()
        #expect(result == [10])
    }
}

extension Sequence.Prefix.`First Test`.`Edge Case` {
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
    func `prefix from empty sequence`() {
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
