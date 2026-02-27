# Audit: Zero-Allocation nextSpan for Generating Iterators

<!--
---
version: 1.0.0
date: 2026-02-26
status: AUDIT
auditor: Claude
source: zero-allocation-nextspan-for-generating-iterators.md
---
-->

## Summary

6 audit items reviewed. 3 VERIFIED, 2 CHALLENGED, 1 FLAGGED.

| # | Item | Verdict |
|---|------|---------|
| 1 | Build and run experiments | **VERIFIED** |
| 2 | V2 REFUTED finding (withUnsafePointer borrowing) | **VERIFIED** (with precision note) |
| 3 | Escaped pointer safety | **VERIFIED** (with caveat) |
| 4 | Option E necessity over Option F | **CHALLENGED** |
| 5 | Memory.Inline tier placement | **VERIFIED** |
| 6 | Research document gaps | **FLAGGED** (3 corrections needed) |

The overall decision (Option E as primary) remains sound, but the reasoning requires correction. The claim that Option F is "Copyable only" is **wrong** — `Optional<Element>` works for `Element: ~Copyable` in Swift 6.2. The true justification for Option E is zero overhead, no layout assumptions, and cleaner ownership semantics — not impossibility of the alternative.

---

## Item 1: Build and Run All Experiments

**Verdict: VERIFIED**

All three experiments compile and run on Swift 6.2.3 / macOS 26.2 (arm64). Output matches all claims.

### Experiment 1: `inline-rawlayout-nextspan`

Builds clean. Results:

```
V1a Counter (next() via nextSpan):  CONFIRMED — [1, 2, 3, 4, 5]
V1b Counter (direct nextSpan):      CONFIRMED — [10, 11, 12, 13]
V2  Fibonacci:                       CONFIRMED — [0, 1, 1, 2, 3, 5, 8, 13]
V3  Cyclic group:                    CONFIRMED — [3, 2, 6, 4, 5, 1]
V4  SingleElementBuffer<Int>:        size=8, stride=8 (== Int: zero overhead)
V5  V1_CounterIterator:              size=25, stride=32
V6  Empty iterator:                  CONFIRMED — [] (deinit safe)
```

All 6 variants confirmed. SingleElementBuffer has true zero size overhead.

### Experiment 2: `stored-property-span-access`

Builds with 5 warnings (StrictMemorySafety: `withUnsafeMutablePointer` closures not wrapped in `unsafe`). No errors. Results:

```
V1  withUnsafeMutablePointer(&_element): CONFIRMED — 42
V2  withUnsafePointer borrowing:         REFUTED (dangling pointer)
V3  Full counter iterator:               CONFIRMED — [1, 2, 3, 4, 5]
V4  Optional stored property:            CONFIRMED — 77
V5  Span as closure result:              REFUTED (compile error)
V6  Stored property iterator:            size=24, stride=24
```

V1, V3, V4 confirmed. V2, V5 correctly refuted. V6 size advantage over rawLayout confirmed (24/24 vs 25/32).

### Experiment 3: `lazy-iterator-nextspan-strategies`

Builds clean. All 7 variants pass:

```
V1  Heap buffer Map:       CONFIRMED — [1, 4, 9, 16, 25]
V2  Inline Optional:       REFUTED
V3  Drop.First forward:    CONFIRMED — [30, 40, 50]
V4  Drop.While sub-span:   CONFIRMED — [7, 8, 9, 10]
V5  Prefix.While sub-span: CONFIRMED — [2, 4, 6]
V6  Filter heap buffer:    CONFIRMED — [2, 4, 6, 8, 10]
V7  Prefix.First forward:  CONFIRMED — [10, 20, 30]
```

Strategy classification confirmed: element-preserving → forward to base (zero allocation); element-transforming → heap buffer.

---

## Item 2: V2 REFUTED Finding — `withUnsafePointer(to: _element)` Semantics

**Verdict: VERIFIED** (the conclusion is correct; one precision note on the reasoning)

### Stdlib Source Analysis

`/Users/coen/Developer/swiftlang/swift/stdlib/public/core/LifetimeManager.swift` reveals **two** overloads of `withUnsafePointer(to:_:)`:

**Overload 1 — borrowing** (line 185):
```swift
public func withUnsafePointer<T: ~Copyable, E: Error, Result: ~Copyable>(
  to value: borrowing T,
  _ body: (UnsafePointer<T>) throws(E) -> Result
) throws(E) -> Result {
  return try unsafe body(UnsafePointer<T>(Builtin.addressOfBorrow(value)))
}
```

**Overload 2 — inout** (line 234):
```swift
public func withUnsafePointer<T: ~Copyable, E: Error, Result: ~Copyable>(
  to value: inout T,
  _ body: (UnsafePointer<T>) throws(E) -> Result
) throws(E) -> Result {
  try unsafe body(UnsafePointer<T>(Builtin.addressof(&value)))
}
```

**`withUnsafeMutablePointer`** has only the **inout** overload (line 124):
```swift
public func withUnsafeMutablePointer<T: ~Copyable, E: Error, Result: ~Copyable>(
  to value: inout T,
  _ body: (UnsafeMutablePointer<T>) throws(E) -> Result
) throws(E) -> Result {
  try unsafe body(UnsafeMutablePointer<T>(Builtin.addressof(&value)))
}
```

### Analysis

When calling `withUnsafePointer(to: _element)` (no `&`), the compiler selects the **borrowing** overload. `Builtin.addressOfBorrow(value)` returns the address of the parameter as received by the callee. For Copyable types, the `borrowing` convention does **not** guarantee address identity with the original storage — the compiler may materialize a temporary copy (e.g., for register-sized values or when the ABI dictates pass-by-value). The returned pointer would then point to a stack temporary destroyed at call return → **dangling**.

For the **inout** overload (`withUnsafePointer(to: &_element)` or `withUnsafeMutablePointer(to: &_element)`), `Builtin.addressof(&value)` is guaranteed to point to the caller's actual storage by the law of exclusivity. This is why only the `&` form is safe for escaping the pointer.

**Precision note**: The experiment's V2 comment says "passes by VALUE (creates a copy)." More precisely: `borrowing` does not guarantee address identity for Copyable types. The value is borrowed (not consumed), but the compiler may materialize the borrow at a temporary address. The practical conclusion — use `withUnsafeMutablePointer(to: &_element)` only — is correct.

**Important subtlety**: For `~Copyable` types, `borrowing` MUST give the original address (can't copy). This is why `Storage.Inline.pointer(at:)` safely uses `withUnsafePointer(to: _storage)` without `&` — `_storage` is `@_rawLayout` (hence `~Copyable`), so the borrow is guaranteed in-place. The V2 REFUTED finding applies specifically to **Copyable** stored properties.

---

## Item 3: Escaped Pointer Safety

**Verdict: VERIFIED** (the safety argument is sound; same pattern as existing infrastructure)

### The Concern

Both Option E and Option F escape a pointer from a `withUnsafe*` closure. The stdlib documentation says: *"The pointer argument is valid only for the duration of the function's execution. Do not store or return the pointer for later use."*

### The Safety Argument

The argument in the research document is:

1. The pointer targets a stored property / `@_rawLayout` field at a **fixed offset** within `self`
2. `@_lifetime(&self)` on `nextSpan` ensures `self` has a mutable borrow that outlives the returned `Span`
3. Therefore `self` cannot move, be consumed, or be destroyed while the `Span` is alive
4. Therefore the pointer remains valid for the `Span`'s lifetime

### Verification Against Existing Infrastructure

`Storage.Inline` in storage-primitives uses the identical pattern. From `Storage.Inline ~Copyable.swift:57-63`:

```swift
package func pointer(at slot: Index<Element>) -> UnsafePointer<Element> {
    unsafe withUnsafePointer(to: _storage) { base in
        unsafe UnsafeRawPointer(base)
            .advanced(by: Index<Element>.Offset(fromZero: slot) * .stride)
            .assumingMemoryBound(to: Element.self)
    }
}
```

And `Storage.Inline+Memory.Contiguous.Protocol.swift:28-37`:

```swift
public var span: Span<Element> {
    @_lifetime(borrow self)
    borrowing get {
        let span = unsafe Span(
            _unsafeStart: pointer(at: .zero),
            count: initialization.count
        )
        return unsafe _overrideLifetime(span, borrowing: self)
    }
}
```

This is the established pattern: escape pointer from `withUnsafePointer` → create `Span` → `_overrideLifetime` to chain lifetime. The `@_lifetime` attribute is the compiler's tool for encoding the safety invariant that the documentation's "do not store" warning addresses. The pattern is sound under the assumption that stored properties have stable offsets within their containing struct — a fundamental property of Swift value types.

**Caveat**: This relies on Swift struct layout stability (stored properties don't move while the struct is alive). This is a reasonable assumption for current and foreseeable Swift, but is not documented as a language guarantee. The Swift runtime has no mechanism to relocate struct storage while a borrow is active, so in practice this is safe.

---

## Item 4: Is Option E Truly Needed Over Option F?

**Verdict: CHALLENGED** — The stated rationale is incorrect, though the decision is still defensible on different grounds.

### The Claim

The research document states (lines 220, 232):

> Option F (stored property) is a secondary technique for **concrete Copyable types** where simplicity wins. [...] Any generic iterator (`Element: ~Copyable`) cannot use `_element = value` assignment — it needs `pointer().initialize(to:)`. Only `@_rawLayout` provides zero-overhead addressable inline storage for `~Copyable` elements.

The comparison table marks Option F as "~Copyable elements: **No** (Copyable only)."

### Counter-evidence

`Optional<Element>` supports `Element: ~Copyable` in Swift 6.2. I verified this experimentally:

```swift
struct GenericIterator<Element: ~Copyable>: ~Copyable {
    var _element: Element?  // ✅ Compiles with ~Copyable
    var _count: Int

    init(count: Int) {
        _element = nil       // ✅ nil literal works
        _count = count
    }

    mutating func storeAndSpan(_ value: consuming Element) -> Span<Element> {
        _element = consume value  // ✅ Explicit consume into Optional
        let ptr = withUnsafeMutablePointer(to: &_element) { p in
            unsafe UnsafeRawPointer(p).assumingMemoryBound(to: Element.self)
        }
        let s = unsafe Span(_unsafeStart: ptr, count: 1)
        return unsafe _overrideLifetime(s, mutating: &self)
    }
}
```

Test with concrete `~Copyable` element:

```
Generic ~Copyable span[0].value = 10  ✅
Generic ~Copyable span[0].value = 20  ✅
```

**Option F works for `Element: ~Copyable` via `Optional<Element>` + `consume`.**

### Corrected Comparison

| Criterion | Option E (@_rawLayout) | Option F (Optional stored property) |
|-----------|----------------------|-------------------------------------|
| ~Copyable elements | Yes | **Yes** (via Optional + consume) |
| Size overhead | **Zero** (same as Element) | 1 byte (Optional tag) |
| Layout assumptions | None | Payload-first layout of Optional |
| Init/deinit management | Manual (pointer().initialize / deinitialize) | Automatic (Optional semantics) |
| `_initialized` tracking | Bool field (1 byte) | Implicit (Optional's .none) |
| Total overhead | 1 byte (Bool) or 0 (if caller manages) | 1 byte (Optional tag) |

### Corrected Rationale for Option E as Primary

Option E is preferred not because Option F is impossible for `~Copyable`, but because:

1. **No layout assumption**: Option F requires `UnsafeRawPointer(optionalPtr).assumingMemoryBound(to: Element.self)` — this assumes `Optional<T>` stores the payload at offset 0 (before the discriminator tag). This is true for Swift's current ABI on all platforms, but is an **implementation detail**, not a language contract. `@_rawLayout` provides direct, correctly-typed pointer access with no reinterpret cast.

2. **Zero overhead at scale**: The 1-byte Optional tag is equivalent to the 1-byte `_initialized` Bool in Option E. But Option E's `SingleElementBuffer` itself is exactly `Element`-sized (zero overhead), while `Optional<Element>` has `stride = max(size(Element) + 1, alignment(Element))`. For 80 iterator types, this is a cleaner primitive.

3. **Explicit ownership model**: `pointer().initialize(to:)` and `pointer().deinitialize(count: 1)` make the memory lifecycle explicit, which aligns with the primitives ecosystem's philosophy of intent-over-mechanism at the implementation layer.

4. **Foundation for Memory.Inline**: The `@_rawLayout` wrapper naturally generalizes to `Memory.Inline<Element, capacity>` for multi-element inline storage. Optional does not generalize this way.

---

## Item 5: Memory.Inline Tier Placement

**Verdict: VERIFIED**

### Tier Verification

From `Primitives Tiers.md`:
- **Tier 13**: geometry, memory, space, transform
- **Tier 14**: binary, layout, storage

`memory-primitives` is Tier 13. `storage-primitives` is Tier 14. ✅

### Domain Analysis

From `Primitives Layering.md`, the semantic domain test asks: "What IS this type? What question does it answer?"

- **`Memory.Inline<Element, capacity>`**: "How do I own a fixed-size block of raw typed memory inline?" → **Memory ownership** → Tier 13
- **`Storage.Inline<N>`**: "How do I manage tracked, initialized storage with per-slot lifecycle?" → **Storage management** → Tier 14

The `inline-storage-layering.md` research in storage-primitives explicitly identifies this separation: `Storage.Inline` bundles two concerns (raw storage + initialization tracking). Decomposing into `Memory.Inline` (raw) + `Bit.Vector.Static` (tracking) is the correct factoring.

### Dependency Direction

`storage-primitives` (Tier 14) depending on `memory-primitives` (Tier 13) is downward. ✅
`Storage.Inline<N>` composing `Memory.Inline<Element, capacity>` + `Bit.Vector.Static<4>` preserves the existing API while cleanly separating concerns.

### Parallel with Existing Types

The research notes `Memory.Contiguous<Element>` (heap) ↔ `Memory.Inline<Element, N>` (stack). This mirrors the heap/stack duality already present in the memory layer. ✅

---

## Item 6: Research Document Gaps and Errors

**Verdict: FLAGGED** — 3 corrections needed, 1 stale comment in experiment 3

### Correction 1: Option F "Copyable Only" Claim

**Location**: Research document lines 193-194, 210

**Current** (line 193-194):
```
| Element constraint | **Copyable only** (regular assignment `_element = value`) |
```

**Current** (comparison table, line 210):
```
| **F: Stored property** | Zero | No | **Zero** | **Minimal** | **No** (Copyable only) |
```

**Proposed**:
```
| Element constraint | **Copyable preferred**; ~Copyable viable via Optional<Element> + consume (with 1-byte overhead and payload-offset assumption) |
```

And comparison table:
```
| **F: Stored property** | Zero | No | 1 byte (Optional tag) | **Minimal** | **Yes** (via Optional) |
```

### Correction 2: Design Rationale Claim

**Location**: Research document line 232

**Current**:
> Any generic iterator (`Element: ~Copyable`) cannot use `_element = value` assignment — it needs `pointer().initialize(to:)`.

**Proposed**:
> A generic iterator (`Element: ~Copyable`) can use `Optional<Element>` with `_element = consume value`, but this introduces a payload-offset layout assumption and 1-byte overhead per element. `@_rawLayout` provides zero-overhead, correctly-typed access without layout assumptions.

### Correction 3: V2 Wording Precision

**Location**: Experiment 2 `stored-property-span-access/Sources/main.swift`, line ~14 area

**Current**:
> V2 REFUTED: withUnsafePointer(to: _element) passes by VALUE (dangling pointer)

**Proposed**:
> V2 REFUTED: withUnsafePointer(to: _element) selects the `borrowing` overload, which does not guarantee address identity with the original storage for Copyable types — the compiler may materialize a temporary copy. Only the `inout` form (`&_element`) guarantees the pointer targets the actual stored property.

### Stale Comment in Experiment 3

**Location**: `lazy-iterator-nextspan-strategies/Sources/main.swift`, lines 13-14

**Current**:
> There is no way to get a pointer to a stored property and return a ~Escapable Span from it in user code.

This is contradicted by experiment 2 (V1, V3, V4), which demonstrates exactly this via `withUnsafeMutablePointer(to: &_element)` → extract `UnsafePointer` (Escapable) → create `Span` outside closure. The comment should be narrowed to say creating Span *inside* the closure is impossible (because `Result: Escapable` constraint), but the two-step pattern works.

---

## Conclusion

The overall research is thorough and the decision for Option E (@_rawLayout wrapper → Memory.Inline) as the primary approach is sound. The experiments are well-designed and produce correct results. The escaped pointer safety argument is validated by precedent in Storage.Inline.

The main correction needed: Option F is not "Copyable only." `Optional<Element>` supports `~Copyable` in Swift 6.2, making stored-property-backed Span viable for generic iterators. This doesn't change the decision — Option E remains superior for a primitives library (zero overhead, no layout assumptions, explicit ownership, generalizes to multi-element) — but the documented reasoning should be corrected to reflect the actual trade-offs rather than an incorrect impossibility claim.
