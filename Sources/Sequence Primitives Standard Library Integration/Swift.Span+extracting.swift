// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Cardinal_Primitives

extension Swift.Span {
    /// Returns a span over the first `count` elements.
    ///
    /// Bridges the typed `Cardinal` count to the stdlib `extracting(first:)` method.
    ///
    /// - Parameter count: The number of elements to extract.
    /// - Returns: A span over the first `count` elements.
    @inlinable
    @_lifetime(copy self)
    public func extracting(first count: Cardinal) -> Self {
        self.extracting(first: Int(bitPattern: count))
    }

    /// Returns a span with the first `count` elements removed.
    ///
    /// Bridges the typed `Cardinal` count to the stdlib `extracting(droppingFirst:)` method.
    ///
    /// - Parameter count: The number of elements to drop.
    /// - Returns: A span with the first `count` elements removed.
    @inlinable
    @_lifetime(copy self)
    public func extracting(droppingFirst count: Cardinal) -> Self {
        self.extracting(droppingFirst: Int(bitPattern: count))
    }
}
