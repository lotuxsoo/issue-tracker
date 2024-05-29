//
//  User.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/28/24.
//

import Foundation

struct UserRequest: Codable {
    let id: String
    let nickname: String?
    let password: String?
}
