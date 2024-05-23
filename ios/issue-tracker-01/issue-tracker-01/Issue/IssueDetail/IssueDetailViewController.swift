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
    
    var issueId: Int?
    var issueModel: IssueModel!
    let commentViewModel = BaseModel<Comment>()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.largeTitleDisplayMode = .never
        
        configureNavigationBar()
        setupTableView()
        bindModel()
        
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
        issueModel.fetchIssueDetail(issueId: issueId)
    }
    
    private func bindModel() {
        issueModel.issueDetailPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.commentViewModel.updateItems(with: self?.issueModel.comment)
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func configureNavigationBar() {
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
        print("이슈에 대한moreButtonTapped!!")
    }
}

extension IssueDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentViewModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IssueDetailCell.identifier, for: indexPath) as? IssueDetailCell,
              let issueDetail = issueModel.issueDetail else {
            return UITableViewCell()
        }
        
        if let comment = commentViewModel.item(at: indexPath.row) {
            cell.setComment(with: comment, issueAuthor: issueDetail.author)
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
