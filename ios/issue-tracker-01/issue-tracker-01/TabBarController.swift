//
//  TabBarController.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/9/24.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    private func setup() {
        guard let issueListVC = storyboard?.instantiateViewController(withIdentifier: "IssueListController") as? IssueListController else { return }
        let issueNavigationController = UINavigationController(rootViewController: issueListVC)
        issueNavigationController.navigationBar.prefersLargeTitles = true
        issueNavigationController.tabBarItem.title = "이슈"
        issueNavigationController.tabBarItem.image = UIImage(named: "exclamation")
        
        guard let labelListVC = storyboard?.instantiateViewController(withIdentifier: "LabelListController") as? LabelListController else { return }
        let labelNavigationController = UINavigationController(rootViewController: labelListVC)
        labelNavigationController.navigationBar.prefersLargeTitles = true
        labelNavigationController.tabBarItem.title = "레이블"
        labelNavigationController.tabBarItem.image = UIImage(named: "tag")
        
        guard let milestoneListVC = storyboard?.instantiateViewController(withIdentifier: "MilestoneListController") as? MilestoneListController else { return }
        let milestoneNavigationController = UINavigationController(rootViewController: milestoneListVC)
        milestoneNavigationController.navigationBar.prefersLargeTitles = true
        milestoneNavigationController.tabBarItem.title = "마일스톤"
        milestoneNavigationController.tabBarItem.image = UIImage(named: "milestone")
        
        guard let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileController") as? ProfileController else { return }
        let profileNavigationController = UINavigationController(rootViewController: profileVC)
        profileNavigationController.navigationBar.prefersLargeTitles = true
        profileNavigationController.tabBarItem.title = "내 계정"
        profileNavigationController.tabBarItem.image = UIImage(named: "profileS")
        
        let controllers = [
           issueNavigationController,
           labelNavigationController,
           milestoneNavigationController,
           profileNavigationController
        ]
        
        setViewControllers(controllers, animated: false)
    }
}
