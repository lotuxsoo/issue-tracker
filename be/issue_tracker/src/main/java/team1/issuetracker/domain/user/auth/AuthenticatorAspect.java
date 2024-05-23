package team1.issuetracker.domain.user.auth;

import jakarta.servlet.http.HttpServletRequest;
import org.apache.tomcat.websocket.AuthenticationException;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import team1.issuetracker.domain.user.auth.annotation.AuthenticatedUserId;
import team1.issuetracker.domain.user.auth.exception.AuthenticateException;

import java.lang.annotation.Annotation;
import java.lang.reflect.Method;
import java.util.NoSuchElementException;
@Aspect
@Component
public class AuthenticatorAspect {
    private final Authenticator authenticator;

    public AuthenticatorAspect(Authenticator authenticator) {
        this.authenticator = authenticator;
    }

    @Around("@annotation(team1.issuetracker.domain.user.auth.annotation.Authenticate)")
    public Object authenticate(ProceedingJoinPoint joinPoint) throws Throwable {
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        Object[] args = joinPoint.getArgs();

        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        HttpServletRequest request = attributes.getRequest();

        String userId = authenticator.authenticate(request);
        int index = findIndexOfAnnotation(method.getParameterAnnotations());
        args[index] = userId;
        return joinPoint.proceed(args);
    }

    private int findIndexOfAnnotation(Annotation[][] parameterAnnotations) {
        for (int i = 0; i < parameterAnnotations.length; i++) {
            for (Annotation annotation : parameterAnnotations[i]) {
                if (annotation instanceof AuthenticatedUserId) {
                    return i;
                }
            }
        }
        throw new NoSuchElementException();
    }
}

