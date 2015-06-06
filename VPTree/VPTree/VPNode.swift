import Foundation

class VPNode<T: Distance> {
    var elements: [T] = []
    var vpPoint: T
    var mu: Int?
    var leftChild: VPNode<T>?
    var rightChild: VPNode<T>?
    
    convenience init(elements: ArraySlice<T>) {
        self.init(elements: [T](elements))
    }
    
    init(elements: [T]) {
        self.elements = elements
        
        //Random get of the VP points
        self.vpPoint = self.elements.removeAtIndex(0)
        
        if self.elements.count == 0 {
            return
        }
        
        let distances = self.elements.map { return (d: $0 ~~ self.vpPoint, point: $0) } .sorted { return $0.d < $1.d }
        let median = Int(ceil(Double(distances.count) / 2.0))
        
        mu = distances[median].d
        leftChild = VPNode(elements: distances[0..<median].map { return $0.point })
        rightChild = VPNode(elements: distances[median...distances.count].map { return $0.point })
    }
    
    var isLeaf: Bool {
        return elements.count == 1
    }
}