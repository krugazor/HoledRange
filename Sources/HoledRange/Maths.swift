// HoledRange ©Nicolas Zinovieff 2019
// Apache 2.0 Licence

import Foundation

extension HoledRange {
    /// Generic function that applies a mathematical function to all the variables in the range
    /// Parameter f the transformation
    public mutating func apply(_ f: @escaping (Bound)->Bound) {
        var newRanges = [ClosedRange<Bound>]()
        for r in ranges {
            let nr = ClosedRange(uncheckedBounds: (f(r.lowerBound), f(r.upperBound)))
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
extension HoledRange where Bound : Numeric {
    public static func ~+(lhs: HoledRange, rhs: Bound) -> HoledRange {
        var result = HoledRange()
        result.append(lhs)
        result.apply { return $0 + rhs }
        return result
    }

    public static func ~-(lhs: HoledRange, rhs: Bound) -> HoledRange {
        var result = HoledRange()
        result.append(lhs)
        result.apply { return $0 - rhs }
        return result
    }

    public static func ~*(lhs: HoledRange, rhs: Bound) -> HoledRange {
        var result = HoledRange()
        result.append(lhs)
        result.apply { return $0 * rhs }
        return result
    }
}

extension HoledRange where Bound : FloatingPoint {
    public static func ~/(lhs: HoledRange, rhs: Bound) -> HoledRange {
         var result = HoledRange()
         result.append(lhs)
         result.apply { return $0 / rhs }
         return result
     }
}

extension HoledRange where Bound == String {
    public static func ~+(lhs: HoledRange, rhs: Bound) -> HoledRange {
        var result = HoledRange()
        result.append(lhs)
        result.apply { return $0 + rhs }
        return result
    }
    
    public static func ~*(lhs: HoledRange, rhs: (Int, Bound)) -> HoledRange {
        var result = HoledRange()
        result.append(lhs)
        for _ in 1...rhs.0 {
            result.apply { return $0 + rhs.1 }
        }
        return result
    }


}
