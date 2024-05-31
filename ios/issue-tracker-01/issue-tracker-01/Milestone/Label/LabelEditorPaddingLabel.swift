//
//  LabelEditorPaddingLabel.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/21/24.
//

import UIKit

class LabelEditorPaddingLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override func draw(_ rect: CGRect) {
        super.draw(rect.inset(by: textInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.width += textInsets.left + textInsets.right
        contentSize.height += textInsets.top + textInsets.bottom
        return contentSize
    }
}
