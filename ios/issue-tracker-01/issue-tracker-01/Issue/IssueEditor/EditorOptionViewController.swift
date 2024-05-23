//
//  EditorOptionViewController.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/17/24.
//

import UIKit

class EditorOptionViewController: UIViewController {

    static let identifier: String = "EditorOptionViewController"
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: SelectedOptionCell.identifier, bundle: .main), forCellReuseIdentifier: SelectedOptionCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func configureNavigationBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backBtnTapped)
        )
        navigationItem.leftBarButtonItem = backButton
        
        let saveButton = UIBarButtonItem(title: "저장",
                                         style: .plain,
                                         target: self,
                                         action: #selector(saveBtnTapped)
        )
        navigationItem.rightBarButtonItem = saveButton
        
        if let title = sectionTitle {
            navigationItem.title = title
        }
    }
    
    @objc private func backBtnTapped() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc private func saveBtnTapped() {
        
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
            let option = selectedOptions.remove(at: indexPath.row)
            unselectedOptions.append(option)
        case 1:
            let option = unselectedOptions.remove(at: indexPath.row)
            selectedOptions.append(option)
        default:
            return
        }
        
        tableView.reloadData()
    }
}
