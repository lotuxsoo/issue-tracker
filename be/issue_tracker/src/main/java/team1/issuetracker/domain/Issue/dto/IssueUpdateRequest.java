package team1.issuetracker.domain.Issue.dto;

import team1.issuetracker.domain.Issue.Issue;
import team1.issuetracker.domain.Issue.IssueStatus;
import team1.issuetracker.domain.Issue.ref.UserRefId;
import team1.issuetracker.domain.Issue.ref.LabelRefId;

import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

public record IssueUpdateRequest(String title , List<String> assigneeIds,  List<Long> labelIds, Long milestoneId) {

    public Issue toIssue(Issue origin){
        AtomicInteger index = new AtomicInteger(1);

        return Issue.builder()
                .id(origin.getId())
                .title(title)
                .userId(origin.getUserId())
                .issueAssignees(assigneeIds.stream().map(id -> new UserRefId(index.getAndIncrement(), id)).collect(Collectors.toSet()))
                .issueHasLabel(labelIds.stream().map(id -> new LabelRefId(index.incrementAndGet(), id)).collect(Collectors.toSet()))
                .milestoneId(milestoneId)
                .status(IssueStatus.OPEN)
                .createdAt(origin.getCreatedAt())
                .build();
    }
}
