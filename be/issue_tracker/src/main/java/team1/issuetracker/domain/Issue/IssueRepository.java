package team1.issuetracker.domain.Issue;

import org.springframework.data.jdbc.repository.query.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import team1.issuetracker.util.repository.FindWithFilter;

@Repository
public interface IssueRepository extends CrudRepository<Issue, Long>, FindWithFilter<Issue> {
    List<Issue> findAllByStatus(IssueStatus status);
}
