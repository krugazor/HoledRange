// HoledRange ©Nicolas Zinovieff 2020
// Apache 2.0 Licence

import Foundation

public protocol Splittable {
    func distanceTo(_ other: Self) -> Double
    func advancedBy(_ distance: Double) -> Self
}

public extension Domain where Bound : Splittable {
    func amplitude() -> Double {
        if self.lowerBound == nil || self.upperBound == nil {
            return 0
        }
        
        return self.lowerBound!.distanceTo(self.upperBound!)
    }
    
    func split(minimalStep: Double = 1, count: Int = 2) -> [Domain<Bound>] {
        if count < 1 { return [self] }
        else if self.lowerBound == nil || self.upperBound == nil { return [self] }
        else if self.lowerBound!.distanceTo(self.upperBound!) <= minimalStep { return [self] }
        else {
            var result = [Domain<Bound>]()
            var current = self.lowerBound!
            let step = Swift.max(minimalStep, self.lowerBound!.distanceTo(self.upperBound!) / Double(count))
            repeat {
                let next = Swift.min(self.upperBound!, current.advancedBy(step))
                var cd = Domain(current...next)
                
                cd.intersection(self)
                result.append(cd)
                current = next
            } while current < self.upperBound!
            return result
        }
    }
}


// MARK: -

extension Double : Splittable {
    public func distanceTo(_ other: Double) -> Double {
        return other - self
    }
    
    public func advancedBy(_ distance: Double) -> Double {
        return self + distance
    }
}

extension Int : Splittable {
    public func distanceTo(_ other: Int) -> Double {
        return Double(other - self)
    }
    
    public func advancedBy(_ distance: Double) -> Int {
        return Int(Double(self) + distance)
    }
}

/// That's mostly for my own amusement
extension Bool : Splittable {
    public func distanceTo(_ other: Bool) -> Double {
        if other != self { return 1.0 }
        else { return 0.0 }
    }
    
    public func advancedBy(_ distance: Double) -> Bool {
        let steps = Int(distance) % 2
        if steps == 0 { return self }
        else { return !self }
    }
}

// Levenstein distance from [SwiftyLevenstein](https://github.com/TheDarkCode/SwiftyLevenshtein)
extension String : Splittable {
    public func distanceTo(_ other: String) -> Double {
        if self.count == 0 { return Double(other.count) }
        else if other.count == 0 { return Double(self.count) }
        return Double(String.levenshtein(sourceString: self, target: other))
    }
    
    public func advancedBy(_ distance: Double) -> String {
        // Levenstein distance measures several things: insertion (+1)/deletion(-1), and substitution(+1) aka the "edits"
        let steps = Int(distance)
        
        // for this, changing string size is our last resort
        if steps < 0 { // we need to remove steps characters randomly
            var remaining = Swift.abs(steps)
            var result = self
            while remaining > 0 && result.count > 0 {
                result.remove(at: result.index(result.startIndex, offsetBy: Int.random(in: 0..<result.count)))
                remaining -= 1
            }
            return result
        } else if steps > self.count { // add characters
            let remaining = Swift.abs(steps) - self.count
            // let's try to add as few characters as possible
            let notForbidden : String = String.letters.filter { (char) -> Bool in
                return !self.contains(char)
            }
            if notForbidden.count > 0 {
                var result = self.advancedBy(Double(steps-remaining))
                for _ in 0..<remaining {
                    let addition = notForbidden.randomElement()!
                    let index = Int.random(in: 0..<result.count)
                    result.insert(addition, at: result.index(result.startIndex, offsetBy: index))
                }
                return result
            } else {
                var result = self
                for _ in 0..<remaining {
                    let addition = String.letters.randomElement()!
                    let index = Int.random(in: 0..<result.count)
                    result.insert(addition, at: result.index(result.startIndex, offsetBy: index))
                }
                return result
            }
        } else {
            var result = self
            let indices = Array<Int>(0..<result.count).shuffled()[0..<steps]
            let notForbidden : String = String.letters.filter { (char) -> Bool in
                return !self.contains(char)
            }
            if notForbidden.count > 0 {
                for idx in indices {
                    let replacement = notForbidden.randomElement()!
                    let charIdx = result.index(result.startIndex, offsetBy: idx)
                    result.remove(at: charIdx)
                    result.insert(replacement, at: charIdx)
                }
            } else {
                for _ in 0..<steps {
                     let addition = String.letters.randomElement()!
                     let index = Int.random(in: 0..<result.count)
                     result.insert(addition, at: result.index(result.startIndex, offsetBy: index))
                 }
            }
            return result
        }
    }
    
    static func min3(a: Int, b: Int, c: Int) -> Int {
        return Swift.min( Swift.min(a, c), Swift.min(b, c))
    }
    struct Array2D {
        var columns: Int
        var rows: Int
        var matrix: [Int]
        
        init(columns: Int, rows: Int) {
            self.columns = columns
            self.rows = rows
            matrix = Array(repeating:0, count:columns*rows)
        }
        
        subscript(column: Int, row: Int) -> Int {
            get {
                return matrix[columns * row + column]
            }
            set {
                matrix[columns * row + column] = newValue
            }
        }
        
        func columnCount() -> Int {
            return self.columns
        }
        
        func rowCount() -> Int {
            return self.rows
        }
    }
    
    static func levenshtein(sourceString: String, target targetString: String) -> Int {
        let source = Array(sourceString.unicodeScalars)
        let target = Array(targetString.unicodeScalars)
        let (sourceLength, targetLength) = (source.count, target.count)
        var distance = Array2D(columns: sourceLength + 1, rows: targetLength + 1)
        
        for x in 1...sourceLength {
            distance[x, 0] = x
        }
        
        for y in 1...targetLength {
            distance[0, y] = y
        }
        
        for x in 1...sourceLength {
            for y in 1...targetLength {
                if source[x - 1] == target[y - 1] {
                    // no difference
                    distance[x, y] = distance[x - 1, y - 1]
                } else {
                    distance[x, y] = min3(
                        // deletions
                        a: distance[x - 1, y] + 1,
                        // insertions
                        b: distance[x, y - 1] + 1,
                        // substitutions
                        c: distance[x - 1, y - 1] + 1
                    )
                }
            }
        }
        
        return distance[source.count, target.count]
    }
}
