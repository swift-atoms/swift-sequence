extension Sequence {

    public struct Map<Base: Sequenceable & ~Copyable & ~Escapable>: ~Copyable, ~Escapable {
        @usableFromInline
        var _base: Base

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base) {
            self._base = _base
        }
    }
}

extension Sequence.Map: Swift.Copyable where Base: Swift.Copyable & ~Escapable {}

extension Sequence.Map: Swift.Escapable where Base: Swift.Escapable & ~Copyable {}
