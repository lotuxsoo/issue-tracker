//
//  ViewController.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/7/24.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var githubView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         setupView()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setupView() {
        self.loginButton.layer.cornerRadius = 20
        self.githubView.layer.cornerRadius = 22
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let id = idTextField.text, !id.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            self.showAlert(message: "ID와 비밀번호를 입력해주세요")
            return
        }
        
        let userRequest = UserRequest(id: id, nickname: nil, password: password)
        AuthenticationManager.shared.loginUser(with: userRequest) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.navigateToMainInterface()
                case .failure(let error):
                    self?.showAlert(message: "로그인 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        let signUpVC = SignUpViewController(nibName: SignUpViewController.identifier, bundle: nil)
        
        let navigationController = UINavigationController(rootViewController: signUpVC)
        present(navigationController, animated: true)
    }
    
    @IBAction func appleButtonTapped(_ sender: Any) {
        print("애플 로그인")
    }
    
    @IBAction func githubButtonTapped(_ sender: Any) {
        print("깃허브 로그인")
    }
    
    private func navigateToMainInterface() {
        if let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController {
            UIView.transition(with: self.view.window!, duration: 0.5, options: .transitionFlipFromRight, animations: {
                self.view.window?.rootViewController = tabBarVC
            }, completion: nil)
        }
    }
}
