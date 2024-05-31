//
//  ProfileController.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/9/24.
//

import UIKit

class ProfileController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    let userProfile = UserProfileModel.shared.getUserProfile()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        idLabel.text = userProfile?.id
        nicknameLabel.text = userProfile?.nickname
        imageView.layer.cornerRadius = 120
        
        setupConfigure()
    }
    
    func setupConfigure() {
        guard let gifURL = Bundle.main.url(forResource: "animation", withExtension: "gif"),
              let gifData = try? Data(contentsOf: gifURL),
              let source = CGImageSourceCreateWithData(gifData as CFData, nil) else { return }
        
        let frameCount = CGImageSourceGetCount(source)
        var images = [UIImage]()
        
        for number in 0..<frameCount {
            if let image = CGImageSourceCreateImageAtIndex(source, number, nil) {
                images.append(UIImage(cgImage: image))
            }
        }
        
        imageView.animationImages = images
        imageView.animationDuration = TimeInterval(frameCount) * 0.05
        imageView.animationRepeatCount = 0
        imageView.startAnimating()
    }
}
