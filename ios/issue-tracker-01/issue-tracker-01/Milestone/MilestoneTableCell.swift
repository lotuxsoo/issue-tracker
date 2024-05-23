//
//  MilestoneTableCell.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/22/24.
//

import UIKit

class MilestoneTableCell: UITableViewCell {

    static let identifier: String = "MilestoneTableCell"
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var completionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var openCountsLabel: UILabel!
    @IBOutlet weak var closedCountsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureFont()
    }
    
    private func configureFont() {
        self.nameLabel.applyStyle(fontManager: FontManager(weight: .semibold, size: .large), textColor: .gray900)
        self.completionLabel.applyStyle(fontManager: FontManager(weight: .semibold, size: .large), textColor: .myBlue)
        self.descriptionLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .medium), textColor: .gray800)
        self.openCountsLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .small), textColor: .gray700)
        self.closedCountsLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .small), textColor: .gray700)
    }
    
    func setMilestone(_ data: MilestoneResponse) {
        self.nameLabel.text = data.name
        self.completionLabel.text = "\(data.completion)%"
        self.descriptionLabel.text = data.description
        self.deadlineLabel.text = data.deadline
        self.openCountsLabel.text = "\(data.openCounts)"
        self.closedCountsLabel.text = "\(data.closedCounts)"
    }
}
