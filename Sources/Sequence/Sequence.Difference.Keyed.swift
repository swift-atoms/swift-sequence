public import Ordinal

extension Sequence.Difference {

    public struct Keyed: Sendable, Hashable {

        public let placements: [Sequence.Difference.Keyed.Placement]

        public let removed: [Ordinal]

        public init(placements: [Sequence.Difference.Keyed.Placement], removed: [Ordinal]) {
            self.placements = placements
            self.removed = removed
        }
    }
}

extension Sequence.Difference.Keyed {

    @inlinable
    public init<Key: Hashable>(
        old: [Key?],
        new: [Key?],
        compatible: (Ordinal, Ordinal) -> Bool = { _, _ in true }
    ) {
        var keyed: [Key: [Int]] = [:]
        var unkeyed: [Int] = []
        for index in old.indices.reversed() {
            if let key = old[index] {
                keyed[key, default: []].append(index)
            } else {
                unkeyed.append(index)
            }
        }
        unkeyed.reverse()
        var used = [Bool](repeating: false, count: old.count)
        var sources = [Int?](repeating: nil, count: new.count)
        var cursor = 0
        for index in new.indices {
            let candidate: Int?
            if let key = new[index] {
                candidate = keyed[key]?.popLast()
            } else if cursor < unkeyed.count {
                candidate = unkeyed[cursor]
                cursor += 1
            } else {
                candidate = nil
            }
            if let candidate, compatible(Ordinal(UInt(candidate)), Ordinal(UInt(index))) {
                sources[index] = candidate
                used[candidate] = true
            }
        }
        let stable = Sequence.Increasing.longest(sources)
        self.init(
            placements: new.indices.map { index in
                guard let source = sources[index] else { return .inserted }
                return stable[index] ? .kept(Ordinal(UInt(source))) : .moved(Ordinal(UInt(source)))
            },
            removed: old.indices.filter { !used[$0] }.map { Ordinal(UInt($0)) }
        )
    }
}
