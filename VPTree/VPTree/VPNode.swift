import Foundation

private func <<T>(left: Point<T>, right: Point<T>) -> Bool {
    return left.d < right.d
}

private func ==<T>(left: Point<T>, right: Point<T>) -> Bool {
    return left.d == right.d
}

private class Point<T>: Comparable {
    var d: Double
    let point: T
    
    init(d: Double, point: T) {
        self.d = d
        self.point = point
    }
}

internal class VPNode<T: Distance> {
    var vpPoint: T!
    var points: [T] = []
    var mu: Double?
    var leftChild: VPNode<T>?
    var rightChild: VPNode<T>?
    
    convenience init?(elements: ArraySlice<T>) {
        self.init(elements: [T](elements))
    }
    
    private func convertion (item: Point<T>) -> T {
        return item.point
    }
    
    convenience init?(elements: [T]) {
        let array: [Point<T>] = elements.map {
            (item: T) -> Point<T> in
            return Point<T>(d: 0, point: item)
        }
        
        self.init(elements: array)
    }
    
    private init?(elements: [Point<T>]) {
        if elements.count == 0 {
            return nil
        }
        var elements = elements
        //Random get of the VP points
        self.vpPoint = elements.removeAtIndex(0).point
        
        if elements.count == 0 {
            return
        }
        
        for item in elements {
            item.d = item.point ~~ self.vpPoint
        }
        
        let (left, right): ([Point<T>], [Point<T>]) = elements.splitByMedian()
        
        mu = left.last!.d
        leftChild = VPNode(elements: left)
        rightChild = VPNode(elements: right)
    }
    
    private func addElement(element: Point<T>) {
        
    }
    
    var isLeaf: Bool {
        return leftChild == nil && rightChild == nil
    }
}