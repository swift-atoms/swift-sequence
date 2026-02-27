//
//  Sequence.Difference.Step.swift
//  swift-sequence-primitives
//
//  A payload-free edit step between two sequences.
//

extension Sequence.Difference {
    /// A single edit step in a difference script.
    ///
    /// Unlike ``Change``, `Step` carries no element payload. This enables
    /// the core Myers algorithm to operate via closure-based comparison,
    /// placing zero constraints on element type — including `~Copyable`.
    ///
    /// - `.first`: element exists only in the old sequence (removal)
    /// - `.second`: element exists only in the new sequence (insertion)
    /// - `.both`: element exists in both sequences (match)
    public enum Step: Sendable, Hashable {
        /// Element exists only in the first (old) sequence.
        case first
        /// Element exists only in the second (new) sequence.
        case second
        /// Element exists in both sequences.
        case both
    }
}

// MARK: - Properties

extension Sequence.Difference.Step {
    /// Whether this step represents a difference (not a match).
    @inlinable
    public var isChange: Bool {
        switch self {
        case .first, .second: true
        case .both: false
        }
    }

    /// The unified diff marker for this step.
    @inlinable
    public var marker: Character {
        switch self {
        case .first: "-"
        case .second: "+"
        case .both: " "
        }
    }
}
