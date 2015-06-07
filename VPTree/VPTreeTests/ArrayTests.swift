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
        var array: Array<Int> = [2, 1, 3, 5, 4, 6, 7];
        let (left: [Int], right: [Int]) = array.splitByMedian()
        
        XCTAssertTrue(find(left, 1) != nil)
        XCTAssertTrue(find(left, 2) != nil)
        XCTAssertTrue(find(left, 3) != nil)
        XCTAssertTrue(find(left, 4) != nil)
        
        XCTAssertTrue(find(right, 5) != nil)
        XCTAssertTrue(find(right, 6) != nil)
        XCTAssertTrue(find(right, 7) != nil)
    }
}
