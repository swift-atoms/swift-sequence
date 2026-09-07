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
    }
}
