//
//  Issue.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/9/24.
//

import Foundation

struct Issue: Codable {
    let id: Int
    let title: String
    let comment: String?
    let labels: [LabelResponse]?
    let milestone: CurrentMilestone?
}

struct IssueDetailResponse: Codable {
    let id: Int
    let title: String
    let author: String
    let lastModifiedAt: String
    let status: String
    let assignees: [String]
    let labels: [LabelResponse]?
    let milestone: CurrentMilestone?
    let comments: [Comment]
}

struct Comment: Codable {
    let id: Int
    let authorId: String
    let authorName: String
    let content: String
    let fileUrls: [String]
    let likedCount: Int
    let lastModifiedAt: String
}

struct IssueCreationRequest: Codable {
    let title: String
    let comment: String
    let assigneeIds: [String]
    let labelIds: [Int]
    let milestoneId: Int?
}
