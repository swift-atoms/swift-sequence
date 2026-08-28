extension Sequence.Drain {

    public protocol `Protocol`: ~Copyable {

        associatedtype Element: ~Copyable

        mutating func drain(_ body: (consuming Element) -> Void)
    }
}
