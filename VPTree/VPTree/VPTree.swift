import Foundation

infix operator ~~ {
}

protocol Distance {
    func ~~(lhs: Self, rhs: Self) -> Int
}

class VPTree<T: Distance> {
    var firstNode: VPNode<T>
    
    init(elements: [T]) {
        firstNode = VPNode<T>(elements: elements);
    }
    
    private func _neighbors(point: T, limit: Int?, maxDistance: Int? = nil) -> [T] {
        var tau: Int? = maxDistance
        var nodesToTest: [VPNode<T>] = [firstNode]
        
        var neighbors = PriorityQueue<T>(limit: limit)
        
        while(nodesToTest.count > 0) {
            let node = nodesToTest.removeAtIndex(0)
            let d = point ~~ node.vpPoint
            if tau == nil || d < tau! {
                neighbors.push(d, item: node.vpPoint)
                if maxDistance == nil {
                    tau = neighbors.biggestWeigth
                }
            }
            
            if node.isLeaf {
                continue
            }
            
            if d < node.mu! {
                if d < node.mu! + tau! {
                    nodesToTest.append(node.leftChild!)
                }
                if d >= node.mu! - tau! {
                    nodesToTest.append(node.rightChild!)
                }
            } else {
                if d >= node.mu! - tau! {
                    nodesToTest.append(node.rightChild!)
                }
                if d < node.mu! + tau! {
                    nodesToTest.append(node.leftChild!)
                }
            }
        }
        
        return neighbors.items
    }
    
    func findNeighbors(point: T, limit: Int) -> [T] {
        return _neighbors(point, limit: limit, maxDistance: nil)
    }
    
    func findClosest(point: T, maxDistance: Int) -> [T] {
        return _neighbors(point, limit: nil, maxDistance: maxDistance)
    }
}