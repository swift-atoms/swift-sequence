//
//  Sequence.Difference+core.swift
//  swift-sequence-primitives
//
//  Core Myers O(ND) difference algorithm — closure-based, zero element constraints.
//

extension Sequence.Difference {
    /// Computes the minimal edit steps between two sequences using closure-based comparison.
    ///
    /// This is the core algorithm entry point. It places **zero constraints** on
    /// element type — the caller provides a comparison closure that receives
    /// ordinal indices into the old and new sequences. This enables diffing
    /// of `~Copyable` containers, `Span`-backed data, or any indexed source.
    ///
    /// Uses Myers' O(ND) difference algorithm (1986) which guarantees
    /// a minimal edit script — the fewest possible insertions and deletions
    /// to transform the old sequence into the new one.
    ///
    /// - Complexity: O(ND) time and O(ND) space, where N is the total length
    ///   of both sequences and D is the edit distance. For similar sequences
    ///   (small D), this is nearly linear.
    ///
    /// - Parameters:
    ///   - oldCount: Number of elements in the old sequence.
    ///   - newCount: Number of elements in the new sequence.
    ///   - equals: Closure comparing elements at ordinal positions in old and new.
    /// - Returns: The edit steps describing how to transform old into new.
    @inlinable
    public static func diff(
        oldCount: Cardinal,
        newCount: Cardinal,
        equals: (Ordinal, Ordinal) -> Bool
    ) -> Steps {
        // WORKAROUND: Myers algorithm operates in Int — array indices are not domain quantities
        // WHY: Algorithm internals (v[k + offset], trace[d]) use 2D array indexing that doesn't
        //      benefit from Ordinal/Cardinal typing
        // WHEN TO REMOVE: If typed array indexing infrastructure emerges
        // TRACKING: sequence-primitives implementation audit
        let n = Int(bitPattern: oldCount)
        let m = Int(bitPattern: newCount)

        if n == 0 {
            return Steps([Step](repeating: .second, count: m))
        }
        if m == 0 {
            return Steps([Step](repeating: .first, count: n))
        }

        let max = n + m
        let size = 2 * max + 1
        let offset = max

        var v = [Int](repeating: 0, count: size)
        v[1 + offset] = 0

        var trace: [[Int]] = []

        // Typed-while per [IMPL-033]: Myers' algorithm is iteration
        // infrastructure. The outer loop sweeps edit-script depth `d`
        // from 0 to the maximum possible (n + m); the inner stride
        // sweeps diagonal `k`.
        var d = 0
        while d <= max {
            trace.append(v)

            for k in stride(from: -d, through: d, by: 2) {
                var x: Int
                if k == -d || (k != d && v[k - 1 + offset] < v[k + 1 + offset]) {
                    x = v[k + 1 + offset]
                } else {
                    x = v[k - 1 + offset] + 1
                }

                var y = x - k

                while x < n && y < m && equals(Ordinal(UInt(x)), Ordinal(UInt(y))) {
                    x += 1
                    y += 1
                }

                v[k + offset] = x

                if x >= n && y >= m {
                    return backtrack(trace: trace, n: n, m: m, offset: offset)
                }
            }
            d += 1
        }

        // Unreachable for valid inputs — the algorithm always terminates
        // within max = n + m steps.
        return Steps([Step](repeating: .first, count: n) + [Step](repeating: .second, count: m))
    }
}

// MARK: - Backtracking

extension Sequence.Difference {
    /// Reconstructs the edit steps by tracing back through saved states.
    @inlinable
    package static func backtrack(
        trace: [[Int]],
        n: Int,
        m: Int,
        offset: Int
    ) -> Steps {
        var x = n
        var y = m
        var steps: [Step] = []

        for d in (0..<trace.count).reversed() {
            let v = trace[d]
            let k = x - y

            let prevK: Int
            if k == -d || (k != d && v[k - 1 + offset] < v[k + 1 + offset]) {
                prevK = k + 1
            } else {
                prevK = k - 1
            }

            let prevX = v[prevK + offset]
            let prevY = prevX - prevK

            while x > prevX && y > prevY {
                x -= 1
                y -= 1
                steps.append(.both)
            }

            if d > 0 {
                if x == prevX {
                    y -= 1
                    steps.append(.second)
                } else {
                    x -= 1
                    steps.append(.first)
                }
            }
        }

        steps.reverse()
        return Steps(steps)
    }
}
