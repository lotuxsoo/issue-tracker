//
//  URLDefines.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/13/24.
//

import Foundation

enum URLDefines {
    
    private static let base: String = {
        guard let urlBase = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String else {
            return ""
        }
        return urlBase
    }()

    static let issue = "\(base)/issue"
    static let issueList = "\(base)/issue/list"
    static let label = "\(base)/label"
    static let labelList = "\(base)/label/list"
    static let milestone = "\(base)/milestone"
    static let milestoneList = "\(base)/milestone/list"
    static let select = "\(base)/select"
}
