//
//  IssueDetailCell.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/14/24.
//

import UIKit

protocol IssueDetailCellDelegate: AnyObject {
    func issueDetailCell(_ cell: IssueDetailCell, commentId: Int, initialContent: String)
    func issueDetailCellDidRequestDelete(_ cell: IssueDetailCell, commentId: Int)
}

class IssueDetailCell: UITableViewCell {
    
    static let identifier: String = "IssueDetailCell"
    
    weak var delegate: IssueDetailCellDelegate?

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var backgroundCellView: UIView!
    
    var commentId: Int?
    var commentModel: CommentModel!
    var userProfileModel: UserProfileModel?
    
    private let defaultImage = UIImage(named: "profileL")
    private let heartImage = UIImage(systemName: "heart.fill")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureFont()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.userImage.image = defaultImage
        self.nameLabel.text = nil
        self.contentLabel.text = nil
        self.contentLabel.text = nil
        self.authorLabel.isHidden = true
        
        actionButton.setImage(nil, for: .normal)
        actionButton.removeTarget(self, action: nil, for: .allEvents)
        actionButton.menu = nil
    }
    
    private func configureFont() {
        self.nameLabel.applyStyle(fontManager: FontManager(weight: .semibold, size: .large), textColor: .gray900)
        self.timeLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .small), textColor: .gray700)
        self.contentLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .large), textColor: .gray900)
        
        self.authorLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .small), textColor: .gray700)
        self.authorLabel.layer.cornerRadius = 8
        self.authorLabel.layer.borderWidth = 1
        self.authorLabel.layer.borderColor = UIColor.gray200.cgColor
    }
    
    func setComment(with comment: Comment) {
        self.nameLabel.text = comment.authorName
        self.contentLabel.text = comment.content
        self.userImage.image = self.defaultImage
        
        if let date = Date.dateFromString(comment.lastModifiedAt) {
            self.timeLabel.text = date.timeAgoDisplay()
        } else {
            self.timeLabel.text = "날짜 오류"
        }
        
        self.updateAuthorLabel(comment: comment)
        self.updateActionButton(comment: comment)
    }
    
    private func updateAuthorLabel(comment: Comment) {
        guard let userProfile = userProfileModel?.getUserProfile() else { return }
        authorLabel.isHidden = !(comment.authorId == userProfile.id)
    }

    private func updateActionButton(comment: Comment) {
        if comment.authorId == userProfileModel?.getUserProfile()?.id {
            configureActionButtonMenu()
        } else {
            configureHeartButton()
        }
    }
    
    private func configureActionButtonMenu() {
        let editAction = UIAction(title: "편집",
                                  image: UIImage(systemName: "pencil")) { [weak self] _ in
            self?.editComment()
        }
        
        let deleteAction = UIAction(title: "삭제",
                                    image: UIImage(systemName: "trash.fill"),
                                    attributes: .destructive) { [weak self] _ in
            self?.deleteComment()
        }
        
        let menu = UIMenu(children: [editAction, deleteAction])
        actionButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        actionButton.menu = menu
        actionButton.showsMenuAsPrimaryAction = true
        actionButton.removeTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
    }
    
    private func configureHeartButton() {
        actionButton.setImage(heartImage, for: .normal)
        actionButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
        actionButton.showsMenuAsPrimaryAction = false
    }
    
    private func editComment() {
        guard let commentId = commentId, let comment = commentModel.getComment(by: commentId) else { return }
        delegate?.issueDetailCell(self, commentId: commentId, initialContent: comment.content)
    }
    
    private func deleteComment() {
        guard let commentId = commentId else { return }
        delegate?.issueDetailCellDidRequestDelete(self, commentId: commentId)
    }
    
    @objc private func heartButtonTapped() {
        print("하트버튼 Tapped!")
        animateButton()
    }
    
    private func animateButton() {
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.actionButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.actionButton.transform = CGAffineTransform.identity
            }
        })
    }
}
