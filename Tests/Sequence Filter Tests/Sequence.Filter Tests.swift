import Sequence_Filter
import Sequence_Hint
import Sequence_Test_Support
import Testing

extension Sequence {
    @Suite
    struct `Filter Test` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Sequence.`Filter Test`.Unit {
    @Test
    func `filter keeps matching elements`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5, 6])
        let result = source.filter { $0 % 2 == 0 }.collect()
        #expect(result == [2, 4, 6])
    }

    @Test
    func `filter preserves order`() {
        let source = Sequence.Fixture.Source([5, 3, 1, 4, 2])
        let result = source.filter { $0 > 2 }.collect()
        #expect(result == [5, 3, 4])
    }
}

extension Sequence.`Filter Test`.`Edge Case` {
    @Test
    func `filter over empty sequence produces empty array`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.filter { $0 > 0 }.collect()
        #expect(result.isEmpty)
    }

    @Test
    func `filter that matches all elements`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.filter { _ in true }.collect()
        #expect(result == [1, 2, 3])
    }

    @Test
    func `filter that matches no elements`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.filter { _ in false }.collect()
        #expect(result.isEmpty)
    }
}
