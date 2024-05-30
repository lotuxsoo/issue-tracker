package team1.issuetracker.domain.Issue;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import team1.issuetracker.domain.Issue.dto.*;

import team1.issuetracker.domain.comment.CommentService;
import team1.issuetracker.domain.comment.dto.CommentPostRequest;
import team1.issuetracker.domain.label.LabelService;
import team1.issuetracker.domain.milestone.MilestoneService;
import team1.issuetracker.domain.user.UserService;
import team1.issuetracker.domain.user.auth.annotation.Authenticate;
import team1.issuetracker.domain.user.auth.annotation.AuthenticatedUserId;

import java.util.List;
import java.util.NoSuchElementException;

@RequestMapping("/issue")
@Slf4j
@RestController
public class IssueController {
    private final IssueService issueService;
    private final CommentService commentService;
    private final LabelService labelService;
    private final MilestoneService milestoneService;
    private final UserService userService;

    @Autowired
    public IssueController(IssueService issueService, CommentService commentService, LabelService labelService,
                           MilestoneService milestoneService, UserService userService) {
        this.issueService = issueService;
        this.commentService = commentService;
        this.labelService = labelService;
        this.milestoneService = milestoneService;
        this.userService = userService;
    }

    @GetMapping("/{id}")
    public IssueShowResponse showIssue(@PathVariable("id") Long id) {
        log.debug("Show issue.{} detail", id);
        Issue issue = issueService.showIssue(id);
        String authorName = userService.getNameById(issue.getUserId());

        return getDetailOf(issue, authorName);
    }

    @GetMapping("/list")
    public List<IssueListResponse> getOpenIssues() {
        log.debug("Show Open issue list");
        List<Issue> openIssues = issueService.getOpenIssues();

        return openIssues.stream().map(this::getPreviewOf).toList();
    }

    @GetMapping("/filter")
    public List<IssueListResponse> getFilterIssues(@RequestBody IssueKeyword issueKeyword) {
        log.debug("Show keyword issue list");

        List<Issue> openIssues = issueService.getKeywordIssues(issueKeyword);

        return openIssues.stream().map(this::getPreviewOf).toList();
    }

    @Authenticate
    @PostMapping
    public IssueListResponse createIssue(@RequestBody IssueMakeRequest issueMakeRequest, @AuthenticatedUserId String userId) {
        log.debug("Create issue with \n{}", issueMakeRequest);

        Issue issue = issueMakeRequest.toIssue(userId);
        Issue saved = issueService.createIssue(issue);

        String comment = issueMakeRequest.getComment();
        commentService.addComment(saved.getId(), userId, new CommentPostRequest(saved.getId(), comment));

        return getPreviewOf(issue);
    }

    @Authenticate
    @PatchMapping("/{id}")
    public IssueUpdateResponse updateIssue(@PathVariable Long id, @RequestBody IssueUpdateRequest issueUpdateRequest, @AuthenticatedUserId String userId) {
        log.debug("Update issue with \n{}", issueUpdateRequest);

        Issue updated = issueService.updateIssue(id, issueUpdateRequest, userId);
        return new IssueUpdateResponse(getPreviewOf(updated) , showIssue(updated.getId()));
    }

    @Authenticate
    @PostMapping("/{id}/close")
    public long closeIssue(@PathVariable("id") Long id, @AuthenticatedUserId String userId) throws NoSuchElementException, IllegalStateException {
        log.debug("Close issue.{}", id);
        return issueService.closeIssue(id, userId);
    }

    @Authenticate
    @PostMapping("/multi/close")
    public void closeMultiIssue(@RequestBody List<Long> issueIds, @AuthenticatedUserId String userId) throws RuntimeException {
        log.debug("Close all issues.{}", issueIds);
        issueService.closeIssues(issueIds, userId);
    }

    @Authenticate
    @DeleteMapping("/{id}")
    public void deleteIssue(@PathVariable("id") Long id, @AuthenticatedUserId String userId) {
        log.debug("Delete issue.{}", id);
        issueService.deleteIssue(id, userId);
    }

    private IssueListResponse getPreviewOf(Issue issue) {
        return IssueListResponse.of(
                issue,
                commentService.getFirstCommentTextAtIssue(issue),
                labelService.getLabelsAyIssue(issue),
                milestoneService.getMilestoneAtIssue(issue));
    }

    private IssueShowResponse getDetailOf(Issue issue, String authorName) {
        return IssueShowResponse.of(
                issue,
                authorName,
                userService.getAssigneeInfoAtIssue(issue),
                labelService.getLabelsAyIssue(issue),
                milestoneService.getMilestoneAtIssue(issue),
                commentService.getCommentsAtIssue(issue.getId()));
    }
}
