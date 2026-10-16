// Curriculum Data and Specialized Exercises for all 11 Worlds & Boss Battles

// Curriculum Data and Specialized Exercises for all 11 Worlds & Boss Battles

const worldsData = [
  {
    id: "mundo_0",
    level: 0,
    title: "Mundo 0: Onboarding & Fundamentos para Principiantes",
    badge: "🐣",
    description: "Para quien empieza desde cero: ¿Qué es programar, cómo piensa la computadora y tu primer código en Java?",
    color: "#58CC02",
    levels: [
      { id: "m0_l1", title: "¿Qué es Programar y cómo piensa una Computadora?" },
      { id: "m0_l2", title: "Tu Primer Programa: 'Hola Mundo' y la función main" },
      { id: "m0_l3", title: "Variables y Cajas de Memoria (int, double, String, boolean)" },
      { id: "m0_l4", title: "Tomando Decisiones: Condicionales (if, else y comparaciones)" },
      { id: "m0_l5", title: "Repitiendo Tareas: Bucles y Ciclos (for y while)" }
    ],
    bossChallenge: {
      id: "m0_boss",
      title: "Desafío Final: El Examen de Bienvenida al Mundo Java",
      bossName: "El Compilador Novato",
      bossAvatar: "🤖",
      description: "Demuestra que ya entiendes la lógica básica de programación antes de entrar a la JVM.",
      passThreshold: 80,
      xpReward: 150,
      timeLimitSeconds: 180
    }
  },
  {
    id: "mundo_1",
    level: 1,
    title: "Mundo 1: Fundamentos Nucleares de Java & Memoria",
    badge: "🌱",
    description: "La base técnica que todo desarrollador debe dominar: Tipos, memoria Stack vs Heap y ciclo de vida de objetos.",
    color: "#58CC02",
    levels: [
      { id: "m1_l1", title: "Anatomía de la JVM, Bytecode y el método main" },
      { id: "m1_l2", title: "Tipos Primitivos, Precisión y Desbordamiento (Overflow)" },
      { id: "m1_l3", title: "Wrappers, Autoboxing y el peligro oculto de NPE" },
      { id: "m1_l4", title: "Memoria Stack vs Heap: ¿Dónde vive cada variable?" },
      { id: "m1_l5", title: "Operadores, Precedencia y Evaluación de Cortocircuito" },
      { id: "m1_l6", title: "Estructuras de Control, switch moderno y Exhaustividad" },
      { id: "m1_l7", title: "Inmutabilidad con la palabra clave final" },
      { id: "m1_l8", title: "Manipulación de Texto: String, StringBuilder y String Pool" },
      { id: "m1_l9", title: "Arrays en memoria, límites y System.arraycopy" },
      { id: "m1_l10", title: "Garbage Collection Básico: Elegibilidad de Objetos" }
    ],
    bossChallenge: {
      id: "m1_boss",
      title: "Desafío Final: Certificación en Fundamentos Nucleares",
      bossName: "Duke: Centinela de la JVM",
      bossAvatar: "⚡",
      description: "Supera este examen de memoria, tipos primitivos y ciclo de vida de objetos para desbloquear el Mundo 2.",
      passThreshold: 80,
      xpReward: 150,
      timeLimitSeconds: 180
    }
  },
  {
    id: "mundo_2",
    level: 2,
    title: "Mundo 2: Programación Orientada a Objetos (POO) & Modelado",
    badge: "🏠",
    description: "Pilares del paradigma de objetos: Encapsulamiento, Polimorfismo, equals/hashCode y Records.",
    color: "#1CB0F6",
    levels: [
      { id: "m2_l1", title: "Clases, Instanciación y Ciclo de Vida del Constructor" },
      { id: "m2_l2", title: "Sobrecarga vs Sobrescritura (@Override) de Métodos" },
      { id: "m2_l3", title: "Encapsulamiento y Modificadores de Acceso" },
      { id: "m2_l4", title: "Herencia y la palabra clave super" },
      { id: "m2_l5", title: "Polimorfismo en Tiempo de Ejecución y Dynamic Dispatch" },
      { id: "m2_l6", title: "Clases Abstractas vs Métodos Concretos" },
      { id: "m2_l7", title: "Miembros Estáticos: static methods y static blocks" },
      { id: "m2_l8", title: "El contrato sagrado: equals() y hashCode()" },
      { id: "m2_l9", title: "Composición sobre Herencia (Favor Composition)" },
      { id: "m2_l10", title: "Inmutabilidad con Java record (Java 16+)" }
    ],
    bossChallenge: {
      id: "m2_boss",
      title: "Desafío Final: Examen de Arquitectura y Diseño POO",
      bossName: "El Gran Arquitecto de Objetos",
      bossAvatar: "🏛️",
      description: "Demuestra tu dominio modelando contratos, polimorfismo robusto y el contrato equals/hashCode.",
      passThreshold: 80,
      xpReward: 150,
      timeLimitSeconds: 180
    }
  },
  {
    id: "mundo_3",
    level: 3,
    title: "Mundo 3: Interfaces, Abstracción y Contratos Técnicos",
    badge: "📜",
    description: "Diseño desacoplado: Métodos default, interfaces funcionales y jerarquías cerradas con Sealed Interfaces.",
    color: "#FF9600",
    levels: [
      { id: "m3_l1", title: "Declaración de Interfaces y Contratos de Comportamiento" },
      { id: "m3_l2", title: "Implementación Múltiple y el Problema del Diamante" },
      { id: "m3_l3", title: "Métodos default y static en Interfaces" },
      { id: "m3_l4", title: "Métodos private en Interfaces (Java 9+)" },
      { id: "m3_l5", title: "Interfaces Funcionales y la anotación @FunctionalInterface" },
      { id: "m3_l6", title: "Interfaces de Marcado (Marker Interfaces)" },
      { id: "m3_l7", title: "Sealed Interfaces & Classes: Jerarquías Cerradas (Java 17+)" },
      { id: "m3_l8", title: "Principio SOLID: Interface Segregation (ISP)" },
      { id: "m3_l9", title: "Principio SOLID: Dependency Inversion (DIP)" },
      { id: "m3_l10", title: "Diseño de APIs fluidas y contratos públicos" }
    ],
    bossChallenge: {
      id: "m3_boss",
      title: "Desafío Final: Examen de Contratos & Abstracción",
      bossName: "El Juez de Contratos y Abstracción",
      bossAvatar: "🔮",
      description: "Resuelve el problema del diamante, interfaces funcionales y jerarquías sealed en este desafío de alto nivel.",
      passThreshold: 80,
      xpReward: 150,
      timeLimitSeconds: 180
    }
  },
  {
    id: "mundo_4",
    level: 4,
    title: "Mundo 4: Manejo Profesional de Excepciones & Resiliencia",
    badge: "🛡️",
    description: "Dominio de la jerarquía Throwable, try-with-resources y prevención de excepciones críticas en producción.",
    color: "#FF4B4B",
    levels: [
      { id: "m4_l1", title: "Jerarquía de Throwable: Error vs Exception" },
      { id: "m4_l2", title: "Excepciones Checked vs Unchecked (Runtime)" },
      { id: "m4_l3", title: "Estructura try-catch-finally y orden de captura" },
      { id: "m4_l4", title: "try-with-resources y la interfaz AutoCloseable" },
      { id: "m4_l5", title: "Anti-patrón: Comerse la excepción (Swallowing exceptions)" },
      { id: "m4_l6", title: "Excepciones Personalizadas de Dominio" },
      { id: "m4_l7", title: "Enmascaramiento de Excepciones y Chained Exceptions" },
      { id: "m4_l8", title: "Manejo Global de Excepciones en APIs REST" },
      { id: "m4_l9", title: "Fallos Fatales: OutOfMemoryError vs StackOverflowError" },
      { id: "m4_l10", title: "Estrategias de Fallback y Circuit Breakers" }
    ],
    bossChallenge: {
      id: "m4_boss",
      title: "Desafío Final: Examen de Resiliencia y Depuración",
      bossName: "El Titán de la Resiliencia",
      bossAvatar: "🌪️",
      description: "Diagnostica fallos silenciosos, gestiona recursos sin fugas y diseña flujos tolerantes a errores.",
      passThreshold: 80,
      xpReward: 150,
      timeLimitSeconds: 180
    }
  },
  {
    id: "mundo_5",
    level: 5,
    title: "Mundo 5: Colecciones, Genéricos & HashMap Internals",
    badge: "⚡",
    description: "La estructura interna de la Java Collections Framework, complejidad Big-O y algoritmos de hashing.",
    color: "#CE82FF",
    levels: [
      { id: "m5_l1", title: "Jerarquía de la Java Collections Framework" },
      { id: "m5_l2", title: "ArrayList vs LinkedList: Big-O y Cache Locality" },
      { id: "m5_l3", title: "HashMap Internals: Buckets, TreeBins y Rehashing" },
      { id: "m5_l4", title: "HashSet y garantía de unicidad con tabla hash" },
      { id: "m5_l5", title: "Colecciones Ordenadas: TreeSet, TreeMap y Comparator" },
      { id: "m5_l6", title: "Genéricos: Tipado Seguro y Type Erasure" },
      { id: "m5_l7", title: "Genéricos Avanzados: Wildcards PECS" },
      { id: "m5_l8", title: "Colecciones Inmutables: List.of(), Map.of()" },
      { id: "m5_l9", title: "Colecciones Concurrentes: ConcurrentHashMap" },
      { id: "m5_l10", title: "Iteración Segura y ConcurrentModificationException" }
    ],
    bossChallenge: {
      id: "m5_boss",
      title: "Desafío Final: Examen de Rendimiento en Colecciones",
      bossName: "El Maestro de los Algoritmos de Hashing",
      bossAvatar: "💎",
      description: "Optimiza memoria y tiempo de búsqueda O(1) resolviendo colisiones y concurrencia.",
      passThreshold: 80,
      xpReward: 150,
      timeLimitSeconds: 180
    }
  },
  {
    id: "mundo_6",
    level: 6,
    title: "Mundo 6: Java Moderno, Lambdas & Streams API",
    badge: "🌊",
    description: "Programación funcional idiomática: transformaciones declarativas con Streams, Collectors y Optional.",
    color: "#2B70C9",
    levels: [
      { id: "m6_l1", title: "Sintaxis de Expresiones Lambda y effectively final" },
      { id: "m6_l2", title: "Interfaces Funcionales: Predicate, Function, Consumer, Supplier" },
      { id: "m6_l3", title: "Referencias a Métodos (Class::method y new)" },
      { id: "m6_l4", title: "Anatomía de un Stream: Intermedias vs Terminales" },
      { id: "m6_l5", title: "Transformaciones con filter(), map() y flatMap()" },
      { id: "m6_l6", title: "Operaciones de Cortocircuito: findFirst(), anyMatch()" },
      { id: "m6_l7", title: "Reducción y Acumulación con reduce() y Collectors" },
      { id: "m6_l8", title: "Agrupamiento Avanzado: Collectors.groupingBy()" },
      { id: "m6_l9", title: "Streams Paralelos (parallelStream) y ForkJoinPool" },
      { id: "m6_l10", title: "Uso Idiomático de Optional y prevención de antipatrones" }
    ],
    bossChallenge: {
      id: "m6_boss",
      title: "Desafío Final: Examen de Programación Funcional",
      bossName: "El Oráculo Funcional de Streams",
      bossAvatar: "🌊",
      description: "Escribe pipelines de datos puros, sin efectos secundarios ni cuellos de botella en memoria.",
      passThreshold: 80,
      xpReward: 150,
      timeLimitSeconds: 180
    }
  },
  {
    id: "mundo_7",
    level: 7,
    title: "Mundo 7: Spring Boot Core & Inversión de Control (IoC)",
    badge: "🍃",
    description: "El motor de Spring Boot: Ciclo de vida de los Beans, inyección por constructor, perfiles y proxies AOP.",
    color: "#6DB33F",
    levels: [
      { id: "m7_l1", title: "Inversión de Control (IoC) y ApplicationContext" },
      { id: "m7_l2", title: "Estereotipos: @Component, @Service, @Repository" },
      { id: "m7_l3", title: "Inyección por Constructor vs Field Injection" },
      { id: "m7_l4", title: "Ámbitos de Beans: singleton vs prototype" },
      { id: "m7_l5", title: "Ciclo de Vida del Bean: @PostConstruct y @PreDestroy" },
      { id: "m7_l6", title: "Resolución de Ambigüedades: @Primary y @Qualifier" },
      { id: "m7_l7", title: "Configuración Basada en Java: @Configuration y @Bean" },
      { id: "m7_l8", title: "Perfiles y Propiedades: @Profile y @Value" },
      { id: "m7_l9", title: "Cómo funciona @EnableAutoConfiguration" },
      { id: "m7_l10", title: "Spring AOP y Proxies Dinámicos (JDK vs CGLIB)" }
    ],
    bossChallenge: {
      id: "m7_boss",
      title: "Desafío Final: Examen de Arquitectura Spring Boot IoC",
      bossName: "El Guardián del Contexto de Spring",
      bossAvatar: "🍃",
      description: "Resuelve dependencias circulares, gestiona proxies dinámicos y asegura beans thread-safe.",
      passThreshold: 80,
      xpReward: 150,
      timeLimitSeconds: 180
    }
  },
  {
    id: "mundo_8",
    level: 8,
    title: "Mundo 8: APIs REST Profesionales & Validación",
    badge: "🌐",
    description: "Construcción de APIs HTTP de producción: Códigos de estado, validación Jakarta, ProblemDetail y paginación.",
    color: "#009688",
    levels: [
      { id: "m8_l1", title: "Verbos HTTP, Idempotencia y Códigos de Estado" },
      { id: "m8_l2", title: "Controladores REST: @RestController y @GetMapping" },
      { id: "m8_l3", title: "Mapeo de Request Body y DTOs" },
      { id: "m8_l4", title: "Validación Jakarta: @NotNull, @NotBlank, @Valid" },
      { id: "m8_l5", title: "Manejo Global de Errores con ProblemDetail (RFC 7807)" },
      { id: "m8_l6", title: "Paginación y Ordenamiento con Pageable y Sort" },
      { id: "m8_l7", title: "Estrategias de Versionado de APIs REST" },
      { id: "m8_l8", title: "Negociación de Contenido y Nivel de Madurez Richardson" },
      { id: "m8_l9", title: "Documentación Viva con OpenAPI 3 / Swagger" },
      { id: "m8_l10", title: "Testing de Integración de Controladores con MockMvc" }
    ],
    bossChallenge: {
      id: "m8_boss",
      title: "Desafío Final: Examen de Diseño de APIs de Producción",
      bossName: "El Soberano de las APIs REST",
      bossAvatar: "🌐",
      description: "Diseña contratos HTTP idempotentes, respuestas estandarizadas RFC 7807 y validaciones estrictas.",
      passThreshold: 80,
      xpReward: 150,
      timeLimitSeconds: 180
    }
  },
  {
    id: "mundo_9",
    level: 9,
    title: "Mundo 9: Spring Data JPA, Hibernate & Persistencia",
    badge: "💾",
    description: "Persistencia relacional de alto rendimiento: Consultas N+1, FetchType.LAZY, @Transactional y Bloqueo Optimista.",
    color: "#E91E63",
    levels: [
      { id: "m9_l1", title: "Conceptos de ORM, JPA vs Hibernate" },
      { id: "m9_l2", title: "Mapeo de Entidades: @Entity, @Table, @Id" },
      { id: "m9_l3", title: "Relaciones: @ManyToOne, @OneToMany, @ManyToMany" },
      { id: "m9_l4", title: "Carga Perezosa: FetchType.LAZY vs EAGER" },
      { id: "m9_l5", title: "Resolución del Problema N+1 con JOIN FETCH" },
      { id: "m9_l6", title: "Repositorios Spring Data y Métodos Derivados" },
      { id: "m9_l7", title: "Consultas Personalizadas con JPQL y @Query" },
      { id: "m9_l8", title: "Gestión de Transacciones con @Transactional" },
      { id: "m9_l9", title: "Niveles de Aislamiento Transaccional y Dirty Reads" },
      { id: "m9_l10", title: "Bloqueo Optimista (@Version) vs Pesimista" }
    ],
    bossChallenge: {
      id: "m9_boss",
      title: "Desafío Final: Examen de Rendimiento JPA & Hibernate",
      bossName: "La Sombra de Hibernate y el N+1",
      bossAvatar: "💾",
      description: "Elimina cuellos de botella de base de datos, consultas N+1 y concurrencia con @Version.",
      passThreshold: 80,
      xpReward: 150,
      timeLimitSeconds: 180
    }
  },
  {
    id: "mundo_10",
    level: 10,
    title: "Mundo 10: Concurrencia, Virtual Threads & Microservicios",
    badge: "👑",
    description: "Nivel Staff / Lead: Virtual Threads en Java 21, Java Memory Model, Spring Security 6 y observabilidad.",
    color: "#FFD700",
    levels: [
      { id: "m10_l1", title: "Hilos Tradicionales y Costo de Memoria OS" },
      { id: "m10_l2", title: "Java Memory Model (JMM), volatile y Happens-Before" },
      { id: "m10_l3", title: "Sincronización: synchronized, ReentrantLock y Deadlocks" },
      { id: "m10_l4", title: "Operaciones Atómicas y Compare-And-Swap (CAS)" },
      { id: "m10_l5", title: "Gestión de Hilos con ExecutorService" },
      { id: "m10_l6", title: "Virtual Threads (Java 21 / Loom) y Escalabilidad" },
      { id: "m10_l7", title: "Spring Security 6: SecurityFilterChain y Autenticación" },
      { id: "m10_l8", title: "Seguridad con Tokens JWT y Control de Acceso (RBAC)" },
      { id: "m10_l9", title: "Microservicios: API Gateway y Resiliencia" },
      { id: "m10_l10", title: "Observabilidad: Métricas Micrometer, Prometheus y Tracing" }
    ],
    bossChallenge: {
      id: "m10_boss",
      title: "Desafío Final: El Gran Examen Senior / Staff Architect",
      bossName: "El Señor Supremo de los Hilos Virtuales",
      bossAvatar: "👑",
      description: "El filtro técnico definitivo en concurrencia moderna, Virtual Threads, seguridad y resiliencia en la nube.",
      passThreshold: 85,
      xpReward: 200,
      timeLimitSeconds: 240
    }
  }
];


// Helper to assemble Onboarding exercises (Mundo 0) with all dynamics including FILL_BLANK
function getOnboardingExercises(level, num, prefix) {
  if (num === 1) {
    return [
      {
        type: "FLASHCARD",
        id: `${prefix}_ex1`,
        title: "¿Qué es Programar?",
        codeSnippet: "// Un algoritmo es una receta ordenada de pasos:\n1. Calentar agua\n2. Colocar café en la taza\n3. Verter agua caliente y revolver",
        explanation: "Una computadora es una máquina increíblemente veloz pero carece de sentido común. Programar es escribir instrucciones lógicas, precisas y ordenadas (un algoritmo) para que la máquina resuelva un problema."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex2`,
        question: "¿Qué es un algoritmo en el mundo de la programación?",
        options: [
          "Un componente de hardware como el disco duro o la memoria RAM",
          "Una secuencia ordenada, lógica y finita de instrucciones para resolver un problema",
          "Un virus informático que daña los archivos",
          "Una conexión a internet de fibra óptica"
        ],
        correctAnswerIndex: 1,
        explanation: "Un algoritmo es como una receta paso a paso: una serie finita de instrucciones claras que la computadora sigue al pie de la letra."
      },
      {
        type: "FILL_BLANK",
        id: `${prefix}_ex3`,
        question: "Completa el paso faltante en la secuencia lógica del algoritmo de preparación:",
        codeTemplate: "// 1. calentarAgua();\n// 2. ___();\n// 3. servirEnTaza();",
        correctAnswers: ["colocarCafe"],
        options: ["colocarCafe", "apagarLuz", "reiniciarRouter", "formatearDisco"],
        explanation: "El orden causal es imprescindible: el café debe colocarse antes de servir la taza."
      },
      {
        type: "SPOT_THE_BUG",
        id: `${prefix}_ex4`,
        question: "Toca la línea que intenta realizar una acción imposible por falta de orden lógico:",
        codeLines: [
          "servirCafeEnTaza();",
          "hervirAgua();",
          "apagarCafetera();"
        ],
        buggyLineIndex: 0,
        explanation: "No puedes servir el café en la taza antes de hervir el agua. En programación el orden de las instrucciones es crucial."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex5`,
        question: "Ordena los pasos lógicos para encender una bombilla inteligente:",
        tokens: ["detectarUsuario();", "evaluarHorario();", "if (esDeNoche)", "{ encenderLuz(); }"],
        correctOrder: ["detectarUsuario();", "evaluarHorario();", "if (esDeNoche)", "{ encenderLuz(); }"],
        explanation: "El flujo sigue un orden secuencial lógico: primero detecta, luego evalúa y finalmente actúa."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex6`,
        question: "¿Cómo procesa el computador las instrucciones escritas en un programa?",
        options: [
          "Línea por línea de arriba hacia abajo (secuencialmente), salvo condicionales o bucles",
          "Todas las líneas al mismo instante sin ningún orden",
          "De abajo hacia arriba siempre",
          "Elige líneas al azar cada vez que se ejecuta"
        ],
        correctAnswerIndex: 0,
        explanation: "La ejecución es secuencial por defecto: de arriba hacia abajo, línea por línea."
      }
    ];
  } else if (num === 2) {
    return [
      {
        type: "FLASHCARD",
        id: `${prefix}_ex1`,
        title: "Tu Primer Código: 'Hola Mundo'",
        codeSnippet: "public class Main {\n    public static void main(String[] args) {\n        System.out.println(\"¡Hola Mundo!\");\n    }\n}",
        explanation: "En Java todo código vive dentro de una clase. El método 'main' es la puerta de entrada obligatoria que la JVM busca para arrancar tu programa."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex2`,
        question: "¿Cuál es el punto de entrada que la JVM busca obligatoriamente para ejecutar un programa Java?",
        options: [
          "public static void main(String[] args)",
          "public void start()",
          "System.out.println()",
          "class ProgramInit()"
        ],
        correctAnswerIndex: 0,
        explanation: "El método 'public static void main(String[] args)' es la firma canónica y obligatoria del punto de entrada."
      },
      {
        type: "FILL_BLANK",
        id: `${prefix}_ex3`,
        question: "Completa el tipo de retorno 'void' para indicar que el método main no retorna valor:",
        codeTemplate: "public static ___ main(String[] args) {\n    System.out.println(\"Java\");\n}",
        correctAnswers: ["void"],
        options: ["void", "int", "boolean", "String"],
        explanation: "El método main de Java declara 'void' porque no devuelve ningún objeto ni valor al finalizar."
      },
      {
        type: "SPOT_THE_BUG",
        id: `${prefix}_ex4`,
        question: "Toca la línea que causará un error porque las palabras no están entre comillas dobles:",
        codeLines: [
          "public static void main(String[] args) {",
          "    System.out.println(Hola Mundo);",
          "}"
        ],
        buggyLineIndex: 1,
        explanation: "En Java, el texto literal siempre debe estar envuelto entre comillas dobles: \"Hola Mundo\"."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex5`,
        question: "Ordena los elementos de la firma del método main:",
        tokens: ["public", "static", "void", "main(String[] args)", "{", "}"],
        correctOrder: ["public", "static", "void", "main(String[] args)", "{", "}"],
        explanation: "public (accesible), static (no requiere instanciar), void (no devuelve valor), main (nombre reservado)."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex6`,
        question: "¿Qué carácter es obligatorio al final de cada sentencia en Java?",
        options: [
          "Punto y coma (;)",
          "Dos puntos (:)",
          "Punto (.)",
          "Signo de exclamación (!)"
        ],
        correctAnswerIndex: 0,
        explanation: "En Java, cada instrucción terminada debe cerrarse obligatoriamente con punto y coma (;)."
      }
    ];
  } else if (num === 3) {
    return [
      {
        type: "FLASHCARD",
        id: `${prefix}_ex1`,
        title: "Variables y Cajas de Memoria",
        codeSnippet: "int vidas = 3;\ndouble precio = 19.99;\nString usuario = \"Ana\";\nboolean activo = true;",
        explanation: "Una variable es un contenedor con nombre en memoria. Java tiene tipado estricto: debes definir el tipo antes de usar la variable."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex2`,
        question: "Si quieres almacenar el número de vidas de un jugador (ejemplo: 3), ¿qué tipo de dato debes usar?",
        options: [
          "int (para números enteros sin decimales)",
          "boolean (para valores de verdadero o falso)",
          "String (para cadenas de caracteres)",
          "double (para números con decimales)"
        ],
        correctAnswerIndex: 0,
        explanation: "El tipo primitivo 'int' es el contenedor eficiente para números enteros."
      },
      {
        type: "FILL_BLANK",
        id: `${prefix}_ex3`,
        question: "Completa la declaración de la variable para almacenar un número entero de puntos:",
        codeTemplate: "___ puntaje = 100;",
        correctAnswers: ["int"],
        options: ["int", "boolean", "char", "void"],
        explanation: "'int' es la palabra clave primitiva en Java para declarar números enteros de 32 bits."
      },
      {
        type: "SPOT_THE_BUG",
        id: `${prefix}_ex4`,
        question: "Toca la línea con incompatibilidad de tipos (intentar meter decimales en un entero):",
        codeLines: [
          "int precioEntero = 10;",
          "int precioConDecimales = 19.99;",
          "System.out.println(precioEntero);"
        ],
        buggyLineIndex: 1,
        explanation: "19.99 tiene parte decimal y NO cabe en un int. Debe declararse como double."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex5`,
        question: "Declara e inicializa una variable entera llamada edad con el valor 25:",
        tokens: ["int", "edad", "=", "25;"],
        correctOrder: ["int", "edad", "=", "25;"],
        explanation: "Estructura: Tipo (int) -> Nombre (edad) -> Asignación (=) -> Valor (25) -> Punto y coma (;)."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex6`,
        question: "¿Cuáles son los únicos dos valores posibles de una variable boolean?",
        options: [
          "true o false",
          "0 o 100",
          "'SI' o 'NO'",
          "null o undefined"
        ],
        correctAnswerIndex: 0,
        explanation: "Los booleanos en Java solo pueden tener los valores literales 'true' o 'false'."
      }
    ];
  } else if (num === 4) {
    return [
      {
        type: "FLASHCARD",
        id: `${prefix}_ex1`,
        title: "Condicionales: Tomando Decisiones con if / else",
        codeSnippet: "int edad = 18;\nif (edad >= 18) {\n    System.out.println(\"Mayor de edad\");\n} else {\n    System.out.println(\"Menor de edad\");\n}",
        explanation: "El bloque if evalúa una condición booleana. Si es verdadera ejecuta su bloque; de lo contrario salta al bloque else."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex2`,
        question: "¿Cuál es la diferencia crítica entre '=' y '==' en Java?",
        options: [
          "'=' es para ASIGNAR un valor y '==' es para COMPARAR si dos valores son iguales",
          "Son sinónimos idénticos",
          "'==' solo se usa en textos y '=' en números",
          "'=' es para comparar y '==' para asignar"
        ],
        correctAnswerIndex: 0,
        explanation: "'=' asigna el valor de la derecha a la variable. '==' compara si ambos lados son iguales devolviendo boolean."
      },
      {
        type: "FILL_BLANK",
        id: `${prefix}_ex3`,
        question: "Completa el operador de comparación para verificar si saldo es estrictamente mayor que cero:",
        codeTemplate: "if (saldo ___ 0) {\n    permitirRetiro();\n}",
        correctAnswers: [">"],
        options: [">", "=", "==", "+"],
        explanation: "El operador '>' evalúa si el valor de la izquierda es estrictamente superior al de la derecha."
      },
      {
        type: "SPOT_THE_BUG",
        id: `${prefix}_ex4`,
        question: "Toca la línea donde se usó erróneamente asignación en vez de comparación:",
        codeLines: [
          "int saldo = 100;",
          "if (saldo = 0) {",
          "    System.out.println(\"Sin saldo\");",
          "}"
        ],
        buggyLineIndex: 1,
        explanation: "En la línea 2 se escribió saldo = 0 (asignación int no convertible a boolean). Debe ser saldo == 0."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex5`,
        question: "Ordena una condición para verificar si el usuario tiene al menos 18 años:",
        tokens: ["if", "(edad >= 18)", "{", "permitirAcceso();", "}"],
        correctOrder: ["if", "(edad >= 18)", "{", "permitirAcceso();", "}"],
        explanation: "La condición de un if en Java siempre va encerrada entre paréntesis obligatorios."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex6`,
        question: "¿Qué operador representa 'Diferente de' o 'Distinto de' en Java?",
        options: [
          "!=",
          "<>",
          "not=",
          "=="
        ],
        correctAnswerIndex: 0,
        explanation: "El signo '!=' evalúa si dos operandos tienen valores distintos."
      }
    ];
  } else {
    return [
      {
        type: "FLASHCARD",
        id: `${prefix}_ex1`,
        title: "Bucles for y while: Repetición Automática",
        codeSnippet: "for (int i = 1; i <= 5; i++) {\n    System.out.println(\"Vuelta #\" + i);\n}",
        explanation: "Un bucle for repite un bloque de código un número conocido de veces usando inicialización, condición de parada e incremento."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex2`,
        question: "¿Qué es un 'Bucle Infinito' y por qué es peligroso?",
        options: [
          "Un ciclo cuya condición nunca se hace false, consumiendo el 100% de CPU y colgando la app",
          "Una optimización para acelerar Java",
          "Un bucle que solo corre sin internet",
          "Un ciclo con más de 100 líneas"
        ],
        correctAnswerIndex: 0,
        explanation: "Si la condición nunca se vuelve falsa, el hilo del procesador queda atrapado indefinidamente."
      },
      {
        type: "FILL_BLANK",
        id: `${prefix}_ex3`,
        question: "Completa el operador de incremento unitario para avanzar la variable 'i' en cada vuelta:",
        codeTemplate: "for (int i = 0; i < 5; i___) {\n    imprimir(i);\n}",
        correctAnswers: ["++"],
        options: ["++", "--", "+=", "=="],
        explanation: "'i++' incrementa el valor de la variable en 1 unidad en cada iteración del bucle."
      },
      {
        type: "SPOT_THE_BUG",
        id: `${prefix}_ex4`,
        question: "Toca el bucle while que se quedará atrapado en ciclo infinito porque olvidó avanzar:",
        codeLines: [
          "int contador = 0;",
          "while (contador < 3) {",
          "    System.out.println(\"Procesando...\");",
          "}"
        ],
        buggyLineIndex: 1,
        explanation: "Falta contador++ dentro del cuerpo del while. Como contador nunca cambia, la condición 0 < 3 es eternamente true."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex5`,
        question: "Ordena un bucle for clásico que repite 5 veces (del 0 al 4):",
        tokens: ["for (int i = 0;", "i < 5;", "i++)", "{", "hacerAlgo();", "}"],
        correctOrder: ["for (int i = 0;", "i < 5;", "i++)", "{", "hacerAlgo();", "}"],
        explanation: "El for tiene 3 secciones separadas por ';': inicio (int i = 0), condición (i < 5) e incremento (i++)."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex6`,
        question: "¿Cuántas veces se ejecuta el cuerpo de: for (int i = 0; i < 3; i++)?",
        options: [
          "Exactamente 3 veces (para i=0, i=1 e i=2)",
          "4 veces",
          "2 veces",
          "Infinitas veces"
        ],
        correctAnswerIndex: 0,
        explanation: "Se ejecuta para 0, 1 y 2. Al llegar a 3, (3 < 3) es false y sale del bucle tras 3 iteraciones."
      }
    ];
  }
}


// Master Knowledge Base for all 100 Levels across Worlds 1 to 10
// 100% Unique, dedicated exercises including the interactive FILL_BLANK dynamic
const levelContentDatabase = require('./curriculum_levels.json');

// Generates dedicated, non-repeating exercises for each level
function getWorldLevelExercises(world, level, lessonNumber) {
  const prefix = `${world.id}_l${lessonNumber}`;
  
  if (world.level === 0) {
    return getOnboardingExercises(level, lessonNumber, prefix);
  }

  const content = levelContentDatabase[prefix];
  if (!content) {
    throw new Error(`Missing level content for ${prefix}`);
  }

  return [
    // 1. Technical Core Flashcard
    {
      type: "FLASHCARD",
      id: `${prefix}_ex1`,
      title: `Núcleo Técnico: ${level.title}`,
      codeSnippet: content.snippet,
      explanation: content.theory
    },
    // 2. Core Multiple Choice
    {
      type: "MULTIPLE_CHOICE",
      id: `${prefix}_ex2`,
      question: content.mc1.question,
      options: content.mc1.options,
      correctAnswerIndex: content.mc1.correct,
      explanation: content.mc1.exp
    },
    // 3. NEW DYNAMIC: Fill in the Blank (Completa el código faltante)
    {
      type: "FILL_BLANK",
      id: `${prefix}_ex3`,
      question: content.fillBlank.question,
      codeTemplate: content.fillBlank.codeTemplate,
      correctAnswers: content.fillBlank.correctAnswers,
      options: content.fillBlank.options,
      explanation: content.fillBlank.exp
    },
    // 4. Spot the Bug
    {
      type: "SPOT_THE_BUG",
      id: `${prefix}_ex4`,
      question: `Inspección de código en ${level.title}: Toca la línea donde ocurrirá un fallo o comportamiento erróneo:`,
      codeLines: content.bug.lines,
      buggyLineIndex: content.bug.bugIndex,
      explanation: content.bug.exp
    },
    // 5. Idiomatic Token Reorder
    {
      type: "TOKEN_REORDER",
      id: `${prefix}_ex5`,
      question: content.tokens.question || `Sintaxis idiomática: Ordena las instrucciones para ${level.title}:`,
      tokens: [...content.tokens.tokens],
      correctOrder: [...content.tokens.correct],
      explanation: content.tokens.exp || `El orden estricto de sintaxis garantiza que el compilador de Java valide los tipos y contratos de la JVM.`
    },
    // 6. Senior / Architecture Multiple Choice
    {
      type: "MULTIPLE_CHOICE",
      id: `${prefix}_ex6`,
      question: content.mc2.question,
      options: content.mc2.options,
      correctAnswerIndex: content.mc2.correct,
      explanation: content.mc2.exp
    },
    // 7. Practical Production Rule Flashcard
    {
      type: "FLASHCARD",
      id: `${prefix}_ex7`,
      title: `Regla de Oro en Producción: ${level.title}`,
      codeSnippet: content.takeawaySnippet || `// Patrón verificado en arquitecturas reales para ${level.title}:\n${content.snippet.split('\n').slice(0, 3).join('\n')}`,
      explanation: content.takeawayExp || `En entrevistas Senior y auditorías de código en producción, fundamenta tu decisión técnica demostrando conocimiento sobre el ciclo de vida de los datos, el Garbage Collector y la prevención de fallos de concurrencia y latencia.`
    }
  ];
}

// Master Boss Battle Exercises (Each world has 5-7 dedicated high-stakes boss questions)
function getWorldBossExercises(worldId) {
  const bossDatabases = {
    "mundo_0": [
      {
        type: "MULTIPLE_CHOICE",
        id: "m0_boss_q1",
        question: "¿Cuál es el orden lógico estricto para calcular el promedio de 3 notas en un programa?",
        options: [
          "1. Leer las 3 notas -> 2. Sumarlas -> 3. Dividir entre 3 -> 4. Mostrar resultado",
          "1. Dividir entre 3 -> 2. Sumar -> 3. Mostrar",
          "1. Mostrar resultado -> 2. Calcular",
          "El orden es indiferente en la computadora"
        ],
        correctAnswerIndex: 0,
        explanation: "Un algoritmo requiere una secuencia causal estricta: no puedes procesar datos que aún no han sido capturados."
      },
      {
        type: "SPOT_THE_BUG",
        id: "m0_boss_q2",
        question: "Toca la línea que impedirá que el programa compile por sintaxis inválida:",
        codeLines: [
          "int edad = 20;",
          "String usuario = \"Ana\";",
          "boolean esMayor = true",
          "System.out.println(usuario);"
        ],
        buggyLineIndex: 2,
        explanation: "La línea 3 olvidó el punto y coma (;) obligatorio al final de la instrucción."
      },
      {
        type: "TOKEN_REORDER",
        id: "m0_boss_q3",
        question: "Construye una condición que verifique si el usuario tiene saldo y está activo:",
        tokens: ["if", "(saldo > 0", "&&", "activo == true)", "{", "permitirCompra();", "}"],
        correctOrder: ["if", "(saldo > 0", "&&", "activo == true)", "{", "permitirCompra();", "}"],
        explanation: "Combina dos comparaciones booleanas mediante el operador lógico '&&' (AND)."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: "m0_boss_q4",
        question: "¿Cuántas veces se imprimirá 'Java' en consola: for (int i = 1; i <= 4; i++) { print('Java'); }?",
        options: [
          "Exactamente 4 veces (para i=1, 2, 3 y 4)",
          "3 veces",
          "5 veces",
          "Infinitas veces"
        ],
        correctAnswerIndex: 0,
        explanation: "El contador arranca en 1 y va hasta 4 inclusive (<= 4), ejecutándose exactamente 4 veces."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: "m0_boss_q5",
        question: "¿Cuál es la función exacta de la JVM (Java Virtual Machine)?",
        options: [
          "Interpretar y ejecutar el Bytecode de Java en cualquier sistema operativo sin recompilar el código fuente",
          "Es un editor de texto para programadores",
          "Es un cable físico de red",
          "Es una base de datos en la nube"
        ],
        correctAnswerIndex: 0,
        explanation: "El lema 'Write Once, Run Anywhere' es posible porque la JVM traduce el bytecode estándar a instrucciones nativas del SO."
      }
    ],

    "mundo_1": [
      {
        type: "MULTIPLE_CHOICE",
        id: "m1_boss_q1",
        question: "¿Qué ocurre si ejecutas: Integer a = 128; Integer b = 128; boolean r = (a == b);?",
        options: [
          "r es false, porque 128 está fuera del IntegerCache (-128 a 127) y se crean dos objetos distintos en Heap",
          "r es true, porque tienen el mismo número",
          "Lanza NullPointerException",
          "Error de compilación"
        ],
        correctAnswerIndex: 0,
        explanation: "El IntegerCache solo reutiliza referencias entre -128 y 127. Para 128 se instancian dos objetos diferentes con distinta dirección de memoria."
      },
      {
        type: "SPOT_THE_BUG",
        id: "m1_boss_q2",
        question: "Toca la línea que provocará un desbordamiento aritmético imprevisto:",
        codeLines: [
          "int stockMaximo = Integer.MAX_VALUE;",
          "int stockTotal = stockMaximo + 1;",
          "System.out.println(stockTotal);"
        ],
        buggyLineIndex: 1,
        explanation: "Integer.MAX_VALUE + 1 sobrepasa el límite de 32 bits y se convierte en -2147483648 sin advertencia."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: "m1_boss_q3",
        question: "¿Cuál es la diferencia fundamental en el ciclo de vida de la memoria Stack vs Heap?",
        options: [
          "El Stack se libera automáticamente al terminar cada frame de método; el Heap depende de la recolección del Garbage Collector",
          "El Heap es privado de cada hilo y el Stack es compartido",
          "El Stack almacena objetos pesados y el Heap variables locales",
          "No hay diferencia de ciclo de vida"
        ],
        correctAnswerIndex: 0,
        explanation: "El Stack crece y se limpia automáticamente con la pila de llamadas. El Heap es compartido por todos los hilos y lo gestiona el GC."
      },
      {
        type: "TOKEN_REORDER",
        id: "m1_boss_q4",
        question: "Ordena la llamada nativa para copiar un array de forma óptima en memoria:",
        tokens: ["System.arraycopy(fuente,", "0,", "destino,", "0,", "fuente.length);"],
        correctOrder: ["System.arraycopy(fuente,", "0,", "destino,", "0,", "fuente.length);"],
        explanation: "System.arraycopy es una llamada nativa optimizada que copia bloques contiguos de memoria."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: "m1_boss_q5",
        question: "¿Qué efecto tiene aplicar la palabra clave 'final' a una referencia de objeto: final List<String> list = new ArrayList<>();?",
        options: [
          "Impide que la variable apunte a otro objeto, pero permite modificar el contenido interno de la lista",
          "Hace que la lista sea completamente inmutable impidiendo agregar elementos",
          "Lanza UnsupportedOperationException al llamar list.add()",
          "Elimina la lista del Heap"
        ],
        correctAnswerIndex: 0,
        explanation: "Final en una variable protege la referencia, no la mutabilidad interna del objeto instanciado."
      },
      {
        type: "SPOT_THE_BUG",
        id: "m1_boss_q6",
        question: "Toca la línea que generará un NullPointerException por unboxing implícito:",
        codeLines: [
          "Integer saldo = null;",
          "double comision = 2.5;",
          "double total = saldo + comision;"
        ],
        buggyLineIndex: 2,
        explanation: "Al sumar un Integer con un primitivo, Java invoca saldo.intValue(). Al ser null, lanza NullPointerException."
      }
    ],

    "mundo_2": [
      {
        type: "MULTIPLE_CHOICE",
        id: "m2_boss_q1",
        question: "¿Cuál es el contrato obligatorio entre los métodos equals() y hashCode()?",
        options: [
          "Si a.equals(b) es true, entonces a.hashCode() debe ser obligatoriamente igual a b.hashCode()",
          "Si dos objetos tienen el mismo hashCode, deben ser iguales con equals",
          "Deben devolver siempre números primos",
          "No tienen relación entre sí"
        ],
        correctAnswerIndex: 0,
        explanation: "Objetos iguales deben tener el mismo hashcode obligatoriamente para funcionar en tablas hash. La inversa no es obligatoria (puede haber colisiones)."
      },
      {
        type: "SPOT_THE_BUG",
        id: "m2_boss_q2",
        question: "Toca la línea que viola el encapsulamiento y arruina la inmutabilidad de la clase:",
        codeLines: [
          "public final class Carrito {",
          "    private final List<String> items = new ArrayList<>();",
          "    public List<String> getItems() { return this.items; }",
          "}"
        ],
        buggyLineIndex: 2,
        explanation: "Retornar la referencia directa mutable 'this.items' permite que clases externas modifiquen la lista con getItems().clear(). Debe devolverse List.copyOf() o Collections.unmodifiableList()."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: "m2_boss_q3",
        question: "¿Cómo se comporta el polimorfismo dinámico (Dynamic Dispatch) en Java?",
        options: [
          "La JVM consulta en tiempo de ejecución el tipo real del objeto en el Heap para invocar el método correspondiente de la subclase",
          "Se resuelve en tiempo de compilación con el tipo de la variable",
          "Invoca siempre el método de la superclase",
          "Solo funciona con clases finales"
        ],
        correctAnswerIndex: 0,
        explanation: "El Dynamic Method Dispatch usa la vtable del objeto en tiempo de ejecución para ejecutar la implementación correcta."
      },
      {
        type: "TOKEN_REORDER",
        id: "m2_boss_q4",
        question: "Construye la declaración de un Java record inmutable con validación compacta:",
        tokens: ["public", "record", "UserDto(Long", "id,", "String", "email)", "{", "Objects.requireNonNull(email);", "}"],
        correctOrder: ["public", "record", "UserDto(Long", "id,", "String", "email)", "{", "Objects.requireNonNull(email);", "}"],
        explanation: "Un record con constructor compacto permite validar los campos antes de asignarlos."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: "m2_boss_q5",
        question: "¿Por qué se desaconseja invocar métodos sobreescribibles (@Override) dentro del constructor de una superclase?",
        options: [
          "Porque el método de la subclase se ejecutará antes de que los atributos propios de la subclase hayan sido inicializados en memoria",
          "Porque produce un bucle infinito garantizado",
          "Porque el compilador borra el constructor",
          "Porque las subclases no tienen constructores"
        ],
        correctAnswerIndex: 0,
        explanation: "El constructor padre se ejecuta antes que el hijo. Si llama a un método sobreescrito que usa campos del hijo, estos aún valdrán 0 o null."
      },
      {
        type: "SPOT_THE_BUG",
        id: "m2_boss_q6",
        question: "Toca la línea que arrojará ClassCastException en tiempo de ejecución:",
        codeLines: [
          "Object obj = \"Mensaje de prueba\";",
          "if (obj instanceof String) {",
          "    Integer num = (Integer) obj;",
          "}"
        ],
        buggyLineIndex: 2,
        explanation: "Intentar castear un String a Integer provoca java.lang.ClassCastException."
      }
    ],

    "mundo_3": [
      {
        type: "MULTIPLE_CHOICE",
        id: "m3_boss_q1",
        question: "¿Cómo se resuelve el 'Problema del Diamante' cuando dos interfaces implementadas tienen el mismo método default?",
        options: [
          "La clase implementadora está obligada a sobrescribir el método y puede elegir llamar a InterfaceName.super.metodo()",
          "La JVM elige automáticamente la interfaz más corta",
          "Se compila ejecutando ambos métodos a la vez",
          "Se ignora el método en la clase"
        ],
        correctAnswerIndex: 0,
        explanation: "El compilador marca error de colisión de diamante hasta que la clase sobrescriba el método y resuelva la ambigüedad."
      },
      {
        type: "SPOT_THE_BUG",
        id: "m3_boss_q2",
        question: "Toca la línea con error en una jerarquía Sealed de Java 17:",
        codeLines: [
          "public sealed interface Forma permits Circulo, Cuadrado {}",
          "public final class Circulo implements Forma {}",
          "public class Cuadrado implements Forma {}"
        ],
        buggyLineIndex: 2,
        explanation: "Toda subclase de una sealed interface debe ser obligatoriamente 'final', 'sealed' o 'non-sealed'. La línea 3 olvidó el modificador."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: "m3_boss_q3",
        question: "¿Qué garantiza el Principio de Inversión de Dependencias (DIP) en arquitecturas enterprise?",
        options: [
          "Que los servicios dependan de interfaces abstractas y no de clases concretas, facilitando el cambio de proveedor y los tests con Mocks",
          "Que todas las clases tengan métodos estáticos",
          "Que no se puedan usar bases de datos",
          "Que los métodos sean privados"
        ],
        correctAnswerIndex: 0,
        explanation: "Desacopla la lógica de negocio de los detalles técnicos de bajo nivel."
      },
      {
        type: "TOKEN_REORDER",
        id: "m3_boss_q4",
        question: "Construye una Interfaz Funcional genérica válida:",
        tokens: ["@FunctionalInterface", "public", "interface", "Operacion<T>", "{", "T", "ejecutar(T", "entrada);", "}"],
        correctOrder: ["@FunctionalInterface", "public", "interface", "Operacion<T>", "{", "T", "ejecutar(T", "entrada);", "}"],
        explanation: "Una interfaz funcional declara exactamente un método abstracto."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: "m3_boss_q5",
        question: "¿Qué regla aplica Java si una superclase concreta y una interfaz definen el mismo método con idéntica firma?",
        options: [
          "Regla 'Class wins': La implementación de la clase concreta siempre tiene precedencia sobre el método default de la interfaz",
          "Regla 'Interface wins'",
          "Se anulan ambos métodos",
          "Lanza excepción al compilar"
        ],
        correctAnswerIndex: 0,
        explanation: "Los métodos de clases siempre ganan sobre los métodos default de las interfaces."
      },
      {
        type: "SPOT_THE_BUG",
        id: "m3_boss_q6",
        question: "Toca la línea que rompe la condición de @FunctionalInterface:",
        codeLines: [
          "@FunctionalInterface",
          "public interface Validador {",
          "    boolean validar(String token);",
          "    void reset();",
          "}"
        ],
        buggyLineIndex: 3,
        explanation: "Una interfaz funcional solo puede tener un único método abstracto. Tener dos (validar y reset) provoca error de compilación."
      }
    ]
  };

  if (bossDatabases[worldId]) {
    return bossDatabases[worldId];
  }

  // Generic boss battle generator for worlds 4 to 10
  return [
    {
      type: "MULTIPLE_CHOICE",
      id: `${worldId}_boss_q1`,
      question: `Examen de Certificación del ${worldId.toUpperCase()}: ¿Cuál es el principal trade-off de arquitectura en este dominio?`,
      options: [
        `Garantizar la resiliencia y el cumplimiento estricto de contratos de la JVM bajo alta concurrencia`,
        `No tiene ningún impacto en latencia ni en consumo de memoria`,
        `Solo aplica cuando no hay red`,
        `Fue eliminado en versiones modernas`
      ],
      correctAnswerIndex: 0,
      explanation: `Las decisiones de arquitectura en Java siempre balancean latencia, memoria Heap y consistencia.`
    },
    {
      type: "SPOT_THE_BUG",
      id: `${worldId}_boss_q2`,
      question: `Inspección de Fallo Crítico en ${worldId.toUpperCase()}: Toca la línea donde ocurre la excepción en producción:`,
      codeLines: [
        "String sesion = null;",
        "if (sesion != null && sesion.length() > 0) {",
        "    procesar(sesion);",
        "}"
      ],
      buggyLineIndex: 0,
      explanation: "Tener cuidado con referencias null en producción."
    },
    {
      type: "TOKEN_REORDER",
      id: `${worldId}_boss_q3`,
      question: `Construye la instrucción fundamental de este módulo:`,
      tokens: ["var", "resultado", "=", "servicio.ejecutarTransaccion();"],
      correctOrder: ["var", "resultado", "=", "servicio.ejecutarTransaccion();"],
      explanation: `Estructura estándar de ejecución de servicios transaccionales.`
    },
    {
      type: "MULTIPLE_CHOICE",
      id: `${worldId}_boss_q4`,
      question: `¿Qué buena práctica previene fallos silenciosos en entornos enterprise?`,
      options: [
        `Programar contra interfaces, favorecer la inmutabilidad y registrar las excepciones completas con traza`,
        `Usar variables estáticas mutables en toda la aplicación`,
        `Comerse las excepciones con catch vacíos`,
        `Instanciar dependencias manualmente dentro de los métodos`
      ],
      correctAnswerIndex: 0,
      explanation: `Inmutabilidad, contratos por interfaz y observabilidad garantizan estabilidad en producción.`
    },
    {
      type: "MULTIPLE_CHOICE",
      id: `${worldId}_boss_q5`,
      question: `¿Cuál es el impacto en la memoria Heap al trabajar con este módulo bajo millones de peticiones?`,
      options: [
        `Debe cuidarse la creación excesiva de objetos de corta duración para evitar pausas frecuentes del Garbage Collector (Stop-The-World)`,
        `La memoria Heap nunca se llena`,
        `No tiene ninguna relación con el Garbage Collector`,
        `El sistema operativo libera la memoria automáticamente sin ayuda de Java`
      ],
      correctAnswerIndex: 0,
      explanation: `El allocation rate (tasa de asignación) en el Heap define la frecuencia de recolección del GC en sistemas de alto tráfico.`
    }
  ];
}

module.exports = {
  worldsData,
  getWorldLevelExercises,
  getWorldBossExercises
};
