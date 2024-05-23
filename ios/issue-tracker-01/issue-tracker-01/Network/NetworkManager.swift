//
//  NetworkManager.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/13/24.
//

import Foundation
import os

class NetworkManager {
    
    enum NetworkError: Error {
        case invalidURL
        case unknown
    }
    
    static let shared = NetworkManager()
    private let httpManager: HTTPManagerProtocol
    
    private let token = Bundle.main.object(forInfoDictionaryKey: "API_ACCESS_TOKEN") as? String
    
    init(httpManager: HTTPManagerProtocol = HTTPManager.shared) {
        self.httpManager = httpManager
    }
    
    func fetchSelectedOption<T: Codable>(from endpoint: APIEndpoint, decodingType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: URLDefines.select + endpoint.urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        let request = URLRequest(url: url)
        
        httpManager.sendRequest(request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NetworkError.unknown))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                self.prettyPrintJSON(decodedData)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchIssues(completion: @escaping ([Issue]?) -> Void) {
        guard let url = URL(string: URLDefines.issueList) else {
            completion(nil)
            return
        }
        print(url)
        let request = URLRequest(url: url)
        
        httpManager.sendRequest(request) { data, _, error in
            guard let data = data, error == nil else {
                os_log("[ fetchIssues ] : \(String(describing: error))")
                completion(nil)
                return
            }
            
            do {
                let issues = try JSONDecoder().decode([Issue].self, from: data)
                self.prettyPrintJSON(issues)
                completion(issues)
            } catch {
                os_log("[ fetchIssues ] : \(error)")
                completion(nil)
            }
        }
    }
    
    func fetchIssueDetail(issueId: Int, completion: @escaping (IssueDetailResponse?) -> Void) {
        guard let url = URL(string: URLDefines.issue + "/\(issueId)") else {
            completion(nil)
            return
        }
        let request = URLRequest(url: url)
        
        httpManager.sendRequest(request) { data, _, error in
            guard let data = data, error == nil else {
                os_log("[ fetchIssueDetail ] : \(String(describing: error))")
                completion(nil)
                return
            }
            
            do {
                let issueDetail = try JSONDecoder().decode(IssueDetailResponse.self, from: data)
                self.prettyPrintJSON(issueDetail)
                completion(issueDetail)
                return
            } catch {
                os_log("[ fetchIssueDetail ] : \(error)")
                completion(nil)
            }
        }
    }
    
    func deleteIssue(issueId: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: URLDefines.issue + "/\(issueId)") else {
            completion(false)
            return
        }
        guard let token = token else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.delete.rawValue
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        httpManager.sendRequest(request) { _, response, error in
            guard let response = response, (200..<300).contains(response.statusCode) else {
                os_log("[ deleteIssue ] : \(String(describing: error))")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func closeIssue(issueId: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: URLDefines.issue + "/\(issueId)/close") else {
            completion(false)
            return
        }
        guard let token = token else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        httpManager.sendRequest(request) { _, response, error in
            guard let response = response, (200..<300).contains(response.statusCode) else {
                os_log("[ closeIssue ] : \(String(describing: error))\n\(String(describing: response?.statusCode))")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func createIssue(issueCreationRequest: IssueCreationRequest, completion: @escaping (Bool, IssueDetailResponse?) -> Void) {
        guard let url = URL(string: URLDefines.issue) else {
            completion(false, nil)
            return
        }
        guard let token = token else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(issueCreationRequest)
            request.httpBody = jsonData
        } catch {
            os_log("[ createIssue ]: \(error)")
            completion(false, nil)
            return
        }
        
        httpManager.sendRequest(request) { data, response, error in
            guard let data = data, error == nil,
                  let response = response, (200..<300).contains(response.statusCode) else {
                os_log("[ createIssue ] : \(String(describing: error?.localizedDescription))\n[ statusCode ]: \(String(describing: response?.statusCode))")
                
                completion(false, nil)
                return
            }
            
            do {
                let decodedIssue = try JSONDecoder().decode(IssueDetailResponse.self, from: data)
                completion(true, decodedIssue)
            } catch {
                os_log("[ createIssue ] : \(String(describing: error))")
                completion(false, nil)
            }
        }
    }
    
    func fetchLabels(completion: @escaping ([LabelResponse]?) -> Void) {
        guard let url = URL(string: URLDefines.labelList) else {
            completion(nil)
            return
        }
        let request = URLRequest(url: url)
        
        httpManager.sendRequest(request) { data, _, error in
            guard let data = data, error == nil else {
                os_log("[ fetchLabels ] : \(String(describing: error))")
                completion(nil)
                return
            }
            
            do {
                let labels = try JSONDecoder().decode([LabelResponse].self, from: data)
                self.prettyPrintJSON(labels)
                completion(labels)
            } catch {
                os_log("[ fetchLabels ]: \(error)")
                completion(nil)
            }
        }
    }
    
    func deleteLabel(labelId: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: URLDefines.label + "/\(labelId)") else {
            completion(false)
            return
        }
        guard let token = token else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.delete.rawValue
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        httpManager.sendRequest(request) { _, response, error in
            guard let response = response, (200..<300).contains(response.statusCode) else {
                os_log("[ deleteLabel ] : \(String(describing: error))\n\(String(describing: response?.statusCode))")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func updateLabel(labelId: Int, labelRequest: LabelRequest, completion: @escaping (Bool, LabelResponse?) -> Void) {
        guard let url = URL(string: URLDefines.label + "/\(labelId)") else {
            completion(false, nil)
            return
        }
        guard let token = token else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.patch.rawValue
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(labelRequest)
            request.httpBody = jsonData
        } catch {
            os_log("[ updateLabel ]: \(error)")
            completion(false, nil)
            return
        }
        
        httpManager.sendRequest(request) { data, response, error in
            guard let data = data, error == nil,
                  let response = response, (200..<300).contains(response.statusCode) else {
                os_log("[ updateLabel ] : \(String(describing: error?.localizedDescription))\n[ statusCode ]: \(String(describing: response?.statusCode))")
                
                completion(false, nil)
                return
            }
            
            do {
                let decodedLabel = try JSONDecoder().decode(LabelResponse.self, from: data)
                completion(true, decodedLabel)
            } catch {
                os_log("[ updateLabel ] : \(error)")
                completion(false, nil)
            }
        }
    }
    
    func createLabel(label: LabelRequest, completion: @escaping (Bool, LabelResponse?) -> Void) {
        guard let url = URL(string: URLDefines.label) else {
            completion(false, nil)
            return
        }
        guard let token = token else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(label)
            request.httpBody = jsonData
        } catch {
            os_log("[ createLabel ]: \(error)")
            completion(false, nil)
            return
        }
        
        httpManager.sendRequest(request) { data, response, error in
            guard let data = data, error == nil,
                  let response = response, (200..<300).contains(response.statusCode) else {
                os_log("[ createLabel ] : \(String(describing: error?.localizedDescription))\n[ statusCode ]: \(String(describing: response?.statusCode))")
                
                completion(false, nil)
                return
            }
            do {
                let decodedLabel = try JSONDecoder().decode(LabelResponse.self, from: data)
                completion(true, decodedLabel)
            } catch {
                os_log("[ createLabel ] : \(String(describing: error))")
                completion(false, nil)
            }
        }
    }
    
    func fetchMilestones(completion: @escaping ([MilestoneResponse]?) -> Void) {
        guard let url = URL(string: URLDefines.milestoneList) else {
            completion(nil)
            return
        }
        let request = URLRequest(url: url)
        
        httpManager.sendRequest(request) { data, _, error in
            guard let data = data, error == nil else {
                os_log("[ fetchMilestones ] : \(String(describing: error))")
                completion(nil)
                return
            }
            
            do {
                let milestones = try JSONDecoder().decode([MilestoneResponse].self, from: data)
                self.prettyPrintJSON(milestones)
                completion(milestones)
            } catch {
                os_log("[ fetchMilestones ]: \(error)")
                completion(nil)
            }
        }
    }
    
    func deleteMilestone(milestoneId: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: URLDefines.milestone + "/\(milestoneId)") else {
            completion(false)
            return
        }
        guard let token = token else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.delete.rawValue
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        httpManager.sendRequest(request) { _, response, error in
            guard let response = response, (200..<300).contains(response.statusCode) else {
                os_log("[ deleteMilestone ] : \(String(describing: error))\n\(String(describing: response?.statusCode))")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func updateMilestone(milestoneId: Int, milestoneRequest: MilestoneRequest, completion: @escaping (Bool, MilestoneResponse?) -> Void) {
        guard let url = URL(string: URLDefines.milestone + "/\(milestoneId)") else {
            completion(false, nil)
            return
        }
        guard let token = token else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.patch.rawValue
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(milestoneRequest)
            request.httpBody = jsonData
        } catch {
            os_log("[ updateMilestone ]: \(error)")
            completion(false, nil)
            return
        }
        
        httpManager.sendRequest(request) { data, response, error in
            guard let data = data, error == nil,
                  let response = response, (200..<300).contains(response.statusCode) else {
                os_log("[ updateMilestone ] : \(String(describing: error?.localizedDescription))\n[ statusCode ]: \(String(describing: response?.statusCode))")
                
                completion(false, nil)
                return
            }
            
            do {
                let decodedMilestone = try JSONDecoder().decode(MilestoneResponse.self, from: data)
                completion(true, decodedMilestone)
            } catch {
                os_log("[ updateMilestone ] : \(error)")
                completion(false, nil)
            }
        }
    }
    
    func createMilestone(milestone: MilestoneRequest, completion: @escaping (Bool, MilestoneResponse?) -> Void) {
        guard let url = URL(string: URLDefines.milestone) else {
            completion(false, nil)
            return
        }
        guard let token = token else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(milestone)
            request.httpBody = jsonData
        } catch {
            os_log("[ createMilestone ]: \(error)")
            completion(false, nil)
            return
        }
        
        httpManager.sendRequest(request) { data, response, error in
            guard let data = data, error == nil,
                  let response = response, (200..<300).contains(response.statusCode) else {
                os_log("[ createMilestone ] : \(String(describing: error?.localizedDescription))\n[ statusCode ]: \(String(describing: response?.statusCode))")
                
                completion(false, nil)
                return
            }
            
            do {
                let decodedMilestone = try JSONDecoder().decode(MilestoneResponse.self, from: data)
                completion(true, decodedMilestone)
            } catch {
                os_log("[ createMilestone ] : \(String(describing: error))")
                completion(false, nil)
            }
        }
    }
    
    private func prettyPrintJSON<T: Encodable>(_ item: T) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try encoder.encode(item)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            os_log("[ prettyPrintJSON ] : \(error)")
        }
    }
}
