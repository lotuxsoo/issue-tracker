package team1.issuetracker.domain.Issue.ref;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;
import org.springframework.data.relational.core.mapping.Table;

@Table("ISSUE_HAS_LABEL")
@Getter
@ToString
@AllArgsConstructor
public class LabelRefId {
    private int sequence;
    private Long labelId;
}