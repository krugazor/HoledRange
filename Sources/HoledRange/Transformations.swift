// HoledRange ©Nicolas Zinovieff 2020
// Apache 2.0 Licence

import Foundation

extension Domain {
    public func transform<Q>(using f: @escaping (Bound)->Q) -> Domain<Q> where Q : Hashable, Q : Comparable{
        var result = Domain<Q>()
        for r in self.ranges {
            let nbounds = [f(r.lowerBound), f(r.upperBound)].sorted()
            let nr = ClosedRange(uncheckedBounds: (lower: nbounds[0], upper: nbounds[1]))
            result.append(nr)
        }
        for e in self.excludedValues {
            let ne = f(e)
            result.excludedValues.insert(ne)
        }
        
        return result
    }
}
