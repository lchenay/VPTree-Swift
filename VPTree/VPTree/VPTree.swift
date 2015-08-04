import Foundation

internal enum VPNode<T: Distance> {
    case Leaf([T])
    indirect case Node(T, Double, VPNode<T>, VPNode)
}

public class VPTree<T: Distance> {
    internal var firstNode: VPNode<T>
    
    let maxLeafElements = 16
    
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
                if (point ~~ vpPoint) > mu {
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
        var nbElementsChecked = 0
        var nbNodeChecked = 0
        while(nodesToTest.count > 0) {
            nbNodeChecked++
            let node = nodesToTest.removeAtIndex(0)!
            switch(node) {
            case .Leaf(let elements):
                let count = elements.count
                for var i = 0 ; i < count ; i++ {
                    nbElementsChecked++
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
                    if d - tau < mu {
                        nodesToTest.append(leftChild)
                    }
                    if d + tau >= mu {
                        nodesToTest.append(rightChild)
                    }
                } else {
                    if d + tau >= mu  {
                        nodesToTest.append(rightChild)
                    }
                    if d - tau < mu {
                        nodesToTest.append(leftChild)
                    }
                }
            }
        }
        print("\(nbElementsChecked), \(nbNodeChecked), \(neighbors.items.count)")
        return neighbors.items
    }
    
    func findNeighbors(point: T, limit: Int) -> [T] {
        return _neighbors(point, limit: limit, maxDistance: nil)
    }
    
    func findClosest(point: T, maxDistance: Double) -> [T] {
        return _neighbors(point, limit: nil, maxDistance: maxDistance)
    }
}