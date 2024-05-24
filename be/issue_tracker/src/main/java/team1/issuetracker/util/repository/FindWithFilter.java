package team1.issuetracker.util.repository;

import java.util.ArrayList;
import java.util.List;
import org.springframework.data.jdbc.core.JdbcAggregateOperations;
import org.springframework.data.relational.core.query.Query;

public interface FindWithFilter<T> {
    JdbcAggregateOperations getJdbcAggregateOperations();

    default <T> List<T> findAll(Query query, Class<T> domainType) {
        Iterable<T> iterable = this.getJdbcAggregateOperations().findAll(query, domainType);
        List<T> list = new ArrayList<>();
        iterable.forEach(list::add);
        return list;
    }
}
