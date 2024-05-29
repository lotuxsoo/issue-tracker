//
//  IssueDetailMoreViewController.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/26/24.
//

import UIKit

protocol IssueDetailViewControllerDelegate: AnyObject {
    func didCompleteTask()
}

class IssueDetailMoreViewController: UIViewController {
    
    static let identifier: String = "IssueDetailMoreViewController"
    
    weak var delegate: IssueDetailViewControllerDelegate?
    
    var issueModel: IssueModel!
    var issueId: Int?
    private var selectedLabels: [LabelResponse] = []
    private var selectedMilestone: CurrentMilestone?
    
    @IBOutlet weak var firstContentView: UIView!
    @IBOutlet weak var secondContentView: UIView!
    
    @IBOutlet weak var labelCollectionView: UICollectionView!
    @IBOutlet weak var milestoneCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstContentView.layer.cornerRadius = 12
        secondContentView.layer.cornerRadius = 12
        setupCollectionView()
        fetchIssueDetail()
        setupNavigationBar()
        registerForNotifications()
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleIssueUpdated),
                                               name: IssueModel.Notifications.issueUpdated,
                                               object: nil
        )
    }
    
    @objc private func handleIssueUpdated(notification: Notification) {
        if let updatedIssueDetail = notification.object as? IssueDetailResponse {
            selectedLabels = updatedIssueDetail.labels
            selectedMilestone = updatedIssueDetail.milestone
        }
        
        self.labelCollectionView.reloadData()
        self.milestoneCollectionView.reloadData()
    }
    
    private func setupCollectionView() {
        labelCollectionView.register(UINib(nibName: LabelCell.identifier, bundle: .main), forCellWithReuseIdentifier: LabelCell.identifier)
        milestoneCollectionView.register(UINib(nibName: MilestoneCollectionViewCell.identifier, bundle: .main), forCellWithReuseIdentifier: MilestoneCollectionViewCell.identifier)
        
        labelCollectionView.dataSource = self
        labelCollectionView.delegate = self
        milestoneCollectionView.dataSource = self
        milestoneCollectionView.delegate = self
    }
    
    private func fetchIssueDetail() {
        if let issueDetail = issueModel.issueDetail {
            selectedLabels = issueDetail.labels
            labelCollectionView.reloadData()
            guard let milestone = issueDetail.milestone else {
                return
            }
            selectedMilestone = milestone
            milestoneCollectionView.reloadData()
        }
    }
    
    private func setupNavigationBar() {
        let leftLabel: UILabel = {
            let label = UILabel()
            label.text = "이슈 상세"
            label.applyStyle(fontManager: FontManager(weight: .semibold, size: .large), textColor: .gray900)
            return label
        }()
        
        let leftItem = UIBarButtonItem(customView: leftLabel)
        navigationItem.leftBarButtonItem = leftItem
        
        let dismissButton: UIBarButtonItem = {
            let button = UIButton(type: .system)
            button.setTitle("닫기", for: .normal)
            button.titleLabel?.applyStyle(fontManager: FontManager(weight: .semibold, size: .large), textColor: .myBlue)
            button.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
            return UIBarButtonItem(customView: button)
        }()
        
        navigationItem.rightBarButtonItem = dismissButton
    }
    
    @objc private func dismissButtonTapped() {
        self.dismiss(animated: true)
    }

    @IBAction func editButtonTapped(_ sender: Any) {
        let issueEditorVC = IssueEditorViewController(nibName: IssueEditorViewController.identifier, bundle: nil)
        issueEditorVC.issueModel = self.issueModel
        issueEditorVC.issueId = self.issueId
        issueEditorVC.isEditingMode = true
        
        let navigationController = UINavigationController(rootViewController: issueEditorVC)
        navigationController.modalPresentationStyle = .fullScreen
        
        self.present(navigationController, animated: true)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        guard let issueId = issueId else { return }
        self.issueModel.closeIssue(issueId: issueId) { [weak self] success in
            if success {
                NotificationCenter.default.post(name: IssueModel.Notifications.issueUpdated, object: self)
                self?.dismiss(animated: true, completion: {
                    self?.delegate?.didCompleteTask()
                })
            } else {
                self?.showAlert(message: "이슈 닫기에 실패하였습니다.")
            }
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        guard let issueId = issueId else { return }
        self.issueModel.deleteIssue(issueId: issueId) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: IssueModel.Notifications.issueUpdated, object: self)
                    self?.dismiss(animated: true, completion: {
                        self?.delegate?.didCompleteTask()
                    })
                }
            } else {
                self?.showAlert(message: "이슈 삭제에 실패하였습니다.")
            }
        }
    }
}

extension IssueDetailMoreViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == labelCollectionView {
            return selectedLabels.count
        } else if collectionView == milestoneCollectionView {
            return selectedMilestone != nil ? 1 : 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == labelCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelCell.identifier, for: indexPath) as? LabelCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: selectedLabels[indexPath.item])
            return cell
        } else if collectionView == milestoneCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MilestoneCollectionViewCell.identifier, for: indexPath) as? MilestoneCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            if let milestone = selectedMilestone {
                cell.configure(with: milestone)
            }
            return cell
        }
        return UICollectionViewCell()
    }
}

extension IssueDetailMoreViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label: UILabel = {
            let label = UILabel()
            label.font = FontManager(weight: .medium, size: .small).font
            return label
        }()
        
        let padding: CGFloat = 20.0
        
        if collectionView == labelCollectionView {
            let labelData = selectedLabels[indexPath.row]
            label.text = labelData.name
            let width = label.intrinsicContentSize.width + padding
            return CGSize(width: width, height: 24)
        } else if collectionView == milestoneCollectionView {
            if let milestone = selectedMilestone {
                label.text = milestone.title
                let width = label.intrinsicContentSize.width + padding
                return CGSize(width: width, height: 24)
            }
        }
        return CGSize(width: 0, height: 0)
    }
}
