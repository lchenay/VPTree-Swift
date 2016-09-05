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
    func isWithin(_ distance: Double, of: Self) -> Bool
}
extension Distance {
    public func isWithin(_ distance: Double, of: Self) -> Bool {
        return (self ~~ of) <= distance
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

open class SpatialTree<T: Distance>: NSObject, NSCoding {
    open var nbElementsChecked = 0
    open var nbNodeChecked = 0
    
    open func encode(with aCoder: NSCoder) {
        
    }
    public required init?(coder aDecoder: NSCoder) {
        
    }
    
    public override init() {
        super.init()
    }
    
    open func addElement(_ point: T) {
        fatalError("Implement this function")
    }

    open func addElements(_ points: [T]) {
        fatalError("Implement this function")
    }
    
    open func findNeighbors(_ point: T, limit: Int) -> [T] {
        fatalError("Implement this function")
    }
    open func findClosest(_ point: T, maxDistance: Double) -> [T] {
        fatalError("Implement this function")
    }
}
