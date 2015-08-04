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
    indirect case Node(T, [Double], [VPNode<T>])
}

public class VPTree<T: Distance> {
    internal var firstNode: VPNode<T>
    
    let maxLeafElements: Int
    let branchingFactor: Int
    
    init(maxLeafElements: Int, branchingFactor: Int) {
        if (maxLeafElements < branchingFactor) {
            fatalError("maxLeafElements can not be lower than branchingFactor")
        }
        self.maxLeafElements = maxLeafElements
        self.branchingFactor = branchingFactor
        self.firstNode = VPNode.Leaf([])
    }
    
    convenience init(elements: [T]) {
        self.init(maxLeafElements: 14, branchingFactor: 7)
        self.addElements(elements)
    }
    
    func addElement(point: T) {
        firstNode = self.addElements([point], node: firstNode)
    }
    
    func addElements(points: [T]) {
        firstNode = self.addElements(points, node: firstNode)
    }
    
    private func addElements(points: [T], node: VPNode<T>) -> VPNode<T> {
        let pointsCount = points.count
        if pointsCount == 0 {
            return node
        }
        switch node {
        case .Leaf(var elements):
            if elements.count + pointsCount <= maxLeafElements {
                elements.extend(points)
                return .Leaf(elements)
            } else {
                var allElements = (points + elements)
                //Random get of the VP points
                let vpPoint = allElements.removeAtIndex(0)
                var points: [Point<T>] = allElements.map {
                    (item: T) -> Point<T> in
                    let d = item ~~ vpPoint
                    return Point<T>(d: d, point: item)
                }
                var childs = [VPNode<T>]()
                var mu = [Double]()
                
                for var i = 0 ; i < branchingFactor - 1 ; i++ {
                    let count = points.count
                    let nbItemLeft = count / (branchingFactor - i)
                    let (left, right) = split(points, nbItemLeft: nbItemLeft, nbItemRight: count-nbItemLeft)
                    points = right
                    mu.append(left.last!.d)
                    childs.append(addElements(left.map {$0.point}, node: VPNode<T>.Leaf([])))
                }
                childs.append(addElements(points.map {$0.point}, node: VPNode<T>.Leaf([])))
                mu.append(Double.infinity)
                
                return VPNode<T>.Node(vpPoint, mu, childs)
            }
        case .Node(let vpPoint, let mus, var childs):
            var toAddInNodes = Array<Array<T>>(count: branchingFactor, repeatedValue: Array<T>())
            
            for var i = 0 ; i < pointsCount ; i++ {
                let point = points[i]
                let d = point ~~ vpPoint
                for var j = 0 ; j < branchingFactor ; j++ {
                    let mu = mus[j]
                    if d <= mu {
                        toAddInNodes[j].append(point)
                        break
                    }
                }
            }
            
            for var i = 0 ; i < branchingFactor ; i++ {
                childs[i] = addElements(toAddInNodes[i], node: childs[i])
            }
            
            return VPNode<T>.Node(vpPoint, mus, childs)
        }
    }
    
    private func _neighbors(point: T, limit: Int?, maxDistance: Double? = nil) -> [T] {
        var tau: Double = maxDistance ?? Double.infinity
        var nodesToTest: [VPNode<T>] = [firstNode]
        
        let neighbors = PriorityQueue<T>(limit: limit)
        var nbElementsChecked = 0
        var nbNodeChecked = 0
        while(nodesToTest.count > 0) {
            nbNodeChecked++
            let node = nodesToTest.removeLast()
            switch(node) {
            case .Leaf(let elements):
                let count = elements.count
                for var i = 0 ; i < count ; i++ {
                    let element = elements[i]
                    let d = point ~~ element
                    nbElementsChecked++
                    if d <= tau {
                        neighbors.push(d, item: element)
                        if maxDistance == nil {
                            tau = neighbors.biggestWeigth
                        }
                    }
                }
            case .Node(let vpPoint, let mus, let childs):
                let dist = point ~~ vpPoint
                if dist <= tau {
                    neighbors.push(dist, item: vpPoint)
                    if maxDistance == nil {
                        tau = neighbors.biggestWeigth
                    }
                }
                var i = 0
                for ; i < branchingFactor - 1 ; i++ {
                    if tau + mus[i] >= dist {
                        break
                    }
                }
                
                for ; i < branchingFactor ; i++ {
                    nodesToTest.append(childs[i])
                    if (tau + dist < mus[i]) {
                        break;
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