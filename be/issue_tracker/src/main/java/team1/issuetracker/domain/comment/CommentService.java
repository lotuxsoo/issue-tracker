package team1.issuetracker.domain.comment;

import org.springframework.data.relational.core.conversion.DbActionExecutionException;
import org.springframework.stereotype.Service;
import team1.issuetracker.domain.Issue.Issue;
import team1.issuetracker.domain.Issue.IssueService;
import team1.issuetracker.domain.comment.dto.CommentListResponse;
import team1.issuetracker.domain.comment.dto.CommentPostRequest;
import team1.issuetracker.domain.user.UserService;
import team1.issuetracker.domain.user.auth.Authorizable;
import team1.issuetracker.domain.user.auth.exception.AuthorizeException;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.function.Predicate;

@Service
public class CommentService implements Authorizable<Comment, Long> {
    private final CommentRepository commentRepository;
    private final IssueService issueService;
    private final UserService userService;

    public CommentService(CommentRepository commentRepository, IssueService issueService, UserService userService) {
        this.commentRepository = commentRepository;
        this.issueService = issueService;
        this.userService = userService;
    }

    public List<CommentListResponse> getCommentsAtIssue(long issueId) {
        List<Comment> comments = commentRepository.findAllByIssueId(issueId);

        return comments.stream()
                .map(comment -> CommentListResponse.of(comment, userService.getNameById(comment.getUserId()))
                ).toList();
    }

    public Comment addComment(long issueId, String userId, CommentPostRequest request) throws NoSuchElementException {
        issueService.getIssueById(issueId);
        Comment newComment = Comment.makeOnlyComment(issueId, userId, request.content());
        return commentRepository.save(newComment);
    }

    public int likeComment(String userId, long commentId) {
        Comment comment = getCommentById(commentId);
        List<Like> likes = comment.getLikes();
        likes.add(Like.of(userId, commentId));

        try {
            commentRepository.save(comment);
        } catch (DbActionExecutionException fail) {
            throw new IllegalStateException("이미 좋아요 하신 댓글입니다");
        }

        return likes.size();
    }

    public int unlikeComment(String userId, long commentId) {
        Comment comment = getCommentById(commentId);
        List<Like> likes = comment.getLikes();

        Optional<Like> optionalLike = likes.stream()
                .filter(isSame(userId, commentId))
                .findAny();

        Like like = optionalLike.orElseThrow(() -> new IllegalStateException("좋아요 한 댓글에만 좋아요 취소할 수 있습니다."));
        likes.remove(like);
        commentRepository.save(comment);

        return likes.size();
    }

    public String getFirstCommentTextAtIssue(Issue issue) {
        Comment firstAtIssue = commentRepository.findFirstAtIssue(issue.getId());
        if (firstAtIssue == null) return null;

        return firstAtIssue.getContent();
    }

    public Comment updateComment(long id, String userId, CommentPostRequest commentInfo) throws NoSuchElementException, AuthorizeException {
        Comment origin = authorize(id, userId);
        Comment newComment = Comment.makeOnlyComment(origin.getIssueId(), userId, commentInfo.content());
        commentRepository.save(newComment);
        return getCommentById(id);
    }

    public void deleteComment(Long commentId, String userId) throws NoSuchElementException, AuthorizeException {
        commentRepository.delete(authorize(commentId, userId));
    }

    @Override
    public Comment authorize(Long commentId, String userId) throws NoSuchElementException{
        Comment comment = getCommentById(commentId);
        if(!comment.getUserId().equals(userId)) throw new AuthorizeException(commentId + "번 댓글에 대한 권한이 없습니다");

        return comment;
    }

    private Comment getCommentById(long commentId) {
        Optional<Comment> byId = commentRepository.findById(commentId);
        if (byId.isEmpty()) throw new NoSuchElementException("존재하지 않는 댓글입니다");

        return byId.get();
    }

    private Predicate<Like> isSame(String userId, long commentId) {
        return like -> like.getCommentId().equals(commentId) && like.getUserId().equals(userId);
    }
}
