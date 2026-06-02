//
//  Sequence.Difference.Changes+hunks.swift
//  swift-sequence-primitives
//
//  Unified diff hunk generation from Changes.
//

extension Sequence.Difference.Changes where Value: CustomStringConvertible {
    /// Generates unified diff hunks from these changes.
    ///
    /// Groups changes into hunks with surrounding context lines.
    /// Adjacent changes within `contextLines` distance are merged
    /// into a single hunk.
    ///
    /// - Parameter contextLines: Number of context lines around changes (default: 3).
    /// - Returns: Array of hunks.
    public func hunks(contextLines: Cardinal = 3) -> [Sequence.Difference.Hunk] {
        var hunks: [Sequence.Difference.Hunk] = []
        var currentLines: [Sequence.Difference.Change<String>] = []
        var oldStart: Ordinal = .zero
        var oldCount: Cardinal = .zero
        var newStart: Ordinal = .zero
        var newCount: Cardinal = .zero
        var inHunk = false

        var oldLine: Ordinal = 1
        var newLine: Ordinal = 1
        var contextBuffer: [(change: Sequence.Difference.Change<String>, oldLine: Ordinal, newLine: Ordinal)] = []
        var trailingCount: Cardinal = .zero

        for change in _storage {
            let stringChange = change.stringified

            if change.isChange {
                if !inHunk {
                    let bufferCount = Cardinal(UInt(contextBuffer.count))
                    let skip = bufferCount.subtract.saturating(contextLines)
                    let leading = Array(contextBuffer.dropFirst(skip))

                    oldStart = leading.first?.oldLine ?? oldLine
                    newStart = leading.first?.newLine ?? newLine
                    oldCount = .zero
                    newCount = .zero
                    currentLines = []

                    for c in leading {
                        currentLines.append(c.change)
                        oldCount += .one
                        newCount += .one
                    }

                    inHunk = true
                } else if !contextBuffer.isEmpty {
                    for c in contextBuffer {
                        currentLines.append(c.change)
                        oldCount += .one
                        newCount += .one
                    }
                }

                currentLines.append(stringChange)
                switch change {
                case .first: oldCount += .one
                case .second: newCount += .one
                case .both: break
                }

                trailingCount = .zero
                contextBuffer.removeAll()
            } else {
                if inHunk {
                    if trailingCount < contextLines {
                        currentLines.append(stringChange)
                        oldCount += .one
                        newCount += .one
                        trailingCount += .one
                    } else {
                        contextBuffer.append((stringChange, oldLine, newLine))
                        if Cardinal(UInt(contextBuffer.count)) > contextLines {
                            contextBuffer.removeFirst()
                        }

                        if Cardinal(UInt(contextBuffer.count)) >= contextLines {
                            hunks.append(
                                Sequence.Difference.Hunk(
                                    old: .init(start: oldStart, count: oldCount),
                                    new: .init(start: newStart, count: newCount),
                                    lines: currentLines
                                )
                            )
                            inHunk = false
                        }
                    }
                }

                if !inHunk {
                    contextBuffer.append((stringChange, oldLine, newLine))
                    if Cardinal(UInt(contextBuffer.count)) > contextLines {
                        contextBuffer.removeFirst()
                    }
                }
            }

            change.advance(old: &oldLine, new: &newLine)
        }

        if inHunk {
            hunks.append(
                Sequence.Difference.Hunk(
                    old: .init(start: oldStart, count: oldCount),
                    new: .init(start: newStart, count: newCount),
                    lines: currentLines
                )
            )
        }

        return hunks
    }
}
