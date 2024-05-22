package team1.issuetracker.domain.label;

import java.util.NoSuchElementException;
import java.util.Optional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import team1.issuetracker.domain.Issue.Issue;
import team1.issuetracker.domain.Issue.ref.LabelRef;
import team1.issuetracker.domain.comment.Comment;
import team1.issuetracker.domain.label.dto.LabelListResponse;

import java.util.List;
import java.util.Set;

import team1.issuetracker.domain.label.dto.LabelMakeRequest;
import team1.issuetracker.domain.user.auth.Authorizable;
import team1.issuetracker.domain.user.auth.AuthorizeException;


@Service
public class LabelService implements Authorizable<Label, Long> {

    private final LabelRepository labelRepository;

    @Autowired
    public LabelService(LabelRepository labelRepository) {
        this.labelRepository = labelRepository;
    }

    public Label saveLabel(LabelMakeRequest labelMakeRequest, String userId) {
        Label label = Label.of(labelMakeRequest, userId);
        return labelRepository.save(label);
    }

    public Label updateLabel(long id, LabelMakeRequest labelMakeRequest, String userId) {
        Label origin = authorize(id, userId); //origin 받기

        Label updateLabel = Label.builder()
                .id(origin.getId())
                .name(labelMakeRequest.name())
                .description(labelMakeRequest.description())
                .color(labelMakeRequest.color())
                .createdAt(origin.getCreatedAt())
                .userId(userId)
                .build();

        return labelRepository.save(updateLabel);
    }

    public void deleteLabel(Long id, String userId) throws NoSuchElementException {
        labelRepository.delete(authorize(id,userId));
    }


    public List<LabelListResponse> getList() {
        List<Label> labelList = (List<Label>) labelRepository.findAll();
        return labelList.stream().map(LabelListResponse::of).toList();
    }

    public List<LabelListResponse> getLabelsAyIssue(Issue issue) {
        Set<LabelRef> issueLabels = issue.getIssueHasLabel();
        List<Long> labelIds = issueLabels.stream().map(LabelRef::getLabelId).toList();

        return labelRepository.findByIdIn(labelIds).stream().map(LabelListResponse::of).toList();
    }

    @Override
    public Label authorize(Long labelId, String userId) {
        Label label = getLabel(labelId);
        if(!label.getUserId().equals(userId)) throw new AuthorizeException(labelId + "번 라벨에 대한 권한이 없습니다");

        return label;
    }

    private Label getLabel(Long id) throws NoSuchElementException {
        Optional<Label> optionalLabel = labelRepository.findById(id);
        if (optionalLabel.isEmpty()) {
            throw new NoSuchElementException(id + "라벨이 존재하지 않습니다!");
        }

        return optionalLabel.get();
    }
}
