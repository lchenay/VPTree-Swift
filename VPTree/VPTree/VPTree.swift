import Foundation

infix operator ~~ {
    precedence 140
}

public protocol Distance {
    func ~~(lhs: Self, rhs: Self) -> Double
}

private func <<T>(left: Point<T>, right: Point<T>) -> Bool {
    return left.d < right.d
}

private func ==<T>(left: Point<T>, right: Point<T>) -> Bool {
    return left.d == right.d
}

private struct Point<T>: Comparable {
    var d: Double
    var point: T
    
    init(d: Double, point: T) {
        self.d = d
        self.point = point
    }
}

internal enum VPNode<T: Distance> {
    case Leaf([T])
    indirect case Node(T, Double, VPNode<T>, VPNode)
}



public class VPTree<T: Distance> {
    internal var firstNode: VPNode<T>
    
    let maxLeafElements = 25
    
    init(elements: [T]) {
        firstNode = VPNode.Leaf([])
        self.addElements(elements)
    }
    
    func addElement(point: T) {
        firstNode = self.addElements([point], node: firstNode)
    }
    
    func addElements(points: [T]) {
        firstNode = self.addElements(points, node: firstNode)
    }
    
    private func addElements(points: [T], node: VPNode<T>) -> VPNode<T> {
        switch node {
        case .Leaf(var elements):
            if elements.count + points.count <= maxLeafElements {
                let count = points.count
                for var i = 0 ; i < count ; i++ {
                    elements.append(points[i])
                }
                return .Leaf(elements)
            } else {
                var allElements = (points + elements)
                let vpPoint = allElements.removeAtIndex(0)
                
                let points: [Point<T>] = allElements.map {
                    (item: T) -> Point<T> in
                    return Point<T>(d: item ~~ vpPoint, point: item)
                }
                //Random get of the VP points
                let (left, right): ([Point<T>], [Point<T>]) = points.splitByMedian()
                let mu = left.last!.d
                
                let leftChild = addElements(left.map {$0.point}, node: VPNode<T>.Leaf([]))
                let rightChild = addElements(right.map {$0.point}, node: VPNode<T>.Leaf([]))
                
                return VPNode<T>.Node(vpPoint, mu, leftChild, rightChild)
            }
        case .Node(let vpPoint, let mu, let leftChild, let rightChild):
            var toAddLeft = [T]()
            var toAddRight = [T]()
            let count = points.count
            for var i = 0 ; i < count ; i++ {
                let point = points[i]
                if (point ~~ vpPoint) < mu {
                    toAddRight.append(point)
                } else {
                    toAddLeft.append(point)
                }
            }
            
            return VPNode<T>.Node(
                vpPoint, mu, addElements(toAddLeft, node: leftChild), addElements(toAddRight, node: rightChild)
            )
        }
    }
    
    private func _neighbors(point: T, limit: Int?, maxDistance: Double? = nil) -> [T] {
        var tau: Double = maxDistance ?? Double.infinity
        var nodesToTest: [VPNode<T>?] = [firstNode]
        
        let neighbors = PriorityQueue<T>(limit: limit)
        
        while(nodesToTest.count > 0) {
            let node = nodesToTest.removeAtIndex(0)!
            switch(node) {
            case .Leaf(let elements):
                let count = elements.count
                for var i = 0 ; i < count ; i++ {
                    let element = elements[i]
                    let d = point ~~ element
                    if d <= tau {
                        neighbors.push(d, item: point)
                        if maxDistance == nil {
                            tau = neighbors.biggestWeigth
                        }
                    }
                }
            case .Node(let vpPoint, let mu, let leftChild, let rightChild):
                let d = point ~~ vpPoint
                if d <= tau {
                    neighbors.push(d, item: vpPoint)
                    if maxDistance == nil {
                        tau = neighbors.biggestWeigth
                    }
                }
                
                if d < mu {
                    if d < mu + tau {
                        nodesToTest.append(leftChild)
                    }
                    if d >= mu - tau {
                        nodesToTest.append(rightChild)
                    }
                } else {
                    if d >= mu - tau  {
                        nodesToTest.append(rightChild)
                    }
                    if d < mu + tau {
                        nodesToTest.append(leftChild)
                    }
                }
            }
        }
        
        return neighbors.items
    }
    
    func findNeighbors(point: T, limit: Int) -> [T] {
        return _neighbors(point, limit: limit, maxDistance: nil)
    }
    
    func findClosest(point: T, maxDistance: Double) -> [T] {
        return _neighbors(point, limit: nil, maxDistance: maxDistance)
    }
}