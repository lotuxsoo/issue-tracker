//
//  CommentModel.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/29/24.
//

import Foundation

class CommentModel: BaseModel<Comment> {
    static let shared = CommentModel()
    
    enum Notifications {
        static let commentUpdated = Notification.Name("commentUpdated")
    }
    
    func getComment(by id: Int) -> Comment? {
        return items.first { $0.id == id }
    }
    
    func updateComment(commentId: Int, comment: String, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        NetworkManager.shared.updateComment(commentId: commentId, comment: comment) { result in
            switch result {
            case .success(let updatedComment):
                if let index = self.items.firstIndex(where: { $0.id == updatedComment.id }) {
                    self.updateItem(at: index, updatedComment)
                }
                
                NotificationCenter.default.post(name: Self.Notifications.commentUpdated, object: nil)
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createComment(commentRequest: CommentCreationRequest, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        NetworkManager.shared.createComment(commentRequest: commentRequest) { result in
            switch result {
            case .success:
                NotificationCenter.default.post(name: Self.Notifications.commentUpdated, object: nil)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteComment(commentId: Int, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        NetworkManager.shared.deleteComment(commentId: commentId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    if let index = self?.items.firstIndex(where: { $0.id == commentId }) {
                        self?.removeItem(at: index)
                    }
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
