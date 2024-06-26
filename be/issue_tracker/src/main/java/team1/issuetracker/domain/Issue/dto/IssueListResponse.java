package team1.issuetracker.domain.Issue.dto;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Getter;
import team1.issuetracker.domain.Issue.Issue;
import team1.issuetracker.domain.label.dto.LabelListResponse;
import team1.issuetracker.domain.milestone.dto.MilestoneShowResponse;

@Getter
@AllArgsConstructor
public class IssueListResponse {
    private long id;
    private String title;
    private String comment;
    private List<LabelListResponse> labels;
    private MilestoneShowResponse milestone;

    public static IssueListResponse of(Issue issue , String comment, List<LabelListResponse> labels, MilestoneShowResponse milestone){
        return new IssueListResponse(
                issue.getId(),
                issue.getTitle(),
                comment,
                labels,
                milestone
        );
    }
}