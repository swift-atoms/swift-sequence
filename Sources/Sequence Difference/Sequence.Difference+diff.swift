internal import Cardinal
internal import Ordinal
internal import Ordinal_Standard_Library_Integration
internal import Ordinal_Successor

extension Sequence.Difference {

    public static func diff<Element: Equatable>(
        _ old: [Element],
        _ new: [Element]
    ) -> Changes<Element> {
        let steps = diff(
            oldCount: Cardinal(UInt(old.count)),
            newCount: Cardinal(UInt(new.count)),
            equals: { old[$0] == new[$1] }
        )

        var changes: [Change<Element>] = []
        changes.reserveCapacity(steps._storage.count)

        var oldPosition: Ordinal = .zero
        var newPosition: Ordinal = .zero

        for step in steps._storage {
            switch step {
            case .first:
                changes.append(.first(old[oldPosition]))
                oldPosition = oldPosition.successor.saturating()

            case .second:
                changes.append(.second(new[newPosition]))
                newPosition = newPosition.successor.saturating()

            case .both:
                changes.append(.both(old[oldPosition]))
                oldPosition = oldPosition.successor.saturating()
                newPosition = newPosition.successor.saturating()
            }
        }

        return Changes(changes)
    }
}
