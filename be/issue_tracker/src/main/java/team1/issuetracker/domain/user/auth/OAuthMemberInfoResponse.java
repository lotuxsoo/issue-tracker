package team1.issuetracker.domain.user.auth;

import com.fasterxml.jackson.annotation.JsonProperty;

public record OAuthMemberInfoResponse(
        @JsonProperty("login") String id,
        @JsonProperty("avatar_url") String profileImage,
        String name
        )

{
}
