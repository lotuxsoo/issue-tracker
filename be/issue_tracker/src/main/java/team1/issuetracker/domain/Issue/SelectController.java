package team1.issuetracker.domain.Issue;

import java.util.List;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import team1.issuetracker.domain.label.LabelService;
import team1.issuetracker.domain.label.dto.LabelListResponse;
import team1.issuetracker.domain.milestone.MilestoneService;
import team1.issuetracker.domain.milestone.dto.MilestoneInfo;
import team1.issuetracker.domain.user.UserService;
import team1.issuetracker.domain.user.dto.AssigneeInfo;

@RequestMapping("/select")
@Slf4j
@RestController
public class SelectController {
    private final UserService userService;
    private final LabelService labelService;
    private final MilestoneService milestoneService;

    public SelectController(UserService userService, LabelService labelService, MilestoneService milestoneService) {
        this.userService = userService;
        this.labelService = labelService;
        this.milestoneService = milestoneService;
    }

    @GetMapping("/assignee")
    public List<AssigneeInfo> getAssignees() {
        return userService.getAssignees().stream().map(user -> new AssigneeInfo(user.getId(), user.getName()))
                .collect(Collectors.toList());
    }

    @GetMapping("/label")
    public List<LabelListResponse> getLabels() {
        return labelService.getList();
    }

    @GetMapping("/milestone")
    public List<MilestoneInfo> getMilestones() {
        return milestoneService.getMilestoneInfo();
    }
}