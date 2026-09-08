import Cardinal
import Sequence
import Iterator
import Ownership
import Property
import Testing

@Suite("Sequence.Hint × Property")
struct Sequence_Hint_Property_Tests {

    @Test("default hint is a zero lower bound")
    func defaultHint() {
        var source = Sequence.Fixture.Source([1, 2, 3])

        #expect(source.hint.count == Cardinal(0))
    }
}
