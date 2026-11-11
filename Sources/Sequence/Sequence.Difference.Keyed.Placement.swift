public import Ordinal

extension Sequence.Difference.Keyed {

    public enum Placement: Sendable, Hashable {

        case inserted

        case kept(Ordinal)

        case moved(Ordinal)
    }
}
