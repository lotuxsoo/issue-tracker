//
//  UserProfileModel.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/29/24.
//

import Foundation

class UserProfileModel {
    static let shared = UserProfileModel()
    
    private var userProfile: UserProfileResoponse?
    
    func setUserProfile(_ profile: UserProfileResoponse) {
        self.userProfile = profile
    }
    
    func getUserProfile() -> UserProfileResoponse? {
        return userProfile
    }
}
