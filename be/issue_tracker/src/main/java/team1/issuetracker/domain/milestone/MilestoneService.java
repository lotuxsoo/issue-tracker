package team1.issuetracker.domain.milestone;

import java.util.Date;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import team1.issuetracker.domain.Issue.Issue;
import team1.issuetracker.domain.milestone.dto.MilestoneInfo;
import team1.issuetracker.domain.milestone.dto.MilestoneMakeRequest;
import team1.issuetracker.domain.milestone.dto.MilestoneShowResponse;
import team1.issuetracker.domain.milestone.dto.MilestoneListResponse;
import team1.issuetracker.domain.user.auth.Authorizable;
import team1.issuetracker.domain.user.auth.AuthorizeException;

@Service
public class MilestoneService implements Authorizable<Milestone, Long> {

    private final MilestoneRepository milestoneRepository;

    @Autowired
    public MilestoneService(MilestoneRepository milestoneRepository) {
        this.milestoneRepository = milestoneRepository;
    }

    public List<MilestoneListResponse> getList() {
        List<Milestone> milestones = (List<Milestone>) milestoneRepository.findAll();
        return milestones.stream().map(MilestoneListResponse::of).toList();
    }

    public List<MilestoneInfo> getMilestoneInfo() {
        List<Milestone> milestones = (List<Milestone>) milestoneRepository.findAll();
        return milestones.stream().map(milestone -> new MilestoneInfo(milestone.getId(), milestone.getName())).collect(
                Collectors.toList());
    }

    public MilestoneShowResponse getMilestoneAtIssue(Issue issue) {
        Long milestoneId = issue.getMilestoneId();
        if (milestoneId == null) {
            return null;
        }

        Milestone milestone = milestoneRepository.findById(milestoneId).get();
        return new MilestoneShowResponse(milestoneId, milestone.getName());
    }

    public Milestone createMilestone(String name, String description, Date deadline, String userId) {
        Milestone milestone = Milestone.builder().name(name).description(description).deadline(deadline).userId(userId).build();
        return milestoneRepository.save(milestone);
    }

    public void deleteMilestone(Long id, String userId) {
        milestoneRepository.delete(authorize(id, userId));
    }

    public Milestone updateMilestone(MilestoneMakeRequest milestoneMakeRequest, Long id, String userId) {
        Milestone origin = authorize(id, userId);
        String name = milestoneMakeRequest.name();
        String description = milestoneMakeRequest.description();
        Date deadline = milestoneMakeRequest.deadline();

        Milestone updateMilestone = Milestone.builder()
                .id(origin.getId())
                .name(name)
                .description(description)
                .issues(origin.getIssues())
                .deadline(deadline)
                .userId(userId)
                .createdAt(origin.getCreatedAt())
                .build();

        milestoneRepository.save(updateMilestone);

        return getMilestoneById(id);
    }

    @Override
    public Milestone authorize(Long milestoneId, String userId) {
        Milestone milestone = getMilestoneById(milestoneId);
        if (milestone.getUserId().equals(userId)) {
            throw new AuthorizeException(milestoneId + "번 마일스톤에 대한 권한이 없습니다.");
        }

        return milestone;
    }

    private Milestone getMilestoneById(long id) {
        Optional<Milestone> optionalMilestone = milestoneRepository.findById(id);
        if (optionalMilestone.isEmpty()) {
            throw new NoSuchElementException("존재하지 않는 마일스톤 입니다.");
        }

        return optionalMilestone.get();
    }
}