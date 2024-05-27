//
//  IssueListController.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/9/24.
//

import UIKit

class IssueListController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let issueModel = IssueModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "이슈"
        setupTableView()
        
        fetchIssues()
        setupPlusButton()
        registerForNotifications()
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleIssueUpdated),
                                               name: IssueModel.Notifications.issueUpdated,
                                               object: nil
        )
    }
    
    @objc private func handleIssueUpdated(notification: Notification) {
        self.tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "IssueTableCell", bundle: .main), forCellReuseIdentifier: IssueTableCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 148
    }
    
    private func fetchIssues() {
        self.issueModel.fetchIssues {
            self.tableView.reloadData()
        }
    }
    
    private func setupPlusButton() {
        let plusButton = UIButton(type: .custom)
        plusButton.backgroundColor = .myBlue
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        plusButton.tintColor = .gray50
        plusButton.layer.cornerRadius = 28
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            plusButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            plusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -23),
            plusButton.widthAnchor.constraint(equalToConstant: 56),
            plusButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    @objc private func plusButtonTapped() {
        let issueEditorVC = IssueEditorViewController(nibName: IssueEditorViewController.identifier, bundle: nil)
        issueEditorVC.issueModel = self.issueModel
        
        let navigationController = UINavigationController(rootViewController: issueEditorVC)
        navigationController.modalPresentationStyle = .fullScreen
        
        present(navigationController, animated: true)
    }
}

extension IssueListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return issueModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IssueTableCell.identifier, for: indexPath) as? IssueTableCell else {
            return UITableViewCell()
        }
        
        if let issue = issueModel.item(at: indexPath.row) {
            cell.setIssue(issue)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = createSwipeAction(title: "삭제",
                                             color: .myRed,
                                             image: UIImage(systemName: "trash.fill"),
                                             style: .destructive) { _, _, completionHandler in
            guard let issue = self.issueModel.item(at: indexPath.row) else {
                completionHandler(false)
                return
            }
            
            self.issueModel.deleteIssue(at: indexPath.row) { success in
                if success {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    print("\(issue.id) 삭제")
                }
                completionHandler(success)
            }
        }
        
        let closeAction = createSwipeAction(title: "닫기",
                                            color: .myPurple,
                                            image: UIImage(systemName: "archivebox.fill"),
                                            style: .destructive) { _, _, completionHandler in
            guard let issue = self.issueModel.item(at: indexPath.row) else {
                completionHandler(false)
                return
            }
            
            self.issueModel.closeIssue(at: indexPath.row) { success in
                if success {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    print("\(issue.id) 닫기")
                }
                completionHandler(success)
            }
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, closeAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let issue = issueModel.item(at: indexPath.row) {
            showIssueDetail(issueId: issue.id)
        }
    }
    
    private func showIssueDetail(issueId: Int) {
        let issueDetailVC = IssueDetailViewController(nibName: IssueDetailViewController.identifier, bundle: nil)
        issueDetailVC.issueId = issueId
        issueDetailVC.issueModel = self.issueModel
        issueDetailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(issueDetailVC, animated: true)
    }
}
