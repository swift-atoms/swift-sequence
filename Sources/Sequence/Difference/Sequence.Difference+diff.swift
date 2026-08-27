import Cardinal
import Ordinal

extension Sequence.Difference {

    public static func diff<Element: Equatable>(
        _ old: [Element],
        _ new: [Element]
    ) -> Changes<Element> {
        let steps = diff(
            oldCount: Cardinal(UInt(old.count)),
            newCount: Cardinal(UInt(new.count)),
            equals: {
                old[Int(clamping: $0.rawValue)] == new[Int(clamping: $1.rawValue)]
            }
        )

        var changes: [Change<Element>] = []
        changes.reserveCapacity(steps._storage.count)

        var oldPosition = 0
        var newPosition = 0

        for step in steps._storage {
            switch step {
            case .first:
                changes.append(.first(old[oldPosition]))
                oldPosition += 1

            case .second:
                changes.append(.second(new[newPosition]))
                newPosition += 1

            case .both:
                changes.append(.both(old[oldPosition]))
                oldPosition += 1
                newPosition += 1
            }
        }

        return Changes(changes)
    }
}
