package team1.issuetracker.domain.Issue;

import java.util.List;

public interface IssueFilterRepository {

    List<Issue> findAllByKeyword(String query);
}
