//
//  IssueTableCell.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/13/24.
//

import UIKit

class IssueTableCell: UITableViewCell {

    static let identifier: String = "IssueTableCell"
    
    private var lables: [LabelResponse]?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var milestoneLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureFont()
        setupCollectionView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        descriptionLabel.text = nil
        milestoneLabel.text = nil
    }
    
    private func setupCollectionView() {
        self.collectionView.register(
            UINib(nibName: "labelCell", bundle: .main),
            forCellWithReuseIdentifier: LabelCell.identifier
        )
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    private func configureFont() {
        self.titleLabel.applyStyle(
            fontManager: FontManager(weight: .bold, size: .large),
            textColor: .gray900
        )
        self.descriptionLabel.applyStyle(
            fontManager: FontManager(weight: .regular, size: .medium),
            textColor: .gray800
        )
        self.milestoneLabel.applyStyle(
            fontManager: FontManager(weight: .regular, size: .medium),
            textColor: .gray800
        )
    }
    
    func setIssue(_ data: Issue) {
        self.titleLabel.text = data.title
        self.descriptionLabel.text = data.comment
        self.milestoneLabel.text = data.milestone?.title
        
        if let labels = data.labels {
            setData(labels)
        }
    }
    
    private func setData(_ data: [LabelResponse]?) {
        self.lables = data
        self.collectionView.reloadData()
    }
}

extension IssueTableCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lables?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelCell.identifier, for: indexPath) as? LabelCell else {
            return UICollectionViewCell() }
        
        if let data = self.lables?[indexPath.item] {
            
            cell.setLabel(data)
        }
        
        return cell
    }
}

extension IssueTableCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let tmpLabel: UILabel = UILabel()
        let padding: CGFloat = 40
        tmpLabel.applyStyle(fontManager: FontManager(weight: .bold, size: .medium), textColor: .gray50)
        tmpLabel.text = lables?[indexPath.item].name
        return CGSize(width: tmpLabel.intrinsicContentSize.width + padding, height: 24)
    }
}
