package team1.issuetracker.domain.Issue;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

@Repository
public class IssueFilterRepositoryImpl implements IssueFilterRepository{

    @Autowired
    private JdbcTemplate jdbcTemplate;
    @Override
    public List<Issue> findAllByKeyword(String query) {
        return jdbcTemplate.query(query, new IssueRowMapper());
    }

    private static class IssueRowMapper implements RowMapper<Issue>{

        @Override
        public Issue mapRow(ResultSet rs, int rowNum) throws SQLException {
            return Issue.builder()
                .id(rs.getLong("id"))
                .userId(rs.getString("user_id"))
                .milestoneId(rs.getLong("milestone_id"))
                .title(rs.getString("title"))
                .status(IssueStatus.valueOf(rs.getString("status")))
                .lastModifiedAt(rs.getObject("last_modified_at", LocalDateTime.class))
                .createdAt(rs.getObject("created_at", LocalDateTime.class))
                .build();
        }
    }
}
