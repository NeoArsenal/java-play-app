package com.javaplay.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@RestController
@RequestMapping("/api/progress")
@CrossOrigin(origins = "*")
public class ProgressController {

    private final Map<String, UserProgressDto> userDatabase = new ConcurrentHashMap<>();

    public record UserProgressDto(String userId, String name, int xp, int lives, int streak) {}

    public ProgressController() {
        userDatabase.put("user_1", new UserProgressDto("user_1", "Alonso (Dev)", 180, 5, 3));
    }

    @GetMapping("/{userId}")
    public ResponseEntity<UserProgressDto> getProgress(@PathVariable String userId) {
        UserProgressDto progress = userDatabase.getOrDefault(userId,
                new UserProgressDto(userId, "Nuevo Dev", 0, 5, 1));
        return ResponseEntity.ok(progress);
    }

    @PostMapping("/{userId}")
    public ResponseEntity<UserProgressDto> updateProgress(
            @PathVariable String userId,
            @RequestBody Map<String, Object> payload) {
        UserProgressDto current = userDatabase.getOrDefault(userId,
                new UserProgressDto(userId, "Alonso (Dev)", 0, 5, 1));

        int xpDelta = payload.containsKey("xpDelta") ? ((Number) payload.get("xpDelta")).intValue() : 0;
        int newLives = payload.containsKey("lives") ? ((Number) payload.get("lives")).intValue() : current.lives();
        int newStreak = payload.containsKey("streak") ? ((Number) payload.get("streak")).intValue() : current.streak();

        UserProgressDto updated = new UserProgressDto(
                userId,
                current.name(),
                current.xp() + xpDelta,
                Math.clamp(newLives, 0, 5),
                newStreak
        );

        userDatabase.put(userId, updated);
        return ResponseEntity.ok(updated);
    }
}
