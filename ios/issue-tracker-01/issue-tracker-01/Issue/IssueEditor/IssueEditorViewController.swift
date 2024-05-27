//
//  IssueEditorViewController.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/16/24.
//

import UIKit

class IssueEditorViewController: UIViewController {

    static let identifier: String = "IssueEditorViewController"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var optionInfoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    
    var issueModel: IssueModel!
    
    private var selectedAssignees: [AssigneeResponse] = []
    private var selectedLabels: [LabelResponse] = []
    private var selectedMilestone: CurrentMilestone?
    
    private let placeholderText = "설명을 입력해주세요"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.largeTitleDisplayMode = .never
        
        setupTableView()
        configureFont()
        setupNavigationBar()
        setupTextFields()
        setupObservers()
    }
    
    private func setupTextFields() {
        descriptionField.delegate = self
        descriptionField.text = placeholderText
        descriptionField.textColor = .lightGray
        
        titleField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        updateSaveButtonState()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdatedAssignees(_:)), name: EditorOptionViewController.Notifications.didUpdateAssignees, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdatedLabels(_:)), name: EditorOptionViewController.Notifications.didUpdateLabels, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdatedMilestone(_:)), name: EditorOptionViewController.Notifications.didUpdateMilestone, object: nil)
    }
    
    @objc private func handleUpdatedAssignees(_ notification: Notification) {
        if let options = notification.object as? [OptionType] {
            let assignees = options.compactMap { option -> AssigneeResponse? in
                if case .assignee(let assignee) = option {
                    return assignee
                }
                return nil
            }
            selectedAssignees = assignees
            tableView.reloadData()
        }
        
    }
    
    @objc private func handleUpdatedLabels(_ notification: Notification) {
        if let options = notification.object as? [OptionType] {
            let labels = options.compactMap { option -> LabelResponse? in
                if case .label(let labelResponse) = option {
                    return labelResponse
                }
                return nil
            }
            selectedLabels = labels
            tableView.reloadData()
        }
    }
    
    @objc private func handleUpdatedMilestone(_ notification: Notification) {
        if let milestone = notification.object as? CurrentMilestone {
            selectedMilestone = milestone
            tableView.reloadData()
        }
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: EditorOptionCell.identifier, bundle: .main), forCellReuseIdentifier: EditorOptionCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func configureFont() {
        self.titleLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .large), textColor: .gray800)
        self.optionInfoLabel.applyStyle(fontManager: FontManager(weight: .semibold, size: .medium), textColor: .gray800)
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
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let segmentedControl = UISegmentedControl(items: ["마크다운", "미리보기"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segmentedControl.frame = CGRect(origin: .zero, size: CGSize(width: 196.0, height: 32.0))
        
        let font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        segmentedControl.setTitleTextAttributes([.font: font, .foregroundColor: UIColor.gray], for: .normal)
        segmentedControl.setTitleTextAttributes([.font: font, .foregroundColor: UIColor.black], for: .selected)
        
        navigationItem.titleView = segmentedControl
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let title = titleField.text, !title.isEmpty,
              let description = descriptionField.text, !description.isEmpty || description == placeholderText else {
            return
        }
        
        let assigneeIds = selectedAssignees.map { $0.id }
        let labelIds = selectedLabels.map { $0.id }
        let milestoneId = selectedMilestone?.id
        
        let issueRequest = IssueCreationRequest(title: title,
                                                comment: description,
                                                assigneeIds: assigneeIds,
                                                labelIds: labelIds,
                                                milestoneId: milestoneId
        )
        
        issueModel.createIsuue(issueRequest: issueRequest) { [weak self] success in
            if success {
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.showCreationFailedAlert()
            }
        }
    }
    
    private func showCreationFailedAlert() {
        let alertController = UIAlertController(title: "이슈 생성 실패",
                                                message: "이슈 생성에 문제가 발생하였습니다. 다시 시도해 주세요.", preferredStyle: .alert)
        
        let retryAction = UIAlertAction(title: "재시도", style: .default) { _ in
            self.saveButtonTapped()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .destructive)
        
        alertController.addAction(retryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("마크다운 선택됨")
        case 1:
            print("미리보기 선택됨")
        default:
            break
        }
    }
}

extension IssueEditorViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EditorOptionCell.identifier, for: indexPath) as? EditorOptionCell else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0: 
            cell.configureTitle(title: "담당자")
            cell.configureOptions(options: selectedAssignees.map { OptionType.assignee($0) })
        case 1:
            cell.configureTitle(title: "레이블")
            cell.configureOptions(options: selectedLabels.map { OptionType.label($0) })
        case 2:
            cell.configureTitle(title: "마일스톤")
            if let milestone = selectedMilestone {
                cell.configureOptions(options: [OptionType.milestone(milestone)])
            } else {
                cell.configureOptions(options: [])
            }
            
        default: return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editorOptionVC = EditorOptionViewController(nibName: EditorOptionViewController.identifier, bundle: nil)
        editorOptionVC.issueModel = self.issueModel
        
        switch indexPath.row {
        case 0:
            editorOptionVC.sectionTitle = "담당자"
            issueModel.fetchAssignees { result in
                switch result {
                case .success(let assignees):
                    let selectedOptions = self.selectedAssignees.map { OptionType.assignee($0) }
                    
                    editorOptionVC.options = assignees.map { OptionType.assignee($0) }
                    editorOptionVC.setupSelectedOptions(with: selectedOptions )
                case .failure(let error):
                    print("[ fetch assignees 실패 ]: \(error) ")
                }
            }
        case 1: editorOptionVC.sectionTitle = "레이블"
            issueModel.fetchLabels { result in
                switch result {
                case .success(let labels):
                    let selectedOptions = self.selectedLabels.map { OptionType.label($0) }
                    
                    editorOptionVC.options = labels.map { OptionType.label($0) }
                    editorOptionVC.setupSelectedOptions(with: selectedOptions)
                case .failure(let error):
                    print("[ fetch labels 실패 ]: \(error) ")
                }
            }
        case 2: editorOptionVC.sectionTitle = "마일스톤"
            issueModel.fetchMilestones { result in
                switch result {
                case .success(let milestones):
                    editorOptionVC.options = milestones.map { OptionType.milestone($0) }
                    
                    if let selectedMilestone = self.selectedMilestone {
                        editorOptionVC.setupSelectedOptions(with: [OptionType.milestone(selectedMilestone)])
                    }
                case .failure(let error):
                    print("[ fetch milestones 실패 ]: \(error) ")
                }
            }
        default: return
        }
        
        let navigationController = UINavigationController(rootViewController: editorOptionVC)
        present(navigationController, animated: true)
    }
}

extension IssueEditorViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateSaveButtonState()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = .lightGray
        }
    }
    
    private func updateSaveButtonState() {
        let titleText = titleField.text ?? ""
        let descriptionText = descriptionField.text ?? ""
        let isDescriptionEmpty = descriptionText.isEmpty || descriptionText == placeholderText
        
        navigationItem.rightBarButtonItem?.isEnabled = !titleText.isEmpty && !isDescriptionEmpty
    }
}
