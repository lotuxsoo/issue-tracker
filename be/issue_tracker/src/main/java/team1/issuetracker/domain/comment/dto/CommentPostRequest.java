package team1.issuetracker.domain.comment.dto;

import team1.issuetracker.domain.comment.Comment;

import java.util.ArrayList;

public record CommentPostRequest (Long issueId, String content){

    public Comment toComment(String author){
        return Comment.builder()
                .issueId(issueId)
                .content(content)
                .userId(author)
                .likes(new ArrayList<>())
                .files(new ArrayList<>())
                .build();
    }

    public Comment toUpdate(Comment origin){
        return Comment.builder()
                .id(origin.getId())
                .issueId(issueId)
                .content(content)
                .userId(origin.getUserId())
                .likes(origin.getLikes())
                .files(origin.getFiles())
                .createdAt(origin.getCreatedAt())
                .build();
    }
}
