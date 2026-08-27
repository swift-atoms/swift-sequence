public import Cardinal
import Ordinal

extension Sequence.Difference.Changes where Value: CustomStringConvertible {

    public func hunks(contextLines: Cardinal = Cardinal(3)) -> [Sequence.Difference.Hunk] {
        let contextLimit = Int(clamping: contextLines.rawValue)
        var hunks: [Sequence.Difference.Hunk] = []
        var currentLines: [Sequence.Difference.Change<String>] = []
        var oldStart: Ordinal = .zero
        var oldCount = Cardinal(0)
        var newStart: Ordinal = .zero
        var newCount = Cardinal(0)
        var inHunk = false

        var oldLine = Ordinal(1)
        var newLine = Ordinal(1)
        var contextBuffer:
            [(change: Sequence.Difference.Change<String>, oldLine: Ordinal, newLine: Ordinal)] = []
        var trailingCount = 0

        for change in _storage {
            let stringChange = change.stringified

            if change.isChange {
                if !inHunk {
                    let skip = Swift.max(contextBuffer.count - contextLimit, 0)
                    let leading = Array(contextBuffer.dropFirst(skip))

                    oldStart = leading.first?.oldLine ?? oldLine
                    newStart = leading.first?.newLine ?? newLine
                    oldCount = Cardinal(0)
                    newCount = Cardinal(0)
                    currentLines = []

                    for c in leading {
                        currentLines.append(c.change)
                        oldCount += Cardinal(1)
                        newCount += Cardinal(1)
                    }

                    inHunk = true
                } else if !contextBuffer.isEmpty {
                    for c in contextBuffer {
                        currentLines.append(c.change)
                        oldCount += Cardinal(1)
                        newCount += Cardinal(1)
                    }
                }

                currentLines.append(stringChange)
                switch change {
                case .first: oldCount += Cardinal(1)
                case .second: newCount += Cardinal(1)
                case .both: break
                }

                trailingCount = 0
                contextBuffer.removeAll()
            } else {
                var buffered = false

                if inHunk {
                    if trailingCount < contextLimit {
                        currentLines.append(stringChange)
                        oldCount += Cardinal(1)
                        newCount += Cardinal(1)
                        trailingCount += 1
                    } else {
                        contextBuffer.append((stringChange, oldLine, newLine))
                        buffered = true
                        if contextBuffer.count > contextLimit {
                            contextBuffer.removeFirst()
                        }

                        if contextBuffer.count >= contextLimit {
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

                if !inHunk && !buffered {
                    contextBuffer.append((stringChange, oldLine, newLine))
                    if contextBuffer.count > contextLimit {
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
