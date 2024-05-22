package team1.issuetracker.domain.milestone;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import team1.issuetracker.domain.milestone.dto.MilestoneListResponse;
import team1.issuetracker.domain.milestone.dto.MilestoneMakeRequest;
import team1.issuetracker.domain.user.auth.annotation.Authenticate;
import team1.issuetracker.domain.user.auth.annotation.AuthenticatedUserId;

import java.util.List;

@RequestMapping("/milestone")
@Slf4j
@RestController
public class MilestoneController {

    private final MilestoneService milestoneService;

    @Autowired
    public MilestoneController(MilestoneService milestoneService) {
        this.milestoneService = milestoneService;
    }

    @GetMapping("/list")
    public List<MilestoneListResponse> milestoneList() {
        return milestoneService.getList();
    }

    @Authenticate
    @PostMapping
    public MilestoneListResponse createMilestone(@RequestBody MilestoneMakeRequest milestoneMakeRequest, @AuthenticatedUserId String userId)
            throws IllegalArgumentException {
        return MilestoneListResponse.of(milestoneService.createMilestone(milestoneMakeRequest.name(), milestoneMakeRequest.description(),
                milestoneMakeRequest.deadline(), userId));
    }

    @Authenticate
    @PatchMapping("/{id}")
    public Milestone updateMilestone(@RequestBody MilestoneMakeRequest milestoneMakeRequest,
                                     @PathVariable("id") Long id, @AuthenticatedUserId String userId)
            throws IllegalArgumentException {
        return milestoneService.updateMilestone(milestoneMakeRequest, id, userId);
    }

    @Authenticate
    @DeleteMapping("/{id}")
    public void deleteMilestone(@PathVariable("id") Long id, @AuthenticatedUserId String userId) {
        milestoneService.deleteMilestone(id, userId);
    }
}