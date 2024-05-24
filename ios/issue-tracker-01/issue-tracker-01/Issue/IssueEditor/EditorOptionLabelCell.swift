//
//  EditorOptionLabelCell.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/24/24.
//

import UIKit

class EditorOptionLabelCell: UICollectionViewCell {
    
    static let identifier: String = "EditorOptionLabelCell"
    
    @IBOutlet weak var titleLabel: LabelEditorPaddingLabel!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.containerView.layer.cornerRadius = 12
        self.containerView.clipsToBounds = true
        configureFont()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleLabel.text = nil
        self.titleLabel.textColor = .gray50
        self.titleLabel.backgroundColor = .gray900
    }
    
    private func configureFont() {
        self.titleLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .small), textColor: .gray50)
        self.titleLabel.backgroundColor = .gray900
    }
    
    func setLabel(with option: OptionType) {
        switch option {
        case .assignee(let assignee):
            titleLabel.text = assignee.name
        case .label(let label):
            let color = UIColor(hex: label.color)
            titleLabel.text = label.name
            titleLabel.backgroundColor = color
            titleLabel.textColor = color.isDarkColor ? .gray50 : .gray900
        case .milestone(let milestone):
            titleLabel.text = milestone.title
        }
    }
}
