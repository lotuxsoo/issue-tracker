//
//  EditorOptionViewController.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/17/24.
//

import UIKit

class EditorOptionViewController: UIViewController {

    static let identifier: String = "EditorOptionViewController"
    
    enum Notifications {
        static let didUpdateAssignees = Notification.Name("didUpdateAssignees")
        static let didUpdateLabels = Notification.Name("didUpdateLabels")
        static let didUpdateMilestone = Notification.Name("didUpdateMilestone")
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var sectionTitle: String?
    var issueModel: IssueModel!
    var options: [OptionType] = [] {
        didSet {
            unselectedOptions = options
            self.tableView.reloadData()
        }
    }
    
    private var unselectedOptions: [OptionType] = []
    private var selectedOptions: [OptionType] = []
    private var selectedMilestone: CurrentMilestone?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTableView()
    }
    
    func setupSelectedOptions(with options: [OptionType]) {
        self.selectedOptions = options
        self.unselectedOptions = self.options.filter { !self.selectedOptions.contains($0) }
        
        if let selectedMilestone = options.first(where: {
            if case .milestone = $0 {
                return true
            }
            return false
        }) {
            self.selectedOptions = [selectedMilestone]
        }
        self.tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: SelectedOptionCell.identifier, bundle: .main), forCellReuseIdentifier: SelectedOptionCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
        
        let saveButton = UIBarButtonItem(title: "저장",
                                         style: .plain,
                                         target: self,
                                         action: #selector(saveButtonTapped)
        )
        navigationItem.rightBarButtonItem = saveButton
        
        if let title = sectionTitle {
            navigationItem.title = title
        }
    }
    
    @objc private func backButtonTapped() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let sectionTitle = sectionTitle else { return }
        
        switch sectionTitle {
        case "담당자":
            NotificationCenter.default.post(name: Notifications.didUpdateAssignees, object: selectedOptions)
        case "레이블":
            NotificationCenter.default.post(name: Notifications.didUpdateLabels, object: selectedOptions)
        case "마일스톤":
            NotificationCenter.default.post(name: Notifications.didUpdateMilestone, object: selectedMilestone)
        default:
            return
        }
        dismiss(animated: true)
    }
}

extension EditorOptionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "선택됨" : "선택하지 않음"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? selectedOptions.count : unselectedOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectedOptionCell.identifier, for: indexPath) as? SelectedOptionCell else {
            return UITableViewCell()
        }
        
        let option: OptionType
        let isSelected: Bool
        switch indexPath.section {
        case 0:
            option = selectedOptions[indexPath.row]
            isSelected = true
        case 1:
            option = unselectedOptions[indexPath.row]
            isSelected = false
        default:
            return UITableViewCell()
        }
        
        cell.configureCell(with: option, isSelected: isSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            handleUnselection(at: indexPath.row)
        case 1:
            handleSelection(at: indexPath.row)
        default:
            return
        }
        
        tableView.reloadData()
    }
    
    private func handleUnselection(at index: Int) {
        let option = selectedOptions.remove(at: index)
        unselectedOptions.append(option)
        if case .milestone = option {
            selectedMilestone = nil
        } 
    }
    
    private func handleSelection(at index: Int) {
        let option = unselectedOptions.remove(at: index)
        if case .milestone(let newtMilestone) = option {
            updateSelectedMilestone(with: newtMilestone)
        } else {
            selectedOptions.append(option)
        }
    }
    
    private func updateSelectedMilestone(with newMilestone: CurrentMilestone) {
        if let currentMilestone = selectedMilestone {
            if let index = selectedOptions.firstIndex(where: {
                if case .milestone(let newMilestone) = $0 {
                    return newMilestone.id == currentMilestone.id
                }
                return false
            }) {
                let removedMilestone = selectedOptions.remove(at: index)
                unselectedOptions.append(removedMilestone)
            }
        }
        
        selectedMilestone = newMilestone
        selectedOptions = [OptionType.milestone(newMilestone)]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}
