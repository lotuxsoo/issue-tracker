package team1.issuetracker.domain.label;

import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LabelRepository extends CrudRepository<Label, Long> {
    List<Label> findByIdIn(List<Long> ids);

    List<Label> findByIdInAndNameIn(List<Long> ids, List<String> names);

    List<Label> findByNameIn(List<String> labelsTitle);
}
