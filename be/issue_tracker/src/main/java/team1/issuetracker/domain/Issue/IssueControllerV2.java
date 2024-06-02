package team1.issuetracker.domain.Issue;

import lombok.extern.slf4j.Slf4j;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import team1.issuetracker.domain.ApiResponse;
import team1.issuetracker.domain.user.auth.annotation.Authenticate;
import team1.issuetracker.domain.user.auth.annotation.AuthenticatedUserId;

import java.util.List;

@RequestMapping("/v2/issue")
@RestController
@Slf4j
@RequiredArgsConstructor
public class IssueControllerV2 {
    private final IssueService issueService;

    @Authenticate
    @PostMapping(value = "/multi/close")
    public ApiResponse<List<Long>> closeMultiIssue(@RequestBody List<Long> issueIds, @AuthenticatedUserId String userId) throws RuntimeException {
        log.debug("Close all issues.{}", issueIds);
        return ApiResponse.of(issueService.closeIssues(issueIds, userId));
    }
}
