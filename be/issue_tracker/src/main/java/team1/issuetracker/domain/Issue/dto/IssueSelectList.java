package team1.issuetracker.domain.Issue.dto;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class IssueSelectList {
    private List<String> assigneeIds;
    private List<Long> labelIds;
    private List<Long> milestoneId;
}
