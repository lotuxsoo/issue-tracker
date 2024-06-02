package team1.issuetracker.domain.user.auth;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import team1.issuetracker.domain.user.auth.exception.AuthenticateException;

@Component
public class JwtAuthenticator implements Authenticator{

    private final JwtUtil jwtUtil;
    private final String AUTHORIZE_HEADER = "Authorization";
    private final String BEARER = "Bearer";

    @Autowired
    public JwtAuthenticator(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    public String authenticate(HttpServletRequest request) throws AuthenticateException {
        String jwtToken = parseBearerAuthorizeHeader(request.getHeader(AUTHORIZE_HEADER));
        String userId = jwtUtil.validateToken(jwtToken);
        if(userId == null) throw new AuthenticateException("유효하지 않은 JWT 토큰");

        return userId;
    }

    private String parseBearerAuthorizeHeader(String authorizeValue) throws AuthenticateException {
        try {
            return authorizeValue.substring(BEARER.length() + 1); // "Bearer" + "\s"
        }catch (NullPointerException noAuthorizeHeader){
            throw new AuthenticateException("인증 정보 미포함");
        }
    }
}
