//
//  IssueModel.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/20/24.
//

import Foundation
import Combine

class IssueModel: BaseModel<Issue> {
    
    enum Notifications {
        static let issueCreated = Notification.Name("issueCreated")
    }
    
    @Published private(set) var issueDetail: IssueDetailResponse?
    var issueDetailPublisher: Published<IssueDetailResponse?>.Publisher { $issueDetail }
    
    var comment: [Comment]? {
        return self.issueDetail?.comments
    }
    
    func fetchIssueDetail(issueId: Int) {
        NetworkManager.shared.fetchIssueDetail(issueId: issueId) { [weak self] issueDetail in
            DispatchQueue.main.async {
                self?.issueDetail = issueDetail
            }
        }
    }
    
    func fetchIssues(completion: @escaping () -> Void) {
        NetworkManager.shared.fetchIssues { [weak self] issues in
            DispatchQueue.main.async {
                self?.updateItems(with: issues ?? [])
                completion()
            }
        }
    }
    
    func fetchAssignees(completion: @escaping (Result<[AssigneeResponse], Error>) -> Void) {
        NetworkManager.shared.fetchSelectedOption(from: .assignee, decodingType: [AssigneeResponse].self, completion: completion)
    }
    
    func fetchLabels(completion: @escaping (Result<[LabelResponse], Error>) -> Void) {
        NetworkManager.shared.fetchSelectedOption(from: .label, decodingType: [LabelResponse].self, completion: completion)
    }
    
    func fetchMilestones(completion: @escaping (Result<[CurrentMilestone], Error>) -> Void) {
        NetworkManager.shared.fetchSelectedOption(from: .milestone, decodingType: [CurrentMilestone].self, completion: completion)
    }
    
    func deleteIssue(at index: Int, completion: @escaping (Bool) -> Void) {
        guard let issue = item(at: index) else {
            completion(false)
            return
        }
        
        NetworkManager.shared.deleteIssue(issueId: issue.id) { [weak self] success in
            
            if success {
                self?.removeItem(at: index)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func closeIssue(at index: Int, completion: @escaping (Bool) -> Void) {
        guard let issue = item(at: index) else {
            completion(false)
            return
        }
        
        NetworkManager.shared.closeIssue(issueId: issue.id) { [weak self] success in
            
            if success {
                self?.removeItem(at: index)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func createIsuue(issueRequest: IssueCreationRequest, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.createIssue(issueRequest: issueRequest) { result in
            switch result {
            case .success(let issue):
                self.appendItem(issue)
                NotificationCenter.default.post(name: Self.Notifications.issueCreated, object: self)
                completion(true)
            case .failure(let error):
                completion(false)
            }
        }
    }
}
