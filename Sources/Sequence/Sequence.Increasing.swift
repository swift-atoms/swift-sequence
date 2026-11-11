extension Sequence {

    public enum Increasing {}
}

extension Sequence.Increasing {

    @inlinable
    public static func longest<Element: Comparable>(_ elements: [Element?]) -> [Bool] {
        var tails: [Int] = []
        var previous = [Int](repeating: -1, count: elements.count)
        for index in elements.indices {
            guard let element = elements[index] else { continue }
            var low = 0
            var high = tails.count
            while low < high {
                let middle = (low + high) / 2
                if let tail = elements[tails[middle]], tail < element {
                    low = middle + 1
                } else {
                    high = middle
                }
            }
            if low > 0 { previous[index] = tails[low - 1] }
            if low == tails.count {
                tails.append(index)
            } else {
                tails[low] = index
            }
        }
        var members = [Bool](repeating: false, count: elements.count)
        var cursor = tails.last ?? -1
        while cursor >= 0 {
            members[cursor] = true
            cursor = previous[cursor]
        }
        return members
    }
}
