//
//  IssueDetailViewController.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/14/24.
//

import UIKit
import Combine

class IssueDetailViewController: UIViewController {
    
    static let identifier: String = "IssueDetailViewController"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    var issueId: Int?
    var issueModel: IssueModel!
    let commentModel = CommentModel.shared
    var userProfileModel: UserProfileModel!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = true
        
        textField.delegate = self
        
        if let issueId = issueId {
            self.fetchIssueDetail(issueId: issueId)
        }
        self.navigationItem.largeTitleDisplayMode = .never
        setupNavigationBar()
        setupTableView()
        bindModel()
        registerForNotifications()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleIssueUpdated),
                                               name: IssueModel.Notifications.issueUpdated,
                                               object: nil
        )
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleCommentUpdated),
                                               name: CommentModel.Notifications.commentUpdated,
                                               object: nil
        )
    }
    
    @objc private func handleIssueUpdated(notification: Notification) {
        self.tableView.reloadData()
    }
    
    @objc private func handleCommentUpdated(notification: Notification) {
        if let issueId = issueId {
            self.fetchIssueDetail(issueId: issueId)
        }
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "IssueDetailHeaderView", bundle: .main), forHeaderFooterViewReuseIdentifier: IssueDetailHeaderView.identifier)
        tableView.register(UINib(nibName: "IssueDetailCell", bundle: .main), forCellReuseIdentifier: IssueDetailCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func fetchIssueDetail(issueId: Int) {
        issueModel.fetchIssueDetail(issueId: issueId) {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    private func bindModel() {
        issueModel.issueDetailPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.commentModel.updateItems(with: self?.issueModel.comment)
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
        
        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(moreButtonTapped)
        )
        navigationItem.rightBarButtonItem = moreButton
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func moreButtonTapped() {
        let detailMoreVC = IssueDetailMoreViewController(nibName: IssueDetailMoreViewController.identifier, bundle: nil)
        detailMoreVC.issueModel = self.issueModel
        detailMoreVC.issueId = self.issueId
        detailMoreVC.delegate = self
        
        let navigationController = UINavigationController(rootViewController: detailMoreVC)
        navigationController.modalPresentationStyle = .pageSheet
        
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 12
        }
        
        present(navigationController, animated: true)
    }
    
    @IBAction func upButtonTapped(_ sender: Any) {
        changeCommentFocus(moveUp: true)
    }
    
    @IBAction func downButtonTapped(_ sender: Any) {
        changeCommentFocus(moveUp: false)
    }
    
    private func changeCommentFocus(moveUp: Bool) {
        let currentRow = tableView.indexPathForSelectedRow?.row
        var newRow: Int?
        
        if let currentRow = currentRow {
            newRow = currentRow + (moveUp ? -1 : 1)
        } else {
            newRow = moveUp ? (commentModel.count - 1) : 0
        }
        
        if let newRow = newRow, newRow >= 0, newRow < commentModel.count {
            let newIndexPath = IndexPath(row: newRow, section: 0)
            tableView.selectRow(at: newIndexPath, animated: true, scrollPosition: .middle)
            tableView.scrollToRow(at: newIndexPath, at: .middle, animated: true)
            updateCommentFocus()
        }
    }

    private func updateCommentFocus() {
        if let indexPaths = tableView.indexPathsForVisibleRows {
            for indexPath in indexPaths {
                if let cell = tableView.cellForRow(at: indexPath) as? IssueDetailCell {
                    DispatchQueue.main.async {
                        cell.backgroundCellView.backgroundColor = (self.tableView.indexPathForSelectedRow == indexPath) ? .gray400 : .systemBackground
                    }
                }
            }
        }
    }
}

extension IssueDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IssueDetailCell.identifier, for: indexPath) as? IssueDetailCell else {
            return UITableViewCell()
        }
        
        if let comment = commentModel.item(at: indexPath.row) {
            cell.userProfileModel = self.userProfileModel
            cell.setComment(with: comment)
            cell.commentId = comment.id
            cell.issueId = self.issueId
            cell.commentModel = self.commentModel
            cell.delegate = self
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: IssueDetailHeaderView.identifier) as? IssueDetailHeaderView,
              let issueDetail = issueModel.issueDetail else {
            return nil
        }
        headerView.contentView.backgroundColor = .systemBackground
        headerView.setDetail(with: issueDetail)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 96
    }
}

extension IssueDetailViewController: IssueDetailViewControllerDelegate {
    func didCompleteTask() {
        navigationController?.popViewController(animated: true)
    }
}

extension IssueDetailViewController: IssueDetailCellDelegate {
    func issueDetailCellDidRequestDelete(_ cell: IssueDetailCell, commentId: Int) {
        commentModel.deleteComment(commentId: commentId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showErrorAlert(for: error)
                }
            }
        }
    }
    
    func issueDetailCell(_ cell: IssueDetailCell, commentId: Int, initialContent: String) {
        let commentEditVC = CommentEditorViewController(nibName: CommentEditorViewController.identifier, bundle: nil)
        commentEditVC.commentID = commentId
        commentEditVC.issueId = self.issueId
        commentEditVC.initialContent = initialContent
        
        let navigationController = UINavigationController(rootViewController: commentEditVC)
        self.present(navigationController, animated: true)
    }
}

extension IssueDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let text = textField.text, !text.isEmpty {
            createComment(content: text)
            textField.text = ""
        }
        return true
    }
    
    private func createComment(content: String) {
        guard let issueId = issueId else { return }
        let commentRequest = CommentCreationRequest(issueId: issueId, content: content)
        commentModel.createComment(commentRequest: commentRequest) { result in
            switch result {
            case .success():
                self.fetchIssueDetail(issueId: issueId)
            case .failure(let error):
                self.showErrorAlert(for: error)
            }
        }
    }
}
