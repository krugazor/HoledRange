// HoledRange ©Nicolas Zinovieff 2019-2022
// Apache 2.0 Licence

import Foundation

public struct MathError<Bound> : Error, CustomStringConvertible, CustomDebugStringConvertible {
    let boundProblem : Bound
    
    public var description: String { return "Cannot transform \(boundProblem)" }
    public var debugDescription: String { return description }
}

extension Domain {
    /// Generic function that applies a mathematical function to all the variables in the range
    /// Parameter f the transformation
    public mutating func apply(_ f: @escaping (Bound)->Bound) throws {
        var newRanges = [ClosedRange<Bound>]()
        for r in ranges {
            let nlb = f(r.lowerBound)
            let nhb = f(r.upperBound)
            
            let nr = ClosedRange(uncheckedBounds: (Swift.min(nlb,nhb),Swift.max(nlb,nhb)))
            newRanges.append(nr)
        }
        var newExclusions = Set<Bound>()
        for e in excludedValues {
            newExclusions.insert(f(e))
        }
        
        self.ranges = newRanges
        self.excludedValues = newExclusions
    }
}

infix operator ~+
infix operator ~-
infix operator ~*
infix operator ~/

// MARK: Standard additions
extension Domain where Bound : Numeric {
    public static func ~+(lhs: Domain, rhs: Bound) throws -> Domain {
        var result = Domain()
        result.append(lhs)
        try result.apply { return $0 + rhs }
        return result
    }
    
    public static func ~-(lhs: Domain, rhs: Bound) throws -> Domain {
        var result = Domain()
        result.append(lhs)
        try result.apply { return $0 - rhs }
        return result
    }
    
    public static func ~*(lhs: Domain, rhs: Bound) throws -> Domain {
        var result = Domain()
        result.append(lhs)
        try result.apply { return $0 * rhs }
        return result
    }
}

extension Domain where Bound : FloatingPoint {
    /// Redefined because we want to trap NaN
    /// Parameter f : the function to apply
    public mutating func apply(_ f: @escaping (Bound)->Bound) throws {
        var newRanges = [ClosedRange<Bound>]()
        for r in ranges {
            let nlb = f(r.lowerBound)
            let nhb = f(r.upperBound)
            
            guard !nlb.isNaN else { throw MathError(boundProblem: nlb)}
            guard !nhb.isNaN else { throw MathError(boundProblem: nhb)}

            let nr = ClosedRange(uncheckedBounds: (Swift.min(nlb,nhb),Swift.max(nlb,nhb)))
            newRanges.append(nr)
            if nr.lowerBound.isNaN || nr.lowerBound.isInfinite { // infinity is tracked through emptiness, NaN isn't cool as a bound
                throw MathError(boundProblem: r.lowerBound)
            } else if nr.upperBound.isNaN || nr.upperBound.isInfinite {
                throw MathError(boundProblem: r.upperBound)
            }
        }
        var newExclusions = Set<Bound>()
        for e in excludedValues {
            let ne = f(e)
            if ne.isInfinite || ne.isNaN {
                throw MathError(boundProblem: e)
            }
            newExclusions.insert(ne)
        }
        
        self.ranges = newRanges
        self.excludedValues = newExclusions
    }
    public static func ~/(lhs: Domain, rhs: Bound) throws -> Domain {
        var result = Domain()
        result.append(lhs)
        try result.apply { return $0 / rhs }
        return result
    }
}

extension Domain where Bound == String {
    public static func ~+(lhs: Domain, rhs: Bound) throws -> Domain {
        var result = Domain()
        result.append(lhs)
        try result.apply { return $0 + rhs }
        return result
    }
    
    public static func ~*(lhs: Domain, rhs: (Int, Bound)) throws -> Domain {
        var result = Domain()
        result.append(lhs)
        for _ in 1...rhs.0 {
            try result.apply { return $0 + rhs.1 }
        }
        return result
    }
    
    
}

extension Domain where Bound : FixedWidthInteger {
    /// Optimizes the storage by merging ranges if needed
    public mutating func optimizeStorageAggressive() {
        var idx = 1
        ranges.sort { (r1, r2) -> Bool in
            return r1.lowerBound < r2.lowerBound
        }
        while idx < ranges.count {
            let r1 = ranges[idx-1]
            let r2 = ranges[idx]
            if r1.upperBound >= r2.lowerBound { // the two should be merged
                let rr = ClosedRange(uncheckedBounds: (r1.lowerBound, Swift.max(r1.upperBound,r2.upperBound)))
                ranges.replaceSubrange(idx-1...idx, with: [rr])
            } else {
                idx += 1
            }
        }
        
        // special case: one of the bounds is in the excludes values
        var nex = Set<Bound>()
        for excl in excludedValues {
            idx = 0
            var keep = true
            while idx < ranges.count {
                let rr = ranges[idx]
                if excl < rr.lowerBound || excl > rr.upperBound {
                    idx += 1
                    continue
                } else if excl == rr.lowerBound && excl == upperBound {
                    // special case, single value
                    ranges.remove(at: idx)
                    keep = false
                    break
                } else if excl == rr.lowerBound {
                    ranges.replaceSubrange(idx...idx, with: [rr.lowerBound+1...rr.upperBound])
                    keep = false
                    break
                } else if excl == rr.upperBound {
                    ranges.replaceSubrange(idx...idx, with: [rr.lowerBound...rr.upperBound-1])
                    keep = false
                    break
                } else if rr.lowerBound < excl && excl < rr.upperBound {
                    // in between
                    ranges.replaceSubrange(idx...idx, with: [rr.lowerBound...excl-1, excl+1...rr.upperBound])
                    keep = false
                    break
                }
                idx += 1
            }
            if keep { nex.insert(excl) }
        }
        excludedValues = nex
    }
}
