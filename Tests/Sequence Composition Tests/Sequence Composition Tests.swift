import Sequence_Primitives_Test_Support
import Testing

extension Sequence {
    @Suite
    struct `Composition Test` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Sequence.`Composition Test`.Integration {
    @Test
    func `map then filter then collect`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        let result =
            source
            .map { $0 * 3 }
            .filter { $0 > 10 }
            .collect()
        #expect(result == [12, 15, 18, 21, 24, 27, 30])
    }

    @Test
    func `filter then map`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let result =
            source
            .filter { $0 % 2 != 0 }
            .map { $0 * $0 }
            .collect()
        #expect(result == [1, 9, 25])
    }

    @Test
    func `drop then prefix`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5, 6, 7, 8])
        let result =
            source
            .drop(first: Cardinal(2))
            .prefix(first: Cardinal(3))
            .collect()
        #expect(result == [3, 4, 5])
    }

    @Test
    func `prefix then map`() {
        let source = Sequence.Fixture.Source([10, 20, 30, 40, 50])
        let result =
            source
            .prefix(first: Cardinal(3))
            .map { $0 / 10 }
            .collect()
        #expect(result == [1, 2, 3])
    }

    @Test
    func `chained maps`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result =
            source
            .map { $0 + 1 }
            .map { $0 * 2 }
            .map { $0 - 1 }
            .collect()
        #expect(result == [3, 5, 7])
    }

    @Test
    func `drop while then filter`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5, 6])
        let result =
            source
            .drop(while: { $0 < 3 })
            .filter { $0 % 2 == 0 }
            .collect()
        #expect(result == [4, 6])
    }

    @Test
    func `compactMap then prefix`() {
        let source = Sequence.Fixture.Source(["1", "two", "3", "four", "5", "6"])
        let result =
            source
            .compactMap { Int($0) }
            .prefix(first: Cardinal(3))
            .collect()
        #expect(result == [1, 3, 5])
    }

    @Test
    func `map then flatMap then collect`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result =
            source
            .map { $0 * 2 }
            .flatMap { n in Sequence.Fixture.Source([n, n + 1]) }
            .collect()
        #expect(result == [2, 3, 4, 5, 6, 7])
    }

    @Test
    func `flatMap then filter then collect`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result =
            source
            .flatMap { n in Sequence.Fixture.Source(Array(1...n)) }
            .filter { $0 > 1 }
            .collect()
        #expect(result == [2, 2, 3])
    }

    @Test
    func `full pipeline on empty sequence`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result =
            source
            .map { $0 * 2 }
            .filter { $0 > 0 }
            .drop(first: .one)
            .prefix(first: Cardinal(5))
            .collect()
        #expect(result.isEmpty)
    }
}
