package team1.issuetracker.util.repository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import team1.issuetracker.domain.Issue.dto.IssueKeyword;
@Slf4j
public class QueryMaker {
    public static Query getQuery(IssueKeyword issueKeyword){ // 동적쿼리를 만들어 보자고!!
        Criteria criteria = Criteria.where("status").is(issueKeyword.status().name());

        if (issueKeyword.title() != null){//제목으로 찾기
            criteria = criteria.and("title").like("%" + issueKeyword.title() + "%");
        }
        if (issueKeyword.author() != null) {//내가 작성한 글로 찾기
            criteria = criteria.and("user_id").is(issueKeyword.author());
        }
        if (issueKeyword.milestoneId() != null) {//마일스톤 아이디로 찾기
            criteria = criteria.and("milestone_id").is(issueKeyword.milestoneId());
        }

        Query query = Query.query(criteria);
        return query;
    }

    public static StringBuilder getDynamicQuery(IssueKeyword issueKeyword) {
        StringBuilder sb = new StringBuilder("SELECT i.*, ia.id, il.id FROM ISSUE i ");

        sb.append("LEFT JOIN ISSUE_HAS_ASSIGNEE ia ON i.id = ia.issue_id ");
        sb.append("LEFT JOIN ISSUE_HAS_LABEL il ON i.id = il.issue_id ");

        boolean hasPreviousCondition = false;

        if (issueKeyword.status() != null) {
            sb.append("WHERE i.status = '").append(issueKeyword.status()).append("' ");
            hasPreviousCondition = true;
        }

        if (issueKeyword.title() != null) {
            if (hasPreviousCondition) {
                sb.append("AND ");
            } else {
                sb.append("WHERE ");
                hasPreviousCondition = true;
            }
            sb.append("i.title LIKE '%").append(issueKeyword.title()).append("%' ");
        }

        if (issueKeyword.author() != null) {
            if (hasPreviousCondition) {
                sb.append("AND ");
            } else {
                sb.append("WHERE ");
                hasPreviousCondition = true;
            }
            sb.append("i.user_id = '").append(issueKeyword.author()).append("' ");
        }

        if (issueKeyword.milestoneId() != null) {
            if (hasPreviousCondition) {
                sb.append("AND ");
            } else {
                sb.append("WHERE ");
                hasPreviousCondition = true;
            }
            sb.append("i.milestone_id = ").append(issueKeyword.milestoneId()).append(" ");
        }

        if (issueKeyword.labelsId() != null && !issueKeyword.labelsId().isEmpty()) {
            if (hasPreviousCondition) {
                sb.append("AND ");
            } else {
                sb.append("WHERE ");
            }
            sb.append("il.label_id IN (");
            for (int i = 0; i < issueKeyword.labelsId().size(); i++) {
                sb.append("'").append(issueKeyword.labelsId().get(i)).append("'");
                if (i < issueKeyword.labelsId().size() - 1) {
                    sb.append(", ");
                }
            }
            sb.append(") ");
        }

        return sb;
    }

}
