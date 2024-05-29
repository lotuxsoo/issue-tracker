//
//  KeychainManager.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/29/24.
//

import KeychainAccess
import os

class KeychainManager {
    static let shared = KeychainManager()
    private let keychain = Keychain(service: "pro.issue-tracker-01")
    
    func saveToken(_ token: String, for key: String) {
        do {
            try keychain.set(token, key: key)
        } catch {
            os_log("[ saveToken ]: \(error)")
        }
    }
    
    func getToken(for key: String) -> String? {
        return try? keychain.get(key)
    }
}
