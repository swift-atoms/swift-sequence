public import Cardinal
public import Ordinal

extension Sequence.Difference.Hunk {

    public struct Side: Sendable, Hashable {

        public let start: Ordinal

        public let count: Cardinal

        public init(start: Ordinal, count: Cardinal) {
            self.start = start
            self.count = count
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.start.rawValue == rhs.start.rawValue
                && lhs.count.rawValue == rhs.count.rawValue
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(start.rawValue)
            hasher.combine(count.rawValue)
        }
    }
}
