//
//  Label.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/22/24.
//

import Foundation

struct LabelResponse: Codable, Hashable {
    let id: Int
    let name: String
    let description: String
    let color: String
}

struct LabelRequest: Codable {
    let name: String
    let description: String
    let color: String
}
