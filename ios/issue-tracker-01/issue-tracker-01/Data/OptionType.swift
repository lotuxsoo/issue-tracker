//
//  OptionType.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/23/24.
//

import Foundation

struct AssigneeResponse: Codable, Hashable {
    let id: String
    let name: String
}

enum OptionType: Hashable {
    
    case assignee(AssigneeResponse)
    case label(LabelResponse)
    case milestone(CurrentMilestone)
    
    var displayText: String {
        switch self {
        case .assignee(let assignee):
            return assignee.name
        case .label(let label):
            return label.name
        case .milestone(let milestone):
            return milestone.title
        }
    }
    
    func isMilestone(withId id: Int) -> Bool {
        if case .milestone(let currentMilestone) = self {
            return currentMilestone.id == id
        }
        return false
    }
    
    static func == (lhs: OptionType, rhs: OptionType) -> Bool {
        switch (lhs, rhs) {
        case (.assignee(let lhsAssignee), .assignee(let rhsAssignee)):
            return lhsAssignee.id == rhsAssignee.id
        case (.label(let lhsLabel), .label(let rhsLabel)):
            return lhsLabel.id == rhsLabel.id
        case (.milestone(let lhsMilestone), .milestone(let rhsMilestone)):
            return lhsMilestone.id == rhsMilestone.id
        default:
            return false
        }
    }
}

enum APIEndpoint {
    case assignee
    case label
    case milestone
    
    var urlString: String {
        switch self {
        case .assignee:
            return "/assignee"
        case .label:
            return "/label"
        case .milestone:
            return "/milestone"
        }
    }
}
