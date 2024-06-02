package team1.issuetracker.domain;

import lombok.Getter;

@Getter
public class ApiResponse<T> {
    private final String result;
    private final T data;
    private final String error;

    private ApiResponse(String result, T data) {
        this.result = result;
        this.data = data;
        this.error = null;
    }

    public ApiResponse(String result, T data, String error) {
        this.result = result;
        this.data = data;
        this.error = error;
    }

    public static <T> ApiResponse<T> ofSuccess(T data) {
        return new ApiResponse<>("SUCCESS", data);
    }

    public static <T> ApiResponse<T> ofSuccess(T data, String result) {
        return new ApiResponse<>(result, data);
    }

    public static ApiResponse ofError(String error) {
        return new ApiResponse<>("ERROR", null, error);
    }

    public static <T> ApiResponse<T> of(ResultWithError<T> result){
        if(!result.error().isEmpty()) return new ApiResponse<>("ERROR", result.result(), result.error());
        return ApiResponse.ofSuccess(result.result());
    }
}
