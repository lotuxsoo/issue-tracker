package team1.issuetracker.domain.comment;

import org.springframework.web.bind.annotation.*;
import team1.issuetracker.domain.comment.dto.CommentListResponse;
import team1.issuetracker.domain.comment.dto.CommentPostRequest;
import team1.issuetracker.domain.user.UserService;
import team1.issuetracker.domain.user.auth.annotation.Authenticate;
import team1.issuetracker.domain.user.auth.annotation.AuthenticatedUserId;
import team1.issuetracker.domain.user.auth.exception.AuthorizeException;

import java.util.NoSuchElementException;


@RestController
public class CommentController {
    private final CommentService commentService;
    private final UserService userService;

    public CommentController(CommentService commentService, UserService userService) {
        this.commentService = commentService;
        this.userService = userService;
    }

    @Authenticate
    @PostMapping("/comment")
    public CommentListResponse createComment(@RequestBody CommentPostRequest commentInfo, @AuthenticatedUserId String userId) {
        return CommentListResponse.of(commentService.addComment(commentInfo.issueId(), userId, commentInfo), userService.getNameById(userId));
    }

    @Authenticate
    @PatchMapping("/comment/{id}")
    public CommentListResponse updateComment(@PathVariable long id, @RequestBody CommentPostRequest commentInfo,
                                             @AuthenticatedUserId String userId) throws NoSuchElementException, AuthorizeException {
        return CommentListResponse.of(commentService.updateComment(id, userId, commentInfo), userService.getNameById(userId));
    }

    @Authenticate
    @DeleteMapping("/comment/{id}")
    public void deleteComment(@PathVariable long id, @AuthenticatedUserId String userId)
            throws NoSuchElementException, AuthorizeException {
        commentService.deleteComment(id, userId);
    }

    @Authenticate
    @PostMapping("/comment/{id}/like")
    public int likeComment(@PathVariable long id, @AuthenticatedUserId String userId) {
        return commentService.likeComment(userId, id);
    }

    @Authenticate
    @PostMapping("/comment/{id}/unlike")
    public int unLikeComment(@PathVariable long id, @AuthenticatedUserId String userId) {
        return commentService.unlikeComment(userId, id);
    }
}