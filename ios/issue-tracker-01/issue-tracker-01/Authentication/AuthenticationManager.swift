//
//  AuthenticationManager.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/29/24.
//

import Foundation

class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    func loginUser(with userRequest: UserRequest, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        NetworkManager.shared.loginUser(userRequest: userRequest) { result in
            switch result {
            case .success(let token):
                KeychainManager.shared.saveToken(token, for: "authToken")
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func registerUser(with userRequest: UserRequest, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        NetworkManager.shared.registerUser(userRequest: userRequest, completion: completion)
    }
    
    func verifyUserId(_ id: String, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        let request = UserRequest(id: id, nickname: nil, password: nil)
        NetworkManager.shared.verifyUserId(idRequest: request, completion: completion)
    }
}
