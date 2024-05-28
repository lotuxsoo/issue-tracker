package team1.issuetracker.domain.user.auth;

import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;

@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public record OAuthAccessTokenRequest(String clientId, String clientSecret, String code) {
}
