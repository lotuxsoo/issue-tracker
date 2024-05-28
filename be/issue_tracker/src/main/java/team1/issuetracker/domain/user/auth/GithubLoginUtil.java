package team1.issuetracker.domain.user.auth;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
@RequiredArgsConstructor
public class GithubLoginUtil {
    private final RestTemplate restTemplate;
    @Value("${github.client_secret}")
    private String clientSecret;
    @Value("${github.client_id}")
    private String clientId;

    public String validateCode(String code) {
        OAuthMemberInfoResponse userInfo = getUserInfo(getAccessToken(code));
        return userInfo.id() + "\n" +  userInfo.name() + "\n" + userInfo.profileImage();
    }

    private OAuthMemberInfoResponse getUserInfo(String accessToken) {
        String url = "https://api.github.com/user";

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        HttpEntity<Void> request = new HttpEntity<>(headers);

        return restTemplate.exchange(
                url,
                HttpMethod.GET,
                request,
                OAuthMemberInfoResponse.class
        ).getBody();
    }

    private String getAccessToken(String code) {
        String url = "https://github.com/login/oauth/access_token";

        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE);
        HttpEntity<OAuthAccessTokenRequest> requestEntity = new HttpEntity<>(new OAuthAccessTokenRequest(clientId, clientSecret, code), headers);

        OAuthAccessTokenResponse body = restTemplate.exchange(url, HttpMethod.POST, requestEntity, OAuthAccessTokenResponse.class).getBody();
        return body.accessToken();
    }
}
