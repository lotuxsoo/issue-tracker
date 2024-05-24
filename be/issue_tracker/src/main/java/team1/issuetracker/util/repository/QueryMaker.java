package team1.issuetracker.util.repository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import team1.issuetracker.domain.Issue.dto.IssueKeyword;
@Slf4j
public class QueryMaker {
    public static Query getQuery(IssueKeyword issueKeyword) {
        log.debug(issueKeyword.getStatus().name());
        Criteria criteria = Criteria.where("status").is(issueKeyword.getStatus().name());

        if (issueKeyword.getTitle() != null){
            criteria = criteria.and("title").like("%" + issueKeyword.getTitle() + "%");
        }
        if (issueKeyword.getAuthor() != null) {
            criteria = criteria.and("user_id").is(issueKeyword.getAuthor());
        }
        if (issueKeyword.getMilestoneTitle() != null) {
            criteria = criteria.and("milestone_id").is(Long.parseLong(issueKeyword.getMilestoneTitle()));
        }

        Query query = Query.query(criteria);
        return query;
    }
}
