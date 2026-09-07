internal import Cardinal
public import Ordinal

extension Sequence.Difference {

    public enum Change<Element> {

        case first(Element)

        case second(Element)

        case both(Element)
    }
}

extension Sequence.Difference.Change {

    public var element: Element {
        switch self {
        case .first(let e), .second(let e), .both(let e): return e
        }
    }

    public var marker: Character {
        switch self {
        case .first: "-"
        case .second: "+"
        case .both: " "
        }
    }

    public var isChange: Bool {
        switch self {
        case .first, .second: true
        case .both: false
        }
    }

    public func advance(old: inout Ordinal, new: inout Ordinal) {
        switch self {
        case .first: old += .one

        case .second: new += .one

        case .both:
            old += .one
            new += .one
        }
    }
}

extension Sequence.Difference.Change where Element: CustomStringConvertible {

    public var stringified: Sequence.Difference.Change<String> {
        switch self {
        case .first(let e): .first(e.description)
        case .second(let e): .second(e.description)
        case .both(let e): .both(e.description)
        }
    }
}

extension Sequence.Difference.Change: Swift.Sendable where Element: Swift.Sendable {}

extension Sequence.Difference.Change: Swift.Equatable where Element: Swift.Equatable {}

extension Sequence.Difference.Change: Swift.Hashable where Element: Swift.Hashable {}
