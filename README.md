# HoledRange

## Motivation

I needed a way to have ranges with holes in them for another project. It's not exactly boilerplate code, but there were multiple instances where I had to deal with data matching and needed such a tool (especially on the union/intersection/symmetric difference side)

HoledRange works by being essentially a *collection* of ranges and as such tries to be as compatible as possible with general uses of regular ranges.

## Usage

Like `Range<T>`, `HoledRange<T>` works with a `Bound` type in mind:

`let h = HoledRange(1.2...7.3)` or `let h = HoledRange(42)`

Bear in mind that `Bound` needs to conform to `Comparable` (for obvious reasons) and `Hashable` (for equality purposes).

If it also conforms to the custom protocol `Randomizable` (some obvious types have already been extended), you get the opportunity to grab samples from your range.

### Union, Intersection, Symmetric Difference

There are two ways to use those operations:

- in a mutable manner by calling the function -- it then modifies the callee
- in an immutable way, by using the operators -- the original ranges aren't modified

```swift

var h = HoledRange(1...1)
h.union(HoledRange(2...2)) // h is modified

let o = h ⊖ HoledRange(2...2) // h is not modified

```

### Set management

Adding, and removing, values or ranges is essential to the utility of this class. Be careful as it almost always calls `optimizeStorage`, which will rearrange the internal ranges as needed

Excluded values are stored separately to provide support for open ranges (this implementation uses `ClosedRange<T>` as storage)

## Contributions

Feel free to report issues, submit PRs, etc.

As of this writing, I am the sole user of this package and as long as the unit tests pass, anything you deem useful to add or modify for your own needs is unlikely to cause any major issue.
