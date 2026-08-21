import Sequence_Primitives_Test_Support
import Testing

extension Sequence {
    @Suite
    struct `Count Test` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension Sequence.`Count Test`.Unit {
    @Test
    func `collect then count returns total element count`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let total = source.collect().count
        #expect(total == 5)
    }

    @Test
    func `count(where:) returns matching count`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5, 6])
        let evens = source.count { $0 % 2 == 0 }
        #expect(evens == 3)
    }
}

extension Sequence.`Count Test`.`Edge Case` {
    @Test
    func `collect then count on empty sequence returns zero`() {
        let source = Sequence.Fixture.Source<Int>([])
        #expect(source.collect().count == 0)
    }

    @Test
    func `count(where:) with no matches returns zero`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        #expect(source.count { $0 > 100 } == .zero)
    }

    @Test
    func `count(where:) with all matching returns total`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        #expect(source.count { _ in true } == 3)
    }
}
