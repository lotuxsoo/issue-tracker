package team1.issuetracker.domain.Issue;

import java.time.LocalDateTime;
import java.util.Set;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.relational.core.mapping.MappedCollection;
import org.springframework.data.relational.core.mapping.Table;
import team1.issuetracker.domain.Issue.ref.UserRefId;
import team1.issuetracker.domain.Issue.ref.LabelRefId;

@Table("ISSUE")
@Getter
@Builder
@ToString
@Slf4j
@AllArgsConstructor
public class Issue {
    @Id
    private Long id;
    private String userId;
    private Long milestoneId;
    private String title;
    @MappedCollection(idColumn = "ISSUE_ID")
    private Set<LabelRefId> issueHasLabel;
    @MappedCollection(idColumn = "ISSUE_ID")
    private Set<UserRefId> issueAssignees;
    private IssueStatus status;

    @LastModifiedDate
    private LocalDateTime lastModifiedAt;
    @CreatedDate
    private LocalDateTime createdAt;

    public void setStatus(IssueStatus status) {
        this.status = status;
    }

    public static Issue makeOnlyIssue(String authorId, String title) {
        return Issue.builder()
                .userId(authorId)
                .title(title)
                .status(IssueStatus.OPEN)
                .build();
    }
}