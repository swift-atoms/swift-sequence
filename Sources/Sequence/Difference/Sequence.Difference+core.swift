public import Cardinal
public import Ordinal

extension Sequence.Difference {

    @inlinable
    public static func diff(
        oldCount: Cardinal,
        newCount: Cardinal,
        equals: (Ordinal, Ordinal) -> Bool
    ) -> Steps {

        let n = Int(clamping: oldCount.rawValue)
        let m = Int(clamping: newCount.rawValue)

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

        return Steps([Step](repeating: .first, count: n) + [Step](repeating: .second, count: m))
    }
}

extension Sequence.Difference {

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

        (0..<trace.count).reversed().forEach { d in
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
