// HoledRange ©Nicolas Zinovieff 2019
// Apache 2.0 Licence

import XCTest
@testable import HoledRange 

final class VersolTests: XCTestCase {
    func testEmpty() {
        var h = HoledRange<Int>()
        XCTAssert(h.isEmpty, "Default should be empty")
        XCTAssert(!h.contains(Int.random(in: -100...100)), "Default should not contain anything")
        let c = h ~= Int.random(in: -100...100)
        XCTAssert(!c, "Default should not contain anything")
        
        let v = Int.random(in: -100...100)
        let v2 = Int.random(in: 101...200)
        h.append(v)
        XCTAssert(!h.isEmpty, "Should contain one value")
        
        h = HoledRange(uncheckedBounds: (v,v2))
        XCTAssert(!h.isEmpty, "Should contain some values")
    }
    
    func testAppending() {
        var h = HoledRange<Int>()
        let v = Int.random(in: -100...100)
        let v2 = Int.random(in: 101...200)
        let v3 = Int.random(in: 300...400)
        let v4 = Int.random(in: 500...600)
        XCTAssert(h.isEmpty, "Default should be empty")
        h.append(v...v2)
        XCTAssert(h.rangesCount == 1, "One range")
        h.append(v3...v4)
        XCTAssert(h.rangesCount == 2, "Two range")
        
        XCTAssert(h ~= (v+v2)/2, "Middle of first range should be inside")
        XCTAssert(h ~= (v3+v4)/2, "Middle of second range should be inside")
        XCTAssertFalse(h ~= (v2+v3)/2, "Middle between ranges should not be inside")
        // test lower and upper bounds
        XCTAssert(h.lowerBound == v, "Lower bound")
        XCTAssert(h.upperBound == v4, "Upper bound")
        
        h.append(v2...v3) // plugging the hole
        XCTAssert(h.rangesCount == 1, "One range")
        XCTAssert(h ~= (v+v2)/2, "Middle of first range should be inside")
        XCTAssert(h ~= (v3+v4)/2, "Middle of second range should be inside")
        XCTAssert(h ~= (v2+v3)/2, "Middle between ranges should be inside")
        
        // test lower and upper bounds
        XCTAssert(h.lowerBound == v, "Lower bound")
        XCTAssert(h.upperBound == v4, "Upper bound")
        
        // MARK: Hole in Hole
        // Merging tests
        var h1 = HoledRange(v...v2)
        let h2 = HoledRange(v3...v4)
        h1.append(h2)
        
        XCTAssert(h1 ~= (v+v2)/2, "Middle of first range should be inside")
        XCTAssert(h1 ~= (v3+v4)/2, "Middle of second range should be inside")
        XCTAssertFalse(h1 ~= (v2+v3)/2, "Middle between ranges should not be inside")
        // test lower and upper bounds
        XCTAssert(h1.lowerBound == v, "Lower bound")
        XCTAssert(h1.upperBound == v4, "Upper bound")
        
        h1.append(v2...v3) // plugging the hole
        XCTAssert(h1.rangesCount == 1, "One range")
        XCTAssert(h1 ~= (v+v2)/2, "Middle of first range should be inside")
        XCTAssert(h1 ~= (v3+v4)/2, "Middle of second range should be inside")
        XCTAssert(h1 ~= (v2+v3)/2, "Middle between ranges should be inside")
        
        // test lower and upper bounds
        XCTAssert(h1.lowerBound == v, "Lower bound")
        XCTAssert(h1.upperBound == v4, "Upper bound")
        
    }
    
    func testOverlaps() {
        // simple single range
        let start = -100
        let end = 100
        let h = HoledRange(start...end)
        
        XCTAssert(h.overlaps(start...end), "Closed Range should overlap")
        XCTAssert(h.overlaps(start..<end), "Range should overlap")
        XCTAssert(h.overlaps(h), "Should overlap itself")
        
        // partial overlap
        XCTAssert(h.overlaps(start+50...end+50), "Closed Range should overlap")
        XCTAssert(h.overlaps(start+50..<end+50), "Range should overlap")
        
        // single value overlap
        XCTAssert(h.overlaps(end...end+50), "Closed Range should overlap")
        XCTAssert(h.overlaps(end..<end+50), "Range should overlap")
        XCTAssert(h.overlaps(end...end), "SVR should overlap")
        
    }
    
    func testOperators() {
        var h = HoledRange<Int>()
        let v = Int.random(in: -100...100)
        let v2 = Int.random(in: 101...200)
        let v3 = Int.random(in: 300...400)
        let v4 = Int.random(in: 500...600)
        XCTAssert(h.isEmpty, "Default should be empty")
        h = h + (v...v2)
        XCTAssert(h.rangesCount == 1, "One range")
        h = (v3...v4) + h
        XCTAssert(h.rangesCount == 2, "Two range")
        
        XCTAssert(h ~= (v+v2)/2, "Middle of first range should be inside")
        XCTAssert(h ~= (v3+v4)/2, "Middle of second range should be inside")
        XCTAssertFalse(h ~= (v2+v3)/2, "Middle between ranges should not be inside")
        // test lower and upper bounds
        XCTAssert(h.lowerBound == v, "Lower bound")
        XCTAssert(h.upperBound == v4, "Upper bound")
        
        h = h+(v2...v3) // plugging the hole
        XCTAssert(h.rangesCount == 1, "One range")
        XCTAssert(h ~= (v+v2)/2, "Middle of first range should be inside")
        XCTAssert(h ~= (v3+v4)/2, "Middle of second range should be inside")
        XCTAssert(h ~= (v2+v3)/2, "Middle between ranges should be inside")
        
        // test lower and upper bounds
        XCTAssert(h.lowerBound == v, "Lower bound")
        XCTAssert(h.upperBound == v4, "Upper bound")
        
        // MARK: Hole in Hole
        // Merging tests
        var h1 = HoledRange(v...v2)
        let h2 = HoledRange(v3...v4)
        h1 = h1+h2
        
        XCTAssert(h1 ~= (v+v2)/2, "Middle of first range should be inside")
        XCTAssert(h1 ~= (v3+v4)/2, "Middle of second range should be inside")
        XCTAssertFalse(h1 ~= (v2+v3)/2, "Middle between ranges should not be inside")
        // test lower and upper bounds
        XCTAssert(h1.lowerBound == v, "Lower bound")
        XCTAssert(h1.upperBound == v4, "Lower bound")
        
        h1 = h1+(v2...v3) // plugging the hole
        XCTAssert(h1.rangesCount == 1, "One range")
        XCTAssert(h1 ~= (v+v2)/2, "Middle of first range should be inside")
        XCTAssert(h1 ~= (v3+v4)/2, "Middle of second range should be inside")
        XCTAssert(h1 ~= (v2+v3)/2, "Middle between ranges should be inside")
        
        // test lower and upper bounds
        XCTAssert(h1.lowerBound == v, "Lower bound")
        XCTAssert(h1.upperBound == v4, "Upper bound")
        
    }
    
    func testSingle() {
        let v = Int.random(in: -100...100)
        let v2 = Int.random(in: 101...200)
        let v3 = Int.random(in: 201...300)
        var h1 = HoledRange(v)
        h1 = h1 + v2
        h1 = v3 + h1
        
        XCTAssert(h1.lowerBound == v, "Lower bound")
        XCTAssert(h1.upperBound == v3, "Upper bound")
        XCTAssert(h1 ~= v, "Contains lower bound")
        XCTAssert(h1 ~= v2, "Contains middle value")
        XCTAssert(h1 ~= v3, "Contains upper bound")
        XCTAssert(h1.overlaps(v...v3), "Overlaps the whole range")
        
        var hs1 = HoledRange<Int>()
        hs1.append(1)
        XCTAssert(hs1.isSingleValue)
        
        let hs21 = HoledRange(1...1)
        XCTAssert(hs21.isSingleValue)
        var hs22 = HoledRange<Int>()
        hs22.append(1...1)
        XCTAssert(hs22.isSingleValue)
        
        var hs3 = HoledRange(1...1)
        hs3.append(2...2)
        hs3.remove(2)
        XCTAssert(hs3.isSingleValue)
    }
    
    func testSingleUnsigned() {
        let oneU : UInt16 = 1
        let twoU : UInt16 = 2
        var hs3 = HoledRange(oneU...oneU)
        hs3.append(twoU...twoU)
        hs3.remove(twoU)
        XCTAssert(hs3.isSingleValue)
        
    }
    
    func testRemoval() {
        var h = HoledRange(0.0...1.0)
        h.remove(0.5)
        h.remove(0.3...0.4)
        XCTAssert(h.contains(0.1))
        XCTAssertFalse(h.contains(0.3))
        XCTAssertFalse(h.contains(0.35))
        XCTAssertFalse(h.contains(0.4))
        XCTAssertFalse(h.contains(0.5))
        XCTAssert(h.rangesCount == 2)
        
        h.append(0.3...0.4)
        XCTAssert(h.contains(0.1))
        XCTAssert(h.contains(0.3))
        XCTAssert(h.contains(0.35))
        XCTAssert(h.contains(0.4))
        XCTAssertFalse(h.contains(0.5))
        XCTAssert(h.rangesCount == 1)
    }
    
    func testRandom() {
        var h = HoledRange(0.0...1.0)
        h.remove(0.5)
        h.remove(0.3...0.4)
        
        if let r1 = h.randomElement() {
            XCTAssert(h.contains(r1))
        }
        if let rt = h.randomSample(10) {
            for r in rt {
                XCTAssert(h.contains(r))
            }
        }
        
        var h2 = HoledRange("A"..."zAQXSWCDEVFR")
        h2.remove("Zzz"..."qWERTY")
        if let r1 = h2.randomElement() {
            XCTAssert(h2.contains(r1))
        }
        if let rt = h2.randomSample(10) {
            for r in rt {
                XCTAssert(h2.contains(r), "\(r) isn't in \(h2.lowerBound ?? "NLB") => \(h2.upperBound ?? "NUB")")
            }
        }
    }
    
    func testOperations() {
        // Union
        var h1 = HoledRange(1...1)
        var h2 = HoledRange(2...2)
        
        h1.union(h2)
        XCTAssert(h1.contains(1))
        XCTAssert(h1.contains(2))
        
        // reset
        h1 = HoledRange(1...1)
        let u = h1 ∪ h2
        XCTAssert(u.contains(1))
        XCTAssert(u.contains(2))
        
        // check for no modification when using the operator
        XCTAssertFalse(h1.contains(2))
        XCTAssertFalse(h2.contains(1))
        
        // Intersection
        // reset
        h1 = HoledRange(1...3)
        h2 = HoledRange(2...4)
        h1.intersection(h2)
        XCTAssert(h1.contains(2))
        XCTAssert(h1.contains(3))
        XCTAssertFalse(h1.contains(1))
        XCTAssertFalse(h1.contains(4))
        
        // reset
        h1 = HoledRange(1...3)
        let i = h1 ∩ h2
        XCTAssert(i.contains(2))
        XCTAssert(i.contains(3))
        XCTAssertFalse(i.contains(1))
        XCTAssertFalse(i.contains(4))
        
        // check for no modification when using the operator
        XCTAssertFalse(h1.contains(4))
        XCTAssertFalse(h2.contains(1))
        
        // Symmetric difference
        // reset
        h1 = HoledRange(1...3)
        h2 = HoledRange(2...4)
        h1.symmetricDifference(h2)
        XCTAssertFalse(h1.contains(2))
        XCTAssertFalse(h1.contains(3))
        XCTAssert(h1.contains(1))
        XCTAssert(h1.contains(4))
        
        // reset
        h1 = HoledRange(1...3)
        let s = h1 ⊖ h2
        XCTAssertFalse(s.contains(2))
        XCTAssertFalse(s.contains(3))
        XCTAssert(s.contains(1))
        XCTAssert(s.contains(4))
        
        // check for no modification when using the operator
        XCTAssertFalse(h1.contains(4))
        XCTAssertFalse(h2.contains(1))
        
        // check for no modification when using the operator
        XCTAssertFalse(h1.contains(4))
        XCTAssertFalse(h2.contains(1))
        
    }
    
    func testEquality() {
        let h1 = HoledRange(1...1)
        let h2 = HoledRange(2...2)
        let h3 = h1 ∪ h2
        
        var h4 = HoledRange(1...1)
        h4.append(2)
        
        XCTAssertFalse(h1 == h2)
        XCTAssertFalse(h1 == h3)
        XCTAssertFalse(h2 == h3)
        XCTAssertFalse(h1 == h4)
        XCTAssertFalse(h2 == h4)
        
        XCTAssert(h3 == h4)
    }
    
    func testMaths() {
        do {
            // ints
            var hi1 = HoledRange(1...3)
            try hi1.apply { $0 + 3 } // now at 4...6
            let hi2 = try HoledRange(1...3) ~+ 3
            XCTAssert(hi1.contains(5) && hi2.contains(5))
            XCTAssertFalse(hi1.contains(1) || hi2.contains(1))
            
            var hi3 = HoledRange(1...3)
            try hi3.apply { $0 * 3 } // now at 3...9
            let hi4 = try HoledRange(1...3) ~* 3
            XCTAssert(hi3.contains(5) && hi4.contains(5))
            XCTAssertFalse(hi3.contains(1) || hi4.contains(1))
            
            var hi5 = HoledRange(1...3)
            try hi5.apply { $0 - 3 } // now at -2...0
            let hi6 = try HoledRange(1...3) ~- 3
            XCTAssert(hi5.contains(-1) && hi6.contains(-1))
            XCTAssertFalse(hi5.contains(1) || hi6.contains(1))
            
            // Doubles
            var hd1 = HoledRange((1.0)...(3.0))
            try hd1.apply { $0 + 3 } // now at 4...6
            let hd2 = try HoledRange((1.0)...(3.0)) ~+ 3
            XCTAssert(hd1.contains(5) && hd2.contains(5))
            XCTAssertFalse(hd1.contains(1) || hd2.contains(1))
            
            var hd3 = HoledRange((1.0)...(3.0))
            try hd3.apply { $0 / 2 } // now at 1...1.5
            let hd4 = try HoledRange((1.0)...(3.0)) ~/ 2
            XCTAssert(hd3.contains(1.25) && hd4.contains(1.25))
            XCTAssertFalse(hd3.contains(3) || hd4.contains(3))
            
            var hs1 = HoledRange("a"..."z")
            let hs2 = try hs1 ~* (4,"1")
            hs1 = try hs1 ~+ "1111"
            XCTAssert(hs1.lowerBound == hs2.lowerBound && hs1.upperBound == hs2.upperBound)
        } catch {
            XCTFail("Exception where there shouldn't be")
        }
        
        do {
            // Larger application for debug purposes
            var hsl = HoledRange<Double>(0.0...10.0)
            hsl.remove([0,1,2,3,4,5,6,7,8,9,10])
            hsl.append(20...100)
            
            var hsl2 = HoledRange<Double>()
            hsl2.append(hsl)
            hsl2.remove([0,1,2,3,4,5,6,7,8,9,10])
            try hsl2.apply { cos(pow($0,2)) }
            
            try hsl.apply { pow(acos($0),2) /* acos² */ }
        } catch(let e) {
            print(e)
        }
    }
    
    // Automaton testing : State graph and enums
    enum DoorState : Comparable, Hashable {
        case closed
        case opening
        case open
        case closing
        
        // because I don't WANT to be an int but have all the advantages of being an int
        private var intValue : Int {
            switch self {
            case .closed:
                return 1
            case .opening:
                return 2
            case .open:
                return 3
            case .closing:
                return 4
            @unknown default:
                return -1
            }
        }
        
        public var isMoving : Bool { return self == .closing || self == .opening }
        static func < (lhs: VersolTests.DoorState, rhs: VersolTests.DoorState) -> Bool {
            return lhs.intValue < rhs.intValue
        }
        
        public func next() -> DoorState {
            switch self {
            case .closed:
                return .opening
            case .opening:
                return .open
            case .open:
                return .closing
            case .closing:
                return .closed
            @unknown default:
                return .closed
            }
        }
    }
    
    func testEnum() {
        var hr = HoledRange<DoorState>()
        hr.append(.closed)
        hr.append(.open)
        hr.remove(.opening)
        hr.remove(.closing)
        
        XCTAssert(hr.contains(.open))
        XCTAssertFalse(hr.contains(.opening))
        
        do { try hr.apply { $0.next() } }
        catch { XCTFail() }
        XCTAssertFalse(hr.contains(.open))
        XCTAssert(hr.contains(.opening))
    }
    
    func testSequence() {
        var iteratedValues = [Int]()
        let hr = HoledRange(1...10) ⊖ HoledRange(21...30)
        for n in hr {
            let assertion = (n >= 0 && n <= 10) || (n >= 20 && n <= 30)
            // Make sure we don't get values of of range
            XCTAssertTrue(assertion)
            
            // Make sure we don't iterate two times over the same number
            XCTAssertFalse(iteratedValues.contains(n))
            iteratedValues.append(n)
        }
        
        // Make sure we iterated over all values
        XCTAssertEqual(20, iteratedValues.count)
        
        iteratedValues = [Int]()
        let hr2 = HoledRange(1...10) ∪ HoledRange(21...30)
        for n in hr2 {
            
            print(n)
            
            let assertion = (n >= 0 && n <= 10) || (n >= 20 && n <= 30)
            XCTAssertTrue(assertion)
            XCTAssertFalse(iteratedValues.contains(n))
            iteratedValues.append(n)
        }
        XCTAssertEqual(20, iteratedValues.count)
        
        iteratedValues = [Int]()
        let hr3 = HoledRange(0...30) ∩ HoledRange(16...25)
        for n in hr3 {
            
            print(n)
            
            let assertion = (n >= 16 && n <= 25)
            XCTAssertTrue(assertion)
            XCTAssertFalse(iteratedValues.contains(n))
            iteratedValues.append(n)
        }
        XCTAssertEqual(10, iteratedValues.count)
        
        // Make sure it can handle 0 elements
        XCTAssertEqual(0, (HoledRange(1...10) ∩ HoledRange(20...30)).map { $0 }.count)
        
        // Asserting for a non interactive HoledRange
        XCTAssertEqual(10, HoledRange(1...10).map{ $0 }.count)
    }
    
    static var allTests = [
        ("testAppendingEmpty", testEmpty),
        ("testAppending", testAppending),
        ("testOverlaps", testOverlaps),
        ("testOperators", testOperators),
        ("testRemoval", testRemoval),
        ("testSingle", testSingle),
        ("testSingleUnsigned", testSingleUnsigned),
        ("testOperations", testOperations),
        ("testEquality", testEquality),
        ("testMaths", testMaths),
        ("testEnum", testEnum),
        ("testSequence", testSequence)
    ]
}
