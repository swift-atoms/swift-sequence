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

extension Sequence.Map: Copyable where Base: Copyable & ~Escapable {}
extension Sequence.Map: Escapable where Base: Escapable & ~Copyable {}
