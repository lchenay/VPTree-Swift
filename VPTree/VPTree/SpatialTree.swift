//
//  SpatialTree.swift
//  VPTree
//
//  Created by Laurent CHENAY on 04/08/2015.
//  Copyright © 2015 Sunday. All rights reserved.
//

import Foundation

infix operator ~~ {
precedence 140
}

public protocol Distance {
    func ~~(lhs: Self, rhs: Self) -> Double
}

internal func <<T>(left: Point<T>, right: Point<T>) -> Bool {
    return left.d < right.d
}

internal func ==<T>(left: Point<T>, right: Point<T>) -> Bool {
    return left.d == right.d
}

internal struct Point<T>: Comparable {
    var d: Double
    var point: T
    
    init(d: Double, point: T) {
        self.d = d
        self.point = point
    }
}

class SpatialTree<T: Distance> {
    func findNeighbors(point: T, limit: Int) -> [T] {
        fatalError("Implement this function")
    }
    func findClosest(point: T, maxDistance: Double) -> [T] {
        fatalError("Implement this function")
    }
}