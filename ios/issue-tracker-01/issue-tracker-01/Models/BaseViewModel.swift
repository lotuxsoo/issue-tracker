//
//  BaseViewModel.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/15/24.
//

import Foundation

protocol ItemManaging: AnyObject {
    associatedtype T
    
    func updateItems(with newItems: [T])
    func item(at index: Int) -> T?
    func removeItem(at index: Int)
}

class BaseViewModel<T>: ItemManaging {
    private(set) var items: [T] = []
    
    var count: Int {
        return items.count
    }
    
    func updateItems(with newItems: [T]) {
        self.items = newItems
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
}
