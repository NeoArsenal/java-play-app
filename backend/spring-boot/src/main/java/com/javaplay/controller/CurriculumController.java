package com.javaplay.controller;

import org.springframework.core.io.ClassPathResource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

@RestController
@RequestMapping("/api/curriculum")
@CrossOrigin(origins = "*")
public class CurriculumController {

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> getCurriculum() throws IOException {
        Path path = Path.of("../assets/data/curriculum.json");
        if (Files.exists(path)) {
            return ResponseEntity.ok(Files.readString(path));
        }
        return ResponseEntity.ok("{}");
    }
}
