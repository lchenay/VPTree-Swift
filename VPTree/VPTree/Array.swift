//
//  Array.swift
//  VPTree
//
//  Created by Laurent CHENAY on 07/06/2015.
//  Copyright (c) 2015 Sunday. All rights reserved.
//

import Foundation

private func split<T: Comparable>(inout array: [T], nbItemLeft: Int, nbItemRight: Int) -> (Array<T>, Array<T>) {
    var left: Array<T> = []
    var right: Array<T> = []
    var middle: Array<T> = []
    
    left.reserveCapacity(nbItemLeft)
    right.reserveCapacity(nbItemRight)
    
    if (nbItemLeft == 0) {
        return (left, array)
    }
    
    if (nbItemRight == 0) {
        return (array, right)
    }
    
    if (nbItemLeft == 1 && nbItemRight == 1) {
        if array[0] < array[1] {
            return ([array[0]], [array[1]])
        } else {
            return ([array[1]], [array[0]])
        }
    }
    
    let pivot: T = array[nbItemLeft]
    for element in array {
        if element < pivot {
            left.append(element)
        } else if element > pivot {
            right.append(element)
        } else {
            middle.append(element)
        }
    }
    
    while (left.count < nbItemLeft && middle.count > 0) {
        left.append(middle.removeLast());
    }
    
    while (middle.count > 0) {
        right.append(middle.removeLast());
    }
    
    if left.count > nbItemLeft {
        let (subLeft, subRight): ([T], [T]) = split(&left, nbItemLeft: nbItemLeft, nbItemRight: nbItemRight - right.count)
        return (subLeft, right + subRight)
    } else if right.count > nbItemRight {
        let (subLeft, subRight): ([T], [T]) = split(&right, nbItemLeft: nbItemLeft - left.count, nbItemRight: nbItemRight)
        return (left + subLeft, subRight)
    } else {
        return (left, right)
    }
}

internal extension Array {
    internal func splitByMedian<T where T: Comparable>() -> ([T], [T]) {
        let mid = count / 2
        var array: Array<T> = self.map {return $0 as! T}
        return split(&array, nbItemLeft: count-mid, nbItemRight: mid)
    }
}
