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
    let sse = zip(left.values, right.values).reduce(0.0) { (total, pair) -> Double in
        let diff = pow(pair.0-pair.1, 2.0)
        return total + diff
    }
    return pow(sse, 0.5)
}

public class Photo: Distance {
    let id: Int
    var values = [Double]()
    
    init(id: Int) {
        self.id = id
        for var i = 0; i < 42 ; i++ {
            values.append((Double(arc4random()) / Double(UINT32_MAX)) * 8.0 - 1)
        }
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
        
        let tree = VPTreePaged<CGPoint>(maxLeafElements: 2, branchingFactor: 2)
        tree.addElement(p1)
        tree.addElement(p2)
        tree.addElement(p3)
        tree.addElement(p4)
        
        let founds = tree.findNeighbors(p4, limit: 3)
        
        XCTAssertEqual(founds.count, 3)

    }
    
    func testFindClosest() {
        let p1 = CGPoint(x: 0, y: 0)
        let p2 = CGPoint(x: 2, y: 2)
        let p3 = CGPoint(x: 1, y: 0)
        let p4 = CGPoint(x: 0, y: 1)
        
        let tree = VPTree(elements: [p1, p2, p3])
        
        let founds = tree.findClosest(p4, maxDistance: 1.0)
        
        XCTAssertEqual(founds.count, 1)
        
    }
    
    func testTryBest() {
        for var j = 2; j < 30 ; j++ {
            for var i = j ; i < 100 ; i += 5 {
                let start = NSDate()
                
                let tree = VPTree<Photo>(elements: [])
                for (var i = 0 ; i < 200 ; i++) {
                    let photo = Photo(id: i);
                    tree.addElement(photo)
                    tree.findClosest(photo, maxDistance: 21)
                }
                
                print("\(i) \(j) \(start.timeIntervalSinceNow)")
            }
        }
    }

    func testPerformanceOfHamming() {
        self.measureBlock() {
            NSLog("start")
            let tree1 = VPTreePaged<Photo>(maxLeafElements: 16, branchingFactor: 2)
            let tree2 = VPTree<Photo>(elements: [])
            for (var i = 0 ; i < 25000 ; i++) {
                let photo = Photo(id: i);
                tree1.addElement(photo)
                tree2.addElement(photo)
                print(i)
                tree1.findClosest(photo, maxDistance: 2.1)
                tree2.findClosest(photo, maxDistance: 2.1)

            }
        }
    }
}
