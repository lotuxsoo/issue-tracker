//
//  OptionType.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/23/24.
//

import Foundation

struct AssigneeResponse: Codable {
    let id: String
    let name: String
}

enum OptionType {
    case assignee(AssigneeResponse)
    case label(LabelResponse)
    case milestone(CurrentMilestone)
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
