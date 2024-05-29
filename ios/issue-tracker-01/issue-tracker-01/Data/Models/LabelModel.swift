//
//  LabelModel.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/20/24.
//

import Foundation

protocol LabelManaging: ItemManaging where T == LabelResponse {
    func fetchLabels(completion: @escaping () -> Void)
    func deleteLabel(at index: Int, completion: @escaping (Bool) -> Void)
    func updateLabel(at index: Int, labelRequest: LabelRequest, completion: @escaping (Bool) -> Void)
    func createLabel(labelRequest: LabelRequest, completion: @escaping (Bool) -> Void)
}

class LabelModel: BaseModel<LabelResponse>, LabelManaging {
    static let shared = LabelModel()
    
    enum Notifications {
        static let labelUpdated = Notification.Name("labelUpdated")
    }
    
    func fetchLabels(completion: @escaping () -> Void) {
        NetworkManager.shared.fetchLabels { [weak self] labels in
            DispatchQueue.main.async {
                self?.updateItems(with: labels ?? [])
                completion()
            }
        }
    }
    
    func deleteLabel(at index: Int, completion: @escaping (Bool) -> Void) {
        guard let label = item(at: index) else {
            completion(false)
            return
        }
        
        NetworkManager.shared.deleteLabel(labelId: label.id) { [weak self] success in
            
            if success {
                self?.removeItem(at: index)
                completion(true)
            } else {
                completion(false)
            }
        }
        
    }
    
    func updateLabel(at index: Int, labelRequest: LabelRequest, completion: @escaping (Bool) -> Void) {
        guard let labelToUpdate = item(at: index) else {
            completion(false)
            return
        }
        
        NetworkManager.shared.updateLabel(labelId: labelToUpdate.id, labelRequest: labelRequest) { [weak self] success, updatedLabel in
            DispatchQueue.main.async {
                if success, let updatedLabel = updatedLabel {
                    self?.updateItem(at: index, updatedLabel)
                    NotificationCenter.default.post(name: Self.Notifications.labelUpdated,
                                                    object: self
                    )
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func createLabel(labelRequest: LabelRequest, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.createLabel(label: labelRequest) { [weak self] success, createdLabel in
            DispatchQueue.main.async {
                if success, let newLabel = createdLabel {
                    self?.appendItem(newLabel)
                    NotificationCenter.default.post(name: Self.Notifications.labelUpdated,
                                                    object: self
                    )
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
