//
//  MilestoneEditorViewController.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/22/24.
//

import UIKit

class MilestoneEditorViewController: UIViewController {

    static let identifier: String = "MilestoneEditorViewController"
    
    var milestoneToEdit: MilestoneResponse?
    var milestoneIndex: Int?
    var isEditingMode = false
    
    var milestoneModel: MilestoneManaging!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var deadlineField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureFont()
        configureNavigationBar()
        configureTextField()
        configureForEditing()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func configureForEditing() {
        if let milestone = milestoneToEdit {
            
            isEditingMode = true
            titleField.text = milestone.name
            descriptionField.text = milestone.description
            deadlineField.text = milestone.deadline
            
            self.title = "마일스톤 편집"
        } else {
            self.title = "마일스톤 추가"
        }
    }
    
    private func configureTextField() {
        titleField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        deadlineField.addTarget(self, action: #selector(deadlineFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let isTitleValid = !(titleField.text?.isEmpty ?? true)
                
        navigationItem.rightBarButtonItem?.isEnabled = isTitleValid
    }
    
    @objc private func deadlineFieldDidChange(_ textField: UITextField) {
        if let deadlineText = textField.text, isVaildDate(dateString: deadlineText) {
            deadlineLabel.textColor = .gray800
            navigationItem.rightBarButtonItem?.isEnabled = isAllFieldsValid()
        } else {
            deadlineLabel.textColor = .red
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func isAllFieldsValid() -> Bool {
        guard let titleText = titleField.text,
              let deadlineText = deadlineField.text,
              !titleText.isEmpty,
              isVaildDate(dateString: deadlineText) else {
            return false
        }
        return true
    }
    
    private func isVaildDate(dateString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.date(from: dateString) != nil
    }

    private func configureFont() {
        self.titleLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .large), textColor: .gray800)
        self.descriptionLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .large), textColor: .gray800)
        self.deadlineLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .large), textColor: .gray800)
    }
    
    private func configureNavigationBar() {
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
    }
    
    @objc private func backButtonTapped() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let name = titleField.text, !name.isEmpty,
              let description = descriptionField.text,
              let deadline = deadlineField.text else {
            return
        }
        
        let milestoneRequest = MilestoneRequest(name: name, description: description, deadline: deadline)
        
        if isEditingMode, let index = milestoneIndex {
            milestoneModel.updateMilestone(at: index, milestoneRequest: milestoneRequest)
            self.navigationController?.dismiss(animated: true)
        } else {
            milestoneModel.createMilestone(milestoneRequest)
            self.navigationController?.dismiss(animated: true)
        }
    }
}
