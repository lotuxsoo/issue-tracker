//
//  UIViewController+Extensions.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/13/24.
//

import UIKit

extension UIViewController {
    func createSwipeAction(title: String, color: UIColor, image: UIImage?, style: UIContextualAction.Style, handler: @escaping (UIContextualAction, UIView, @escaping (Bool) -> Void) -> Void) -> UIContextualAction {
        let action = UIContextualAction(style: style, title: title, handler: handler)
        action.backgroundColor = color

        action.image = image
        
        return action
    }
    
    func showAlert(title: String = "알림", message: String, buttonTitle: String = "확인", handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default, handler: handler)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func showErrorAlert(for error: NetworkError) {
        var message: String
        
        switch error {
        case .invalidURL:
            message = "유효하지 않은 URL입니다."
        case .jsonEncodingFailed:
            message = "JSON 인코딩에 실패했습니다."
        case .networkFailed(let err):
            message = "네트워크 오류: \(err.localizedDescription)"
        case .noData:
            message = "데이터가 없습니다."
        case .invalidResponse(let statusCode):
            message = "유효하지 않은 응답: \(statusCode)"
        case .jsonDecodingFailed:
            message = "JSON 디코딩에 실패했습니다."
        case .serverError(let errorMessage):
            message = "서버 오류: \(errorMessage)"
        case .unauthorized:
            message = "허가받지 않은 토큰입니다."
        }
        
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
}
