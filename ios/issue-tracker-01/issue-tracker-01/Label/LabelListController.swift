//
//  LabelListController.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/9/24.
//

import UIKit

class LabelListController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var labelModel: any LabelManaging = LabelModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "레이블"
        
        configureNavigationBar()
        setupTableView()
        fetchLabels()
        registerForNotifications()
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleLabelUpdated),
                                               name: LabelModel.Notifications.labelUpdated,
                                               object: nil
        )
    }
    
    @objc private func handleLabelUpdated(notification: Notification) {
        self.tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: LabelTableCell.identifier, bundle: .main), forCellReuseIdentifier: LabelTableCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 100
    }
    
    private func fetchLabels() {
        self.labelModel.fetchLabels {
            self.tableView.reloadData()
        }
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
        let labelEditorVC = LabelEditorViewController(nibName: LabelEditorViewController.identifier, bundle: nil)
        
        let navigationController = UINavigationController(rootViewController: labelEditorVC)
        present(navigationController, animated: true)
    }
}

extension LabelListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labelModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LabelTableCell.identifier, for: indexPath) as? LabelTableCell else {
            return UITableViewCell()
        }
        
        if let label = labelModel.item(at: indexPath.row) {
            cell.configure(with: label)
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
                                             style: .normal) { _, _, completionHandler in
            guard let label = self.labelModel.item(at: indexPath.row) else {
                completionHandler(false)
                return
            }
            
            self.labelModel.deleteLabel(at: indexPath.row) { success in
                if success {
                    tableView.deleteRows(at: [indexPath], with: .bottom)
                    print("\(label.id) 삭제")
                }
                completionHandler(success)
            }
        }
        
        let editAction = createSwipeAction(title: "편집",
                                           color: .myPurple,
                                           image: UIImage(systemName: "pencil"),
                                           style: .destructive) { _, _, completionHandler in
            guard let label = self.labelModel.item(at: indexPath.row) else {
                completionHandler(false)
                return
            }
            
            let labelEditorVC = LabelEditorViewController(nibName: LabelEditorViewController.identifier, bundle: nil)
            labelEditorVC.labelToEdit = label
            labelEditorVC.labelIndex = indexPath.row
            let navigationController = UINavigationController(rootViewController: labelEditorVC)
            self.present(navigationController, animated: true)
            completionHandler(true)
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}
