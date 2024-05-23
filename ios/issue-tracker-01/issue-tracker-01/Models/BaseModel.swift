//
//  BaseModel.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/15/24.
//

import Foundation

protocol ItemManaging: AnyObject {
    associatedtype T
    
    var count: Int { get }
    func updateItems(with newItems: [T]?)
    func item(at index: Int) -> T?
    func removeItem(at index: Int)
    func appendItem(_ item: T)
    func updateItem(at index: Int, _ item: T)
}

class BaseModel<T>: ItemManaging {
    private(set) var items: [T] = []
    
    var count: Int {
        return items.count
    }
    
    func updateItems(with newItems: [T]?) {
        if let newItems = newItems {
            self.items = newItems
        }
    }
    
    func item(at index: Int) -> T? {
        guard index >= 0 && index < items.count else { return nil }
        return items[index]
    }
    
    func removeItem(at index: Int) {
        if index >= 0 && index < items.count {
            items.remove(at: index)
        }
    }
    
    func appendItem(_ item: T) {
        self.items.append(item)
    }
    
    func updateItem(at index: Int, _ item: T) {
        if index >= 0 && index < items.count {
            items[index] = item
        }
    }
}
