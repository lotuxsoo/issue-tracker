//
//  EditorOptionCell.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/17/24.
//

import UIKit

class EditorOptionCell: UITableViewCell {
    
    static let identifier: String = "EditorOptionCell"
    
    private var options: [OptionType]? = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleLabel.text = nil
    }
    
    private func setupCollectionView() {
        self.collectionView.register(
            UINib(nibName: "EditorOptionLabelCell", bundle: .main),
            forCellWithReuseIdentifier: EditorOptionLabelCell.identifier
        )
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            UIView.animate(withDuration: 0.1,
                           animations: {
                self.contentView.transform = CGAffineTransform(scaleX: 1.015, y: 1.015)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    self.contentView.transform = CGAffineTransform.identity
                }
            })
        }
    }
    
    func configureTitle(title: String) {
        self.titleLabel.text = title
    }
    
    func configureOptions(options: [OptionType]?) {
        self.options = options
        self.collectionView.reloadData()
    }
}

extension EditorOptionCell: UICollectionViewDataSource, UICollectionViewDelegate {
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
}

extension EditorOptionCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let option = options?[indexPath.item] else {
            return CGSize(width: 0, height: 0)
        }
        
        let label = UILabel()
        let padding: CGFloat = 20
        label.applyStyle(fontManager: FontManager(weight: .bold, size: .medium), textColor: .gray50)
        label.text = option.displayText
        
        let width = label.intrinsicContentSize.width + padding
        return CGSize(width: width, height: 24)
    }
}
