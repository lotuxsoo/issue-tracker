package team1.issuetracker.domain;

public record ResultWithError<T> (T result, String error){
}
