# Revisión de Contenido Curricular (Content Review)

> **Nota:** Según las restricciones de la tarea actual, `assets/data/curriculum.json` permanece **sin modificaciones**. Los siguientes hallazgos se documentan para su futura corrección planificada.

---

## Hallazgos de Integridad en Ejercicios FILL_BLANK

Se detectaron 3 ejercicios de tipo `FILL_BLANK` donde el número de delimitadores de hueco en `codeTemplate` (`___`) no coincide con el tamaño del array `correctAnswers`:

### 1. Ejercicio `m1l3e9` (Mundo 1, Lección 3, Ejercicio 9)
- **Pregunta:** Concatenación de cadenas en Java.
- **`codeTemplate` actual:**
  ```java
  String completo = nombre ___ " " ___ apellido;
  ```
- **`correctAnswers` actual:** `["+"]` (longitud 1).
- **Problema:** Hay 2 huecos para rellenar (`nombre ___ " "` y `" " ___ apellido`), pero solo se provee 1 respuesta en el array, impidiendo que el motor de validación pueda completar el segundo hueco correctamente si evalúa ambos.
- **Propuesta de solución:**
  - **Opción A (Recomendada):** Actualizar `correctAnswers` a `["+", "+"]` y en `options` permitir seleccionar `+` dos veces o proveer dos tokens `+`.
  - **Opción B:** Dejar un solo hueco en el template: `String completo = nombre + " " ___ apellido;` con `correctAnswers: ["+"]`.

---

### 2. Ejercicio `m2l4e9` (Mundo 2, Lección 4, Ejercicio 9)
- **Pregunta:** Recorrido de matrices bidimensionales.
- **`codeTemplate` actual:**
  ```java
  for (int i = 0; i < ___; i++) {
      for (int j = 0; j < ___; j++) {
          System.out.println(matriz[i][j]);
      }
  }
  ```
- **`correctAnswers` actual:** `["matriz.length"]` (longitud 1).
- **Problema:** Hay 2 huecos en los bucles anidados (`i < ___` y `j < ___`), pero solo se provee `matriz.length` en `correctAnswers`. El segundo límite (`matriz[i].length` o `matriz[0].length`) no está en `correctAnswers`.
- **Propuesta de solución:**
  - **Opción A (Recomendada):** Fijar el bucle externo y evaluar el interno:
    ```java
    for (int i = 0; i < matriz.length; i++) {
        for (int j = 0; j < ___; j++) {
            System.out.println(matriz[i][j]);
        }
    }
    ```
    con `correctAnswers: ["matriz[i].length"]` o `["matriz[0].length"]`.
  - **Opción B:** Si se desean ambos huecos, definir `correctAnswers: ["matriz.length", "matriz[i].length"]` y añadir las opciones correspondientes en `options`.

---

### 3. Ejercicio `m3l7e9` (Mundo 3, Lección 7, Ejercicio 9)
- **Pregunta:** Clases y métodos abstractos.
- **`codeTemplate` actual:**
  ```java
  public ___ class Figura {
      ___ double calcularArea();
  }
  ```
- **`correctAnswers` actual:** `["abstract"]` (longitud 1).
- **Problema:** Hay 2 huecos (`public ___ class` y `___ double calcularArea()`), pero solo una entrada en `correctAnswers`.
- **Propuesta de solución:**
  - **Opción A (Recomendada):** Actualizar `correctAnswers` a `["abstract", "abstract"]` y permitir el token duplicado.
  - **Opción B:** Dejar un solo hueco en la clase o en el método:
    ```java
    public abstract class Figura {
        ___ double calcularArea();
    }
    ```
    con `correctAnswers: ["abstract"]`.

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
