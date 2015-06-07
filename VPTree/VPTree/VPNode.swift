import Foundation

private func <<T>(left: Point<T>, right: Point<T>) -> Bool {
    return left.d < right.d
}

private func ==<T>(left: Point<T>, right: Point<T>) -> Bool {
    return left.d == right.d
}

private struct Point<T>: Comparable {
    let d: Double
    let point: T
}


internal class VPNode<T: Distance> {
    var vpPoint: T!
    var mu: Double?
    var leftChild: VPNode<T>?
    var rightChild: VPNode<T>?
    
    convenience init?(elements: ArraySlice<T>) {
        self.init(elements: [T](elements))
    }
    
    init?(elements: [T]) {
        if elements.count == 0 {
            return nil
        }
        var elements = elements
        //Random get of the VP points
        self.vpPoint = elements.removeAtIndex(0)
        
        if elements.count == 0 {
            return
        }
        
        let array: [Point<T>] = elements.map {
            (item: T) -> Point<T> in
            return Point<T>(d: item ~~ self.vpPoint, point: item)
        }

        let (left: [Point<T>], right: [Point<T>]) = array.splitByMedian()
        
        mu = left.last!.d
        leftChild = VPNode(elements: left.map { return $0.point })
        rightChild = VPNode(elements: right.map { return $0.point })
    }
    
    var isLeaf: Bool {
        return leftChild == nil && rightChild == nil
    }
}