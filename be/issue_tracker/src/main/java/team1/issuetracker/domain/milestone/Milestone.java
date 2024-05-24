package team1.issuetracker.domain.milestone;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.Set;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Generated;
import lombok.Getter;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.MappedCollection;
import org.springframework.data.relational.core.mapping.Table;
import team1.issuetracker.domain.Issue.Issue;
import team1.issuetracker.domain.Issue.IssueStatus;

@Table("MILESTONE")
@Getter
@Builder
@AllArgsConstructor
public class Milestone {
    @Id
    @Generated
    private Long id;
    private String name;
    private String description;
    @MappedCollection(idColumn = "MILESTONE_ID")
    private Set<Issue> issues;
    private LocalDate deadline;
    private String userId;
    @CreatedDate
    private LocalDateTime createdAt;

    public int getOpenIssueCount() {
        return (int) issues.stream().filter(issue -> issue.getStatus() == IssueStatus.OPEN).count();
    }

    public int getClosedIssueCount() {
        return (int) issues.stream().filter(issue -> issue.getStatus() == IssueStatus.CLOSE).count();
    }

    public int getCompletionPercentage() {
        int total = issues.size();
        if (total == 0) {
            return 0;
        }
        return (int) ((double) getClosedIssueCount() / total * 100);
    }
}
