package team1.issuetracker.domain.user.auth;

import com.fasterxml.jackson.annotation.JsonProperty;

public record OAuthAccessTokenResponse(
        @JsonProperty("access_token")
        String accessToken,
        int expiresIn,
        String refreshToken,
        int refreshTokenExpiresIn,
        String scope,
        @JsonProperty("token_type")
        String tokenType
)
{ }
