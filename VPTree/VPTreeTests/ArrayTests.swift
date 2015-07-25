//
//  ArrayTests.swift
//  VPTree
//
//  Created by Laurent CHENAY on 07/06/2015.
//  Copyright (c) 2015 Sunday. All rights reserved.
//

import Foundation
import XCTest

class ArrayTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSplit() {
        let array: Array<Int> = [2, 1, 3, 5, 4, 6, 7];
        let (left, right): ([Int], [Int]) = array.splitByMedian()
        
        XCTAssertTrue(left.indexOf(1) != nil)
        XCTAssertTrue(left.indexOf(2) != nil)
        XCTAssertTrue(left.indexOf(3) != nil)
        XCTAssertTrue(left.indexOf(4) != nil)
        
        XCTAssertTrue(right.indexOf(5) != nil)
        XCTAssertTrue(right.indexOf(6) != nil)
        XCTAssertTrue(right.indexOf(7) != nil)
    }
}
