import UIKit
import XCTest

public func ~~(left: CGPoint, right: CGPoint) -> Double {
    return Double(pow(pow(left.x - right.x, 2) + pow(left.y - right.y, 2), 0.5))
}

extension CGPoint: Distance {
    
}

func hammingWeight(x: UInt64) -> Int {
    var i = x
    i = i - ((i >> 1) & 0x55555555);
    i = (i & 0x33333333) + ((i >> 2) & 0x33333333);
    return Int((((i + (i >> 4)) & 0x0F0F0F0F) * 0x01010101) >> 24)
}

func random64() -> UInt64 {
    var rnd : UInt64 = 0
    arc4random_buf(&rnd, Int(sizeofValue(rnd)))
    return rnd
}

public func ~~(left: Photo, right: Photo) -> Double {
    return Double(hammingWeight(left.pHash^right.pHash))
}

public class Photo: Distance {
    let id: Int
    let pHash: UInt64
    init(id: Int, pHash: UInt64) {
        self.id = id
        self.pHash = pHash
    }
}

class VPTreeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFindNeighbors() {
        let p1 = CGPoint(x: 0, y: 0)
        let p2 = CGPoint(x: 1, y: 1)
        let p3 = CGPoint(x: 1, y: 0)
        let p4 = CGPoint(x: 0, y: 1)
        
        let tree = VPTree(elements: [p1, p2, p3])
        
        let founds = tree.findNeighbors(p4, limit: 3)
        
        XCTAssertEqual(founds.count, 3)

    }
    
    func testFindClosest() {
        let p1 = CGPoint(x: 0, y: 0)
        let p2 = CGPoint(x: 1, y: 1)
        let p3 = CGPoint(x: 1, y: 0)
        let p4 = CGPoint(x: 0, y: 1)
        
        let tree = VPTree(elements: [p1, p2, p3])
        
        let founds = tree.findClosest(p4, maxDistance: 1.0)
        
        XCTAssertEqual(founds.count, 2)
        
    }
    
    func testPerformanceOfHamming() {
        self.measureBlock() {
            var photos = [Photo]()
            
            for (var i = 0 ; i < 25000 ; i++) {
                photos.append(Photo(id: i, pHash: random64()))
                let tree = VPTree(elements: photos)
            }
        }
    }
    
}
