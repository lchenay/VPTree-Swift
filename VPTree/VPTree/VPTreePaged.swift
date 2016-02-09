import Foundation

internal enum VPNodePaged<T: AnyObject where T: Distance> {
    case Leaf([T])
    indirect case Node(T, [Double], [VPNodePaged<T>])
    
    var count: Int {
        switch self {
        case .Leaf(let elements):
            return elements.count
        case .Node(_, _, let childs):
            return childs.reduce(0, combine: { return $0 + $1.count }) + 1
        }
    }
    
    internal func encodeWithCoder(aCoder: NSCoder) {
        switch self {
        case .Node(let vpPoint, let mus, let childs):
            
            aCoder.encodeObject(vpPoint, forKey: "v")
            aCoder.encodeObject(mus, forKey: "m")
            childs.enumerate().forEach {
                let mutableData = NSMutableData()
                let archiver = NSKeyedArchiver(forWritingWithMutableData: mutableData)
            
                $1.encodeWithCoder(archiver)
                archiver.finishEncoding()
                
                aCoder.encodeObject(mutableData, forKey: "\($0)" )
            }
        case .Leaf(let elements):
            aCoder.encodeObject(elements, forKey: "e")
        }
    }
    
    internal init(coder aDecoder: NSCoder) {
        if let elemenst = aDecoder.decodeObjectForKey("e") as? [T] {
            self = VPNodePaged<T>.Leaf(elemenst)
        } else {
            var i = 0;
            var childs = [VPNodePaged<T>]()
            var childData = aDecoder.decodeObjectForKey("\(i++)") as? NSData
            
            while childData != nil {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: childData!)
                childs.append(VPNodePaged<T>(coder: unarchiver))
                unarchiver.finishDecoding()
                
                childData = aDecoder.decodeObjectForKey("\(i++)") as? NSData
            }
            
            let vpPoint = aDecoder.decodeObjectForKey("v") as! T
            let mus = aDecoder.decodeObjectForKey("m") as! [Double]
            self = VPNodePaged<T>.Node(vpPoint, mus, childs)
        }
    }
}

public class VPTreePaged<T: Distance where T: AnyObject>: SpatialTree<T> {
    internal var firstNode: VPNodePaged<T>
    
    private let maxLeafElements: Int
    private let branchingFactor: Int
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        
        aCoder.encodeInteger(maxLeafElements, forKey: "maxLeafElements")
        aCoder.encodeInteger(branchingFactor, forKey: "branchingFactor")
        firstNode.encodeWithCoder(aCoder)
    }
    public required init?(coder aDecoder: NSCoder) {
        self.maxLeafElements = aDecoder.decodeIntegerForKey("maxLeafElements")
        self.branchingFactor = aDecoder.decodeIntegerForKey("branchingFactor")
        self.firstNode = VPNodePaged(coder: aDecoder)
        
        super.init(coder: aDecoder)
    }
    
    public init(maxLeafElements: Int, branchingFactor: Int) {
        if (maxLeafElements < branchingFactor) {
            fatalError("maxLeafElements can not be lower than branchingFactor")
        }
        self.maxLeafElements = maxLeafElements
        self.branchingFactor = branchingFactor
        self.firstNode = VPNodePaged.Leaf([])
        super.init()
    }
    
    public convenience init(elements: [T]) {
        self.init(maxLeafElements: 14, branchingFactor: 7)
        self.addElements(elements)
    }
    
    override public func addElement(point: T) {
        firstNode = self.addElements([point], node: firstNode)
    }
    
    override public func addElements(points: [T]) {
        firstNode = self.addElements(points, node: firstNode)
    }
    
    private func addElements(points: [T], node: VPNodePaged<T>) -> VPNodePaged<T> {
        let pointsCount = points.count
        if pointsCount == 0 {
            return node
        }
        switch node {
        case .Leaf(var elements):
            if elements.count + pointsCount <= maxLeafElements {
                elements.appendContentsOf(points)
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
                var childs = [VPNodePaged<T>]()
                var mu = [Double]()
                
                for var i = 0 ; i < branchingFactor - 1 ; i++ {
                    let count = points.count
                    if count == 0 {
                        break
                    }
                    var nbItemLeft = count / (branchingFactor - i)
                    if nbItemLeft == 0 {
                        nbItemLeft = 1
                    }
                    let (left, right) = trySplit(points, nbItemLeft: nbItemLeft, nbItemRight: count-nbItemLeft)
                    points = right
                    mu.append(left.last!.d)
                    childs.append(addElements(left.map {$0.point}, node: VPNodePaged<T>.Leaf([])))
                }
                childs.append(addElements(points.map {$0.point}, node: VPNodePaged<T>.Leaf([])))
                mu.append(Double.infinity)
                
                return VPNodePaged<T>.Node(vpPoint, mu, childs)
            }
        case .Node(let vpPoint, let mus, var childs):
            var toAddInNodes = Array<Array<T>>(count: branchingFactor, repeatedValue: Array<T>())
            let musCount = mus.count
            for var i = 0 ; i < pointsCount ; i++ {
                let point = points[i]
                let d = point ~~ vpPoint
                for var j = 0 ; j < musCount ; j++ {
                    let mu = mus[j]
                    if d <= mu {
                        toAddInNodes[j].append(point)
                        break
                    }
                }
            }
            
            for var i = 0 ; i < musCount ; i++ {
                childs[i] = addElements(toAddInNodes[i], node: childs[i])
            }
            
            return VPNodePaged<T>.Node(vpPoint, mus, childs)
        }
    }
    
    private func _neighbors(point: T, limit: Int) -> [T] {
        var tau: Double = Double.infinity
        var nodesToTest: [VPNodePaged<T>] = [firstNode]
        
        let neighbors = PriorityQueue<T>(limit: limit)
        nbElementsChecked = 0
        nbNodeChecked = 0
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
                        tau = neighbors.biggestWeigth
                    }
                }
            case .Node(let vpPoint, let mus, let childs):
                let dist = point ~~ vpPoint
                if dist <= tau {
                    neighbors.push(dist, item: vpPoint)
                    tau = neighbors.biggestWeigth
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
    
    private func _neighbors(point: T, maxDistance: Double) -> [T] {
        let tau: Double = maxDistance ?? Double.infinity
        var nodesToTest: [VPNodePaged<T>] = [firstNode]
        
        var neighbors = [T]()
        nbElementsChecked = 0
        nbNodeChecked = 0
        while(nodesToTest.count > 0) {
            nbNodeChecked++
            let node = nodesToTest.removeLast()
            switch(node) {
            case .Leaf(let elements):
                let count = elements.count
                for var i = 0 ; i < count ; i++ {
                    let element = elements[i]
                    nbElementsChecked++
                    if point.isWithin(tau, of: element) {
                        neighbors.append(element)
                    }
                }
            case .Node(let vpPoint, let mus, let childs):
                let dist = point ~~ vpPoint
                if dist <= tau {
                    neighbors.append(vpPoint)
                }
                var i = 0
                let count = childs.count

                for ; i < count - 1 ; i++ {
                    if tau + mus[i] >= dist {
                        break
                    }
                }
                
                for ; i < count ; i++ {
                    nodesToTest.append(childs[i])
                    if (tau + dist < mus[i]) {
                        break;
                    }
                }
            }
        }
        
        return neighbors
    }

    public override func findNeighbors(point: T, limit: Int) -> [T] {
        return _neighbors(point, limit: limit)
    }

    public override func findClosest(point: T, maxDistance: Double) -> [T] {
        return _neighbors(point, maxDistance: maxDistance)
    }
}