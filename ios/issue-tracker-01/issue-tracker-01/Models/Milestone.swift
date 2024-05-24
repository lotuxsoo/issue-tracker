//
//  Milestone.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/22/24.
//

import Foundation

struct CurrentMilestone: Codable, Hashable {
    let id: Int
    let title: String
}

struct MilestoneResponse: Codable {
    let id: Int
    let name: String
    let description: String?
    let deadline: String?
    let openCounts: Int
    let closedCounts: Int
    let completion: Int
}

struct MilestoneRequest: Codable {
    let name: String
    let description: String?
    let deadline: String?
}
