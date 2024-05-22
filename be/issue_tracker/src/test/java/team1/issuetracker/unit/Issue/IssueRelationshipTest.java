package team1.issuetracker.unit.Issue;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.data.jdbc.DataJdbcTest;
import org.springframework.transaction.annotation.Transactional;
import team1.issuetracker.domain.Issue.Issue;
import team1.issuetracker.domain.Issue.IssueRepository;
import team1.issuetracker.domain.comment.CommentRepository;
import team1.issuetracker.domain.user.UserRepository;

import javax.sql.DataSource;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@DataJdbcTest
public class IssueRelationshipTest {

    @Autowired
    private DataSource dataSource;

    @Autowired
    IssueRepository issueRepository;
    @Autowired
    UserRepository userRepository;
    @Autowired
    CommentRepository commentRepository;

    @DisplayName("keyword filter test")
    @Test
    void filterTest() {
        //given
        String keyowrd = "label:Discussion label:BE author:test1";

        issueRepository.findAll();
    }

    @DisplayName("작성자 ID와 제목만 전달하여 새 이슈를 저장할 수 있다.")
    @Test
    @Transactional
    void saveEmptyIssue() {
        // given
        Issue issue = Issue.makeOnlyIssue("test", "제목");

        // when
        issueRepository.save(issue);
        List<Issue> byId = (List<Issue>) issueRepository.findAll();

        //then
        assertThat(byId).hasSize(1);
        Issue found = byId.get(0);
        assertThat(found.getTitle()).isEqualTo("제목");
        assertThat(found.getUserId()).isEqualTo("test");
    }
}
