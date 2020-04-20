// HoledRange ©Nicolas Zinovieff 2019
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
