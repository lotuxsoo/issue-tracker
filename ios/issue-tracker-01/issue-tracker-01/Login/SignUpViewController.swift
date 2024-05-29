//
//  SignUpViewController.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/29/24.
//

import UIKit

class SignUpViewController: UIViewController {
    
    static let identifier: String = "SignUpViewController"

    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    private var isAvailable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "회원가입"
        configureFont()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func configureFont() {
        self.nicknameLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .large), textColor: .gray800)
        self.idLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .large), textColor: .gray800)
        self.passwordLabel.applyStyle(fontManager: FontManager(weight: .medium, size: .large), textColor: .gray800)
    }
    
    private func configureNavigationBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTapped() {
        navigationController?.dismiss(animated: true)
    }

    @IBAction func verifyButtonTapped(_ sender: Any) {
        guard let id = idTextField.text, !id.isEmpty, id.count >= 6 && id.count <= 16 else {
            showAlert(message: "아이디는 6자리에서 16자리까지 입력해주세요.")
            return
        }
        
        AuthenticationManager.shared.verifyUserId(id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    if result {
                        self?.showAlert(message: "이미 사용 중인 아이디입니다.")
                        self?.isAvailable = false
                    } else {
                        self?.showAlert(message: "사용 가능한 아이디입니다.")
                        self?.isAvailable = true
                    }
                case .failure(let error):
                    self?.showAlert(message: "중복확인 실패입니다: \(error.localizedDescription)")
                    self?.isAvailable = false
                }
            }
        }
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        guard let id = idTextField.text, !id.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let nickName = nicknameTextField.text, !nickName.isEmpty else {
            self.showAlert(message: "모든 필드를 작성해주세요.")
            return
        }
        
        guard id.count >= 6 && id.count <= 16 else {
            self.showAlert(message: "아이디는 6자리에서 16자리까지 입력해주세요.")
            return
        }
        
        guard password.count >= 6 && password.count <= 12 else {
            self.showAlert(message: "비밀번호는 6자리에서 12자리까지 입력해주세요.")
            return
        }
        
        let userRequest = UserRequest(id: id, nickname: nickName, password: password)
        
        if isAvailable {
            AuthenticationManager.shared.registerUser(with: userRequest) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        self?.showAlert(message: "회원가입이 완료되었습니다.") { _ in
                            self?.dismiss(animated: true)
                        }
                    case .failure(let error):
                        self?.showAlert(message: "회원가입이 실패하였습니다: \(error)")
                    }
                }
            }
        } else {
            self.showAlert(message: "아이디 중복확인을 해주세요.")
            return
        }
    }
}
