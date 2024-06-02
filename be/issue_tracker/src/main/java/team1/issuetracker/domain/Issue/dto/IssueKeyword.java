package team1.issuetracker.domain.Issue.dto;

import java.util.List;
import team1.issuetracker.domain.Issue.IssueStatus;

public record IssueKeyword(
    String title,
    String author,
    IssueStatus status,
    List<String> assignees,
    List<Long> labelsId,
    Long milestoneId
) {}
