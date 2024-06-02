package team1.issuetracker.domain.Issue.ref;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Table("ISSUE_HAS_ASSIGNEE")
@Getter
@ToString
@AllArgsConstructor
public class UserRefId {
    private int sequence;
    @Column("ASSIGNEE_ID")
    private String userId;
}