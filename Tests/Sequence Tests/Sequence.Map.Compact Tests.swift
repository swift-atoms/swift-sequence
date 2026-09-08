import Sequence
import Sequence_Test_Support
import Testing

extension Sequence {
    @Suite
    struct `Compact mapping transforms elements and discards nil results` {
        @Suite struct `Compact mapping preserves transformed nonnil results` {}
        @Suite struct `Compact mapping handles empty sources and uniformly nil or nonnil results` {}
        @Suite struct `No sequence compact mapping integration cases are defined` {}
    }
}

extension Sequence.`Compact mapping transforms elements and discards nil results`.`Compact mapping preserves transformed nonnil results` {
    @Test
    func `compactMap removes nils`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let result = source.compactMap { $0 % 2 == 0 ? $0 : nil }.collect()
        #expect(result == [2, 4])
    }

    @Test
    func `compactMap transforms and filters`() {
        let source = Sequence.Fixture.Source(["1", "two", "3", "four"])
        let result = source.compactMap { Int($0) }.collect()
        #expect(result == [1, 3])
    }
}

extension Sequence.`Compact mapping transforms elements and discards nil results`.`Compact mapping handles empty sources and uniformly nil or nonnil results` {
    @Test
    func `Compact mapping preserves an empty sequence`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.compactMap { $0 % 2 == 0 ? $0 : nil }.collect()
        #expect(result.isEmpty)
    }

    @Test
    func `Compact mapping discards every element when all results are nil`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.compactMap { _ -> Int? in nil }.collect()
        #expect(result.isEmpty)
    }

    @Test
    func `Compact mapping retains every transformed nonnil result`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.compactMap { Optional($0) }.collect()
        #expect(result == [1, 2, 3])
    }
}
