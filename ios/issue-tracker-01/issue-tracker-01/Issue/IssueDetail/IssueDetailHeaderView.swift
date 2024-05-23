//
//  IssueDetailHeaderView.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/16/24.
//

import UIKit

class IssueDetailHeaderView: UITableViewHeaderFooterView {
    
    static let identifier: String = "IssueDetailHeaderView"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var captionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        statusView.layer.cornerRadius = 12
        
        configureFont()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleLabel.text = nil
        self.idLabel.text = nil
        self.captionLabel.text = nil
    }
    
    private func configureFont() {
        self.titleLabel.applyStyle(fontManager: FontManager(weight: .semibold, size: .xlarge), textColor: .gray900)
        self.idLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .xlarge), textColor: .gray700)
        self.captionLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .medium), textColor: .gray700)
    }
    
    func setDetail(with issueDetail: IssueDetailResponse) {
        self.titleLabel.text = issueDetail.title
        self.idLabel.text = "#\(issueDetail.id)"
        
        if let date = Date.dateFromString(issueDetail.lastModifiedAt) {
            self.captionLabel.text = date.timeAgoDisplay() + ", \(issueDetail.author)님이 작성했습니다."
        }
    }
}
