package team1.issuetracker.domain.user;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import team1.issuetracker.domain.Issue.Issue;
import team1.issuetracker.domain.Issue.ref.AssigneeRef;
import team1.issuetracker.domain.user.dto.AssigneeInfo;
import team1.issuetracker.domain.user.dto.LoginInfo;
import team1.issuetracker.domain.user.dto.RegisterInfo;
import team1.issuetracker.domain.user.dto.UserInfoResponse;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public String getNameById(String userId) {
        Optional<User> byId = userRepository.findById(userId);
        return byId.get().getName();
    }

    public boolean isDuplicateId(String id) {
        return userRepository.existsById(id);
    }

    public boolean isDuplicateNickName(String nickname) {
        return userRepository.existsByName(nickname);
    }

    public void createUser(RegisterInfo registerInfo) {
        if (isDuplicateId(registerInfo.id())) {
            throw new IllegalArgumentException("이미 등록된 ID 입니다");
        }
        if (isDuplicateNickName(registerInfo.nickname())) {
            throw new IllegalArgumentException("이미 등록된 닉네임 입니다");
        }

        User newUser = User.normalUSerOf(registerInfo);
        userRepository.insert(newUser);
    }

    public UserInfoResponse getUserInfo(String id) {
        User userById = getUserById(id);
        return UserInfoResponse.of(userById);
    }

    public List<String> getAssigneeNameAtIssue(Issue issue) {
        Set<AssigneeRef> issueAssignees = issue.getIssueAssignees();

        return issueAssignees.stream()
                .map(AssigneeRef::getUserId)
                .map(this::getNameById).toList();
    }

    public List<User> getAssignees() {
      return (List<User>) userRepository.findAll();
    }

    public boolean authentication(LoginInfo loginInfo) throws NoSuchElementException {
        User tryingUser = getUserById(loginInfo.id());

        return tryingUser.getPassword().equals(loginInfo.password());
    }

    private User getUserById(String id) {
        Optional<User> byId = userRepository.findById(id);
        byId.orElseThrow(() -> new NoSuchElementException("존재하지 않는 회원 ID 입니다"));

        return byId.get();
    }
}