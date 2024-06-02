package team1.issuetracker.util.repository;

import org.springframework.data.jdbc.core.JdbcAggregateOperations;
import org.springframework.stereotype.Component;

@Component
public class FindWithFilterImpl implements FindWithFilter{
    private final JdbcAggregateOperations jdbcAggregateOperations;
    public FindWithFilterImpl(JdbcAggregateOperations jdbcAggregateOperations) {
        this.jdbcAggregateOperations = jdbcAggregateOperations;
    }

    @Override
    public JdbcAggregateOperations getJdbcAggregateOperations() {
        return this.jdbcAggregateOperations;
    }
}
