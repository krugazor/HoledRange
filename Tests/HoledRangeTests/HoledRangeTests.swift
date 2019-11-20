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
    ]
}
