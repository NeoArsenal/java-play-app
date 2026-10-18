# JavaPlay App - Efectos de Sonido (Sound FX)

Esta carpeta está destinada a los efectos de audio opcionales de la aplicación.
El servicio `FeedbackService` (`lib/core/services/feedback_service.dart`) opera en **modo silencioso por defecto** si los archivos no se encuentran presentes, garantizando que la aplicación funcione de forma idéntica sin lanzar errores ni interrupciones.

## Archivos Requeridos

Coloca los siguientes archivos en este directorio (`assets/sounds/`):

1. **`correct.mp3`**: Sonido alegre y sutil al acertar una pregunta en el quiz o ejercicio.
2. **`wrong.mp3`**: Tono suave de retroalimentación de error al fallar un ejercicio.
3. **`complete.mp3`**: Fanfarria breve de celebración al completar una lección o pantalla de resultados.
4. **`hit.mp3`**: Efecto de impacto/golpe crítico al acertar un ataque contra un jefe en la `BossChallengeScreen`.

## Pautas Técnicas y de Licencia

- **Duración sugerida**: Corta, menor a **1.5 segundos** (< 1.5 s) para evitar saturación de audio o retrasos perceptibles.
- **Formato**: MP3 estéreo o mono, 44.1 kHz, bitrate de 128 kbps a 192 kbps.
- **Licencia**: Deben ser de Dominio Público (**CC0**) o contar con una licencia comercial libre de regalías (Royalty-Free / Permissive).
- **Registro en pubspec.yaml**: Una vez colocados los archivos `.mp3`, añade la carpeta en la sección `flutter -> assets` de `pubspec.yaml`:
  ```yaml
  flutter:
    assets:
      - assets/data/
      - assets/branding/
      - assets/sounds/
  ```
