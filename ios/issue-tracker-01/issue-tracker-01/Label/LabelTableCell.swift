//
//  LabelTableCell.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/17/24.
//

import UIKit

class LabelTableCell: UITableViewCell {

    static let identifier: String = "LabelTableCell"
    
    @IBOutlet weak var nameLabel: LabelEditorPaddingLabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = .systemBackground
        self.nameLabel.layer.cornerRadius = 12
        self.nameLabel.clipsToBounds = true
        configureFont()
    }
    
    private func configureFont() {
        self.nameLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .small), textColor: .gray50)
        self.descriptionLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .medium), textColor: .gray800)
    }
    
    func configure(with label: LabelResponse) {
        let color = UIColor(hex: label.color)
        
        self.nameLabel.text = label.name
        self.nameLabel.backgroundColor = color
        self.nameLabel.textColor = color.isDarkColor ? .gray50 : .gray900
        self.descriptionLabel.text = label.description
    }
}
