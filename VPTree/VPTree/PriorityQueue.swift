import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PriorityQueue<T> {
    fileprivate var _items: [(weight: Double, item: T)] = []
    var limit: Int?
    
    init(limit: Int?) {
        self.limit = limit
    }
    
    init() {
    }
    
    func push(_ weight: Double, item: T) {
        var index = 0
        
        while (index < _items.count) {
            if (weight < _items[index].weight) {
                break
            }
            index += 1
        }
        
        _items.insert((weight: weight, item: item), at: index)
        
        if limit != nil && _items.count > limit {
            _items.removeLast()
        }
    }
    
    var count: Int { return _items.count }
    var items: [T] { return _items.map { return $0.item } }
    var last: T? { return _items.last?.item }
    var first: T? { return _items.first?.item }
    var biggestWeigth: Double {
        if _items.count == limit {
            return _items.last!.weight
        }
        return Double.infinity
    }
}
