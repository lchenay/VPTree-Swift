//
//  Array.swift
//  VPTree
//
//  Created by Laurent CHENAY on 07/06/2015.
//  Copyright (c) 2015 Sunday. All rights reserved.
//

import Foundation

internal extension Array {
    private func split<T: Comparable>(nbItemLeft: Int, nbItemRight: Int) -> ([T], [T]) {
        var left: [T] = []
        var right: [T] = []
        var middle: [T] = []
        
        left.reserveCapacity(nbItemLeft)
        right.reserveCapacity(nbItemRight)
        
        if (nbItemLeft == 0) {
            right = self.map {return $0 as! T }
            return (left, right)
        }
        
        if (nbItemRight == 0) {
            left = self.map { return $0 as! T }
            return (left, right)
        }
        
        let pivot: T = self[nbItemLeft] as! T
        var element: T
        for i in 0..<self.count {
            element = self[i] as! T
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
            let (subLeft: [T], subRight: [T]) = left.split(nbItemLeft, nbItemRight: nbItemRight - right.count)
            return (subLeft, right + subRight)
        } else if right.count > nbItemRight {
            let (subLeft: [T], subRight: [T]) = right.split(nbItemLeft - left.count, nbItemRight: nbItemRight)
            return (left + subLeft, subRight)
        } else {
            return (left, right)
        }
    }
    
    internal func splitByMedian<Element: Comparable>() -> ([Element], [Element]) {
        let mid = count / 2
        return split(count-mid, nbItemRight: mid)
    }
}
