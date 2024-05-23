//
//  MilestoneListController.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/9/24.
//

import UIKit
import Combine

class MilestoneListController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var milestoneModel: MilestoneManaging!
    private var cancelMilestones = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        milestoneModel = MilestoneModel()
        
        self.title = "마일스톤"
        
        configureNavigationBar()
        setupTableView()
        bindModel()
        fetchMilestones()
    }
    
    private func fetchMilestones() {
        milestoneModel.fetchMilestones()
    }
    
    private func bindModel() {
        milestoneModel.milestonesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancelMilestones)
        
        milestoneModel.milestoneDeleted
            .sink { [weak self] index in
                self?.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .bottom)
            }
            .store(in: &cancelMilestones)
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: MilestoneTableCell.identifier, bundle: nil), forCellReuseIdentifier: MilestoneTableCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 148
    }
    
    private func configureNavigationBar() {
        let addButton = UIBarButtonItem(title: "추가",
                                        style: .plain,
                                        target: self,
                                        action: #selector(addButtonTapped)
        )
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func addButtonTapped() {
        let milestoneEditorVC = MilestoneEditorViewController(nibName: MilestoneEditorViewController.identifier, bundle: nil)
        milestoneEditorVC.milestoneModel = self.milestoneModel
        
        let navigationController = UINavigationController(rootViewController: milestoneEditorVC)
        present(navigationController, animated: true)
    }
}

extension MilestoneListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return milestoneModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MilestoneTableCell.identifier, for: indexPath) as? MilestoneTableCell else {
            return UITableViewCell()
        }
        
        if let milestone = milestoneModel.item(at: indexPath.row) {
            cell.setMilestone(milestone)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = createSwipeAction(title: "삭제",
                                             color: .myRed,
                                             image: UIImage(systemName: "trash.fill"),
                                             style: .destructive) { _, _, completionHandler in
            self.milestoneModel.deleteMilestone(at: indexPath.row)
            completionHandler(true)
        }
        
        let editAction = createSwipeAction(title: "편집",
                                           color: .myPurple,
                                           image: UIImage(systemName: "pencil"),
                                           style: .destructive) { _, _, completionHandler in
            guard let milestone = self.milestoneModel.item(at: indexPath.row) else {
                completionHandler(false)
                return
            }
            
            let milestoneEditorVC = MilestoneEditorViewController(nibName: MilestoneEditorViewController.identifier, bundle: nil)
            milestoneEditorVC.milestoneToEdit = milestone
            milestoneEditorVC.milestoneModel = self.milestoneModel
            milestoneEditorVC.milestoneIndex = indexPath.row
            let navigationController = UINavigationController(rootViewController: milestoneEditorVC)
            self.present(navigationController, animated: true)
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}
