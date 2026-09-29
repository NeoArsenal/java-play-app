# Java & Spring Boot Interview Duolingo 🚀 (Flutter + Web Preview)

Aplicación móvil gamificada estilo **Duolingo** diseñada para preparar entrevistas técnicas en **Java** y **Spring Boot** (JVM Internals, Colecciones, Concurrencia, Scopes, Proxies de Spring, Transacciones y JPA).

---

## 🌟 Características Principales
1. **Árbol de Aprendizaje por Mundos**:
   - Mundo 1: Java Core & JVM Internals (Stack vs Heap, String Pool, Classloaders, Exceptions).
   - Mundo 2: Colecciones y Estructuras de Datos (HashMap Treeification, equals/hashCode).
   - Mundo 3: Concurrencia y Virtual Threads (Java 21, Project Loom).
   - Mundo 4: Spring Boot Core & AOP (Inyección por constructor, Scopes, Proxies y @Transactional).
   - Mundo 5: Spring Data JPA & Transacciones (Problema N+1, Join Fetch, Dirty Checking).

2. **Gamificación y Motor de Quiz**:
   - Vidas (❤️ 5), Racha diaria (🔥) y Puntos de Experiencia (⚡ XP).
   - Feedback visual y sonoro estilo Duolingo con banner inferior (Verde/Rojo) y explicación técnica profunda del error.
   - 4 Tipos de ejercicios:
     - **Flashcard**: Micro-teoría nuclear con fragmentos de código.
     - **Multiple Choice**: Tarjetas interactivas con badges A/B/C/D.
     - **Code Fill-in-the-Blank**: Slots dinámicos en fragmentos de código con chips seleccionables.
     - **Token Reordering**: Ordenar sintaxis y palabras clave de Java / Spring.

3. **Simulador de Entrevista Técnica (Mock Interview)**:
   - Temporizador estricto de cuenta regresiva (45-60s).
   - Grabación de voz en tiempo real con micrófono.
   - Reproducción de audio grabado + Checklist de autoevaluación técnica ("Conceptos que debiste mencionar") + Respuesta ideal del entrevistador Senior.

---

## 📂 Arquitectura del Código Flutter
Implementado con **Clean Architecture / Feature-First** y **Riverpod**:

```text
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart          # Paleta estilo Duolingo (#58CC02, #EA2B2B, #1CB0F6)
│   └── theme/
│       └── app_theme.dart           # Material 3 Dark Mode para desarrolladores
├── features/
│   ├── learning_path/
│   │   ├── domain/models/           # World y Lesson
│   │   └── presentation/screens/    # LearningPathScreen (Árbol con nodos circulares)
│   ├── quiz/
│   │   ├── domain/models/           # Ejercicios polimórficos (Flashcard, MultipleChoice, FillBlank, TokenReorder)
│   │   ├── presentation/
│   │   │   ├── controllers/         # QuizNotifier & QuizState (Riverpod)
│   │   │   ├── screens/             # QuizScreen
│   │   │   └── widgets/             # ExerciseHeader, FeedbackBottomSheet, Vistas de Ejercicios
│   └── mock_interview/
│       ├── domain/models/           # InterviewQuestion
│       └── presentation/screens/    # MockInterviewScreen (Temporizador, Audio, Checklist)
└── main.dart                        # ProviderScope & MaterialApp
```

---

## ⚡ Cómo Probar el Prototipo Web Inmediatamente
No necesitas esperar a instalar o configurar Flutter SDK. Puedes abrir el prototipo interactivo con todos los ejercicios y sonidos en tu navegador:

1. Abre directamente con tu navegador el archivo:
   `web_preview/index.html`
2. O levanta un servidor local:
   ```bash
   npx serve web_preview
   ```

---

## 📱 Cómo Ejecutar la App en Flutter
Una vez tengas configurado Flutter en tu sistema:
```bash
# 1. Instalar dependencias
flutter pub get

# 2. Ejecutar en emulador o dispositivo móvil
flutter run
```
