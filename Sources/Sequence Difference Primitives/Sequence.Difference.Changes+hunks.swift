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
        let context = Int(bitPattern: contextLines)
        var hunks: [Sequence.Difference.Hunk] = []
        var currentLines: [Sequence.Difference.Change<String>] = []
        var oldStart: Int = 0
        var oldCount: Int = 0
        var newStart: Int = 0
        var newCount: Int = 0
        var inHunk = false

        var oldLine = 1
        var newLine = 1
        var contextBuffer: [(change: Sequence.Difference.Change<String>, oldLine: Int, newLine: Int)] = []
        var trailingCount = 0

        for change in _storage {
            let stringChange: Sequence.Difference.Change<String>
            switch change {
            case .first(let e): stringChange = .first(String(describing: e))
            case .second(let e): stringChange = .second(String(describing: e))
            case .both(let e): stringChange = .both(String(describing: e))
            }

            if change.isChange {
                if !inHunk {
                    let contextStart = max(0, contextBuffer.count - context)
                    let leading = Array(contextBuffer[contextStart...])

                    oldStart = leading.first?.oldLine ?? oldLine
                    newStart = leading.first?.newLine ?? newLine
                    oldCount = 0
                    newCount = 0
                    currentLines = []

                    for c in leading {
                        currentLines.append(c.change)
                        oldCount += 1
                        newCount += 1
                    }

                    inHunk = true
                } else if !contextBuffer.isEmpty {
                    for c in contextBuffer {
                        currentLines.append(c.change)
                        oldCount += 1
                        newCount += 1
                    }
                }

                currentLines.append(stringChange)
                switch change {
                case .first: oldCount += 1
                case .second: newCount += 1
                case .both: break
                }

                trailingCount = 0
                contextBuffer.removeAll()
            } else {
                if inHunk {
                    if trailingCount < context {
                        currentLines.append(stringChange)
                        oldCount += 1
                        newCount += 1
                        trailingCount += 1
                    } else {
                        contextBuffer.append((stringChange, oldLine, newLine))
                        if contextBuffer.count > context {
                            contextBuffer.removeFirst()
                        }

                        if contextBuffer.count >= context {
                            hunks.append(Sequence.Difference.Hunk(
                                oldStart: try! Ordinal(oldStart),
                                oldCount: try! Cardinal(oldCount),
                                newStart: try! Ordinal(newStart),
                                newCount: try! Cardinal(newCount),
                                lines: currentLines
                            ))
                            inHunk = false
                        }
                    }
                }

                if !inHunk {
                    contextBuffer.append((stringChange, oldLine, newLine))
                    if contextBuffer.count > context {
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
            hunks.append(Sequence.Difference.Hunk(
                oldStart: Ordinal(UInt(oldStart)),
                oldCount: Cardinal(UInt(oldCount)),
                newStart: Ordinal(UInt(newStart)),
                newCount: Cardinal(UInt(newCount)),
                lines: currentLines
            ))
        }

        return hunks
    }
}
