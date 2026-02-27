//
//  Sequence.Difference+hunks.swift
//  swift-sequence-primitives
//
//  Unified diff hunk generation from changes.
//

extension Sequence.Difference {
    /// Generates unified diff hunks from a sequence of changes.
    ///
    /// Groups changes into hunks with surrounding context lines.
    /// Adjacent changes within `contextLines` distance are merged
    /// into a single hunk.
    ///
    /// - Parameters:
    ///   - changes: The computed differences.
    ///   - contextLines: Number of context lines around changes (default: 3).
    /// - Returns: Array of hunks.
    public static func hunks<Element: Sendable & CustomStringConvertible>(
        from changes: [Change<Element>],
        contextLines: Int = 3
    ) -> [Hunk] {
        var hunks: [Hunk] = []
        var currentLines: [Change<String>] = []
        var oldStart = 0
        var oldCount = 0
        var newStart = 0
        var newCount = 0
        var inHunk = false

        var oldLine = 1
        var newLine = 1
        var contextBuffer: [(change: Change<String>, oldLine: Int, newLine: Int)] = []
        var lastChangeIndex = -1

        for (index, change) in changes.enumerated() {
            let stringChange: Change<String>
            switch change {
            case .first(let e): stringChange = .first(String(describing: e))
            case .second(let e): stringChange = .second(String(describing: e))
            case .both(let e): stringChange = .both(String(describing: e))
            }

            if change.isChange {
                if !inHunk {
                    // Start new hunk with buffered context.
                    let contextStart = max(0, contextBuffer.count - contextLines)
                    let context = Array(contextBuffer[contextStart...])

                    oldStart = context.first?.oldLine ?? oldLine
                    newStart = context.first?.newLine ?? newLine
                    oldCount = 0
                    newCount = 0
                    currentLines = []

                    for c in context {
                        currentLines.append(c.change)
                        oldCount += 1
                        newCount += 1
                    }

                    inHunk = true
                }

                currentLines.append(stringChange)
                switch change {
                case .first: oldCount += 1
                case .second: newCount += 1
                case .both: break
                }

                lastChangeIndex = index
                contextBuffer.removeAll()
            } else {
                if inHunk {
                    let distance = index - lastChangeIndex
                    if distance <= contextLines * 2 {
                        // Within merge distance — add to current hunk.
                        currentLines.append(stringChange)
                        oldCount += 1
                        newCount += 1
                    } else {
                        // Close current hunk.
                        hunks.append(Hunk(
                            oldStart: oldStart,
                            oldCount: oldCount,
                            newStart: newStart,
                            newCount: newCount,
                            lines: currentLines
                        ))
                        inHunk = false
                        contextBuffer.removeAll()
                    }
                }

                if !inHunk {
                    contextBuffer.append((stringChange, oldLine, newLine))
                    if contextBuffer.count > contextLines {
                        contextBuffer.removeFirst()
                    }
                }
            }

            switch change {
            case .first: oldLine += 1
            case .second: newLine += 1
            case .both: oldLine += 1; newLine += 1
            }
        }

        if inHunk {
            hunks.append(Hunk(
                oldStart: oldStart,
                oldCount: oldCount,
                newStart: newStart,
                newCount: newCount,
                lines: currentLines
            ))
        }

        return hunks
    }
}
