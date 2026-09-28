import Sequence
import Sequence
import Cardinal
import Iterator
import Ownership
import Property
import Testing

@Suite("Sequenceable.collect × Cardinal")
struct Sequenceable_Collect_Cardinal_Tests {}

extension Sequenceable_Collect_Cardinal_Tests {
    @Test
    func `collect materializes sequence into array`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let result = source.collect()
        #expect(result == [1, 2, 3, 4, 5])
    }

    @Test
    func `collect preserves element order`() {
        let source = Sequence.Fixture.Source([5, 3, 1, 4, 2])
        let result = source.collect()
        #expect(result == [5, 3, 1, 4, 2])
    }
}

extension Sequenceable_Collect_Cardinal_Tests {
    @Test
    func `collect on empty sequence returns empty array`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.collect()
        #expect(result.isEmpty)
    }

    @Test
    func `collect on single element`() {
        let source = Sequence.Fixture.Source([42])
        let result = source.collect()
        #expect(result == [42])
    }
}
