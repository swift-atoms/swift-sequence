internal import Cardinal
public import Ordinal

extension Sequence.Difference.Change: Swift.CustomStringConvertible {

    public var description: String {
        switch self {
        case .first(let e): ".first(\(e))"
        case .second(let e): ".second(\(e))"
        case .both(let e): ".both(\(e))"
        }
    }
}
