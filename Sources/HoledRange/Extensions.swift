// HoledRange ©Nicolas Zinovieff 2019
// Apache 2.0 Licence

import Foundation

/// HoledRange didn't appeal to some people, Domain is an acceptable substitute
/// Reversed on renaming to avoid breaking code downstream
public typealias HoledRange = Domain

/// Protocol used for random sample in the ranges
public protocol Randomizable : Comparable {
	/// Standard semantics for `randomElement` that also appears in other Foundation classes
	/// - Returns: a random element of that type
    static func randomElement() -> Self?
    
	/// Standard semantics for `randomElement` that also appears in other Foundation classes
	/// - Parameters: 
	///   - in r: a constraining range for the random element
	///
	/// - Returns: a random element of that type
    static func randomElement(in r: ClosedRange<Self>) -> Self?
}

// MARK: -
// MARK: Various standard type extensions
extension Int : Randomizable {
    public static func randomElement(in r: ClosedRange<Int>) -> Int? {
        return Int.random(in: r)
    }
    
    public static func randomElement() -> Int? {
        return Int.random(in: 0...Int.max)*(Bool.random() ? 1 : -1)
    }
}

extension Double : Randomizable {
    public static func randomElement(in r: ClosedRange<Double>) -> Double? {
        return Double.random(in: r)
    }
    
    public static func randomElement() -> Double? {
        return Double.random(in: 0...Double.greatestFiniteMagnitude)*(Bool.random() ? 1.0 : -1.0)
    }
}

extension String : Randomizable {
    // Couldn't find a way to grab from CharacterSet, have to go old school, sorry UTF8
    static let letters : String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?.:;/=-+*@#%&"
    public static func randomElement(in range: ClosedRange<String>) -> String? {
        let length = Int.random(in: 8...100)
        let len = letters.count
        var randomString:String = ""
        var consecutiveRetries = 0 // have to stop at some point
        for _ in 0 ..< length {
            if consecutiveRetries > 100 { break }
            let rand = Int.random(in: 0..<len)
            let tRand = randomString + letters.map { String($0) }[rand]
            if range.contains(tRand) {
                randomString = tRand
                consecutiveRetries = 0
            } else { consecutiveRetries += 1 }
        }
        return randomString
    }
    
    public static func randomElement() -> String? {
        // Couldn't find a way to grab from CharacterSet, have to go old school, sorry UTF8
        let length = Int.random(in: 8...100) 
        let letters : String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?.:;/=-+*@#%&"
        let len = letters.count
        var randomString:String = ""
        for _ in 0 ..< length {
            let rand = Int.random(in: 0..<len)
            randomString += letters.map { String($0) }[rand]
        }
        return randomString
    }
}

extension Bool : Randomizable {
    public static func randomElement() -> Bool? {
        return Int.random(in: 0...100) % 2 == 0
    }
    
    public static func randomElement(in r: ClosedRange<Bool>) -> Bool? {
        if r.contains(false) && r.contains(true) { return randomElement() }
        else if r.contains(false) { return false }
        else if r.contains(true) { return true }
        else { return nil }
    }
    
    public static func < (lhs: Bool, rhs: Bool) -> Bool {
        if !lhs {
            if !rhs { return false }
            else { return true } // false < true is the only true thing
        } else {
            return false
        }
    }
    
    
}
