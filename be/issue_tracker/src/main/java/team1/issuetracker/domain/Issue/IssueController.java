package team1.issuetracker.domain.Issue;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.NoSuchElementException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import team1.issuetracker.domain.Issue.dto.IssueListResponse;
import team1.issuetracker.domain.Issue.dto.IssueMakeRequest;
import team1.issuetracker.domain.Issue.dto.IssueShowResponse;
import team1.issuetracker.domain.comment.CommentService;
import team1.issuetracker.domain.comment.dto.CommentPostRequest;
import team1.issuetracker.domain.label.LabelService;
import team1.issuetracker.domain.milestone.MilestoneService;
import team1.issuetracker.domain.user.UserService;
import team1.issuetracker.domain.user.auth.Authenticator;

@RequestMapping("/issue")
@Slf4j
@RestController
public class IssueController {
    private final IssueService issueService;
    private final CommentService commentService;
    private final LabelService labelService;
    private final MilestoneService milestoneService;
    private final UserService userService;
    private final Authenticator authenticator;

    @Autowired
    public IssueController(IssueService issueService, CommentService commentService, LabelService labelService,
                           MilestoneService milestoneService, UserService userService, Authenticator authenticator) {
        this.issueService = issueService;
        this.commentService = commentService;
        this.labelService = labelService;
        this.milestoneService = milestoneService;
        this.userService = userService;
        this.authenticator = authenticator;
    }

    @GetMapping("/{id}")
    public IssueShowResponse showIssue(@PathVariable("id") Long id) {
        log.debug("Show issue.{} detail", id);
        Issue issue = issueService.showIssue(id);
        String authorName = userService.getNameById(issue.getUserId());

        return IssueShowResponse.of(
                issue,
                authorName,
                userService.getAssigneeNameAtIssue(issue),
                labelService.getLabelsAyIssue(issue),
                milestoneService.getMilestoneAtIssue(issue),
                commentService.getCommentsAtIssue(issue.getId()));
    }

    @GetMapping("/list")
    public List<IssueListResponse> openIssues() {
        log.debug("Show Open issue list");
        List<Issue> openIssues = issueService.getOpenIssues();

        return openIssues.stream().map(issue -> IssueListResponse.of(
                        issue,
                        commentService.getFirstCommentTextAtIssue(issue),
                        labelService.getLabelsAyIssue(issue),
                        milestoneService.getMilestoneAtIssue(issue)))
                .toList();
    }

    @PostMapping
    public IssueShowResponse createIssue(@RequestBody IssueMakeRequest issueMakeRequest, HttpServletRequest httpServletRequest) {
        log.debug("Create issue with \n{}" , issueMakeRequest);

        String userId= authenticator.authenticate(httpServletRequest);
        Issue issue = Issue.from(issueMakeRequest, userId);
        Issue saved = issueService.createIssue(issue);

        String comment = issueMakeRequest.getComment();
        commentService.addComment(saved.getId(), userId, new CommentPostRequest(saved.getId(),comment));

        return showIssue(saved.getId());
    }

    @PostMapping("/{id}/close")
    public long closeIssue(@PathVariable("id") Long id, HttpServletRequest httpServletRequest) throws NoSuchElementException, IllegalStateException {
        log.debug("Close issue.{}", id);
        String userId = authenticator.authenticate(httpServletRequest);
        return issueService.closeIssue(id,userId);
    }

    @PostMapping("/multi/close")
    public void closeMultiIssue(@RequestBody List<Long> issueIds, HttpServletRequest httpServletRequest) throws RuntimeException {
        log.debug("Close all issues.{}", issueIds);
        String userId = authenticator.authenticate(httpServletRequest);
        issueService.closeIssues(issueIds, userId);
    }

    @DeleteMapping("/{id}")
    public void deleteIssue(@PathVariable("id") Long id, HttpServletRequest httpServletRequest) {
        log.debug("Delete issue.{}", id);
        String userId = authenticator.authenticate(httpServletRequest);
        issueService.deleteIssue(id, userId);
    }
}