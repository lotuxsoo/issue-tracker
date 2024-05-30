package team1.issuetracker.domain.comment;

import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.relational.core.mapping.MappedCollection;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Table("COMMENT")
@Getter
@Builder
@ToString
@EqualsAndHashCode
@AllArgsConstructor
public class Comment {
    @Id
    @Generated
    private Long id;
    private Long issueId;
    private String userId;
    private String content;
    @MappedCollection(idColumn = "COMMENT_ID", keyColumn = "ID")
    private List<CommentFile> files;
    @MappedCollection(idColumn = "COMMENT_ID", keyColumn = "ID")
    private List<Like> likes;

    @LastModifiedDate
    private LocalDateTime lastModifiedAt;
    @CreatedDate
    private LocalDateTime createdAt;

    public String getContent() {
        return content;
    }

    public int getLikeCount() {
        return likes.size();
    }

    public static Comment makeOnlyComment(Long issueId, String userId, String content) {
        return Comment.builder()
                .issueId(issueId)
                .userId(userId)
                .content(content)
                .files(new ArrayList<>()).
                build();
    }
}
