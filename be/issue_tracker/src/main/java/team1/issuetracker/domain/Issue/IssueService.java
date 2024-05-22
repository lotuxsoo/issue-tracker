package team1.issuetracker.domain.Issue;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.relational.core.conversion.DbActionExecutionException;
import org.springframework.stereotype.Service;

import java.util.*;

import team1.issuetracker.domain.Issue.dto.IssueUpdateRequest;
import team1.issuetracker.domain.ResultWithError;
import team1.issuetracker.domain.user.auth.Authorizable;
import team1.issuetracker.domain.user.auth.exception.AuthorizeException;

import static team1.issuetracker.domain.Issue.IssueStatus.CLOSE;

@Service
public class IssueService implements Authorizable<Issue, Long> {

    private final IssueRepository issueRepository;

    @Autowired
    public IssueService(IssueRepository issueRepository) {
        this.issueRepository = issueRepository;
    }

    public List<Issue> getOpenIssues(String keyword) {
        if(keyword != null && !keyword.isEmpty()){
            parsingKeyword(keyword);
            // 키워드가 널이 아니고 비어있지 않으면 실행
            return issueRepository.findAllByStatus(IssueStatus.CLOSE);
        }
        return issueRepository.findAllByStatus(IssueStatus.OPEN);
    }

    public Issue showIssue(Long id) throws NoSuchElementException {
        return getIssueById(id);
    }

    public Issue createIssue(Issue issue) {
        Issue saved;

        try {
            saved = issueRepository.save(issue);
        } catch (DbActionExecutionException notExistsLabel){
            throw new IllegalArgumentException("유효하지 않은 이슈 등록 요청 : 유저, 라벨, 마일스톤을 다시 확인하세요.");
        }

        return saved;
    }

    public Issue updateIssue(Long issueId, IssueUpdateRequest updateRequest, String userId) {
        Issue origin = authorize(issueId, userId);
        return issueRepository.save(updateRequest.toIssue(origin));
    }

    public long closeIssue(Long id, String userId) throws NoSuchElementException {
        Issue issue = authorize(id,userId);
        if (issue.getStatus() == CLOSE) throw new IllegalStateException(id + "번 이슈는 이미 닫힌 상태입니다!");

        issue.setStatus(CLOSE);
        issueRepository.save(issue);
        return id;
    }

    public void deleteIssue(Long id, String userId) throws NoSuchElementException {
        issueRepository.delete(authorize(id, userId));
    }

    public Issue getIssueById(Long id) throws NoSuchElementException {
        Optional<Issue> optionalIssue = issueRepository.findById(id);
        if (optionalIssue.isEmpty()) {
            throw new NoSuchElementException(id + "번 이슈가 존재하지 않습니다!");
        }

        return optionalIssue.get();
    }

    public ResultWithError<List<Long>> closeIssues(List<Long> issueIds, String userId) {
        List<Long> result = new ArrayList<>();
        StringJoiner exceptionMessages = new StringJoiner("\n");
        issueIds.forEach(id -> {
            try {
                closeIssue(id, userId);
                result.add(id);
            } catch (RuntimeException exception) {
                exceptionMessages.add(exception.getMessage());
            }
        });
        return new ResultWithError<>(result, exceptionMessages.toString());
    }

    private Map<String, String> parsingKeyword(String keyword) {
        Map<String,String> keywordMap =new HashMap<>();

        String[] tokens = keyword.split(" "); //여기까지 하면 들어온 값을 파싱
        //ex) label:be label:bug milestone:Feature-2 author:eddy

        return keywordMap;
    }

    @Override
    public Issue authorize(Long issueId, String userId) {
        Issue issue = getIssueById(issueId);
        if(!issue.getUserId().equals(userId)) throw new AuthorizeException(issueId + "번 이슈에 대한 권한이 없습니다");

        return issue;
    }
}
