package team1.issuetracker;

import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import team1.issuetracker.util.S3Util;

import java.io.IOException;

@RestController
@RequestMapping("/")
@RequiredArgsConstructor
public class HomeController {

    private final S3Util s3Util;

    @GetMapping("/github")
    public void redirectToGithub(HttpServletResponse httpServletResponse) throws IOException {
        httpServletResponse.sendRedirect("https://github.com/codesquad-masters2024-team01/issue-tracker");
    }

    @PostMapping("/upload")
    public String uploadImage(@RequestPart(value = "image", required = false) MultipartFile image){
        return s3Util.upload(image);
    }
}
