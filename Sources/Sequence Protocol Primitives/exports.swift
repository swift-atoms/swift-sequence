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

@_exported public import Index_Primitives
@_exported public import Iterator_Protocol
// World-A reconciliation (A2/A3a): the attachable reuses the foundation scalar
// `Iterator.Protocol` from swift-iterator-primitives. The bulk (span) iterator
// contract is the canonical `Iterator.Chunk.Protocol` (= top-level
// `__IteratorChunkProtocol`) from swift-iterator-primitives; the formerly-siloed
// `Sequence.Iterator.Protocol` duplicate has been removed in favour of it.
// `Sequence.Iterator` remains as the documentation namespace only.
@_exported public import Sequence_Primitive
