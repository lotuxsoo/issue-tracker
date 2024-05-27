//
//  EditorOptionDataSource.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/27/24.
//

import UIKit

class EditorOptionDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var options: [OptionType]?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditorOptionLabelCell.identifier, for: indexPath) as? EditorOptionLabelCell else {
            return UICollectionViewCell()
        }
        
        if let option = options?[indexPath.item] {
            cell.setLabel(with: option)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let option = options?[indexPath.item] else {
            return CGSize(width: 0, height: 0)
        }
        
        let label = UILabel()
        let padding: CGFloat = 20
        label.applyStyle(fontManager: FontManager(weight: .medium, size: .small), textColor: .gray50)
        label.text = option.displayText
        
        let width = label.intrinsicContentSize.width + padding
        return CGSize(width: width, height: 24.0)
    }
}
