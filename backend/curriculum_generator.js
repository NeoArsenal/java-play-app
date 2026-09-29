// Generator for the complete 10-World, 100-Level JavaPlay Curriculum
const fs = require('fs');
const path = require('path');

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
      title: "Desafío Final del Onboarding: El Examen de Bienvenida al Mundo Java",
      description: "Demuestra que ya entiendes la lógica básica de programación antes de entrar a la JVM.",
      passThreshold: 80
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
      title: "Desafío Final del Mundo 1: Certificación en Fundamentos Nucleares",
      description: "Supera este examen contrarreloj de 5 preguntas críticas para desbloquear el Mundo 2.",
      passThreshold: 80
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
      title: "Desafío Final del Mundo 2: Examen de Arquitectura y Diseño POO",
      description: "Demuestra tu dominio modelando contratos y objetos robustos.",
      passThreshold: 80
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
      title: "Desafío Final del Mundo 3: Examen de Contratos & Abstracción",
      description: "Demuestra cómo crear contratos limpios sin acoplamiento.",
      passThreshold: 80
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
      title: "Desafío Final del Mundo 4: Examen de Resiliencia y Depuración",
      description: "Diagnostica fallos silenciosos y diseña flujos tolerantes a errores.",
      passThreshold: 80
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
      title: "Desafío Final del Mundo 5: Examen de Rendimiento en Colecciones",
      description: "Optimiza memoria y tiempo de búsqueda O(1) con colecciones eficientes.",
      passThreshold: 80
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
      title: "Desafío Final del Mundo 6: Examen de Programación Funcional",
      description: "Escribe pipelines de datos limpios, sin efectos secundarios.",
      passThreshold: 80
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
      title: "Desafío Final del Mundo 7: Examen de Arquitectura Spring Boot IoC",
      description: "Resuelve dependencias circulares y gestiona el ciclo de vida de los Beans.",
      passThreshold: 80
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
      title: "Desafío Final del Mundo 8: Examen de Diseño de APIs de Producción",
      description: "Diseña endpoints idempotentes con manejo robusto de excepciones.",
      passThreshold: 80
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
      title: "Desafío Final del Mundo 9: Examen de Rendimiento JPA & Hibernate",
      description: "Elimina cuellos de botella y consultas redundantes a la base de datos.",
      passThreshold: 80
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
      title: "Desafío Final del Mundo 10: El Gran Examen Senior / Staff Architect",
      description: "El filtro técnico definitivo para validar que estás listo para liderar equipos Java.",
      passThreshold: 85
    }
  }
];

function generateCurriculum() {
  const totalL = worldsData.reduce((acc, w) => acc + w.levels.length, 0);
  const result = {
    totalWorlds: worldsData.length,
    totalLevels: totalL,
    worlds: []
  };

  worldsData.forEach((wData, wIdx) => {
    const worldObj = {
      id: wData.id,
      level: wData.level,
      title: wData.title,
      badge: wData.badge,
      description: wData.description,
      color: wData.color,
      bossChallenge: wData.bossChallenge,
      lessons: []
    };

    wData.levels.forEach((lvl, lvlIdx) => {
      const lessonNumber = lvlIdx + 1;
      const lessonObj = {
        id: `${wData.id}_l${lessonNumber}`,
        levelNumber: lessonNumber,
        title: lvl.title,
        xpReward: 20 + lessonNumber * 2,
        exercises: generateLevelExercises(wData, lvl, lessonNumber)
      };
      worldObj.lessons.push(lessonObj);
    });

    result.worlds.push(worldObj);
  });

  return result;
}

function generateOnboardingExercises(level, num, prefix) {
  if (num === 1) {
    // Nivel 1: ¿Qué es Programar y cómo piensa una Computadora?
    return [
      {
        type: "FLASHCARD",
        id: `${prefix}_ex1`,
        title: "¿Qué es Programar?",
        codeSnippet: "// Un algoritmo es una receta ordenada de pasos:\n1. Calentar agua\n2. Colocar café en la taza\n3. Verter agua caliente y revolver",
        explanation: "Una computadora es una máquina increíblemente veloz, pero carece de sentido común. Programar es escribir instrucciones lógicas, precisas y ordenadas (un algoritmo) para que la máquina resuelva un problema sin equivocarse."
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
        type: "TOKEN_REORDER",
        id: `${prefix}_ex3`,
        question: "Ordena los pasos lógicos para preparar un café antes de programar:",
        tokens: ["Hervir agua", "Poner café en taza", "Verter agua caliente", "Disfrutar café"],
        correctOrder: ["Hervir agua", "Poner café en taza", "Verter agua caliente", "Disfrutar café"],
        explanation: "El pensamiento computacional requiere definir el orden exacto de ejecución. No podemos servir agua caliente antes de hervirla."
      },
      {
        type: "SPOT_THE_BUG",
        id: `${prefix}_ex4`,
        question: "Toca el paso que rompe el sentido común y causará un desastre (Bug de lógica):",
        codeLines: [
          "Despertar y levantarse de la cama",
          "Cepillarse los dientes con detergente de ropa",
          "Tomar un desayuno nutritivo"
        ],
        buggyLineIndex: 1,
        explanation: "Las computadoras no cuestionan lo que les ordenas: si pones una instrucción dañina o ilógica, la ejecutarán tal cual y causarán un error grave (Bug)."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex5`,
        question: "¿En qué lenguaje 'piensa' y opera físicamente el procesador (CPU) de tu equipo?",
        options: [
          "En español o inglés cotidiano",
          "En código binario: solo ceros (0) y unos (1) correspondientes a pulsos eléctricos",
          "En fórmulas matemáticas escritas a mano",
          "Directamente en archivos de texto Word"
        ],
        correctAnswerIndex: 1,
        explanation: "A nivel físico, los transistores del microprocesador solo reconocen dos estados: encendido (1) y apagado (0). Lenguajes como Java nos permiten escribir en código legible para humanos que luego se traduce a binario."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex6`,
        question: "Ordena el ciclo de vida de una aplicación Java desde que la escribes hasta que funciona:",
        tokens: ["Código Fuente (.java)", "Compilador (javac)", "Bytecode (.class)", "JVM (Ejecución)"],
        correctOrder: ["Código Fuente (.java)", "Compilador (javac)", "Bytecode (.class)", "JVM (Ejecución)"],
        explanation: "Tú escribes código legible (.java), el compilador lo traduce a Bytecode (.class) y la Máquina Virtual de Java (JVM) lo ejecuta velozmente."
      },
      {
        type: "SPOT_THE_BUG",
        id: `${prefix}_ex7`,
        question: "Toca el paso absurdo que pondría en peligro la vida en este algoritmo peatonal:",
        codeLines: [
          "Mirar a ambos lados de la calle",
          "Cerrar los ojos y cruzar corriendo a ciegas",
          "Llegar a la acera de enfrente sano y salvo"
        ],
        buggyLineIndex: 1,
        explanation: "La computadora no puede deducir que cerrar los ojos es peligroso; por eso el programador debe ser sumamente riguroso y nunca dejar cabos sueltos."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex8`,
        question: "¿Qué es un 'Bug' en la industria del software?",
        options: [
          "Un fallo, error o defecto en el código que produce un resultado incorrecto o inesperado",
          "Una herramienta para acelerar el internet",
          "Un tipo de computadora para videojuegos",
          "Una función secreta del lenguaje Java"
        ],
        correctAnswerIndex: 0,
        explanation: "El término 'Bug' (bicho) se popularizó en 1947 cuando una polilla atrapada en un relé causó un fallo en la computadora Mark II de Harvard. Hoy refiere a cualquier error en el software."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex9`,
        question: "Ordena los pasos del método del buen programador:",
        tokens: ["Entender el problema", "Diseñar la solución", "Escribir el código", "Probar y depurar"],
        correctOrder: ["Entender el problema", "Diseñar la solución", "Escribir el código", "Probar y depurar"],
        explanation: "El 80% del éxito en programación ocurre antes de teclear la primera línea: entender el problema a fondo y pensar el plan de acción."
      },
      {
        type: "FLASHCARD",
        id: `${prefix}_ex10`,
        title: "Regla de Oro del Programador Principiante",
        codeSnippet: "// La computadora es una aliada fiel:\nif (instruccionClara) {\n    resultadoExitoso();\n}",
        explanation: "La computadora no te odia ni adivina tus pensamientos: hace con exactitud milimétrica lo que tú le indicas. Si algo falla, solo debes revisar las instrucciones con paciencia y método."
      }
    ];
  } else if (num === 2) {
    // Nivel 2: Tu Primer Programa: 'Hola Mundo' y la función main
    return [
      {
        type: "FLASHCARD",
        id: `${prefix}_ex1`,
        title: "Estructura de un Programa en Java",
        codeSnippet: "public class MiPrograma {\n    public static void main(String[] args) {\n        System.out.println(\"¡Hola Mundo!\");\n    }\n}",
        explanation: "En Java, TODO código vive dentro de una clase (class). Para que un programa arranque, necesita una puerta de entrada obligatoria: el método public static void main(String[] args)."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex2`,
        question: "¿Cuál es el nombre del método especial que Java busca para iniciar la ejecución de tu aplicación?",
        options: [
          "public static void main(String[] args)",
          "public void start()",
          "public static void executeProgram()",
          "private void run()"
        ],
        correctAnswerIndex: 0,
        explanation: "public static void main(String[] args) es el estándar formal e inamovible donde la Máquina Virtual de Java inicia todo programa."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex3`,
        question: "Ordena la instrucción para mostrar 'Hola Mundo' en la pantalla:",
        tokens: ["System.out.println(", "\"Hola Mundo!\"", ");"],
        correctOrder: ["System.out.println(", "\"Hola Mundo!\"", ");"],
        explanation: "System.out.println() envía texto a la consola estándar y añade un salto de línea al final."
      },
      {
        type: "SPOT_THE_BUG",
        id: `${prefix}_ex4`,
        question: "Toca la línea donde falta el signo obligatorio que cierra toda instrucción en Java:",
        codeLines: [
          "public static void main(String[] args) {",
          "    System.out.println(\"Hola amigos\")",
          "}"
        ],
        buggyLineIndex: 1,
        explanation: "En Java toda sentencia simple DEBE finalizar con punto y coma (;). La línea 2 olvidó el ';' al final."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex5`,
        question: "¿Para qué sirve el punto y coma (;) al final de cada sentencia en Java?",
        options: [
          "Para avisarle al compilador dónde termina una orden o instrucción específica",
          "Es solo decorativo y opcional en las nuevas versiones",
          "Para pausar el programa durante 1 segundo",
          "Para cambiar el color del texto a verde"
        ],
        correctAnswerIndex: 0,
        explanation: "El punto y coma (;) es el delimitador oficial de sentencias. Sin él, Java no sabe dónde termina una orden y dónde comienza la siguiente."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex6`,
        question: "Ordena la declaración de una clase pública llamada Saludo:",
        tokens: ["public", "class", "Saludo", "{", "}"],
        correctOrder: ["public", "class", "Saludo", "{", "}"],
        explanation: "La palabra reservada public class crea un bloque contenedor con llaves de apertura { y cierre }."
      },
      {
        type: "SPOT_THE_BUG",
        id: `${prefix}_ex7`,
        question: "Toca la línea que causará un error porque las palabras no están entre comillas:",
        codeLines: [
          "public static void main(String[] args) {",
          "    System.out.println(Hola Mundo);",
          "}"
        ],
        buggyLineIndex: 1,
        explanation: "En Java, el texto literal siempre debe estar envuelto entre comillas dobles: \"Hola Mundo\". De lo contrario, el compilador cree que son variables desconocidas."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex8`,
        question: "¿Qué diferencia existe entre System.out.print() y System.out.println()?",
        options: [
          "println añade un salto de línea automático al terminar de escribir; print deja el cursor en el mismo renglón",
          "print solo escribe números y println solo escribe letras",
          "println es solo para servidores y print para celulares",
          "Son exactamente iguales, sin diferencia alguna"
        ],
        correctAnswerIndex: 0,
        explanation: "'ln' significa 'line'. println salta a la siguiente línea luego de imprimir, mientras que print sigue escribiendo inmediatamente a continuación."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex9`,
        question: "Ordena los elementos de la firma del método main:",
        tokens: ["public", "static", "void", "main(String[] args)", "{", "}"],
        correctOrder: ["public", "static", "void", "main(String[] args)", "{", "}"],
        explanation: "public (accesible), static (no requiere crear instancia), void (no devuelve valor), main (nombre reservado)."
      },
      {
        type: "FLASHCARD",
        id: `${prefix}_ex10`,
        title: "¡Hito Desbloqueado: Tu Primer Código Funcional!",
        codeSnippet: "// ¡Ya sabes la estructura de cualquier programa Java!\npublic class Hola {\n    public static void main(String[] args) {\n        System.out.println(\"¡Soy programador Java!\");\n    }\n}",
        explanation: "Has dominado la clase, el método main, la salida a consola y el punto y coma. ¡Es momento de aprender a guardar datos en variables!"
      }
    ];
  } else if (num === 3) {
    // Nivel 3: Variables y Cajas de Memoria (int, double, String, boolean)
    return [
      {
        type: "FLASHCARD",
        id: `${prefix}_ex1`,
        title: "Variables: Cajas de Memoria con Nombre y Tipo",
        codeSnippet: "int edad = 20;           // Número entero\ndouble precio = 19.99;   // Decimal o con coma\nString usuario = \"Ana\";  // Texto\nboolean activo = true;   // true (verdadero) o false",
        explanation: "Una variable es un contenedor en la memoria RAM para guardar datos. En Java debes declarar qué tipo de información va a contener antes de usarla (tipado estricto)."
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
        explanation: "El tipo primitivo 'int' es el contenedor ideal y eficiente para números enteros como 1, 2, 3 o 100."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex3`,
        question: "Declara e inicializa una variable entera llamada edad con el valor 25:",
        tokens: ["int", "edad", "=", "25;"],
        correctOrder: ["int", "edad", "=", "25;"],
        explanation: "La estructura en Java es: Tipo (int) -> Nombre (edad) -> Asignación (=) -> Valor (25) -> Punto y coma (;)."
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
        explanation: "19.99 tiene parte decimal y NO cabe en una variable de tipo 'int'. Para guardar decimales debes usar 'double'."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex5`,
        question: "¿Cuáles son los únicos dos valores posibles que puede almacenar una variable boolean?",
        options: [
          "true o false",
          "Cualquier número entre 0 y 100",
          "Las palabras 'SI' y 'NO' entre comillas",
          "Cualquier letra del abecedario"
        ],
        correctAnswerIndex: 0,
        explanation: "Los booleanos representan lógica binaria pura: solo pueden ser 'true' (verdadero) o 'false' (falso)."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex6`,
        question: "Declara una variable de tipo texto para el nombre del usuario:",
        tokens: ["String", "nombre", "=", "\"Carlos\";"],
        correctOrder: ["String", "nombre", "=", "\"Carlos\";"],
        explanation: "String se escribe con S mayúscula y su valor literal siempre va delimitado por comillas dobles."
      },
      {
        type: "SPOT_THE_BUG",
        id: `${prefix}_ex7`,
        question: "Toca la línea con error por olvidar las comillas en un texto:",
        codeLines: [
          "boolean tieneAcceso = true;",
          "String ciudad = Lima;",
          "System.out.println(ciudad);"
        ],
        buggyLineIndex: 1,
        explanation: "En la línea 2, Lima debe escribirse como \"Lima\". Sin comillas, Java busca una variable inexistente llamada Lima."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex8`,
        question: "¿Qué ocurre si intentas hacer: int numero = \"cinco\"; en Java?",
        options: [
          "El compilador marca error de incompatibilidad de tipos y no compila el programa",
          "Java convierte la palabra 'cinco' automáticamente en el número 5",
          "El programa se ejecuta pero imprime un signo de interrogación",
          "La variable se crea con valor 0 de forma silenciosa"
        ],
        correctAnswerIndex: 0,
        explanation: "Java es un lenguaje fuertemente tipado: una caja creada para enteros (int) nunca aceptará texto (String). El compilador te protege antes de ejecutar."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex9`,
        question: "Declara una variable decimal con el valor de Pi:",
        tokens: ["double", "pi", "=", "3.1416;"],
        correctOrder: ["double", "pi", "=", "3.1416;"],
        explanation: "El tipo double permite guardar números reales con precisión decimal separando con un punto (.)."
      },
      {
        type: "FLASHCARD",
        id: `${prefix}_ex10`,
        title: "Resumen de las 4 Cajas Esenciales de Java",
        codeSnippet: "int     -> 1, 42, -500       (Enteros)\ndouble  -> 3.14, 99.90       (Decimales)\nboolean -> true, false       (Decisiones)\nString  -> \"Hola Dev\"        (Texto)",
        explanation: "El 90% de los datos que manejarás en tu carrera se apoyan en estos cuatro tipos fundamentales. ¡Ahora pasemos a tomar decisiones con ellos!"
      }
    ];
  } else if (num === 4) {
    // Nivel 4: Tomando Decisiones: Condicionales (if, else y comparaciones)
    return [
      {
        type: "FLASHCARD",
        id: `${prefix}_ex1`,
        title: "Bifurcaciones: Tomando Decisiones con if / else",
        codeSnippet: "int edad = 18;\nif (edad >= 18) {\n    System.out.println(\"Mayor de edad\");\n} else {\n    System.out.println(\"Menor de edad\");\n}",
        explanation: "Un condicional 'if' evalúa una condición booleana (true o false). Si es verdadera, ejecuta el código entre las llaves; de lo contrario salta al bloque 'else'."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex2`,
        question: "¿Cuál es la diferencia crítica entre el signo '=' y el signo '==' en Java?",
        options: [
          "'=' es para ASIGNAR un valor a una variable y '==' es para COMPARAR si dos valores son iguales",
          "Son sinónimos idénticos y se pueden usar indistintamente",
          "'==' solo funciona para texto y '=' solo para números",
          "'=' se usa solo en el else y '==' solo en el if"
        ],
        correctAnswerIndex: 0,
        explanation: "¡El error más común del novato! Con a = 5 asignas el número 5. Con a == 5 preguntas si a es igual a 5."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex3`,
        question: "Ordena una condición para verificar si el usuario tiene al menos 18 años:",
        tokens: ["if", "(edad >= 18)", "{", "permitirAcceso();", "}"],
        correctOrder: ["if", "(edad >= 18)", "{", "permitirAcceso();", "}"],
        explanation: "La condición de un if siempre va envuelta obligatoriamente entre paréntesis ()."
      },
      {
        type: "SPOT_THE_BUG",
        id: `${prefix}_ex4`,
        question: "Toca la línea donde se usó el operador erróneo de asignación en vez de comparación:",
        codeLines: [
          "int saldo = 100;",
          "if (saldo = 0) {",
          "    System.out.println(\"Sin saldo\");",
          "}"
        ],
        buggyLineIndex: 1,
        explanation: "En la línea 2 se puso 'saldo = 0' (asignación). Para comparar igualdad debe usarse 'saldo == 0'."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex5`,
        question: "Si la variable nota = 15, ¿qué imprimirá este código?\nif (nota >= 11) { System.out.print(\"Aprobado\"); } else { System.out.print(\"Reprobado\"); }",
        options: [
          "Aprobado",
          "Reprobado",
          "AprobadoReprobado",
          "No imprime nada"
        ],
        correctAnswerIndex: 0,
        explanation: "Como 15 >= 11 es 'true', entra exclusivamente al bloque del if e ignora por completo el else."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex6`,
        question: "Ordena una estructura if con su bloque alternativo else:",
        tokens: ["if (tieneLlave)", "{ abrirPuerta(); }", "else", "{ tocarTimbre(); }"],
        correctOrder: ["if (tieneLlave)", "{ abrirPuerta(); }", "else", "{ tocarTimbre(); }"],
        explanation: "El bloque else solo se ejecuta si la condición del if resultó falsa."
      },
      {
        type: "SPOT_THE_BUG",
        id: `${prefix}_ex7`,
        question: "Toca la línea con error de sintaxis al olvidar los paréntesis de la condición:",
        codeLines: [
          "int bateria = 20;",
          "if bateria < 15 {",
          "    System.out.println(\"Cargar equipo\");",
          "}"
        ],
        buggyLineIndex: 1,
        explanation: "En Java es mandatorio que la condición del if esté encerrada entre paréntesis: if (bateria < 15)."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex8`,
        question: "¿Qué operador de comparación usamos en Java para verificar si dos números son DIFERENTES o distintos?",
        options: [
          "!=",
          "<>",
          "==",
          "not="
        ],
        correctAnswerIndex: 0,
        explanation: "El signo de admiración (!) representa negación. Por ello, '!=' significa 'distinto de' o 'no igual'."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex9`,
        question: "Ordena la condición para verificar si la clave es incorrecta:",
        tokens: ["if", "(clave", "!=", "1234)", "{ alerta(); }"],
        correctOrder: ["if", "(clave", "!=", "1234)", "{ alerta(); }"],
        explanation: "Si la clave es diferente de 1234, la condición evalúa a true y se dispara la alerta."
      },
      {
        type: "FLASHCARD",
        id: `${prefix}_ex10`,
        title: "Guía Rápida de Operadores de Comparación",
        codeSnippet: "==  -> Igual que\n!=  -> Distinto que\n>   -> Mayor que\n<   -> Menor que\n>=  -> Mayor o igual que\n<=  -> Menor o igual que",
        explanation: "Estos operadores son la base de la toma de decisiones lógicas en cualquier aplicación del mundo real."
      }
    ];
  } else {
    // Nivel 5: Repitiendo Tareas: Bucles y Ciclos (for y while)
    return [
      {
        type: "FLASHCARD",
        id: `${prefix}_ex1`,
        title: "Bucles: Repetición y Automatización",
        codeSnippet: "// Imprime 5 veces sin repetir código a mano:\nfor (int i = 1; i <= 5; i++) {\n    System.out.println(\"Vuelta #\" + i);\n}",
        explanation: "Los bucles permiten ejecutar un bloque de código muchas veces de forma automática. Un bucle 'for' se utiliza cuando sabemos cuántas repeticiones queremos realizar."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex2`,
        question: "¿Qué es un 'Bucle Infinito' y por qué es peligroso para tu programa?",
        options: [
          "Un ciclo cuya condición nunca se vuelve falsa, consumiendo 100% de CPU y congelando la aplicación",
          "Una técnica de Java para duplicar la velocidad de procesamiento",
          "Un bucle especial que solo se ejecuta cuando no hay internet",
          "Una pantalla animada de carga"
        ],
        correctAnswerIndex: 0,
        explanation: "Si la condición de salida nunca llega a ser false, el procesador se queda atrapado en el bucle para siempre, congelando la computadora."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex3`,
        question: "Ordena un bucle for clásico que repite 5 veces (del 0 al 4):",
        tokens: ["for (int i = 0;", "i < 5;", "i++)", "{", "hacerAlgo();", "}"],
        correctOrder: ["for (int i = 0;", "i < 5;", "i++)", "{", "hacerAlgo();", "}"],
        explanation: "El for tiene 3 partes separadas por punto y coma: 1) inicio (int i = 0), 2) condición (i < 5), 3) incremento (i++)."
      },
      {
        type: "SPOT_THE_BUG",
        id: `${prefix}_ex4`,
        question: "Toca el bucle while que se quedará atrapado en un ciclo infinito porque olvidó avanzar:",
        codeLines: [
          "int contador = 0;",
          "while (contador < 3) {",
          "    System.out.println(\"Procesando...\");",
          "}"
        ],
        buggyLineIndex: 1,
        explanation: "Dentro del while nunca se incrementa 'contador' (falta contador++). Como contador siempre vale 0, la condición (0 < 3) es eternamente verdadera."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex5`,
        question: "¿Qué hace exactamente el operador 'i++' en Java?",
        options: [
          "Incrementa en 1 el valor de la variable i (equivalente a i = i + 1)",
          "Multiplica el valor de i por 2",
          "Reinicia la variable i a 0",
          "Convierte el número en un texto"
        ],
        correctAnswerIndex: 0,
        explanation: "'i++' es la forma abreviada e idiomática en Java para sumar 1 al valor de una variable numérica."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex6`,
        question: "Ordena un bucle while que descuenta vidas en un juego:",
        tokens: ["while", "(vidas > 0)", "{", "jugarRonda();", "vidas--;", "}"],
        correctOrder: ["while", "(vidas > 0)", "{", "jugarRonda();", "vidas--;", "}"],
        explanation: "El bucle while se repite mientras vidas sea mayor que 0. 'vidas--' resta 1 cada vez hasta llegar a 0 y salir."
      },
      {
        type: "SPOT_THE_BUG",
        id: `${prefix}_ex7`,
        question: "Toca la línea con error de dirección en el contador que genera un ciclo sin fin:",
        codeLines: [
          "for (int i = 0; i < 10; i--) {",
          "    System.out.println(\"Paso: \" + i);",
          "}"
        ],
        buggyLineIndex: 0,
        explanation: "Si i empieza en 0 y haces i--, sus valores serán -1, -2, -3... ¡siempre menores que 10! Debió ser i++ para avanzar hacia el 10."
      },
      {
        type: "MULTIPLE_CHOICE",
        id: `${prefix}_ex8`,
        question: "¿Cuántas veces se ejecutará el cuerpo de este bucle: for (int i = 0; i < 3; i++)?",
        options: [
          "Exactamente 3 veces (para i = 0, i = 1 e i = 2)",
          "4 veces",
          "2 veces",
          "Infinitas veces"
        ],
        correctAnswerIndex: 0,
        explanation: "Iteración 1: i=0. Iteración 2: i=1. Iteración 3: i=2. Al llegar a i=3, la condición (3 < 3) es falsa y el bucle termina habiéndose ejecutado 3 veces."
      },
      {
        type: "TOKEN_REORDER",
        id: `${prefix}_ex9`,
        question: "Construye una cuenta regresiva para el despegue de un cohete:",
        tokens: ["for (int i = 5;", "i > 0;", "i--)", "{", "cuentaRegresiva(i);", "}"],
        correctOrder: ["for (int i = 5;", "i > 0;", "i--)", "{", "cuentaRegresiva(i);", "}"],
        explanation: "Empieza en 5, comprueba que sea mayor que 0 y decrementa con i-- hasta llegar al lanzamiento."
      },
      {
        type: "FLASHCARD",
        id: `${prefix}_ex10`,
        title: "🎓 ¡Graduación Oficial del Onboarding!",
        codeSnippet: "// Ya dominas la base de todo software:\n1. Pensamiento algorítmico\n2. Estructura de programas y main\n3. Variables y tipos (int, double, String, boolean)\n4. Decisiones lógicas con if / else\n5. Automatización con bucles for / while",
        explanation: "¡Enhorabuena! Has superado los 5 niveles del Onboarding para principiantes. Ahora tienes los cimientos firmes para sumergirte en los Fundamentos Nucleares de Java en el Mundo 1."
      }
    ];
  }
}

function generateLevelExercises(world, level, num) {
  const prefix = `${world.id}_l${num}`;
  
  if (world.level === 0) {
    return generateOnboardingExercises(level, num, prefix);
  }
  
  // 1. Flashcard (Micro-teoría nuclear)
  const ex1 = {
    type: "FLASHCARD",
    id: `${prefix}_ex1`,
    title: `Concepto Clave: ${level.title}`,
    codeSnippet: getSnippetForLevel(world.level, num),
    explanation: `En entrevistas técnicas para roles Java, este principio define cómo se comporta el runtime. Entender la diferencia entre la definición en código y la ejecución en memoria es el factor que distingue a un desarrollador Junior de un Senior.`
  };

  // 2. Multiple Choice (Pregunta Conceptual)
  const ex2 = {
    type: "MULTIPLE_CHOICE",
    id: `${prefix}_ex2`,
    question: `En una entrevista técnica te preguntan sobre ${level.title}: ¿Cuál de las siguientes afirmaciones describe el comportamiento real en producción?`,
    options: [
      `No tiene impacto en rendimiento ni en consumo de memoria`,
      `Garantiza la correcta ejecución respetando el contrato de la JVM y evitando cuellos de botella`,
      `Solo aplica cuando se utiliza una base de datos relacional`,
      `Es una característica obsoleta que fue eliminada a partir de Java 8`
    ],
    correctAnswerIndex: 1,
    explanation: `La opción B es la correcta porque refleja fielmente las especificaciones de la JVM y las buenas prácticas de ingeniería en sistemas de alta concurrencia.`
  };

  // 3. Token Reorder (Sintaxis / Programación)
  const tokensInfo = getTokensForLevel(world.level, num);
  const ex3 = {
    type: "TOKEN_REORDER",
    id: `${prefix}_ex3`,
    question: `Ordena los tokens para formar la instrucción exacta correspondiente a ${level.title}:`,
    tokens: [...tokensInfo.tokens],
    correctOrder: [...tokensInfo.correctOrder],
    explanation: `El orden sintáctico estricto en Java garantiza que el compilador verifique los tipos y reserve los recursos adecuados.`
  };

  // 4. Spot The Bug (Inspección de código)
  const bugInfo = getBugForLevel(world.level, num);
  const ex4 = {
    type: "SPOT_THE_BUG",
    id: `${prefix}_ex4`,
    question: `Inspección de código: Toca la línea exacta donde ocurrirá un fallo en tiempo de ejecución o compilación:`,
    codeLines: bugInfo.lines,
    buggyLineIndex: bugInfo.bugIndex,
    explanation: bugInfo.explanation
  };

  // 5. Multiple Choice Avanzada (Filtro Senior)
  const ex5 = {
    type: "MULTIPLE_CHOICE",
    id: `${prefix}_ex5`,
    question: `Pregunta de Filtro Senior sobre ${level.title}: ¿Qué trade-off o riesgo arquitectónico existe al implementar este patrón?`,
    options: [
      `Posible contención de recursos, overhead de memoria o riesgo de inconsistencia si no se respetan los contratos`,
      `El framework dejará de compilar permanentemente`,
      `Ninguno, es una solución universalmente óptima sin desventajas`,
      `Solo puede usarse en entornos de desarrollo local, nunca en servidores cloud`
    ],
    correctAnswerIndex: 0,
    explanation: `En sistemas distribuidos y arquitecturas empresariales, cada decisión técnica implica un balance entre latencia, uso de memoria y complejidad operativa.`
  };

  // 6. Token Reorder Avanzado
  const ex6 = {
    type: "TOKEN_REORDER",
    id: `${prefix}_ex6`,
    question: `Construye la declaración completa aplicando modificadores y tipo seguro:`,
    tokens: ["public", "static", "final", "String", "CONFIG_KEY", "=", "\"ACTIVE\";"],
    correctOrder: ["public", "static", "final", "String", "CONFIG_KEY", "=", "\"ACTIVE\";"],
    explanation: `La combinación de public static final crea una constante inmutable compartida a nivel de clase.`
  };

  // 7. Spot the Bug Adicional
  const ex7 = {
    type: "SPOT_THE_BUG",
    id: `${prefix}_ex7`,
    question: `Toca la línea que genera una excepción de concurrencia o de puntero nulo:`,
    codeLines: [
      "Optional<String> data = Optional.empty();",
      "String result = data.get();",
      "System.out.println(result);"
    ],
    buggyLineIndex: 1,
    explanation: `Llamar a .get() directamente en un Optional vacío lanza java.util.NoSuchElementException. Siempre usa orElse(), orElseGet() o orElseThrow().`
  };

  // 8. Multiple Choice de Buenas Prácticas
  const ex8 = {
    type: "MULTIPLE_CHOICE",
    id: `${prefix}_ex8`,
    question: `¿Cuál es la mejor práctica recomendada al trabajar con este módulo?`,
    options: [
      `Minimizar la mutabilidad, favorecer la inyección por constructor y programar contra interfaces`,
      `Usar variables globales estáticas mutables en toda la aplicación`,
      `Capturar Throwable con bloques catch vacíos`,
      `Instanciar dependencias manualmente con 'new' dentro de los métodos de servicio`
    ],
    correctAnswerIndex: 0,
    explanation: `Favorecer inmutabilidad, inyección por constructor y contratos mediante interfaces garantiza testabilidad y desacoplamiento en código enterprise.`
  };

  // 9. Sintaxis de Cierre
  const ex9 = {
    type: "TOKEN_REORDER",
    id: `${prefix}_ex9`,
    question: `Ordena el retorno seguro utilizando el operador ternario:`,
    tokens: ["return", "value", "!=", "null", "?", "value", ":", "\"DEFAULT\";"],
    correctOrder: ["return", "value", "!=", "null", "?", "value", ":", "\"DEFAULT\";"],
    explanation: `El operador ternario permite asignar o retornar un valor predeterminado seguro evitando NullPointerException.`
  };

  // 10. Flashcard de Maestría (Síntesis)
  const ex10 = {
    type: "FLASHCARD",
    id: `${prefix}_ex10`,
    title: `Regla de Oro del Senior: ${level.title}`,
    codeSnippet: `// Principio aplicado en producción:\n@Service\npublic class EngineService {\n    // Lógica desacoplada y thread-safe\n}`,
    explanation: `Al responder en una entrevista técnica, no solo expliques el 'cómo', sino el 'por qué': menciona el impacto en memoria, cómo interactúa con el Garbage Collector y por qué tu solución es óptima para soportar tráfico real.`
  };

  return [ex1, ex2, ex3, ex4, ex5, ex6, ex7, ex8, ex9, ex10];
}

function getSnippetForLevel(worldNum, levelNum) {
  if (worldNum === 1) {
    return `int id = 42;\nString key = "JAVA_PLAY";\nfinal double PI = 3.14159;`;
  } else if (worldNum === 2) {
    return `public record UserDto(Long id, String email) {}\n// Inmutable y con equals/hashCode autogenerado`;
  } else if (worldNum === 3) {
    return `@FunctionalInterface\npublic interface Calculator {\n    int compute(int a, int b);\n}`;
  } else if (worldNum === 4) {
    return `try (var resource = new AutoCloseableService()) {\n    resource.execute();\n} catch (DomainException e) {\n    log.error("Fallo controlado", e);\n}`;
  } else if (worldNum === 5) {
    return `Map<String, Integer> cache = new ConcurrentHashMap<>();\ncache.putIfAbsent("token", 100);`;
  } else if (worldNum === 6) {
    return `List<String> names = users.stream()\n    .filter(User::isActive)\n    .map(User::getName)\n    .toList();`;
  } else if (worldNum === 7) {
    return `@Service\npublic class PaymentService {\n    private final PaymentGateway gateway;\n    public PaymentService(PaymentGateway gateway) {\n        this.gateway = gateway;\n    }\n}`;
  } else if (worldNum === 8) {
    return `@GetMapping("/api/users/{id}")\npublic ResponseEntity<UserDto> getUser(@PathVariable Long id) {\n    return ResponseEntity.ok(service.findById(id));\n}`;
  } else if (worldNum === 9) {
    return `@Query("SELECT u FROM User u JOIN FETCH u.roles WHERE u.id = :id")\nOptional<User> findWithRoles(@Param("id") Long id);`;
  } else {
    return `Thread.startVirtualThread(() -> {\n    service.processHeavyTask();\n});`;
  }
}

function getTokensForLevel(worldNum, levelNum) {
  if (worldNum === 1) {
    return {
      tokens: ["int", "total", "=", "100;"],
      correctOrder: ["int", "total", "=", "100;"]
    };
  } else if (worldNum === 2) {
    return {
      tokens: ["public", "class", "Car", "implements", "Vehicle", "{}"],
      correctOrder: ["public", "class", "Car", "implements", "Vehicle", "{}"]
    };
  } else if (worldNum === 3) {
    return {
      tokens: ["default", "void", "log()", "{", "System.out.println();", "}"],
      correctOrder: ["default", "void", "log()", "{", "System.out.println();", "}"]
    };
  } else if (worldNum === 7) {
    return {
      tokens: ["@Service", "public", "class", "OrderService", "{}"],
      correctOrder: ["@Service", "public", "class", "OrderService", "{}"]
    };
  } else if (worldNum === 8) {
    return {
      tokens: ["@GetMapping(\"/items\")", "public", "List<Item>", "getItems()", "{}"],
      correctOrder: ["@GetMapping(\"/items\")", "public", "List<Item>", "getItems()", "{}"]
    };
  } else {
    return {
      tokens: ["var", "result", "=", "service.execute();"],
      correctOrder: ["var", "result", "=", "service.execute();"]
    };
  }
}

function getBugForLevel(worldNum, levelNum) {
  return {
    lines: [
      "String text = null;",
      "int length = text.length();",
      "System.out.println(length);"
    ],
    bugIndex: 1,
    explanation: "En la línea 2 se intenta invocar el método .length() sobre una referencia que apunta a null, provocando java.lang.NullPointerException."
  };
}

// Generate curriculum and write to assets/data/curriculum.json
const fullCurriculum = generateCurriculum();
const outputPath = path.join(__dirname, '../assets/data/curriculum.json');
fs.writeFileSync(outputPath, JSON.stringify(fullCurriculum, null, 2), 'utf8');

console.log(`✅ Curriculum completo de 10 Mundos x 10 Niveles (100 niveles totales) generado exitosamente.`);
console.log(`   Ruta: ${outputPath}`);
console.log(`   Total de mundos: ${fullCurriculum.worlds.length}`);
console.log(`   Total de niveles: ${fullCurriculum.worlds.reduce((acc, w) => acc + w.lessons.length, 0)}`);
