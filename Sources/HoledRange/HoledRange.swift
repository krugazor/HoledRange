// HoledRange ©Nicolas Zinovieff 2019
// Apache 2.0 Licence

import Foundation

/// HoledRange allows for ranges to be more than open or closed. They can have holes in the middle as well
public struct HoledRange<Bound> where Bound : Comparable, Bound : Hashable {
	/// private storage as `ClosedRange` collection
    var ranges: [ClosedRange<Bound>] = []
    /// private storage for excluded values, mostly to simulate open ranges (where boundaries are excluded)
    var excludedValues : Set<Bound> = Set() /// Because we use closed ranges, we need to be able to punch single value holes
    
    var rangesCount : Int { return ranges.count } /// mostly for debug/test purposes
    
    /// The range's lower bound.
    /// We can't count on optimization being done, so we're not checking the first one only
    public var lowerBound: Bound? {
        return ranges.min { (r1, r2) -> Bool in
            return r1.lowerBound < r2.lowerBound
            }?.lowerBound
    }
    
    /// The range's upper bound.
    /// We can't count on optimization being done, so we're not checking the last one only
    public var upperBound: Bound? {
        return ranges.max { (r1, r2) -> Bool in
            return r1.upperBound < r2.upperBound
            }?.upperBound
    }
    
    /// Creates an empty HoledRange
    public init() {
        // this space for rent
    }
    
    /// Creates a HoledRange from a ClosedRange
    /// - Parameter r: Another range.
    public init(_ r: ClosedRange<Bound>) {
        ranges.append(r)
    }
    
    /// Creates a HoledRange from a single value
    /// - Parameter v: The value.
    public init(_ v: Bound) {
        ranges.append(v...v)
    }
    
    /// Creates an instance with the given bounds.
    ///
    /// Because this initializer does not perform any checks, it should be used
    /// as an optimization only when you are absolutely certain that `lower` is
    /// less than or equal to `upper`. Using the closed range operator (`...`)
    /// to form `ClosedRange` instances is preferred.
    ///
    /// - Parameter bounds: A tuple of the lower and upper bounds of the range.
    public init(uncheckedBounds bounds: (lower: Bound, upper: Bound)) {
        let r = ClosedRange(uncheckedBounds: bounds)
        ranges.append(r)
    }
    
    /// A Boolean value indicating whether the range contains no elements.
    ///
    /// Because a closed range cannot represent an empty range, this property is
    /// always `false`, unless we have no range left
    public var isEmpty : Bool {
        return ranges.count == 0
    }
    
    /// Function to determine if the range contains only one value. Mostly used for esoteric needs, not perfect
    /// 
    /// Returns: true if there's only one value possible for this range
    public var isSingleValue : Bool {
        if self.lowerBound == nil { return false }
        if self.lowerBound != self.upperBound { // complicated case
            // we know the bounds are apart, if there's only one range, there should be only one possible single value case : integers. See the extensions
            return false
        }
        return self.lowerBound == self.upperBound && !excludedValues.contains(self.lowerBound!)
    }
    
    /// Function that returns the single value if available
    /// 
    /// Returns the single value if possible
    public var singleValue: Bound? {
        if self.isSingleValue { return self.lowerBound }
        else { return nil }
    }
    
    /// Optimizes the storage by merging ranges if needed
    private mutating func optimizeStorage() {
        var idx = 1
        ranges.sort { (r1, r2) -> Bool in
            return r1.lowerBound < r2.lowerBound
        }
        while idx < ranges.count {
            let r1 = ranges[idx-1]
            let r2 = ranges[idx]
            if r1.upperBound >= r2.lowerBound { // the two should be merged
                let rr = ClosedRange(uncheckedBounds: (r1.lowerBound, r2.upperBound))
                ranges.replaceSubrange(idx-1...idx, with: [rr])
            } else {
                idx += 1
            }
        }
        
        // TODO look for single value ranges and remove them if they are excluded
    }
    
    /// Standard `Range` and `ClosedRange` compatibility: contain will confirm the presence of a value in the range
    /// 
    /// Parameters: 
    ///   - v: the value to look for
    ///
    /// Returns: whether the value is within the range(s)
    public func contains(_ v: Bound) -> Bool {
        if excludedValues.contains(v) { return false }
        var result = false
        var idx = 0
        while idx < ranges.count && !result {
            result = result || ranges[idx].contains(v)
            idx += 1
        }
        return result
    }
    
    /// Operator for the `contains` function
    public static func ~= (pattern: HoledRange<Bound>, value: Bound) -> Bool {
        return pattern.contains(value)
    }
    
}

/// Integers are the only special case in regular use where single value has a meaning even when the upper and lower bounds differ
extension HoledRange where Bound : SignedInteger {
    public var isSingleValue : Bool {
        if self.lowerBound == nil { return false }
        if self.lowerBound != self.upperBound { // complicated case
            // we know the bounds are apart, if there's only one range, there should be only a few possible single value cases :
            // - Int, with distance 1, and one of the bounds excluded.
            // - Int with multiple value ranges where all the values are excluded but one
            if ranges.count == 1 {
                if let l = self.lowerBound, let u = self.upperBound, u-l==1 {
                    return excludedValues.contains(l) || excludedValues.contains(u)
                }
            } else  {
                // This is super ugly, but unfortunately we have no choice. The storage optimization should take care of the most egregious cases, but...
                var possibleValues = 0
                for r in ranges {
                    var v = r.lowerBound
                    while v <= r.upperBound { // for loop can't work because of Strideable conformance
                        if !excludedValues.contains(v) { possibleValues += 1 }
                        v += 1
                        if possibleValues > 1 { break }
                    }
                }
                
                return possibleValues == 1
            }
            return false
        }
        return self.lowerBound == self.upperBound && !excludedValues.contains(self.lowerBound!)
    }
}

// sadly because there's no unified signed/unsigned
extension HoledRange where Bound : UnsignedInteger {
    public var isSingleValue : Bool {
        if self.lowerBound == nil { return false }
        if self.lowerBound != self.upperBound { // complicated case
            // we know the bounds are apart, if there's only one range, there should be only a few possible single value cases :
            // - Int, with distance 1, and one of the bounds excluded.
            // - Int with multiple value ranges where all the values are excluded but one
            if ranges.count == 1 {
                if let l = self.lowerBound, let u = self.upperBound, u-l==1 {
                    return excludedValues.contains(l) || excludedValues.contains(u)
                }
            } else  {
                // This is super ugly, but unfortunately we have no choice. The storage optimization should take care of the most egregious cases, but...
                var possibleValues = 0
                for r in ranges {
                    var v = r.lowerBound
                    while v <= r.upperBound { // for loop can't work because of Strideable conformance
                        if !excludedValues.contains(v) { possibleValues += 1 }
                        v += 1
                        if possibleValues > 1 { break }
                    }
                }
                
                return possibleValues == 1
            }
            return false
        }
        return self.lowerBound == self.upperBound && !excludedValues.contains(self.lowerBound!)
    }
}

extension HoledRange { // additions
    /// add a single value range
    /// - Parameter v: the new range to take into account
    public mutating func append(_ v: Bound) {
        if excludedValues.contains(v) { excludedValues.remove(v) }
        ranges.append(v...v)
        optimizeStorage()
    }
    
    /// add a range to the list
    /// - Parameter r: the new range to take into account
    public mutating func append(_ r: ClosedRange<Bound>) {
        var toRemove = [Bound]()
        for e in excludedValues {
            if r.contains(e) { toRemove.append(e) }
        }
        for e in toRemove { excludedValues.remove(e) }
        ranges.append(r)
        optimizeStorage()
    }
    
    /// add a range to the list
    /// - Parameter other: the new range to take into account
    public mutating func append(_ other: HoledRange) {
        var toRemove = [Bound]()
        for e in excludedValues {
            if other.contains(e) { toRemove.append(e) }
        }
        for e in toRemove { excludedValues.remove(e) }
        for r in other.ranges { ranges.append(r) }
        optimizeStorage()
    }
    
    // Operator shenanigans
    public static func +(r1: HoledRange<Bound>, v: Bound) -> HoledRange<Bound> {
        var rr = HoledRange()
        rr.append(r1)
        rr.append(v)
        return rr
    }
    public static func +(v: Bound, r1: HoledRange<Bound>) -> HoledRange<Bound> {
        var rr = HoledRange()
        rr.append(r1)
        rr.append(v)
        return rr
    }
    public static func +(r1: HoledRange<Bound>, r2: ClosedRange<Bound>) -> HoledRange<Bound> {
        var rr = HoledRange()
        rr.append(r1)
        rr.append(r2)
        return rr
    }
    public static func +(r2: ClosedRange<Bound>, r1: HoledRange<Bound>) -> HoledRange<Bound> {
        var rr = HoledRange()
        rr.append(r1)
        rr.append(r2)
        return rr
    }
    public static func +(r1: HoledRange<Bound>, r2: HoledRange<Bound>) -> HoledRange<Bound> {
        var rr = HoledRange()
        rr.append(r1)
        rr.append(r2)
        return rr
    }
}

extension HoledRange { // comparisons
    /// Tests if the union is empty
    /// - Parameter other: the range to test for
    /// - Returns: true if there are elements in common
    public func overlaps(_ other: ClosedRange<Bound>) -> Bool {
        return ranges.reduce(false) { (p, r) in
            p || r.overlaps(other)
        }
    }
    
    /// Tests if the union is empty
    /// - Parameter other: the range to test for
    /// - Returns: true if there are elements in common
    public func overlaps(_ other: Range<Bound>) -> Bool {
        return ranges.reduce(false) { (p, r) in
            p || r.overlaps(other)
        }
    }
    
    /// Tests if the union is empty
    /// - Parameter other: the range to test for
    /// - Returns: true if there are elements in common
    public func overlaps(_ other: HoledRange<Bound>) -> Bool {
        var result = false
        for o in other.ranges {
            result = result || ranges.reduce(false) { (p, r) in
                p || o.overlaps(r)
            }
        }
        return result
    }
}

extension HoledRange { // punching holes
    /// Removes a single value from the range
    /// - Parameter v: the value to remove
     public mutating func remove(_ v: Bound) {
        excludedValues.insert(v)
    }
    
    /// Removes a list of values from the range
    /// - Parameter v: the value to remove
     public mutating func remove(_ v: [Bound]) {
        for vv in v { excludedValues.insert(vv) }
    }
    
    /// Removes a range from the holed range
    ///
    /// Note: this is a fairly complex proposition. There are multiple ways we can remove a range from another, depending on overlaps and where the two ranges are in relation to each other
    /// Parameter r: the range to deduct from ourselves
    public mutating func remove(_ r: ClosedRange<Bound>) {
        var holedIndexes = [Int]()
        for i in 0..<ranges.count {
            if ranges[i].overlaps(r) { holedIndexes.append(i) }
        }
        
        for i in holedIndexes {
            /// we need to separate the range in 2 if needed and exclude the bounds
            let original = ranges[i]
            if original == r {
                // just remove the range
                ranges.remove(at: i)
            } else if original.lowerBound < r.lowerBound && original.upperBound > r.upperBound {
                // right in the middle
                let rr1 = original.lowerBound...r.lowerBound
                let rr2 = r.upperBound...original.upperBound
                ranges.replaceSubrange(i...i, with: [rr1,rr2])
                excludedValues.insert(r.lowerBound)
                excludedValues.insert(r.upperBound)
            } else if r.lowerBound < original.lowerBound && original.upperBound >= r.upperBound {
                // astride lower part, exclude upper bound
                let rr = original.lowerBound...r.upperBound
                ranges.replaceSubrange(i...i, with: [rr])
                excludedValues.insert(r.upperBound)
            } else if original.lowerBound <= r.lowerBound && r.upperBound > original.upperBound {
                // astride upper part, exclude lower bound
                let rr = original.lowerBound...r.lowerBound
                ranges.replaceSubrange(i...i, with: [rr])
                excludedValues.insert(r.lowerBound)
            } else if r.lowerBound == original.upperBound {
                // intersection of one value, exclude
                excludedValues.insert(r.lowerBound)
            } else if r.upperBound == original.lowerBound {
                // intersection of one value, exclude
                excludedValues.insert(r.upperBound)
            } else {
                fatalError("Forgot a case?")
            }
            
        }
        
        optimizeStorage()
    }
    
    
    /// Removes a holed range from the holed range
    ///
    /// Note: this is complex for as many reasons as there are ranges in the `other` parameter
    /// Parameter other: the range to deduct from ourselves
    public mutating func remove(_ other: HoledRange) {
        for r in other.ranges { remove(r) }
    }
}

infix operator ∪
infix operator ∩
infix operator ⊖
extension HoledRange { // Unions, intersections, etc
    /// Elements that are either in this holed range or the other one.
    /// - Parameter other: the other holed range
    public mutating func union(_ other: HoledRange) {
        // just merge the ranges
        ranges.append(contentsOf: other.ranges)
        optimizeStorage()
    }
    public static func ∪(lhs: HoledRange, rhs: HoledRange) -> HoledRange {
        var rr = lhs
        rr.union(rhs)
        return rr
    }
    
    /// Elements that are in both holed ranges.
    /// - Parameter other: the other holed range
    public mutating func intersection(_ other: HoledRange) {
        // find the overlaps
        var contacts = [(selfIdx: Int, otherIdx: Int)]()
        for i in 0..<ranges.count {
            for j in 0..<other.ranges.count {
                if ranges[i].overlaps(other.ranges[j]) { contacts.append((i,j)) }
            }
        }
        
        // reduce the ranges
        var newRanges = [ClosedRange<Bound>]()
        for contact in contacts {
            let sr = ranges[contact.selfIdx]
            let or = other.ranges[contact.otherIdx]
            newRanges.append(max(sr.lowerBound, or.lowerBound)...min(sr.upperBound,or.upperBound))
        }
        
        // finalize
        ranges = newRanges
        excludedValues = excludedValues.union(other.excludedValues)
        optimizeStorage()
    }
    public static func ∩(lhs: HoledRange, rhs: HoledRange) -> HoledRange {
        var rr = lhs
        rr.intersection(rhs)
        return rr
    }
    
    /// Elements that are either in this set or in the given sequence, but not in both.
    /// - Parameter other: the other holed range
    public mutating func symmetricDifference(_ other: HoledRange) {
        // find disjointed
        let selfdisjointed = ranges.filter { (r) -> Bool in
            return !other.overlaps(r)
        }
        let otherdisjointed = other.ranges.filter { (r) -> Bool in
            return !self.overlaps(r)
        }
        
        var newRanges = [ClosedRange<Bound>]()
        newRanges.append(contentsOf: selfdisjointed)
        newRanges.append(contentsOf: otherdisjointed)
        
        // find contacts
        var contacts = [(selfIdx: Int, otherIdx: Int)]()
        for i in 0..<ranges.count {
            for j in 0..<other.ranges.count {
                if ranges[i].overlaps(other.ranges[j]) { contacts.append((i,j)) }
            }
        }
        
        var newExcludedValues = Set<Bound>()
        // reduce the ranges
        for contact in contacts {
            let sr = ranges[contact.selfIdx]
            let or = other.ranges[contact.otherIdx]
            if sr.lowerBound <= or.lowerBound {
                if sr.upperBound <= or.upperBound {
                    if sr.lowerBound == or.lowerBound {
                        if sr.upperBound == or.upperBound {
                            continue
                        } else { // sr.upperBound < or.upperBound && sr.lowerBound == or.lowerBound
                            newRanges.append(sr.upperBound...or.upperBound)
                            newExcludedValues.insert(sr.upperBound)
                        }
                    } else { // sr.lowerBound < or.lowerband
                        if sr.upperBound == or.upperBound {
                            newRanges.append(sr.lowerBound...or.lowerBound)
                            newExcludedValues.insert(or.lowerBound)
                        } else { // sr.upperBound < or.upperBound && sr.lowerBound < or.lowerBound
                            newRanges.append(sr.lowerBound...or.lowerBound)
                            newRanges.append(sr.upperBound...or.upperBound)
                            newExcludedValues.insert(or.lowerBound)
                            newExcludedValues.insert(sr.upperBound)
                        }
                    }
                } else { // sr.upperBound > or.upperBound
                    if sr.lowerBound == or.lowerBound {
                        newRanges.append(or.upperBound...sr.upperBound)
                        newExcludedValues.insert(or.upperBound)
                    } else { // sr.upperBound > or.upperBound && sr.lowerBound < or.lowerBound
                        newRanges.append(sr.lowerBound...or.lowerBound)
                        newRanges.append(or.upperBound...sr.upperBound)
                        newExcludedValues.insert(or.lowerBound)
                        newExcludedValues.insert(or.upperBound)
                    }
                }
            } else { // sr.lowerBound > or.lowerBound
                if sr.upperBound <= or.upperBound {
                    if sr.upperBound == or.upperBound {
                        newRanges.append(or.lowerBound...sr.lowerBound)
                        newExcludedValues.insert(sr.lowerBound)
                    } else { // sr.upperBound < or.upperBound
                        newRanges.append(or.lowerBound...sr.lowerBound)
                        newRanges.append(sr.upperBound...or.upperBound)
                        newExcludedValues.insert(sr.lowerBound)
                        newExcludedValues.insert(sr.upperBound)
                    }
                } else { // sr.upperBound > or.upperBound
                    newRanges.append(or.lowerBound...sr.lowerBound)
                    newRanges.append(or.upperBound...sr.upperBound)
                    newExcludedValues.insert(sr.lowerBound)
                    newExcludedValues.insert(or.upperBound)
                }
            }
        }
        
        // finalize
        excludedValues = newExcludedValues.union(excludedValues).union(other.excludedValues) // TODO check the maths
        ranges = newRanges
        optimizeStorage()
    }
    public static func ⊖(lhs: HoledRange, rhs: HoledRange) -> HoledRange {
        var rr = lhs
        rr.symmetricDifference(rhs)
        return rr
    }
}

extension HoledRange : Equatable { // Equatable makes sense, comparable, a little less. It's also a crude approximation as it doesn't handle edge cases
    public static func ==(lhs: HoledRange, rhs: HoledRange) -> Bool {
        var result = lhs.excludedValues == rhs.excludedValues
        if !result { return result }
        if lhs.ranges.count != rhs.ranges.count { return false }
        for r in lhs.ranges {
            result = result && (rhs.ranges.filter( { $0 == r} ).count > 0)
            if !result { return result }
        }
        return result
    }
}

extension HoledRange where Bound : Randomizable { // random, sample. etc...
	/// Selects a random element in this range
	/// 
 	/// Returns: nil if no element can be selected, a random element of that type otherwise
    public func randomElement() -> Bound? {
        if self.isEmpty { return nil }
        guard let bounds = ranges.randomElement() else { return nil }
        var candidate = Bound.randomElement(in: bounds)
        while candidate == nil { candidate = Bound.randomElement(in: bounds) }
        
        return candidate
    }
    
	/// Selects a collection of random element in this range
	/// 
 	/// Returns: nil if no element can be selected, a list of random element of that type otherwise
    public func randomSample(_ count: Int) -> [Bound]? {
        if self.isEmpty { return nil }
        
        var result = [Bound]()
        while result.count < count {
            if let r = self.randomElement() { result.append(r) }
        }
        
        return result
    }
}

extension HoledRange : Sequence where Bound : Strideable, Bound.Stride : SignedInteger {
    public typealias Element = Bound
    public typealias Iterator = IndexingIterator<Array<Element>>
    private var iterable : [Element] {
        get {
            ranges.flatMap { $0 }
        }
    }
    
    public func makeIterator() -> Iterator {
        return iterable.makeIterator()
    }
}
