import Foundation

class PriorityQueue<T> {
    private var _items: [(weight: Int, item: T)] = []
    var limit: Int?
    
    init(limit: Int?) {
        self.limit = limit
    }
    
    init() {
    }
    
    func push(weight: Int, item: T) {
        var index = 0
        
        while (index < _items.count) {
            if (weight < _items[index].weight) {
                break
            }
            index++
        }
        
        _items.insert((weight: weight, item: item), atIndex: index)
        
        if _items.count > limit {
            _items.removeLast()
        }
    }
    
    var count: Int { return _items.count }
    var items: [T] { return _items.map { return $0.item } }
    var last: T? { return _items.last?.item }
    var first: T? { return _items.first?.item }
    var biggestWeigth: Int? { return _items.last?.weight }
}