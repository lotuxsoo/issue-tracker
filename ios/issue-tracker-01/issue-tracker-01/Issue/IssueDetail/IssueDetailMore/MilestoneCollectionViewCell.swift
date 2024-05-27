//
//  MilestoneCollectionViewCell.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/27/24.
//

import UIKit

class MilestoneCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MilestoneCollectionViewCell"
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.containerView.layer.cornerRadius = 12
        self.containerView.clipsToBounds = true
        titleLabel.backgroundColor = .gray900
        configureFont()
    }
    
    private func configureFont() {
        self.titleLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .small), textColor: .gray50)
    }
    
    func configure(with milestone: CurrentMilestone) {
        self.titleLabel.text = milestone.title
    }
}
