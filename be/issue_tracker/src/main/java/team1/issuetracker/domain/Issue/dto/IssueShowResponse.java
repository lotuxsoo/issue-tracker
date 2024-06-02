package team1.issuetracker.domain.Issue.dto;

import java.time.LocalDateTime;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Getter;
import team1.issuetracker.domain.Issue.Issue;
import team1.issuetracker.domain.Issue.IssueStatus;
import team1.issuetracker.domain.comment.dto.CommentListResponse;
import team1.issuetracker.domain.label.dto.LabelListResponse;
import team1.issuetracker.domain.milestone.dto.MilestoneShowResponse;
import team1.issuetracker.domain.user.dto.AssigneeInfo;

@Getter
@AllArgsConstructor
public class IssueShowResponse {
    private Long id;
    private String title;
    private String author;
    private LocalDateTime lastModifiedAt;
    private IssueStatus status;
    private List<AssigneeInfo> assignees;
    private List<LabelListResponse> labels;
    private MilestoneShowResponse milestone;
    private List<CommentListResponse> comments;

    public static IssueShowResponse of(Issue issue,
                                       String authorName,
                                       List<AssigneeInfo> assignees,
                                       List<LabelListResponse> labels,
                                       MilestoneShowResponse milestone,
                                       List<CommentListResponse> comments) {

        return new IssueShowResponse(
                issue.getId(),
                issue.getTitle(),
                authorName,
                issue.getLastModifiedAt(),
                issue.getStatus(),
                assignees,
                labels,
                milestone,
                comments
        );
    }
}