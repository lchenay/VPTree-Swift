//
//  Array.swift
//  VPTree
//
//  Created by Laurent CHENAY on 07/06/2015.
//  Copyright (c) 2015 Sunday. All rights reserved.
//

import Foundation


internal extension Array {
    private func split<Element: Comparable>(nbItemLeft: Int, nbItemRight: Int) -> ([Element], [Element]) {
        var left: [Element] = []
        var right: [Element] = []
        
        if (nbItemLeft == 0) {
            right = self.map { return $0 as! Element }
            return (left, right)
        }
        
        if (nbItemRight == 0) {
            left = self.map { return $0 as! Element }
            return (left, right)
        }
        
        let pivot: Element = self[nbItemLeft] as! Element
        
        for i in 0..<self.count {
            let element: Element = self[i] as! Element
            if element < pivot {
                left.append(element)
            } else {
                right.append(element)
            }
        }
        
        if left.count - right.count > 1 {
            let (subLeft: [Element], subRight: [Element]) = left.split(nbItemLeft, nbItemRight: nbItemRight - right.count)
            return (subLeft, right + subRight)
        } else if right.count - left.count > 1 {
            let (subLeft: [Element], subRight: [Element]) = right.split(nbItemLeft - left.count, nbItemRight: nbItemRight)
            return (left + subLeft, subRight)
        } else {
            return (left, right)
        }
    }
    
    internal func splitByMedian<Element: Comparable>() -> ([Element], [Element]) {
        let mid = count / 2
        return split(mid, nbItemRight: count - mid)
    }
}
