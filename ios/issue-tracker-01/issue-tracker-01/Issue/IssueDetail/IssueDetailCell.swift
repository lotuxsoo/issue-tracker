//
//  IssueDetailCell.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/14/24.
//

import UIKit

class IssueDetailCell: UITableViewCell {
    
    static let identifier: String = "IssueDetailCell"

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
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
        self.timeLabel.text = nil
        self.contentLabel.text = nil
        self.contentLabel.text = nil
        self.authorLabel.isHidden = true
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
    
    func setComment(with comment: Comment, issueAuthor: String) {
        self.nameLabel.text = comment.authorName
        self.contentLabel.text = comment.content
        self.userImage.image = defaultImage
        
        if let date = Date.dateFromString(comment.lastModifiedAt) {
            self.timeLabel.text = date.timeAgoDisplay()
        } else {
            self.timeLabel.text = "날짜 오류"
        }
        
        if comment.authorName == issueAuthor {
            self.authorLabel.isHidden = false
            self.actionButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        } else {
            self.authorLabel.isHidden = true
            self.actionButton.setImage(heartImage, for: .normal)
            self.actionButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
        }
    }
    
    @objc private func moreButtonTapped() {
        print("more버튼 Tapped!")
        animateButton()
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
