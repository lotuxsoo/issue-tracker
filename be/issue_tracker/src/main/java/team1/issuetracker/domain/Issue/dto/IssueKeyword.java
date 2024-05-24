package team1.issuetracker.domain.Issue.dto;

import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.ToString;
import team1.issuetracker.domain.Issue.IssueStatus;
@Getter
@ToString
@AllArgsConstructor
public class IssueKeyword {
    private String title;
    private String author;
    private IssueStatus status;
    private List<String> labelsTitle;
    private String milestoneTitle;
}
