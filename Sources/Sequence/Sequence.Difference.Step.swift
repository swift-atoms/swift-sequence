extension Sequence.Difference {

    public enum Step: Sendable, Hashable {

        case first

        case second

        case both
    }
}

extension Sequence.Difference.Step {

    @inlinable
    public var isChange: Bool {
        switch self {
        case .first, .second: true
        case .both: false
        }
    }

    @inlinable
    public var marker: Character {
        switch self {
        case .first: "-"
        case .second: "+"
        case .both: " "
        }
    }
}
