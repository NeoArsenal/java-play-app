# Revisión de Contenido Curricular (Content Review)

> **Estado:** Ejercicios corregidos en rama `feat/code-block-fix`. Respaldo previo resguardado en `docs_private/curriculum.backup2.json`.

---

## Hallazgos de Integridad en Ejercicios FILL_BLANK (Resueltos)

Se detectaron y corrigieron 3 ejercicios de tipo `FILL_BLANK` donde el número de delimitadores de hueco en `codeTemplate` (`___`) no coincidía con el tamaño del array `correctAnswers`. Se aplicó la **Opción B** para preservar la consistencia con el motor de validación:

### 1. Ejercicio `m1l3e9` (Mundo 1, Lección 3, Ejercicio 9) - RESUELTO
- **Pregunta:** Concatenación de cadenas en Java.
- **`codeTemplate` corregido:**
  ```java
  String completo = nombre + " " ___ apellido;
  ```
- **`correctAnswers`:** `["+"]` (1 hueco, 1 respuesta).
- **Estado:** Corregido en `assets/data/curriculum.json`.

---

### 2. Ejercicio `m2l4e9` (Mundo 2, Lección 4, Ejercicio 9) - RESUELTO
- **Pregunta:** Recorrido de matrices bidimensionales.
- **`codeTemplate` corregido:**
  ```java
  for (int i = 0; i < matriz.length; i++) {
      for (int j = 0; j < ___; j++) {
          System.out.println(matriz[i][j]);
      }
  }
  ```
- **`correctAnswers`:** `["matriz[i].length"]` (1 hueco, 1 respuesta).
- **`options`:** `["matriz[i].length", "matriz.length", "matriz[j].length", "i"]`.
- **Estado:** Corregido en `assets/data/curriculum.json`.

---

### 3. Ejercicio `m3l7e9` (Mundo 3, Lección 7, Ejercicio 9) - RESUELTO
- **Pregunta:** Clases y métodos abstractos.
- **`codeTemplate` corregido:**
  ```java
  public abstract class Figura {
      ___ double calcularArea();
  }
  ```
- **`correctAnswers`:** `["abstract"]` (1 hueco, 1 respuesta).
- **Estado:** Corregido en `assets/data/curriculum.json`.

---

## Análisis de Enunciados en Ejercicios SPOT_THE_BUG

De los **140 ejercicios** totales de tipo `SPOT_THE_BUG` presentes en el currículum:
- **100 ejercicios** (exactamente todos los correspondientes al ejercicio 4 de cada una de las 100 lecciones principales, con IDs `mundo_X_lY_ex4`) utilizan un enunciado largo generado por plantilla:
  > `"Inspección de código en <Título de Lección>: Toca la línea donde ocurrirá un fallo o comportamiento erróneo:"`
- Los otros **40 ejercicios** (en su mayoría ejercicios adicionales como `mXlYe10` o desafíos de jefe) utilizan enunciados específicos y directos (ej. `"Toca la línea que intenta instanciar una clase abstracta:"`).

### Diagnóstico de UX / UI
1. **Redundancia:** La barra de encabezado ya indica `"ENCUENTRA EL ERROR"` y `"DINÁMICA JAVA"`, por lo que repetir `"Inspección de código en..."` ocupa espacio vertical valioso (~110-140 caracteres).
2. **Empuje de contenido:** En pantallas de 360 dp de ancho, este texto toma de 3 a 4 líneas completas, desplazando el bloque de código hacia abajo y reduciendo el espacio disponible.

### Propuestas de Versión Abreviada (Pendiente de Aprobación, enunciados intactos por ahora)
- **Propuesta 1 (Ultra corta):** `"Toca la línea con el error:"` (28 caracteres).
- **Propuesta 2 (Acción directa):** `"Encuentra el fallo en este código:"` (34 caracteres).
- **Propuesta 3 (Contextual breve):** `"<Tema>: Toca la línea errónea"` (~40 caracteres).

---

## Verificación de Líneas Largas (Inspección de Desplazamiento Horizontal)

Se verificó el renderizado con las líneas más extensas del currículum para garantizar que el nuevo scroll horizontal (`SingleChildScrollView(scrollDirection: Axis.horizontal)`) con fuente monoespaciada mantenga el formato exacto de Java sin cortes:

1. **`mundo_4_l8_ex3` (107 caracteres):**
   `    public ResponseEntity<String> manejar(Exception e) { return ResponseEntity.status(500).body("Error"); }`
2. **`mundo_7_l9_ex3` (104 caracteres):**
   `    public static void main(String[] args) { SpringApplication.run(ApiBackendApplication.class, args); }`
3. **`mundo_7_l7_ex4` (110 caracteres):**
   `    @Bean public Repo repo() { return new Repo(); } // Sin CGLIB proxy creará dos instancias distintas de Repo`
4. **`mundo_10_l10_ex4` (109 caracteres):**
   `meterRegistry.counter("pedidos", "orderId", pedido.getId().toString()); // Destruirá la memoria de Prometheus`
