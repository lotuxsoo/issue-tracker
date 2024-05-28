package team1.issuetracker.domain.Issue.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import team1.issuetracker.domain.Issue.Issue;
import team1.issuetracker.domain.Issue.IssueStatus;
import team1.issuetracker.domain.Issue.ref.UserRefId;
import team1.issuetracker.domain.Issue.ref.LabelRefId;
import team1.issuetracker.domain.user.User;

import java.util.List;
import java.util.Set;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

@Getter
@AllArgsConstructor
public class IssueMakeRequest {
    private String title;
    private String comment;
    private List<String> assigneeIds;
    private List<Long> labelIds;
    private Long milestoneId;

    public Issue toIssue(String userId) {
        AtomicInteger index = new AtomicInteger(1);

        Set<UserRefId> issueAssignees = assigneeIds.stream()
                .map(assigneeId -> new UserRefId(index.getAndIncrement(), assigneeId))
                .collect(Collectors.toSet());

        Set<LabelRefId> issueHasLabel = labelIds.stream().map(labelId -> new LabelRefId(index.getAndIncrement(), labelId))
                .collect(Collectors.toSet());

        return Issue.builder()
                .userId(userId)
                .title(title)
                .issueHasLabel(issueHasLabel)
                .issueAssignees(issueAssignees)
                .milestoneId(milestoneId)
                .status(IssueStatus.OPEN)
                .build();
    }
}