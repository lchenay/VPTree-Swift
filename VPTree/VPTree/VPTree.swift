import Foundation

internal enum VPNode<T: Distance> {
    case leaf([T])
    indirect case node(T, Double, VPNode<T>, VPNode)
}

open class VPTree<T: Distance>: SpatialTree<T> {
    internal var firstNode: VPNode<T>
    
    let maxLeafElements = 16
    
    public init(elements: [T]) {
        firstNode = VPNode.leaf([])
        super.init()
        self.addElements(elements)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func addElement(_ point: T) {
        firstNode = self.addElements([point], node: firstNode)
    }
    
    override open func addElements(_ points: [T]) {
        firstNode = self.addElements(points, node: firstNode)
    }
    
    fileprivate func addElements(_ points: [T], node: VPNode<T>) -> VPNode<T> {
        let pointCount = points.count
        switch node {
        case .leaf(var elements):
            if elements.count + pointCount <= maxLeafElements {
                for i in 0  ..< pointCount {
                    elements.append(points[i])
                }
                return .leaf(elements)
            } else {
                var allElements = (points + elements)
                let vpPoint = allElements.remove(at: 0)
                
                let points: [Point<T>] = allElements.map {
                    (item: T) -> Point<T> in
                    return Point<T>(d: item ~~ vpPoint, point: item)
                }
                //Random get of the VP points
                let (left, right): ([Point<T>], [Point<T>]) = points.splitByMedian()
                let mu = left.last!.d
                
                let leftChild = addElements(left.map {$0.point}, node: VPNode<T>.leaf([]))
                let rightChild = addElements(right.map {$0.point}, node: VPNode<T>.leaf([]))
                
                return VPNode<T>.node(vpPoint, mu, leftChild, rightChild)
            }
        case .node(let vpPoint, let mu, let leftChild, let rightChild):
            var toAddLeft = [T]()
            var toAddRight = [T]()
            for i in 0  ..< pointCount {
                let point = points[i]
                if point.isWithin(mu, of: vpPoint) {
                    toAddLeft.append(point)
                } else {
                    toAddRight.append(point)
                }
            }
            
            return VPNode<T>.node(
                vpPoint, mu, addElements(toAddLeft, node: leftChild), addElements(toAddRight, node: rightChild)
            )
        }
    }
    
    fileprivate func _neighbors(_ point: T, maxDistance: Double) -> [T] {
        let tau: Double = maxDistance
        var nodesToTest: [VPNode<T>?] = [firstNode]
        
        var neighbors = [T]()
        nbElementsChecked = 0
        nbNodeChecked = 0
        while(nodesToTest.count > 0) {
            nbNodeChecked += 1
            let node = nodesToTest.remove(at: 0)!
            switch(node) {
            case .leaf(let elements):
                let count = elements.count
                for i in 0  ..< count {
                    nbElementsChecked += 1
                    let element = elements[i]
                    if point.isWithin(tau, of: element) {
                        neighbors.append(element)
                    }
                }
            case .node(let vpPoint, let mu, let leftChild, let rightChild):
                let d = point ~~ vpPoint
                if d <= tau {
                    neighbors.append(vpPoint)
                }
                
                if d < mu {
                    if d - tau <= mu {
                        nodesToTest.append(leftChild)
                    }
                    if d + tau > mu {
                        nodesToTest.append(rightChild)
                    }
                } else {
                    if d + tau > mu  {
                        nodesToTest.append(rightChild)
                    }
                    if d - tau <= mu {
                        nodesToTest.append(leftChild)
                    }
                }
            }
        }
        
        return neighbors
    }
    
    fileprivate func _neighbors(_ point: T, limit: Int?) -> [T] {
        var tau: Double = Double.infinity
        var nodesToTest: [VPNode<T>?] = [firstNode]
        
        let neighbors = PriorityQueue<T>(limit: limit)
        nbElementsChecked = 0
        nbNodeChecked = 0
        
        while(nodesToTest.count > 0) {
            nbNodeChecked += 1
            let node = nodesToTest.remove(at: 0)!
            switch(node) {
            case .leaf(let elements):
                let count = elements.count
                for i in 0  ..< count {
                    nbElementsChecked += 1
                    let element = elements[i]
                    let d = point ~~ element
                    if d <= tau {
                        neighbors.push(d, item: point)
                        tau = neighbors.biggestWeigth
                    }
                }
            case .node(let vpPoint, let mu, let leftChild, let rightChild):
                let d = point ~~ vpPoint
                if d <= tau {
                    neighbors.push(d, item: vpPoint)
                    tau = neighbors.biggestWeigth
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

        return neighbors.items
    }
    
    open override func findNeighbors(_ point: T, limit: Int) -> [T] {
        return _neighbors(point, limit: limit)
    }
    
    open override func findClosest(_ point: T, maxDistance: Double) -> [T] {
        return _neighbors(point, maxDistance: maxDistance)
    }
}
