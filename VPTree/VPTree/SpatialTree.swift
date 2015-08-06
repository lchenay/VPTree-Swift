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
    func isWithin(distance: Double, of: Self) -> Bool
}
extension Distance {
    public func isWithin(distance: Double, of: Self) -> Bool {
        return self ~~ of <= distance
    }
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

public class SpatialTree<T: Distance> {
    public var nbElementsChecked = 0
    public var nbNodeChecked = 0
    
    public func addElement(point: T) {
        fatalError("Implement this function")
    }

    public func addElements(points: [T]) {
        fatalError("Implement this function")
    }
    
    public func findNeighbors(point: T, limit: Int) -> [T] {
        fatalError("Implement this function")
    }
    public func findClosest(point: T, maxDistance: Double) -> [T] {
        fatalError("Implement this function")
    }
}