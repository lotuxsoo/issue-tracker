//
//  CommentEditorViewController.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/29/24.
//

import UIKit

class CommentEditorViewController: UIViewController {

    static let identifier: String = "CommentEditorViewController"
    
    var issueId: Int?
    var commentID: Int?
    var initialContent: String?
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.text = initialContent
        textView.delegate = self
        saveButton.isEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let commentID = commentID, let issueId = issueId else { return }
        guard let updatedContent = textView.text, !updatedContent.isEmpty else {
            showAlert(message: "코멘트 내용을 입력해주세요.")
            return
        }
        let comment = CommentCreationRequest(issueId: issueId, content: updatedContent)
        
        CommentModel.shared.updateComment(commentId: commentID, commentRequest: comment) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.dismiss(animated: true)
                case .failure(let error):
                    self?.showErrorAlert(for: error)
                }
            }
        }
    }
}

extension CommentEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let initialContent = initialContent else { return }
        saveButton.isEnabled = textView.text != initialContent && !textView.text.isEmpty
    }
}
