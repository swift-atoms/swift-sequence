//
//  Sequence.Difference.Change.swift
//  swift-sequence-primitives
//
//  A single change between two sequences.
//

extension Sequence.Difference {
    /// A single change between two sequences.
    ///
    /// Each element in the diff output is one of:
    /// - `.first`: element exists only in the first sequence (removed)
    /// - `.second`: element exists only in the second sequence (inserted)
    /// - `.both`: element exists in both sequences (matched)
    public enum Change<Element: Sendable>: Sendable {
        /// Element exists only in the first sequence.
        case first(Element)
        /// Element exists only in the second sequence.
        case second(Element)
        /// Element exists in both sequences.
        case both(Element)
    }
}

// MARK: - Properties

extension Sequence.Difference.Change {
    /// The element carried by this change.
    public var element: Element {
        switch self {
        case .first(let e), .second(let e), .both(let e): return e
        }
    }

    /// The unified diff marker for this change.
    public var marker: Character {
        switch self {
        case .first: "-"
        case .second: "+"
        case .both: " "
        }
    }

    /// Whether this change represents a difference (not a match).
    public var isChange: Bool {
        switch self {
        case .first, .second: true
        case .both: false
        }
    }
}

// MARK: - Equatable

extension Sequence.Difference.Change: Equatable where Element: Equatable {}

// MARK: - Hashable

extension Sequence.Difference.Change: Hashable where Element: Hashable {}

// MARK: - CustomStringConvertible

extension Sequence.Difference.Change: CustomStringConvertible {
    public var description: String {
        switch self {
        case .first(let e): ".first(\(e))"
        case .second(let e): ".second(\(e))"
        case .both(let e): ".both(\(e))"
        }
    }
}
