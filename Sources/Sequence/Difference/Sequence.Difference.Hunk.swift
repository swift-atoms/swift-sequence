extension Sequence.Difference {

    public struct Hunk: Sendable, Hashable {

        public let old: Side

        public let new: Side

        public let lines: [Change<String>]

        public init(
            old: Side,
            new: Side,
            lines: [Change<String>]
        ) {
            self.old = old
            self.new = new
            self.lines = lines
        }
    }
}

extension Sequence.Difference.Hunk {

    public var header: String {
        "@@ -\(old.start),\(old.count) +\(new.start),\(new.count) @@"
    }
}
