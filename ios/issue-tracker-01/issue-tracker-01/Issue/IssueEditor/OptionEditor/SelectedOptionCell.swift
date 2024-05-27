//
//  SelectedOptionCell.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/23/24.
//

import UIKit

class SelectedOptionCell: UITableViewCell {

    static let identifier: String = "SelectedOptionCell"
    
    @IBOutlet weak var titleLabel: LabelEditorPaddingLabel!
    @IBOutlet weak var circleImage: UIImageView!
    
    var isOptionSelected: Bool = false {
        didSet {
            updateCircleImage()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.layer.cornerRadius = 12
        titleLabel.clipsToBounds = true
        configureFont()
        titleLabel.backgroundColor = .gray900
    }

    private func configureFont() {
        self.titleLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .small), textColor: .gray50)
    }
    
    private func updateCircleImage() {
        circleImage.image = isOptionSelected ? UIImage(systemName: "multiply.circle.fill")?.withTintColor(.gray600, renderingMode: .alwaysOriginal) : UIImage(systemName: "plus.circle")
    }
    
    func configureCell(with option: OptionType, isSelected: Bool) {
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
        
        isOptionSelected = isSelected
    }
}
