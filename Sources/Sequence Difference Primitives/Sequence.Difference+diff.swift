//
//  Sequence.Difference+diff.swift
//  swift-sequence-primitives
//
//  Myers' O(ND) difference algorithm.
//

extension Sequence.Difference {
    /// Computes the minimal differences between two sequences.
    ///
    /// Uses Myers' O(ND) difference algorithm (1986) which guarantees
    /// a minimal edit script — the fewest possible insertions and deletions
    /// to transform `old` into `new`.
    ///
    /// - Complexity: O(ND) time and O(ND) space, where N is the total length
    ///   of both sequences and D is the edit distance. For similar sequences
    ///   (small D), this is nearly linear.
    ///
    /// - Parameters:
    ///   - old: The original sequence.
    ///   - new: The modified sequence.
    /// - Returns: Array of changes describing how to transform `old` into `new`.
    public static func diff<Element: Equatable>(
        _ old: [Element],
        _ new: [Element]
    ) -> [Change<Element>] {
        let n = old.count
        let m = new.count

        if n == 0 { return new.map { .second($0) } }
        if m == 0 { return old.map { .first($0) } }

        // The edit graph has diagonals k = x - y where x indexes into old
        // and y indexes into new. V[k] stores the furthest x reached on
        // diagonal k. We offset k so array indices are non-negative.
        let max = n + m
        let size = 2 * max + 1
        let offset = max

        var v = [Int](repeating: 0, count: size)
        v[1 + offset] = 0

        // Save V at each step for backtracking.
        var trace: [[Int]] = []

        // Explore increasing edit distances until we reach (n, m).
        for d in 0...max {
            trace.append(v)

            for k in stride(from: -d, through: d, by: 2) {
                // Choose direction: down (insert from new) or right (delete from old).
                // Go down if forced (k == -d) or if down reaches further.
                var x: Int
                if k == -d || (k != d && v[k - 1 + offset] < v[k + 1 + offset]) {
                    x = v[k + 1 + offset]
                } else {
                    x = v[k - 1 + offset] + 1
                }

                var y = x - k

                // Follow free diagonal moves (matches).
                while x < n && y < m && old[x] == new[y] {
                    x += 1
                    y += 1
                }

                v[k + offset] = x

                if x >= n && y >= m {
                    return backtrack(trace: trace, old: old, new: new, offset: offset)
                }
            }
        }

        // Unreachable for valid inputs — the algorithm always terminates
        // within max = n + m steps.
        return old.map { .first($0) } + new.map { .second($0) }
    }
}

// MARK: - Backtracking

extension Sequence.Difference {
    /// Reconstructs the edit script by tracing back through saved states.
    private static func backtrack<Element: Equatable>(
        trace: [[Int]],
        old: [Element],
        new: [Element],
        offset: Int
    ) -> [Change<Element>] {
        var x = old.count
        var y = new.count
        var changes: [Change<Element>] = []

        for d in stride(from: trace.count - 1, through: 0, by: -1) {
            let v = trace[d]
            let k = x - y

            // Determine the previous diagonal.
            let prevK: Int
            if k == -d || (k != d && v[k - 1 + offset] < v[k + 1 + offset]) {
                prevK = k + 1
            } else {
                prevK = k - 1
            }

            let prevX = v[prevK + offset]
            let prevY = prevX - prevK

            // Collect diagonal moves (matches) in reverse.
            while x > prevX && y > prevY {
                x -= 1
                y -= 1
                changes.append(.both(old[x]))
            }

            // Collect the non-diagonal move.
            if d > 0 {
                if x == prevX {
                    y -= 1
                    changes.append(.second(new[y]))
                } else {
                    x -= 1
                    changes.append(.first(old[x]))
                }
            }
        }

        changes.reverse()
        return changes
    }
}
