//
//  MilestoneModel.swift
//  issue-tracker-01
//
//  Created by 조호근 on 5/22/24.
//

import Foundation
import Combine

protocol MilestoneManaging {
    var milestonesPublisher: Published<[MilestoneResponse]>.Publisher { get }
    var milestoneDeleted: AnyPublisher<Int, Never> { get }
    var count: Int { get }
    
    func item(at index: Int) -> MilestoneResponse?
    func fetchMilestones()
    func createMilestone(_ milestoneRequest: MilestoneRequest)
    func updateMilestone(at index: Int, milestoneRequest: MilestoneRequest)
    func deleteMilestone(at index: Int)
}

class MilestoneModel: MilestoneManaging {
    @Published private(set) var milestones: [MilestoneResponse] = []
    var milestonesPublisher: Published<[MilestoneResponse]>.Publisher { $milestones }
    
    private var milestoneDeletedSubject = PassthroughSubject<Int, Never>()
    
    var milestoneDeleted: AnyPublisher<Int, Never> {
        return milestoneDeletedSubject.eraseToAnyPublisher()
    }
    
    var count: Int {
        return milestones.count
    }
    
    func item(at index: Int) -> MilestoneResponse? {
        guard index >= 0 && index < milestones.count else { return nil }
        return milestones[index]
    }
    
    func fetchMilestones() {
        NetworkManager.shared.fetchMilestones { [weak self] milestones in
            DispatchQueue.main.async {
                self?.milestones = milestones ?? []
            }
        }
    }
    
    func createMilestone(_ milestoneRequest: MilestoneRequest) {
        NetworkManager.shared.createMilestone(milestone: milestoneRequest) { [weak self] success, milestone in
            if success, let milestone = milestone {
                DispatchQueue.main.async {
                    self?.milestones.append(milestone)
                }
            }
        }
    }
    
    func updateMilestone(at index: Int, milestoneRequest: MilestoneRequest) {
        let milestoneId = milestones[index].id
        
        NetworkManager.shared.updateMilestone(milestoneId: milestoneId, milestoneRequest: milestoneRequest) { [weak self] success, updatedMilestone in
            if success, let updatedMilestone = updatedMilestone {
                DispatchQueue.main.async {
                    self?.milestones[index] = updatedMilestone
                }
            }
        }
    }
    
    func deleteMilestone(at index: Int) {
        let milestoneId = milestones[index].id
        
        NetworkManager.shared.deleteMilestone(milestoneId: milestoneId) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.milestones.remove(at: index)
                    self?.milestoneDeletedSubject.send(index)
                }
            }
        }
    }
}
