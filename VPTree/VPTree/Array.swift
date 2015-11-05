//
//  Array.swift
//  VPTree
//
//  Created by Laurent CHENAY on 07/06/2015.
//  Copyright (c) 2015 Sunday. All rights reserved.
//

import Foundation

internal func trySplit<T: Comparable>(array: [T], nbItemLeft: Int, nbItemRight: Int) -> (Array<T>, Array<T>) {
    
    if nbItemLeft == 0 {
        return ([], array)
    }
    
    var left: Array<T> = []
    var right: Array<T> = []
    var middle: Array<T> = []
    
    left.reserveCapacity(nbItemLeft)
    right.reserveCapacity(nbItemRight)
    
    let pivot: T = array.sort()[nbItemLeft - 1]
    for element in array {
        if element < pivot {
            left.append(element)
        } else if element > pivot {
            right.append(element)
        } else {
            middle.append(element)
        }
    }
    
    left.appendContentsOf(middle)
    
    return (left, right)
}

internal extension Array {
    internal func splitByMedian<T where T: Comparable>() -> ([T], [T]) {
        let mid = count / 2
        let array: Array<T> = self.map {return $0 as! T}
        return trySplit(array, nbItemLeft: count-mid, nbItemRight: mid)
    }
}
