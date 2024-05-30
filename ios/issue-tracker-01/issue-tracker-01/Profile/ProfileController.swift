//
//  ProfileController.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/9/24.
//

import UIKit

class ProfileController: UIViewController {
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    let userProfile = UserProfileModel.shared.getUserProfile()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        idLabel.text = userProfile?.id
        nicknameLabel.text = userProfile?.nickname
    }
}
