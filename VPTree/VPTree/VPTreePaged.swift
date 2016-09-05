import Foundation

internal enum VPNodePaged<T: AnyObject> where T: Distance {
    case leaf([T])
    indirect case node(T, [Double], [VPNodePaged<T>])
    
    var count: Int {
        switch self {
        case .leaf(let elements):
            return elements.count
        case .node(_, _, let childs):
            return childs.reduce(0, { return $0 + $1.count }) + 1
        }
    }
    
    internal func encodeWithCoder(_ aCoder: NSCoder) {
        switch self {
        case .node(let vpPoint, let mus, let childs):
            
            aCoder.encode(vpPoint, forKey: "v")
            aCoder.encode(mus, forKey: "m")
            childs.enumerated().forEach {
                let mutableData = NSMutableData()
                let archiver = NSKeyedArchiver(forWritingWith: mutableData)
            
                $1.encodeWithCoder(archiver)
                archiver.finishEncoding()
                
                aCoder.encode(mutableData, forKey: "\($0)" )
            }
        case .leaf(let elements):
            aCoder.encode(elements, forKey: "e")
        }
    }
    
    internal init(coder aDecoder: NSCoder) {
        if let elemenst = aDecoder.decodeObject(forKey: "e") as? [T] {
            self = VPNodePaged<T>.leaf(elemenst)
        } else {
            var i = 0;
            var childs = [VPNodePaged<T>]()
            var childData = aDecoder.decodeObject(forKey: "\(i)") as? Data
            i += 1
            
            while childData != nil {
                let unarchiver = NSKeyedUnarchiver(forReadingWith: childData!)
                childs.append(VPNodePaged<T>(coder: unarchiver))
                unarchiver.finishDecoding()
                
                childData = aDecoder.decodeObject(forKey: "\(i)") as? Data
                i += 1
            }
            
            let vpPoint = aDecoder.decodeObject(forKey: "v") as! T
            let mus = aDecoder.decodeObject(forKey: "m") as! [Double]
            self = VPNodePaged<T>.node(vpPoint, mus, childs)
        }
    }
}

open class VPTreePaged<T: Distance>: SpatialTree<T> where T: AnyObject {
    internal var firstNode: VPNodePaged<T>
    
    fileprivate let maxLeafElements: Int
    fileprivate let branchingFactor: Int
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        
        aCoder.encode(maxLeafElements, forKey: "maxLeafElements")
        aCoder.encode(branchingFactor, forKey: "branchingFactor")
        firstNode.encodeWithCoder(aCoder)
    }
    public required init?(coder aDecoder: NSCoder) {
        self.maxLeafElements = aDecoder.decodeInteger(forKey: "maxLeafElements")
        self.branchingFactor = aDecoder.decodeInteger(forKey: "branchingFactor")
        self.firstNode = VPNodePaged(coder: aDecoder)
        
        super.init(coder: aDecoder)
    }
    
    public init(maxLeafElements: Int, branchingFactor: Int) {
        if (maxLeafElements < branchingFactor) {
            fatalError("maxLeafElements can not be lower than branchingFactor")
        }
        self.maxLeafElements = maxLeafElements
        self.branchingFactor = branchingFactor
        self.firstNode = VPNodePaged.leaf([])
        super.init()
    }
    
    public convenience init(elements: [T]) {
        self.init(maxLeafElements: 14, branchingFactor: 7)
        self.addElements(elements)
    }
    
    override open func addElement(_ point: T) {
        firstNode = self.addElements([point], node: firstNode)
    }
    
    override open func addElements(_ points: [T]) {
        firstNode = self.addElements(points, node: firstNode)
    }
    
    fileprivate func addElements(_ points: [T], node: VPNodePaged<T>) -> VPNodePaged<T> {
        let pointsCount = points.count
        if pointsCount == 0 {
            return node
        }
        switch node {
        case .leaf(var elements):
            if elements.count + pointsCount <= maxLeafElements {
                elements.append(contentsOf: points)
                return .leaf(elements)
            } else {
                var allElements = (points + elements)
                //Random get of the VP points
                let vpPoint = allElements.remove(at: 0)
                var points: [Point<T>] = allElements.map {
                    (item: T) -> Point<T> in
                    let d = item ~~ vpPoint
                    return Point<T>(d: d, point: item)
                }
                var childs = [VPNodePaged<T>]()
                var mu = [Double]()
                
                for i in 0  ..< branchingFactor - 1 {
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
                    childs.append(addElements(left.map {$0.point}, node: VPNodePaged<T>.leaf([])))
                }
                childs.append(addElements(points.map {$0.point}, node: VPNodePaged<T>.leaf([])))
                mu.append(Double.infinity)
                
                return VPNodePaged<T>.node(vpPoint, mu, childs)
            }
        case .node(let vpPoint, let mus, var childs):
            var toAddInNodes = Array<Array<T>>(repeating: Array<T>(), count: branchingFactor)
            let musCount = mus.count
            for i in 0  ..< pointsCount {
                let point = points[i]
                let d = point ~~ vpPoint
                for j in 0  ..< musCount {
                    let mu = mus[j]
                    if d <= mu {
                        toAddInNodes[j].append(point)
                        break
                    }
                }
            }
            
            for i in 0  ..< musCount {
                childs[i] = addElements(toAddInNodes[i], node: childs[i])
            }
            
            return VPNodePaged<T>.node(vpPoint, mus, childs)
        }
    }
    
    fileprivate func _neighbors(_ point: T, limit: Int) -> [T] {
        var tau: Double = Double.infinity
        var nodesToTest: [VPNodePaged<T>] = [firstNode]
        
        let neighbors = PriorityQueue<T>(limit: limit)
        nbElementsChecked = 0
        nbNodeChecked = 0
        while(nodesToTest.count > 0) {
            nbNodeChecked += 1
            let node = nodesToTest.removeLast()
            switch(node) {
            case .leaf(let elements):
                let count = elements.count
                for i in 0  ..< count {
                    let element = elements[i]
                    let d = point ~~ element
                    nbElementsChecked += 1
                    if d <= tau {
                        neighbors.push(d, item: element)
                        tau = neighbors.biggestWeigth
                    }
                }
            case .node(let vpPoint, let mus, let childs):
                let dist = point ~~ vpPoint
                if dist <= tau {
                    neighbors.push(dist, item: vpPoint)
                    tau = neighbors.biggestWeigth
                }
                var i = 0
                while i < branchingFactor - 1 {
                    if tau + mus[i] >= dist {
                        break
                    }
                    i += 1
                }
                
                while i < branchingFactor {
                    nodesToTest.append(childs[i])
                    if (tau + dist < mus[i]) {
                        break;
                    }
                    i += 1
                }
            }
        }
        
        return neighbors.items
    }
    
    fileprivate func _neighbors(_ point: T, maxDistance: Double) -> [T] {
        let tau: Double = maxDistance ?? Double.infinity
        var nodesToTest: [VPNodePaged<T>] = [firstNode]
        
        var neighbors = [T]()
        nbElementsChecked = 0
        nbNodeChecked = 0
        while(nodesToTest.count > 0) {
            nbNodeChecked += 1
            let node = nodesToTest.removeLast()
            switch(node) {
            case .leaf(let elements):
                let count = elements.count
                for i in 0  ..< count {
                    let element = elements[i]
                    nbElementsChecked += 1
                    if point.isWithin(tau, of: element) {
                        neighbors.append(element)
                    }
                }
            case .node(let vpPoint, let mus, let childs):
                let dist = point ~~ vpPoint
                if dist <= tau {
                    neighbors.append(vpPoint)
                }
                var i = 0
                let count = childs.count

                while i < count - 1 {
                    if tau + mus[i] >= dist {
                        break
                    }
                }
                
                while i < count {
                    nodesToTest.append(childs[i])
                    if (tau + dist < mus[i]) {
                        break;
                    }
                }
            }
        }
        
        return neighbors
    }

    open override func findNeighbors(_ point: T, limit: Int) -> [T] {
        return _neighbors(point, limit: limit)
    }

    open override func findClosest(_ point: T, maxDistance: Double) -> [T] {
        return _neighbors(point, maxDistance: maxDistance)
    }
}
