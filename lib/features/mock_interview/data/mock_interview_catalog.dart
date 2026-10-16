import '../domain/models/interview_question.dart';

class MockInterviewCatalog {
  static const List<InterviewQuestion> allQuestions = [
    // ==========================================
    // MUNDO 0: Onboarding & Fundamentos (Principiante)
    // ==========================================
    InterviewQuestion(
      id: "mock_m0_q1",
      worldId: "mundo_0",
      category: "Fundamentos Básicos",
      title: "Variables y Tipado Fuerte",
      question:
          "En una entrevista te piden explicar con tus propias palabras: ¿Qué es una variable en memoria y por qué Java exige especificar el tipo de dato (como int o String)?",
      timeLimitSeconds: 45,
      keyConcepts: ["caja / contenedor", "memoria RAM", "tipo de dato", "seguridad / prevención de errores"],
      idealResponse:
          "Una variable es un espacio reservado en la memoria RAM con un nombre para almacenar un dato. Java es de tipado estático y fuerte, lo que significa que debemos especificar el tipo (como int o String) para que el compilador sepa cuánta memoria reservar y qué operaciones son válidas, previniendo errores antes de ejecutar el programa.",
      followUpQuestion: "¿Cuál es la diferencia entre un tipo primitivo como 'int' y un texto como 'String' en Java?",
    ),
    InterviewQuestion(
      id: "mock_m0_q2",
      worldId: "mundo_0",
      category: "Control de Flujo",
      title: "Condicionales vs Bucles",
      question:
          "Explica la diferencia lógica fundamental entre una estructura condicional (if/else) y un bucle (while o for). ¿Qué riesgo existe si no se define bien una condición de parada?",
      timeLimitSeconds: 45,
      keyConcepts: ["condición booleana", "ejecución única", "repetición / iteración", "bucle infinito"],
      idealResponse:
          "El 'if/else' evalúa una condición booleana una sola vez para decidir qué camino tomar. Un bucle 'while' o 'for' repite un bloque de código continuamente mientras la condición sea verdadera. Si la condición nunca se vuelve falsa, se produce un bucle infinito que puede congelar el programa y saturar la CPU.",
      followUpQuestion: "¿En qué situación prefieres utilizar un bucle 'for' en lugar de un 'while'?",
    ),
    InterviewQuestion(
      id: "mock_m0_q3",
      worldId: "mundo_0",
      category: "Estructura del Programa",
      title: "El método main y 'public static void'",
      question:
          "¿Por qué todo programa en Java comienza en 'public static void main(String[] args)' y qué significa cada una de esas palabras clave?",
      timeLimitSeconds: 50,
      keyConcepts: ["punto de entrada", "public accesible por JVM", "static sin instanciar", "void no retorna valor"],
      idealResponse:
          "Es el punto de entrada que busca la JVM para iniciar la ejecución. 'public' permite que la JVM lo ejecute desde fuera de la clase; 'static' permite llamarlo sin crear antes un objeto de la clase; 'void' indica que no devuelve ningún valor; y 'main' es el nombre estándar reconocido por la máquina virtual.",
      followUpQuestion: "¿Para qué sirve el parámetro 'String[] args' en la firma del método main?",
    ),
    InterviewQuestion(
      id: "mock_m0_q4",
      worldId: "mundo_0",
      category: "Tipos de Datos",
      title: "Primitivos vs Objetos",
      question:
          "¿Cuál es la diferencia entre los tipos primitivos como int y double, y los objetos como Integer y Double en Java? ¿Cuándo usarías cada uno?",
      timeLimitSeconds: 45,
      keyConcepts: ["stack vs heap", "autoboxing", "null safety", "wrappers"],
      idealResponse:
          "Los tipos primitivos (int, double, boolean) se almacenan directamente en el stack y son más eficientes en memoria y velocidad. Los objetos wrapper (Integer, Double) se almacenan en el heap, pueden ser null y son necesarios cuando se usan colecciones genéricas como List<Integer>. Java realiza autoboxing automático al convertir entre ellos, pero esto tiene un costo de rendimiento.",
      followUpQuestion: "¿Qué es el autoboxing y cuándo puede causar problemas de rendimiento?",
    ),
    InterviewQuestion(
      id: "mock_m0_q5",
      worldId: "mundo_0",
      category: "Operadores",
      title: "Operadores Aritméticos y Lógicos",
      question:
          "Explica el operador módulo (%) y da un ejemplo de cuándo lo usarías en un problema real. También explica la diferencia entre && y &.",
      timeLimitSeconds: 45,
      keyConcepts: ["residuo de división", "par/impar", "short-circuit evaluation", "bitwise vs lógico"],
      idealResponse:
          "El operador % devuelve el residuo de una división entera. Por ejemplo, para saber si un número es par: numero % 2 == 0. En cuanto a && vs &: el doble && (AND lógico) usa evaluación de cortocircuito, es decir, si el primer operando es false, el segundo no se evalúa. El simple & (AND bit a bit) evalúa ambos operandos siempre, lo cual puede causar NullPointerException si el segundo operando podría fallar.",
      followUpQuestion: "¿Cómo usarías el operador módulo para rotar elementos en un array circular?",
    ),
    InterviewQuestion(
      id: "mock_m0_q6",
      worldId: "mundo_0",
      category: "Fundamentos",
      title: "Compilación vs Interpretación y la JVM",
      question:
          "¿Cómo funciona el proceso de compilación en Java? ¿Qué es el bytecode y cuál es el rol de la JVM en la ejecución multiplataforma?",
      timeLimitSeconds: 55,
      keyConcepts: ["javac", "bytecode .class", "JVM como intérprete", "Write Once Run Anywhere"],
      idealResponse:
          "En Java, el compilador 'javac' transforma el código fuente (.java) en bytecode (.class), que es un formato intermedio independiente de la plataforma. La JVM (Java Virtual Machine) interpreta y ejecuta este bytecode, traduciéndolo en tiempo real a instrucciones nativas del sistema operativo y hardware específico. Esto es lo que permite que el mismo código Java funcione en Windows, Linux o macOS sin recompilarse.",
      followUpQuestion: "¿Qué es el JIT (Just-In-Time) Compiler y cómo mejora el rendimiento de la JVM?",
    ),
    InterviewQuestion(
      id: "mock_m0_q7",
      worldId: "mundo_0",
      category: "Estructura",
      title: "Clases como contenedores de lógica",
      question:
          "¿Por qué en Java todo el código debe estar dentro de una clase? ¿Qué es una clase conceptualmente y cómo se relaciona con los objetos?",
      timeLimitSeconds: 50,
      keyConcepts: ["plantilla / molde", "instanciación con new", "atributos y métodos", "encapsulamiento básico"],
      idealResponse:
          "En Java, la clase es la unidad fundamental de organización del código. Conceptualmente, una clase es un molde o plantilla que define estructura (atributos) y comportamiento (métodos). Un objeto es una instancia concreta de esa clase creada en memoria con 'new'. Java es puramente orientado a objetos, por lo que todo debe estar dentro de una clase para mantener encapsulamiento y reutilización.",
      followUpQuestion: "¿Qué diferencia hay entre un atributo de instancia y un atributo estático en una clase?",
    ),

    // ==========================================
    // MUNDO 1: JVM Internals & Fundamentos Nucleares
    // ==========================================
    InterviewQuestion(
      id: "mock_m1_q1",
      worldId: "mundo_1",
      category: "JVM Internals & Memoria",
      title: "Stack vs Heap y Diagnóstico de OOM",
      question:
          "Explica la diferencia entre la memoria Stack y Heap en la JVM. ¿Puede ocurrir una fuga de memoria (Memory Leak) en Java a pesar del Garbage Collector? ¿Cómo sucede?",
      timeLimitSeconds: 60,
      keyConcepts: ["stack para frames y variables locales", "heap para objetos", "GC roots / referencias vivas", "memory leak por referencias estáticas"],
      idealResponse:
          "El Stack almacena frames de ejecución de métodos y variables locales de forma LIFO; cada hilo tiene su propio stack. El Heap almacena todos los objetos creados con 'new' y es compartido. El GC solo recolecta objetos sin referencias activas. Un memory leak ocurre cuando se mantienen referencias a objetos que ya no son necesarios, por ejemplo, en colecciones estáticas que crecen indefinidamente.",
      followUpQuestion: "¿Cómo diagnosticarías un OutOfMemoryError: Java heap space en producción?",
    ),
    InterviewQuestion(
      id: "mock_m1_q2",
      worldId: "mundo_1",
      category: "String Internals",
      title: "Inmutabilidad de String y String Pool",
      question:
          "¿Por qué la clase String en Java es inmutable? ¿Qué es el String Pool y qué diferencia hay entre 'new String()' y un literal de String?",
      timeLimitSeconds: 60,
      keyConcepts: ["inmutabilidad y seguridad en hilos", "String pool en heap", "intern()", "== vs .equals()"],
      idealResponse:
          "String es inmutable porque sus caracteres no pueden modificarse tras la creación. Esto garantiza seguridad en entornos multihilo, permite reutilización en el String Pool y es necesario para usar Strings como claves en HashMap. El String Pool es un área del heap donde Java reutiliza literales idénticos. Con 'new String()' se crea siempre un objeto nuevo fuera del pool. Por eso, para comparar contenido se usa .equals() y no ==.",
      followUpQuestion: "¿Por qué es una mala práctica concatenar Strings con + dentro de un bucle?",
    ),
    InterviewQuestion(
      id: "mock_m1_q3",
      worldId: "mundo_1",
      category: "Excepciones",
      title: "Excepciones Checked vs Unchecked",
      question:
          "¿Cuál es la diferencia entre una excepción Checked y una Unchecked en Java? ¿En qué casos crearías una excepción personalizada de cada tipo?",
      timeLimitSeconds: 55,
      keyConcepts: ["Checked extiende Exception", "Unchecked extiende RuntimeException", "manejo obligatorio vs opcional", "excepciones de dominio"],
      idealResponse:
          "Las Checked exceptions extienden Exception y el compilador obliga a manejarlas con try-catch o declararlas en throws. Se usan para errores recuperables donde el llamador puede tomar una acción alternativa, como IOException. Las Unchecked extienden RuntimeException, son errores de programación como NullPointerException o IllegalArgumentException que no deberían ocurrir en código correcto.",
      followUpQuestion: "¿Por qué las excepciones de Spring Framework son mayormente Unchecked?",
    ),
    InterviewQuestion(
      id: "mock_m1_q4",
      worldId: "mundo_1",
      category: "Tipos y Casting",
      title: "Casting de tipos y ClassCastException",
      question:
          "Explica la diferencia entre casting implícito (widening) y explícito (narrowing) en Java. ¿Qué precaución debes tomar antes de hacer un downcast para evitar ClassCastException?",
      timeLimitSeconds: 55,
      keyConcepts: ["widening automático", "narrowing requiere cast explícito", "instanceof antes del downcast", "pérdida de datos en narrowing"],
      idealResponse:
          "El widening (de tipo más estrecho a más amplio, ej. int a double) es automático y seguro. El narrowing (de double a int) requiere cast explícito y puede perder datos. En herencia, el upcasting (subclase a superclase) es automático. El downcast requiere verificar con instanceof antes de castear para evitar ClassCastException en runtime. En Java 16+ se puede usar pattern matching: if (obj instanceof String s) { s.length(); }.",
      followUpQuestion: "¿Qué ventaja ofrece el pattern matching de instanceof sobre el enfoque tradicional?",
    ),
    InterviewQuestion(
      id: "mock_m1_q5",
      worldId: "mundo_1",
      category: "Operadores Avanzados",
      title: "Operadores bit a bit y desplazamiento",
      question:
          "¿Cuándo usarías operadores bit a bit (&, |, ^, <<, >>) en Java? Da un ejemplo práctico de un caso de uso real.",
      timeLimitSeconds: 60,
      keyConcepts: ["máscaras de bits para flags", "desplazamiento para multiplicar/dividir por 2", "flags de permisos", "optimización de rendimiento"],
      idealResponse:
          "Los operadores bit a bit se usan cuando se necesita eficiencia extrema o manipulación directa de flags. Ejemplo práctico: un sistema de permisos donde READ=1, WRITE=2, EXECUTE=4. Con OR se combinan: int perms = READ | WRITE; Con AND se verifica: if ((perms & READ) != 0). El desplazamiento << n equivale a multiplicar por 2^n y es más eficiente que la multiplicación en contextos de bajo nivel.",
      followUpQuestion: "¿Cómo implementarías un conjunto de flags de permisos usando operadores de bits en Java?",
    ),
    InterviewQuestion(
      id: "mock_m1_q6",
      worldId: "mundo_1",
      category: "Garbage Collection",
      title: "Algoritmos del Garbage Collector en la JVM",
      question:
          "Describe cómo funciona el Garbage Collector de Java. ¿Qué diferencia hay entre el GC Generacional y el G1GC? ¿Cuándo elegirías ZGC?",
      timeLimitSeconds: 70,
      keyConcepts: ["Eden, Survivor, Old Gen", "Minor GC vs Full GC", "G1GC para latencia predecible", "ZGC para latencia ultra-baja"],
      idealResponse:
          "El GC generacional divide el heap en Young (Eden + Survivors) y Old Generation. Los objetos jóvenes mueren rápido (Minor GC muy frecuente). Los que sobreviven N ciclos promueven a Old Gen (Full GC más costoso). G1GC divide el heap en regiones y puede interrumpir el GC pausando solo algunas regiones para latencias predecibles. ZGC ofrece pausas sub-milisegundo haciendo casi todo el trabajo de forma concurrente, ideal para sistemas de trading de alta frecuencia.",
      followUpQuestion: "¿Qué es el Stop-The-World y cómo los GC modernos minimizan su impacto?",
    ),
    InterviewQuestion(
      id: "mock_m1_q7",
      worldId: "mundo_1",
      category: "JVM Avanzado",
      title: "ClassLoader y carga dinámica de clases",
      question:
          "¿Cómo funciona el sistema de ClassLoader en la JVM? ¿Qué es la delegación de carga padre-hijo y cómo se relaciona con el aislamiento en frameworks como Spring o Tomcat?",
      timeLimitSeconds: 70,
      keyConcepts: ["Bootstrap, Extension, Application ClassLoader", "delegación parent-first", "ClassLoader custom para plugins", "aislamiento de versiones"],
      idealResponse:
          "La JVM usa una jerarquía de ClassLoaders: Bootstrap (carga java.lang.*), Extension (jars de ext/), Application (classpath de la aplicación). Cuando se carga una clase, el loader delega al padre primero (parent-first), solo carga él mismo si el padre no la encuentra. Tomcat usa ClassLoaders separados por webapp para aislar dependencias entre aplicaciones. Spring Boot crea un URLClassLoader propio para cargar el fat jar de forma eficiente.",
      followUpQuestion: "¿Cómo implementarías un sistema de plugins con ClassLoaders para cargar código en caliente sin reiniciar la JVM?",
    ),

    // ==========================================
    // MUNDO 2: Control de Flujo & Algoritmos
    // ==========================================
    InterviewQuestion(
      id: "mock_m2_q1",
      worldId: "mundo_2",
      category: "Algoritmos de Búsqueda",
      title: "Búsqueda Binaria y complejidad O(log n)",
      question:
          "Explica el algoritmo de búsqueda binaria. ¿Por qué su complejidad es O(log n) y cuál es el prerequisito para poder aplicarlo?",
      timeLimitSeconds: 60,
      keyConcepts: ["array ordenado", "dividir a la mitad en cada paso", "O(log n)", "mid = low + (high-low)/2"],
      idealResponse:
          "La búsqueda binaria requiere un array ordenado. Compara el elemento buscado con el elemento del medio. Si es menor, descarta la mitad derecha; si es mayor, descarta la izquierda. En cada paso elimina la mitad de los elementos restantes. Como divide el problema a la mitad en cada iteración, necesita log₂(n) pasos para n elementos. Importante: calcular mid como low+(high-low)/2 y no (low+high)/2 para evitar overflow de int.",
      followUpQuestion: "¿Cómo adaptarías la búsqueda binaria para encontrar el primer elemento que cumple una condición en un array?",
    ),
    InterviewQuestion(
      id: "mock_m2_q2",
      worldId: "mundo_2",
      category: "Recursividad",
      title: "Recursividad vs Iteración y Tail Recursion",
      question:
          "¿Cuándo prefieres recursividad sobre iteración? ¿Qué es el Tail Call Optimization y por qué Java no lo implementa? ¿Cómo evitarías un StackOverflowError en un algoritmo recursivo profundo?",
      timeLimitSeconds: 65,
      keyConcepts: ["caso base obligatorio", "call stack", "tail call optimization ausente en JVM", "convertir a iterativo con Stack explícita"],
      idealResponse:
          "La recursividad es más legible para problemas naturalmente recursivos como árboles o divide y vencerás. El TCO permite que el compilador reutilice el stack frame cuando la llamada recursiva es la última operación, evitando stack overflow. La JVM no implementa TCO por decisión de diseño. Para árboles o grafos muy profundos, se puede convertir la recursión en iteración usando una Stack<> explícita en el heap.",
      followUpQuestion: "¿Cómo convertirías el recorrido recursivo de un árbol binario en un recorrido iterativo?",
    ),
    InterviewQuestion(
      id: "mock_m2_q3",
      worldId: "mundo_2",
      category: "Manejo de Excepciones",
      title: "Excepciones en Flujo de Negocio",
      question:
          "¿Es una buena práctica usar excepciones para controlar el flujo normal de la aplicación? ¿Cuál es el impacto en rendimiento y alternativas modernas en Java?",
      timeLimitSeconds: 60,
      keyConcepts: ["excepciones costosas por stack trace", "Optional como alternativa", "Result pattern", "validación anticipada"],
      idealResponse:
          "No es buena práctica usar excepciones para flujo normal porque crear una excepción captura el stack trace, lo cual es costoso (miles de instrucciones de CPU). La alternativa moderna es Optional<T> para valores que pueden ser nulos, o un patrón Result<T, E> inspirado en Rust para representar éxito o fallo con tipos. También se puede usar validación anticipada con guard clauses antes de ejecutar lógica.",
      followUpQuestion: "¿Cómo implementarías un patrón Result en Java usando generics?",
    ),
    InterviewQuestion(
      id: "mock_m2_q4",
      worldId: "mundo_2",
      category: "Estructuras de Datos",
      title: "Complejidad de Operaciones en Estructuras Comunes",
      question:
          "Para un ArrayList, LinkedList, HashMap y TreeMap: ¿cuál es la complejidad Big-O de insertar, buscar y eliminar? ¿Cuándo elegirías cada uno?",
      timeLimitSeconds: 65,
      keyConcepts: ["ArrayList O(1) acceso por índice", "LinkedList O(1) inserción al inicio", "HashMap O(1) promedio", "TreeMap O(log n) siempre ordenado"],
      idealResponse:
          "ArrayList: acceso por índice O(1), inserción al final O(1) amortizado, inserción en medio O(n), búsqueda O(n). LinkedList: inserción al inicio/final O(1), acceso por índice O(n). HashMap: inserción y búsqueda O(1) promedio con buena función hash, O(n) peor caso. TreeMap: todas las operaciones O(log n), garantiza orden natural de las claves. Elegir según patrón de acceso predominante.",
      followUpQuestion: "¿Qué ocurre internamente en un HashMap cuando dos claves tienen el mismo hashCode?",
    ),
    InterviewQuestion(
      id: "mock_m2_q5",
      worldId: "mundo_2",
      category: "Algoritmos de Ordenamiento",
      title: "Ordenamiento y el método Arrays.sort",
      question:
          "¿Qué algoritmo usa internamente Arrays.sort() en Java para primitivos vs objetos? ¿Cuándo es estable un algoritmo de ordenamiento y por qué importa?",
      timeLimitSeconds: 60,
      keyConcepts: ["Dual-Pivot Quicksort para primitivos", "TimSort para objetos", "estabilidad: orden relativo de iguales", "estabilidad importante para ordenamientos múltiples"],
      idealResponse:
          "Arrays.sort() para primitivos usa Dual-Pivot Quicksort (O(n log n) promedio), que no es estable pero es más rápido en la práctica. Para objetos usa TimSort (híbrido de Merge Sort e Insertion Sort), que SÍ es estable. Un algoritmo es estable si mantiene el orden relativo de elementos con el mismo valor. Esto importa cuando se ordena por múltiples criterios en pasos sucesivos.",
      followUpQuestion: "¿Cómo implementarías un Comparator personalizado para ordenar una lista de empleados primero por departamento y luego por salario?",
    ),
    InterviewQuestion(
      id: "mock_m2_q6",
      worldId: "mundo_2",
      category: "Patrones Avanzados",
      title: "Dynamic Programming y Memoización",
      question:
          "¿Qué es la Programación Dinámica y cuándo la aplicas? Explica la diferencia entre memoización (top-down) y tabulación (bottom-up).",
      timeLimitSeconds: 70,
      keyConcepts: ["subproblemas superpuestos", "subestructura óptima", "memoización con HashMap/array", "tabulación iterativa sin recursión"],
      idealResponse:
          "La Programación Dinámica se aplica cuando un problema tiene subproblemas solapados (se resuelven múltiples veces) y subestructura óptima. Memoización (top-down): recursividad con caché para evitar recalcular. Ejemplo: Fibonacci con HashMap<Integer,Long>. Tabulación (bottom-up): construir la solución iterativamente desde los casos base. Es más eficiente en memoria al evitar el call stack. Para Fibonacci, se puede hacer con solo 2 variables.",
      followUpQuestion: "¿Cómo resolverías el problema de la mochila 0-1 usando programación dinámica?",
    ),
    InterviewQuestion(
      id: "mock_m2_q7",
      worldId: "mundo_2",
      category: "Recursión Avanzada",
      title: "Backtracking y exploración de espacios de búsqueda",
      question:
          "¿Qué es el backtracking y cómo lo aplicarías para resolver un Sudoku o el problema de las N-Reinas? ¿Cómo lo diferencias de la fuerza bruta pura?",
      timeLimitSeconds: 70,
      keyConcepts: ["exploración con retroceso", "poda de ramas inválidas", "estado parcial y decisión", "complejidad exponencial mitigada por poda"],
      idealResponse:
          "El backtracking explora un árbol de decisiones, intentando cada opción y retrocediendo cuando detecta que la opción actual no puede llevar a una solución. La diferencia con fuerza bruta es la poda: antes de explorar una rama se verifica si todavía puede llevar a una solución válida. En N-Reinas: se coloca una reina por fila y se verifican conflictos de columna y diagonal antes de continuar con la siguiente fila.",
      followUpQuestion: "¿Cómo optimizarías el backtracking de N-Reinas usando conjuntos de bits para verificar conflictos en O(1)?",
    ),

    // ==========================================
    // MUNDO 3: POO Avanzada
    // ==========================================
    InterviewQuestion(
      id: "mock_m3_q1",
      worldId: "mundo_3",
      category: "Principios SOLID",
      title: "Single Responsibility y Open/Closed Principle",
      question:
          "¿Cómo aplicas el Principio de Responsabilidad Única (SRP) y el Principio Abierto/Cerrado (OCP) en el diseño de una clase de servicio en Java?",
      timeLimitSeconds: 65,
      keyConcepts: ["una razón para cambiar", "cerrado para modificación", "abierto para extensión", "interfaces y herencia"],
      idealResponse:
          "SRP: una clase debe tener solo una razón para cambiar. Un UserService que valida, persiste y envía emails viola SRP. Se separa en UserService, UserValidator y EmailNotificationService. OCP: el comportamiento debe extenderse sin modificar el código existente. Se logra programando contra interfaces: en lugar de if (type == 'email') ... se define una interface NotificationStrategy y se inyectan implementaciones.",
      followUpQuestion: "¿Cómo violaciones del SRP impactan en la testabilidad del código con JUnit y Mockito?",
    ),
    InterviewQuestion(
      id: "mock_m3_q2",
      worldId: "mundo_3",
      category: "Polimorfismo",
      title: "Polimorfismo en tiempo de ejecución y dispatch dinámico",
      question:
          "Explica el dispatch dinámico de métodos en Java. ¿Cómo determina la JVM qué método ejecutar cuando tienes una referencia de tipo padre que apunta a un objeto hijo?",
      timeLimitSeconds: 60,
      keyConcepts: ["vtable por clase", "binding tardío en runtime", "overriding vs overloading", "final para deshabilitar override"],
      idealResponse:
          "La JVM usa una virtual method table (vtable) para cada clase, una tabla de punteros a métodos. Cuando se llama a un método mediante una referencia padre, la JVM consulta la vtable del objeto real en runtime (binding tardío o dynamic dispatch). El método que se ejecuta es el de la clase concreta del objeto, no el de la referencia. Los métodos final y static usan binding estático (early binding) y son más rápidos al resolverse en compile time.",
      followUpQuestion: "¿Por qué no es recomendable llamar a métodos polimórficos desde un constructor?",
    ),
    InterviewQuestion(
      id: "mock_m3_q3",
      worldId: "mundo_3",
      category: "Herencia vs Composición",
      title: "Herencia vs Composición: cuándo usar cada uno",
      question:
          "¿Cuándo prefieres composición sobre herencia en el diseño orientado a objetos? Da un ejemplo concreto donde el cambio de herencia a composición mejora el diseño.",
      timeLimitSeconds: 65,
      keyConcepts: ["herencia rompe encapsulamiento del padre", "composición favorece bajo acoplamiento", "has-a vs is-a", "Decorator pattern como composición"],
      idealResponse:
          "Se prefiere composición cuando la relación es 'tiene-un' en lugar de 'es-un'. La herencia rompe el encapsulamiento porque la subclase depende de los detalles de implementación del padre. Ejemplo: Stack que extiende Vector hereda métodos de Vector que no tiene sentido en una pila (como get(index)). Mejor composición: Stack que tiene un List interno. El principio 'Favor composition over inheritance' del GoF evita jerarquías frágiles.",
      followUpQuestion: "¿Qué es el Fragile Base Class Problem y cómo la composición lo soluciona?",
    ),
    InterviewQuestion(
      id: "mock_m3_q4",
      worldId: "mundo_3",
      category: "Interfaces & Abstracciones",
      title: "Interfaces con métodos default y el Diamond Problem",
      question:
          "¿Qué son los métodos default en interfaces (Java 8+)? ¿Cómo resuelve Java el problema del diamante cuando una clase implementa dos interfaces con el mismo método default?",
      timeLimitSeconds: 60,
      keyConcepts: ["evolución de API sin romper implementaciones", "override obligatorio en conflicto", "Interface.super.metodo()", "herencia múltiple de comportamiento"],
      idealResponse:
          "Los métodos default permiten agregar implementaciones a interfaces sin romper clases existentes que la implementen. El Diamond Problem ocurre cuando dos interfaces tienen un método default con el mismo nombre. Java obliga a la clase implementadora a hacer @Override del método y puede llamar a una específica con InterfaceA.super.metodo() o InterfaceB.super.metodo().",
      followUpQuestion: "¿Cuándo preferirías una clase abstracta sobre una interfaz con métodos default en Java?",
    ),
    InterviewQuestion(
      id: "mock_m3_q5",
      worldId: "mundo_3",
      category: "Patrones de Diseño",
      title: "Patrones Creacionales: Singleton Thread-Safe",
      question:
          "¿Cuál es la forma correcta de implementar un Singleton thread-safe en Java? Explica las diferencias entre Double-Checked Locking, Initialization-on-Demand Holder y Enum Singleton.",
      timeLimitSeconds: 70,
      keyConcepts: ["Double-Checked Locking con volatile", "Holder: lazy init garantizada por ClassLoader", "Enum: reflección y serialización seguras", "anti-patrón en pruebas unitarias"],
      idealResponse:
          "DCL: private static volatile Singleton instance con synchronized en el primer check para performance. Holder (preferido): clase inner estática que Java inicializa de forma lazy y thread-safe gracias al ClassLoader. Es simple y eficiente. Enum Singleton (Joshua Bloch): garantiza unicidad incluso ante reflection y serialización, pero no admite lazy initialization ni herencia. En general, el Singleton dificulta los tests unitarios.",
      followUpQuestion: "¿Por qué el Singleton es considerado un anti-patrón en arquitecturas modernas con Spring IoC?",
    ),
    InterviewQuestion(
      id: "mock_m3_q6",
      worldId: "mundo_3",
      category: "Records y Clases Selladas",
      title: "Records, Sealed Classes y Pattern Matching (Java 17+)",
      question:
          "¿Qué son los Records en Java 17 y cuándo los usarías? ¿Cómo se combinan con Sealed Classes y Pattern Matching para modelar algebraic data types?",
      timeLimitSeconds: 65,
      keyConcepts: ["record: immutable data carrier", "sealed: subclases conocidas en compile time", "switch pattern matching exhaustivo", "algebraic data types en Java"],
      idealResponse:
          "Un Record es una clase inmutable con constructor canónico, equals/hashCode/toString autogenerados. Perfecto para DTOs y objetos de valor. Las Sealed Classes restringen qué clases pueden extender o implementar un tipo, conocidas en compile time. Combinados con switch pattern matching, el compilador puede verificar exhaustividad: sealed interface Shape permits Circle, Rectangle; luego switch(shape) { case Circle c -> ...; case Rectangle r -> ... } es verificado por el compilador.",
      followUpQuestion: "¿Cómo modelarías los estados de un pedido de e-commerce usando sealed classes y records?",
    ),
    InterviewQuestion(
      id: "mock_m3_q7",
      worldId: "mundo_3",
      category: "SOLID Avanzado",
      title: "Dependency Inversion y su relación con IoC",
      question:
          "¿Cómo el Principio de Inversión de Dependencias (DIP) es la base del Inversion of Control? Da un ejemplo de código que viola DIP y cómo refactorizarlo.",
      timeLimitSeconds: 70,
      keyConcepts: ["módulos de alto nivel no dependen de bajo nivel", "ambos dependen de abstracciones", "inyección de dependencias", "testabilidad con mocks"],
      idealResponse:
          "DIP: los módulos de alto nivel no deben depender de los de bajo nivel; ambos deben depender de abstracciones. Violación: class OrderService { MySqlOrderRepository repo = new MySqlOrderRepository(); }. OrderService está acoplado a MySql. Refactoring: class OrderService { OrderRepository repo; OrderService(OrderRepository repo) { this.repo = repo; } }. Ahora se puede inyectar MySqlOrderRepository o un InMemoryOrderRepository para tests sin cambiar OrderService.",
      followUpQuestion: "¿Cómo Spring Framework implementa el IoC Container y la Dependency Injection?",
    ),

    // ==========================================
    // MUNDO 4: Colecciones & Generics
    // ==========================================
    InterviewQuestion(
      id: "mock_m4_q1",
      worldId: "mundo_4",
      category: "Colecciones Java",
      title: "HashMap: hashing, buckets y resize",
      question:
          "Describe el funcionamiento interno de un HashMap en Java. ¿Qué ocurre con los buckets cuando el factor de carga se supera? ¿Qué cambio significativo introdujo Java 8 con las colisiones?",
      timeLimitSeconds: 65,
      keyConcepts: ["array de buckets", "hashCode para índice", "LinkedList -> TreeMap en colisiones Java 8", "resize con rehashing"],
      idealResponse:
          "HashMap usa un array de buckets. Para insertar: calcula hashCode(), aplica una función de dispersión y usa módulo para encontrar el bucket. Si hay colisión, antes de Java 8 se encadenaba en LinkedList O(n). Java 8 convierte a TreeMap (Red-Black tree) cuando hay 8+ colisiones en un bucket, mejorando a O(log n). Cuando el factor de carga (0.75 por defecto) se supera, se crea un array el doble de grande y se rehashean todos los elementos.",
      followUpQuestion: "¿Por qué es importante que hashCode() sea consistente con equals() en una clase que usas como clave de HashMap?",
    ),
    InterviewQuestion(
      id: "mock_m4_q2",
      worldId: "mundo_4",
      category: "Generics",
      title: "Wildcards: ? extends T vs ? super T (PECS)",
      question:
          "Explica el principio PECS (Producer Extends, Consumer Super) en Generics de Java con un ejemplo concreto.",
      timeLimitSeconds: 60,
      keyConcepts: ["covariance con extends", "contravariance con super", "Producer: solo lectura", "Consumer: solo escritura"],
      idealResponse:
          "PECS define cuándo usar ? extends T vs ? super T. Producer Extends: cuando la colección produce datos para consumir, usa ? extends T. Ejemplo: void processar(List<? extends Number> nums) - solo puedes leer Numbers de nums. Consumer Super: cuando la colección consume datos que le escribes, usa ? super T. Ejemplo: void addNumbers(List<? super Integer> lista) - puedes escribir Integers en lista que acepta Integer o supertipo.",
      followUpQuestion: "¿Por qué no puedes hacer new ArrayList<?>() o new ArrayList<? extends Number>()?",
    ),
    InterviewQuestion(
      id: "mock_m4_q3",
      worldId: "mundo_4",
      category: "Colecciones Avanzadas",
      title: "ConcurrentHashMap vs synchronized HashMap",
      question:
          "¿Cuál es la diferencia entre ConcurrentHashMap y Collections.synchronizedMap(HashMap)? ¿Por qué ConcurrentHashMap tiene mejor rendimiento en entornos multihilo?",
      timeLimitSeconds: 65,
      keyConcepts: ["bloqueo por segmento en lugar de mapa completo", "reads sin bloqueo", "atomic operations putIfAbsent", "synchronizedMap bloquea todo"],
      idealResponse:
          "synchronizedMap envuelve un HashMap con un lock sobre todos los métodos, bloqueando todo el mapa en cada operación, incluyendo lecturas. ConcurrentHashMap usa segmentos o un mecanismo de CAS (Compare-And-Swap) para lecturas sin lock y escrituras con bloqueo granular solo en el bucket afectado. Esto permite múltiples lecturas concurrentes y escrituras simultáneas en diferentes buckets, mejorando enormemente el throughput.",
      followUpQuestion: "¿Cuándo usarías CopyOnWriteArrayList y cuál es su trade-off de rendimiento?",
    ),
    InterviewQuestion(
      id: "mock_m4_q4",
      worldId: "mundo_4",
      category: "Generics Avanzado",
      title: "Type Erasure y sus implicaciones en runtime",
      question:
          "¿Qué es el Type Erasure en Java? ¿Por qué no puedes hacer 'new T()' o 'instanceof List<String>' en runtime, y cómo lo trabajas alrededor?",
      timeLimitSeconds: 65,
      keyConcepts: ["tipos genéricos eliminados en bytecode", "Object en runtime", "Class<T> como token de tipo", "Unchecked cast"],
      idealResponse:
          "Type Erasure: el compilador Java elimina la información de tipos genéricos al compilar, reemplazando con Object (o con el bound si lo hay). En runtime, List<String> y List<Integer> son simplemente List. Por eso 'obj instanceof List<String>' no es válido en runtime. Para operaciones que necesitan el tipo real, se pasa Class<T> como parámetro ('Type Token'). Para 'new T()' se usa Supplier<T> o reflection con clazz.getDeclaredConstructor().newInstance().",
      followUpQuestion: "¿Cómo Jackson de deserialización usa TypeReference para preservar información de tipos genéricos?",
    ),
    InterviewQuestion(
      id: "mock_m4_q5",
      worldId: "mundo_4",
      category: "Arrays & Performance",
      title: "Arrays vs ArrayList: cuándo usar cada uno",
      question:
          "¿En qué escenarios es más apropiado usar un array primitivo (int[]) en lugar de ArrayList<Integer>? ¿Qué impacto de memoria y rendimiento tiene la diferencia?",
      timeLimitSeconds: 60,
      keyConcepts: ["cache locality del array primitivo", "autoboxing overhead de ArrayList", "tamaño fijo vs dinámico", "Arrays.asList limitaciones"],
      idealResponse:
          "Un array de primitivos (int[]) es 3-5x más eficiente en memoria (sin overhead de objeto Integer) y tiene mejor cache locality al ser memoria contigua. ArrayList<Integer> requiere autoboxing en cada elemento y almacena referencias a objetos en heap. Usa int[] cuando el tamaño es fijo, el rendimiento es crítico (procesamiento numérico masivo) o trabajas con APIs de bajo nivel. ArrayList cuando necesitas resize dinámico, polimorfismo con Collection<> o integración con Streams.",
      followUpQuestion: "¿Cómo mejorarías el rendimiento de un algoritmo que usa ArrayList<Integer> con muchas operaciones numéricas?",
    ),
    InterviewQuestion(
      id: "mock_m4_q6",
      worldId: "mundo_4",
      category: "Colecciones Especializadas",
      title: "PriorityQueue, Deque y casos de uso",
      question:
          "¿Cuándo usarías una PriorityQueue en lugar de una cola normal? Explica también cuándo un ArrayDeque es mejor que LinkedList para implementar pilas y colas.",
      timeLimitSeconds: 60,
      keyConcepts: ["min-heap para prioridad", "O(log n) insert en PriorityQueue", "ArrayDeque sin overhead de nodo", "Deque para ambos extremos"],
      idealResponse:
          "PriorityQueue implementa un min-heap binario. Inserción y eliminación del mínimo son O(log n). Ideal para schedulers de tareas por prioridad, algoritmo de Dijkstra o cualquier caso donde siempre necesitas procesar el elemento más prioritario. ArrayDeque para pilas y colas es preferido sobre LinkedList porque no tiene el overhead de memoria de los nodos enlazados y tiene mejor cache locality. No admite null pero es más rápido en la práctica.",
      followUpQuestion: "¿Cómo implementarías una PriorityQueue de máximo en lugar de mínimo en Java?",
    ),
    InterviewQuestion(
      id: "mock_m4_q7",
      worldId: "mundo_4",
      category: "Generics Avanzado",
      title: "Bounded Type Parameters y Generic Methods",
      question:
          "¿Cómo declararías un método genérico que acepta solo tipos que implementen Comparable y retorna el máximo de una lista? ¿Qué diferencia hay con el uso de wildcards?",
      timeLimitSeconds: 65,
      keyConcepts: ["<T extends Comparable<T>>", "método genérico vs wildcard", "bounded parameter en declaración", "inference de tipos"],
      idealResponse:
          "public static <T extends Comparable<T>> T max(List<T> list) - el type parameter T está bounded: debe implementar Comparable<T>. Esto permite llamar a compareTo() dentro del método. La diferencia con wildcards: los type parameters se usan cuando necesitas referenciar el tipo múltiples veces en la firma (parámetro y retorno relacionados). Los wildcards (?) se usan cuando solo importa la capacidad de lectura/escritura sin necesitar nombrar el tipo.",
      followUpQuestion: "¿Cómo funcionaria <T extends Comparable<? super T>> y cuándo es necesario ese nivel adicional de wildcard?",
    ),

    // ==========================================
    // MUNDO 5: Functional Java & Streams
    // ==========================================
    InterviewQuestion(
      id: "mock_m5_q1",
      worldId: "mundo_5",
      category: "Lambdas & Funcional",
      title: "Interfaces Funcionales y Closures en Java",
      question:
          "¿Qué es una interfaz funcional en Java y cómo las lambdas implementan closures? ¿Por qué las variables capturadas deben ser efectivamente final?",
      timeLimitSeconds: 60,
      keyConcepts: ["@FunctionalInterface con un método abstracto", "lambda captura del contexto léxico", "effectively final por seguridad de hilos", "Predicate Function Consumer Supplier"],
      idealResponse:
          "Una interfaz funcional tiene exactamente un método abstracto y puede tener métodos default y static. Las lambdas son closures que capturan variables del contexto léxico donde se definen. Las variables capturadas deben ser efectivamente final (no modificadas después de capturarlas) para garantizar thread safety: si una lambda se ejecuta en otro hilo y la variable cambiara, habría condición de carrera. Esto obliga a que cada hilo vea un valor consistente.",
      followUpQuestion: "¿Cómo pasarías estado mutable a una lambda de forma thread-safe?",
    ),
    InterviewQuestion(
      id: "mock_m5_q2",
      worldId: "mundo_5",
      category: "Stream API",
      title: "Laziness en Streams y operaciones terminales",
      question:
          "¿Por qué los Streams de Java son perezosos (lazy)? ¿Cómo afecta esto al orden de ejecución cuando encadenas filter, map y findFirst?",
      timeLimitSeconds: 60,
      keyConcepts: ["operaciones intermedias no ejecutan", "terminal operation activa el pipeline", "short-circuit con findFirst/limit", "orden de evaluación elemento por elemento"],
      idealResponse:
          "Las operaciones intermedias (filter, map) no se ejecutan inmediatamente, solo declaran el pipeline. La evaluación real ocurre cuando se llama a una operación terminal (collect, forEach, findFirst). La laziness permite optimización: list.stream().filter(p).map(m).findFirst() procesa el primer elemento que pase el filtro y se detiene. Sin laziness, filter procesaría toda la lista antes de que map haga algo. El orden es: elemento 1 -> filter -> map -> resultado; luego elemento 2, etc.",
      followUpQuestion: "¿Cuándo un Stream puede procesar elementos en paralelo con parallelStream() sin problemas de concurrencia?",
    ),
    InterviewQuestion(
      id: "mock_m5_q3",
      worldId: "mundo_5",
      category: "Collectors Avanzados",
      title: "groupingBy, partitioningBy y Collectors compuestos",
      question:
          "Usa Collectors.groupingBy() y Collectors.partitioningBy() para agregar una lista de empleados. ¿Cuándo usarías downstream collectors como counting() o mapping()?",
      timeLimitSeconds: 65,
      keyConcepts: ["groupingBy retorna Map<K, List<V>>", "partitioningBy retorna Map<Boolean, List<V>>", "downstream collector para agregación adicional", "Collectors.toMap vs groupingBy"],
      idealResponse:
          "groupingBy(Employee::getDepartment) retorna Map<String, List<Employee>>. Con downstream: groupingBy(Employee::getDept, counting()) retorna Map<String, Long> con el conteo por departamento. partitioningBy(e -> e.getSalary() > 5000) retorna Map<Boolean, List<Employee>> separando en dos grupos. Para obtener solo nombres: groupingBy(dept, mapping(Employee::getName, toList())). Collectors.toMap falla con duplicados, groupingBy los agrupa.",
      followUpQuestion: "¿Cómo crearías un Collector personalizado para calcular la moda estadística de una lista de números?",
    ),
    InterviewQuestion(
      id: "mock_m5_q4",
      worldId: "mundo_5",
      category: "Optional",
      title: "Optional: uso correcto y anti-patrones",
      question:
          "¿Cuál es el propósito de Optional<T> y cuáles son sus anti-patrones más comunes? ¿Cuándo NO deberías usar Optional?",
      timeLimitSeconds: 55,
      keyConcepts: ["señalar ausencia de valor", "anti-patrón: Optional en campos de clase", "anti-patrón: get() sin isPresent()", "flatMap para encadenar Optionals"],
      idealResponse:
          "Optional es un contenedor para valores que pueden estar ausentes, principalmente como tipo de retorno de métodos. Fuerza al llamador a manejar el caso null explícitamente. Anti-patrones: usar Optional como parámetro de método (mejor overloading); como campo de clase (serialización problemática, memoria extra); llamar get() sin verificar isPresent() (lanza NoSuchElementException). No usar en colecciones (ya pueden estar vacías). Usar orElse() para default, orElseGet() para default costoso, ifPresent() para efectos secundarios.",
      followUpQuestion: "¿Cómo encadenarías múltiples operaciones que retornan Optional usando flatMap para evitar Optional<Optional<T>>?",
    ),
    InterviewQuestion(
      id: "mock_m5_q5",
      worldId: "mundo_5",
      category: "Method References",
      title: "Tipos de Method References y cuándo usarlos",
      question:
          "Java tiene 4 tipos de method references. Explica cada uno con un ejemplo concreto y describe cuándo una lambda es más clara que un method reference.",
      timeLimitSeconds: 60,
      keyConcepts: ["static: Clase::metodoEstatico", "instancia arbitraria: Clase::metodoInstancia", "instancia particular: objeto::metodo", "constructor: Clase::new"],
      idealResponse:
          "1) Estático: Integer::parseInt equivale a s -> Integer.parseInt(s). 2) Instancia de tipo arbitrario: String::toUpperCase equivale a s -> s.toUpperCase(). 3) Instancia particular: System.out::println, el objeto ya está fijado. 4) Constructor: ArrayList::new equivale a () -> new ArrayList<>(). Usar lambdas cuando la lógica es más que solo delegar: x -> process(x, extraParam) no puede ser method reference directo porque tiene argumentos extra.",
      followUpQuestion: "¿Qué tipo de method reference usarías para adaptar un BiFunction a Function cuando el primer parámetro es una instancia?",
    ),
    InterviewQuestion(
      id: "mock_m5_q6",
      worldId: "mundo_5",
      category: "Streams Avanzado",
      title: "flatMap vs map y streams de streams",
      question:
          "¿Cuál es la diferencia entre map() y flatMap() en la Stream API? ¿En qué escenario flatMap() evita un Stream<Stream<T>>?",
      timeLimitSeconds: 55,
      keyConcepts: ["map retorna Stream<R>", "flatMap aplana Stream<Stream<R>> a Stream<R>", "aplanar listas anidadas", "Optional::stream para flatMap con Optional"],
      idealResponse:
          "map(f) aplica f a cada elemento y retorna un stream del mismo número de elementos. Si f retorna un Stream, tendrías Stream<Stream<T>>. flatMap(f) aplica f y 'aplana' los resultados en un solo stream. Ejemplo: List<List<String>> -> stream().flatMap(Collection::stream) da Stream<String>. Otro caso: orders.stream().flatMap(o -> o.getItems().stream()) para trabajar con todos los items de todas las órdenes sin streams anidados.",
      followUpQuestion: "¿Cómo usarías Optional::stream junto con flatMap para filtrar un Stream<Optional<T>> a un Stream<T> con solo los valores presentes?",
    ),
    InterviewQuestion(
      id: "mock_m5_q7",
      worldId: "mundo_5",
      category: "Functional Patterns",
      title: "Composición de funciones: compose, andThen y Function.identity()",
      question:
          "¿Cómo se componen funciones en Java usando compose() y andThen()? ¿En qué orden se ejecutan y cómo construirías un pipeline de transformaciones?",
      timeLimitSeconds: 60,
      keyConcepts: ["andThen: f luego g", "compose: g luego f", "Function.identity()", "pipeline de transformaciones tipado"],
      idealResponse:
          "Function.andThen(g): primero aplica f, luego g. f.andThen(g).apply(x) = g(f(x)). Function.compose(g): primero aplica g, luego f. f.compose(g).apply(x) = f(g(x)). Para un pipeline: Function<String, String> pipeline = String::trim.andThen(String::toLowerCase).andThen(s -> s.replace(' ', '_')). Function.identity() retorna su argumento sin cambio, útil como no-op en composiciones condicionales o como Comparator base.",
      followUpQuestion: "¿Cómo implementarías un pipeline de validaciones componiendo Predicate con Predicate.and(), Predicate.or() y Predicate.negate()?",
    ),

    // ==========================================
    // MUNDO 6: Spring Boot & APIs REST
    // ==========================================
    InterviewQuestion(
      id: "mock_m6_q1",
      worldId: "mundo_6",
      category: "Spring IoC",
      title: "ApplicationContext y ciclo de vida de los Beans",
      question:
          "Describe el ciclo de vida completo de un Bean en Spring. ¿Qué diferencia hay entre @PostConstruct, InitializingBean y BeanPostProcessor?",
      timeLimitSeconds: 65,
      keyConcepts: ["instanciación -> inyección -> @PostConstruct -> uso -> @PreDestroy", "BeanPostProcessor intercepta todos los beans", "orden de inicialización con @DependsOn", "scope Singleton vs Prototype"],
      idealResponse:
          "Ciclo: 1) Instanciación del bean. 2) Inyección de dependencias. 3) BeanPostProcessor.postProcessBeforeInitialization(). 4) @PostConstruct / InitializingBean.afterPropertiesSet(). 5) BeanPostProcessor.postProcessAfterInitialization(). 6) Bean disponible. 7) @PreDestroy en shutdown. BeanPostProcessor permite interceptar y modificar TODOS los beans (úsalo para AOP, logging). @PostConstruct es más simple y portátil (JSR-250).",
      followUpQuestion: "¿Cómo garantizarías el orden de inicialización de dos beans con dependencias circulares en Spring?",
    ),
    InterviewQuestion(
      id: "mock_m6_q2",
      worldId: "mundo_6",
      category: "REST API Design",
      title: "Idempotencia y diseño RESTful correcto",
      question:
          "Explica el concepto de idempotencia en HTTP. ¿Por qué PUT es idempotente y POST no? ¿Cuándo usarías PATCH en lugar de PUT?",
      timeLimitSeconds: 60,
      keyConcepts: ["idempotente: misma solicitud = mismo estado", "PUT reemplaza el recurso completo", "POST crea recurso nuevo (no idempotente)", "PATCH para actualizaciones parciales"],
      idealResponse:
          "Idempotente significa que ejecutar la operación N veces deja el servidor en el mismo estado que ejecutarla 1 vez. PUT: reemplaza el recurso completo; llamarlo 5 veces deja el recurso en el mismo estado. POST: crea un nuevo recurso; 5 llamadas crean 5 recursos distintos. PATCH: actualiza solo los campos enviados (no idempotente si usa operaciones relativas). PUT requiere enviar toda la representación; PATCH es más eficiente para actualizaciones parciales.",
      followUpQuestion: "¿Cómo implementarías idempotencia en un endpoint POST de pagos para evitar cobros duplicados?",
    ),
    InterviewQuestion(
      id: "mock_m6_q3",
      worldId: "mundo_6",
      category: "Spring AOP",
      title: "Aspect-Oriented Programming y Spring AOP",
      question:
          "¿Cómo funciona Spring AOP internamente? Explica la diferencia entre JDK Dynamic Proxy y CGLIB Proxy y cuándo Spring usa cada uno.",
      timeLimitSeconds: 65,
      keyConcepts: ["JDK Proxy solo para interfaces", "CGLIB para clases concretas", "Pointcut y Advice", "@Around vs @Before @After"],
      idealResponse:
          "Spring AOP crea proxies en runtime que interceptan llamadas a beans. JDK Dynamic Proxy: solo funciona cuando el bean implementa una interfaz; crea un proxy que implementa la misma interfaz e intercepta llamadas. CGLIB: subclasifica la clase concreta en bytecode para crear el proxy; por eso los métodos final no pueden ser interceptados. Spring usa JDK proxy si hay interfaz (recomendado), CGLIB si no. @Around es el advice más poderoso: controla si el método original se ejecuta y puede modificar parámetros y retorno.",
      followUpQuestion: "¿Por qué llamar a un método desde dentro de la misma clase (@Transactional en un método llamado internamente) puede no funcionar en Spring AOP?",
    ),
    InterviewQuestion(
      id: "mock_m6_q4",
      worldId: "mundo_6",
      category: "Performance API",
      title: "Paginación eficiente y N+1 Query Problem",
      question:
          "¿Cómo implementas paginación eficiente en un endpoint REST con Spring Data? ¿Qué es el problema N+1 y cómo lo detectas y solucionas?",
      timeLimitSeconds: 70,
      keyConcepts: ["Pageable y Page<T>", "cursor-based vs offset pagination", "Hibernate lazy loading N+1", "JOIN FETCH o @EntityGraph"],
      idealResponse:
          "Paginación offset: Pageable pageable = PageRequest.of(page, size, Sort.by('name')). Para datasets grandes, cursor-based es más eficiente (evita OFFSET que escanea N filas). El N+1 ocurre cuando se carga una lista de entidades (1 query) y luego se accede a una relación lazy de cada una (N queries adicionales). Se detecta con Hibernate Statistics o herramientas como Datadog. Se resuelve con JOIN FETCH en JPQL, @EntityGraph o Batch Fetching.",
      followUpQuestion: "¿Cuándo es apropiado usar proyecciones (Projections) en Spring Data JPA y qué ventaja ofrecen sobre las entidades?",
    ),
    InterviewQuestion(
      id: "mock_m6_q5",
      worldId: "mundo_6",
      category: "Seguridad",
      title: "CORS, CSRF y headers de seguridad en APIs REST",
      question:
          "¿Qué es CORS y cómo se configura correctamente en Spring Boot? ¿Cuándo es necesario CSRF protection en una API REST y cuándo no?",
      timeLimitSeconds: 65,
      keyConcepts: ["preflight request OPTIONS", "Access-Control-Allow-Origin", "CSRF no necesario en stateless JWT", "CSRF necesario en session cookies"],
      idealResponse:
          "CORS permite a un frontend en un origen diferente llamar a la API. El navegador envía un preflight OPTIONS para verificar los headers permitidos. En Spring: @CrossOrigin o CorsConfigurationSource global. CSRF (Cross-Site Request Forgery) protege contra peticiones forjadas usando cookies de sesión. En APIs REST stateless con JWT en Authorization header, CSRF no aplica porque el token no es enviado automáticamente por el navegador. Desactivar CSRF en APIs JWT es correcto: http.csrf(csrf -> csrf.disable()).",
      followUpQuestion: "¿Qué otros security headers HTTP (como HSTS, CSP, X-Frame-Options) deberías configurar en una API Spring Boot productiva?",
    ),
    InterviewQuestion(
      id: "mock_m6_q6",
      worldId: "mundo_6",
      category: "Observabilidad",
      title: "Actuator, Micrometer y Distributed Tracing",
      question:
          "¿Cómo implementas observabilidad completa (métricas, health checks y trazas distribuidas) en una aplicación Spring Boot con Actuator y Micrometer?",
      timeLimitSeconds: 70,
      keyConcepts: ["Actuator endpoints: /health /metrics /info", "Micrometer como facade de métricas", "Counter Timer DistributionSummary", "Spring Boot 3 y Micrometer Tracing (Brave/OTLP)"],
      idealResponse:
          "Spring Actuator expone endpoints: /health para readiness/liveness, /metrics para métricas JVM y negocio, /info para metadata. Micrometer es la fachada: meterRegistry.counter('orders.created').increment(). Se exporta a Prometheus, DataDog, etc. Para trazas distribuidas: Spring Boot 3 incluye Micrometer Tracing con propagación automática de TraceId/SpanId via headers. Se visualiza en Zipkin o Jaeger. Custom spans: Observation.createNotStarted('operacion', registry).observe(...).",
      followUpQuestion: "¿Cómo correlacionarías logs, métricas y trazas usando el TraceId para investigar una latencia alta en producción?",
    ),
    InterviewQuestion(
      id: "mock_m6_q7",
      worldId: "mundo_6",
      category: "Reactive",
      title: "Spring WebFlux y programación reactiva vs MVC",
      question:
          "¿Cuándo elegirías Spring WebFlux sobre Spring MVC? ¿Cómo el modelo reactivo mejora el throughput en escenarios de I/O intensivo?",
      timeLimitSeconds: 70,
      keyConcepts: ["event loop no-bloqueante", "backpressure con Reactor", "Mono y Flux", "thread-per-request vs few event loop threads"],
      idealResponse:
          "Spring MVC usa modelo thread-per-request: cada petición ocupa un hilo mientras espera I/O (DB, HTTP). Con 200 peticiones concurrentes necesitas 200+ hilos. WebFlux usa pocos hilos de event loop: cuando hay I/O, el hilo se libera y atiende otra petición; cuando el I/O termina, retoma. Con Reactor, el backpressure controla el flujo para evitar saturar el sistema. WebFlux brilla en microservicios con muchas llamadas a APIs externas o streaming de datos. No usar WebFlux con código bloqueante.",
      followUpQuestion: "¿Cómo probarías un endpoint WebFlux con StepVerifier de Reactor Test?",
    ),

    // ==========================================
    // MUNDO 7: JPA & Persistencia
    // ==========================================
    InterviewQuestion(
      id: "mock_m7_q1",
      worldId: "mundo_7",
      category: "JPA & Hibernate",
      title: "Contexto de Persistencia y ciclo de vida de entidades",
      question:
          "Explica los estados de una entidad JPA: Transient, Managed, Detached y Removed. ¿Qué sucede al hacer merge() de una entidad Detached?",
      timeLimitSeconds: 65,
      keyConcepts: ["Transient: sin persistir ni asociar", "Managed: en contexto de persistencia activo", "Detached: contexto cerrado", "merge() copia estado al managed"],
      idealResponse:
          "Transient: objeto nuevo sin id, no gestionado. Managed: dentro de una transacción activa, los cambios se sincronizan automáticamente con la DB en el flush. Detached: la sesión/EntityManager fue cerrado, JPA ya no rastrea cambios. Removed: marcado para eliminar al hacer flush. merge(entity): si hay una entidad managed con el mismo id, copia el estado del detached al managed; si no existe, crea una nueva entidad managed. El detached original no se convierte en managed.",
      followUpQuestion: "¿Cuándo ocurre el flush automático y cómo puedes controlarlo con FlushModeType?",
    ),
    InterviewQuestion(
      id: "mock_m7_q2",
      worldId: "mundo_7",
      category: "Transacciones",
      title: "@Transactional: propagación y aislamiento",
      question:
          "Explica los niveles de propagación de @Transactional más comunes (REQUIRED, REQUIRES_NEW, NESTED). ¿Cuándo usarías REQUIRES_NEW para el logging de auditoría?",
      timeLimitSeconds: 65,
      keyConcepts: ["REQUIRED: reutiliza transacción existente", "REQUIRES_NEW: siempre nueva transacción independiente", "NESTED: savepoint dentro de la transacción padre", "auditoría con REQUIRES_NEW para sobrevivir rollback"],
      idealResponse:
          "REQUIRED (default): reutiliza la transacción activa o crea una nueva. Si el método interno hace rollback, afecta toda la transacción. REQUIRES_NEW: suspende la activa y crea una completamente nueva e independiente. Si la transacción interna hace commit o rollback, no afecta la externa. NESTED: crea un savepoint dentro de la transacción padre; el rollback del nested va al savepoint sin afectar la transacción completa. Para auditoría: REQUIRES_NEW garantiza que el log se guarda aunque el proceso principal haga rollback.",
      followUpQuestion: "¿Qué niveles de aislamiento SQL (READ_COMMITTED, REPEATABLE_READ) afectan al comportamiento de transacciones concurrentes en Spring?",
    ),
    InterviewQuestion(
      id: "mock_m7_q3",
      worldId: "mundo_7",
      category: "Optimización JPA",
      title: "Optimistic vs Pessimistic Locking en JPA",
      question:
          "¿Cuándo usas optimistic locking con @Version vs pessimistic locking con PESSIMISTIC_WRITE en JPA? ¿Qué es un OptimisticLockException?",
      timeLimitSeconds: 65,
      keyConcepts: ["@Version: columna de versión incrementada", "OptimisticLockException si la versión cambió", "PESSIMISTIC_WRITE: SELECT FOR UPDATE", "optimistic para baja contención"],
      idealResponse:
          "Optimistic Locking (@Version): agrega una columna version a la entidad. Al hacer UPDATE, JPA incluye WHERE version = :versión_leída. Si otro proceso modificó la entidad entre la lectura y el update, la versión no coincide y JPA lanza OptimisticLockException. Ideal cuando las colisiones son raras. Pessimistic Locking (PESSIMISTIC_WRITE): ejecuta SELECT FOR UPDATE, bloqueando el registro hasta que la transacción termina. Garantiza exclusividad pero genera contención y riesgo de deadlock. Usar en operaciones críticas con alta probabilidad de colisión.",
      followUpQuestion: "¿Cómo implementarías un reintentos automáticos ante OptimisticLockException usando Spring Retry?",
    ),
    InterviewQuestion(
      id: "mock_m7_q4",
      worldId: "mundo_7",
      category: "Query Optimization",
      title: "JPQL vs Criteria API vs Native Queries",
      question:
          "¿Cuándo usarías JPQL, Criteria API o native queries en JPA? ¿Qué ventajas y desventajas tiene cada una en términos de seguridad y portabilidad?",
      timeLimitSeconds: 65,
      keyConcepts: ["JPQL: orientado a entidades", "Criteria API: type-safe y dinámico", "Native: SQL específico del DB", "riesgo SQL injection con native sin bindparams"],
      idealResponse:
          "JPQL: legible, portátil entre DBs JPA-compatibles, refactorizable. Ideal para queries simples a moderadas. Criteria API: type-safe (detecta errores en compile time), ideal para queries dinámicas donde los filtros son opcionales según parámetros en runtime. Verbosa pero segura. Native queries: cuando necesitas features SQL específicos del DB (full-text search, window functions, hints). Riesgo: siempre usar parámetros vinculados (:param o ?) para evitar SQL injection, nunca concatenar strings.",
      followUpQuestion: "¿Cómo usarías @NamedNativeQuery con @SqlResultSetMapping para mapear resultados de un native query a un DTO?",
    ),
    InterviewQuestion(
      id: "mock_m7_q5",
      worldId: "mundo_7",
      category: "Migraciones",
      title: "Flyway y Liquibase para migraciones de base de datos",
      question:
          "¿Cómo gestionas migraciones de esquema de base de datos en un entorno de CI/CD con múltiples instancias? ¿Qué diferencia hay entre Flyway y Liquibase?",
      timeLimitSeconds: 60,
      keyConcepts: ["versionado de schema con archivos SQL", "checksums para detectar cambios", "bloqueo distribuido para múltiples instancias", "Flyway SQL puro vs Liquibase XML/YAML/JSON"],
      idealResponse:
          "Ambos rastrean las migraciones aplicadas en una tabla de historial. Flyway usa archivos SQL versionados (V1__Create_table.sql) y su filosofía es 'never modify applied migrations'. Liquibase usa changesets en XML/YAML/JSON con más metadatos y permite rollback definido. Para múltiples instancias en startup: ambos usan bloqueo distribuido (table lock) para que solo una instancia aplique las migraciones a la vez. Spring Boot auto-configura ambos si están en classpath.",
      followUpQuestion: "¿Cómo manejarías una migración fallida en producción cuando múltiples instancias están corriendo?",
    ),
    InterviewQuestion(
      id: "mock_m7_q6",
      worldId: "mundo_7",
      category: "Caching",
      title: "Estrategias de caché: @Cacheable, @CacheEvict y Redis",
      question:
          "¿Cómo implementas caché en capas de servicio con Spring Cache? ¿Qué estrategias de cache-aside, read-through y write-through existen y cuándo se aplican?",
      timeLimitSeconds: 70,
      keyConcepts: ["@Cacheable para hit/miss", "@CacheEvict para invalidación", "Redis como cache distribuido", "TTL y cache stampede"],
      idealResponse:
          "Cache-aside (Spring @Cacheable): la app consulta el cache, si miss consulta DB y guarda en cache. @CacheEvict invalida al actualizar. Read-through: el cache consulta la DB automáticamente en miss. Write-through: cada escritura en DB también actualiza el cache sincrónicamente. Write-behind: escrituras van al cache y se propagan async a DB. Con Redis en cluster: TTL previene datos stale. Problema: cache stampede cuando muchas peticiones llegan con miss simultáneo. Solución: locks de refresco o probabilistic early expiration.",
      followUpQuestion: "¿Cómo implementarías un patrón Circuit Breaker para degradar gracefully cuando Redis no está disponible?",
    ),
    InterviewQuestion(
      id: "mock_m7_q7",
      worldId: "mundo_7",
      category: "Arquitectura de Datos",
      title: "Event Sourcing y CQRS con Spring",
      question:
          "¿Qué es CQRS (Command Query Responsibility Segregation) y Event Sourcing? ¿Cómo se implementan con Spring y qué problemas resuelven?",
      timeLimitSeconds: 70,
      keyConcepts: ["Commands modifican estado", "Queries solo leen", "Event Store como fuente de verdad", "Eventual consistency"],
      idealResponse:
          "CQRS separa el modelo de escritura (Commands) del de lectura (Queries). Los Commands modifican el estado y producen eventos. Las Queries leen desde vistas optimizadas para consulta. Event Sourcing: el estado de la aplicación se deriva de una secuencia de eventos inmutables. La DB es el Event Store. Para reconstruir el estado se replayan los eventos. Ventajas: auditabilidad completa, tiempo al punto (point-in-time recovery). Desafíos: eventual consistency entre el store y las vistas de lectura, complejidad de proyecciones.",
      followUpQuestion: "¿Cómo manejarías la consistencia eventual entre el read model y el event store en un sistema CQRS de alto volumen?",
    ),

    // ==========================================
    // MUNDO 8: Microservicios & Arquitectura
    // ==========================================
    InterviewQuestion(
      id: "mock_m8_q1",
      worldId: "mundo_8",
      category: "Patrones de Microservicios",
      title: "Saga Pattern para transacciones distribuidas",
      question:
          "¿Cómo manejas transacciones distribuidas en microservicios sin un coordinador central? Explica el Saga Pattern en sus variantes Choreography y Orchestration.",
      timeLimitSeconds: 70,
      keyConcepts: ["sin transacciones 2PC distribuidas", "Choreography: eventos reactivos", "Orchestration: Saga orquestador central", "compensating transactions"],
      idealResponse:
          "Las transacciones 2PC son impracticables en microservicios por latencia y acoplamiento. El Saga Pattern divide la transacción en pasos locales con transacciones compensadoras para rollback. Choreography: cada servicio publica eventos y reacciona a eventos de otros (Event-driven). Más desacoplado pero difícil de rastrear. Orchestration: un Saga Orchestrator dirige los pasos y ejecuta las compensaciones si algo falla. Más fácil de rastrear pero es un punto central. Para pagos: un failed step en el inventario lanza el evento de rollback de cargo.",
      followUpQuestion: "¿Cómo garantizarías que el Saga Orchestrator sea resiliente a reinicios del servicio usando estado persistente?",
    ),
    InterviewQuestion(
      id: "mock_m8_q2",
      worldId: "mundo_8",
      category: "Circuit Breaker",
      title: "Circuit Breaker pattern y Resilience4j",
      question:
          "¿Cómo funciona el patrón Circuit Breaker con Resilience4j? Explica los estados CLOSED, OPEN y HALF_OPEN y cuándo transiciona entre ellos.",
      timeLimitSeconds: 65,
      keyConcepts: ["CLOSED normal", "OPEN falla rápida sin llamar", "HALF_OPEN prueba recuperación", "fallback method"],
      idealResponse:
          "CLOSED: todas las llamadas pasan normalmente. Si el % de fallos supera el threshold, transiciona a OPEN. OPEN: las llamadas fallan inmediatamente con fallback sin intentar llamar al servicio real (fail-fast). Después del waitDurationInOpenState, transiciona a HALF_OPEN. HALF_OPEN: permite un número limitado de llamadas de prueba. Si tienen éxito, vuelve a CLOSED; si fallan, regresa a OPEN. Con @CircuitBreaker(name='service', fallbackMethod='fallback') en Spring, el método fallback se invoca cuando el circuito está abierto.",
      followUpQuestion: "¿Cuándo combinarías Circuit Breaker con Retry y cuál sería el orden correcto de las políticas?",
    ),
    InterviewQuestion(
      id: "mock_m8_q3",
      worldId: "mundo_8",
      category: "API Gateway",
      title: "API Gateway patterns y Spring Cloud Gateway",
      question:
          "¿Cuáles son las responsabilidades de un API Gateway? ¿Cómo implementas rate limiting, routing y autenticación centralizada con Spring Cloud Gateway?",
      timeLimitSeconds: 70,
      keyConcepts: ["entry point único", "routing por predicados", "filtros: pre y post", "rate limiting con Redis"],
      idealResponse:
          "El API Gateway centraliza: routing a microservicios, autenticación/autorización, rate limiting, SSL termination, logging y circuit breaking. Spring Cloud Gateway usa predicados para routing: Path=/api/users/** -> UserService. Los filtros permiten transformar requests/responses: pre-filters para autenticación JWT, post-filters para agregar headers de seguridad. Rate limiting: RequestRateLimiterGatewayFilter con Redis para tracking distribuido de solicitudes por cliente. StripPrefix para quitar el prefijo antes de reenviar.",
      followUpQuestion: "¿Cómo implementarías el patrón Backend for Frontend (BFF) usando múltiples API Gateways especializados?",
    ),
    InterviewQuestion(
      id: "mock_m8_q4",
      worldId: "mundo_8",
      category: "Comunicación entre Servicios",
      title: "REST vs gRPC vs Message Queues: cuándo usar cada uno",
      question:
          "¿En qué escenarios elegirías REST, gRPC o mensajería asíncrona (Kafka/RabbitMQ) para comunicación entre microservicios?",
      timeLimitSeconds: 70,
      keyConcepts: ["REST: simple y ubicuo", "gRPC: performance y contratos Protobuf", "async messaging: desacoplamiento y fiabilidad", "at-least-once vs exactly-once delivery"],
      idealResponse:
          "REST: cuando necesitas interoperabilidad máxima, API pública o la simplicidad es prioritaria. gRPC: para comunicación interna de alta frecuencia donde el performance importa (Protobuf es 3-5x más compacto que JSON) y quieres contratos tipados con generación de código. Mensajería async (Kafka/RabbitMQ): cuando la operación puede ser eventual (no necesitas respuesta inmediata), para desacoplamiento temporal (producer no necesita que consumer esté disponible) o para fan-out a múltiples consumers.",
      followUpQuestion: "¿Cómo garantizarías exactly-once processing en Kafka para un sistema de pagos?",
    ),
    InterviewQuestion(
      id: "mock_m8_q5",
      worldId: "mundo_8",
      category: "Service Discovery",
      title: "Service Discovery, Load Balancing y Kubernetes",
      question:
          "¿Cómo funciona el service discovery en una arquitectura de microservicios? Compara client-side load balancing (Ribbon/Spring LoadBalancer) con server-side load balancing en Kubernetes.",
      timeLimitSeconds: 65,
      keyConcepts: ["Registry: Eureka / DNS de Kubernetes", "client-side: el consumer elige instancia", "server-side: L4/L7 balancer elige", "health checks para membership"],
      idealResponse:
          "Client-side discovery: el microservicio consulta un registro (Eureka) para obtener instancias disponibles del servicio destino y elige una con algoritmo (round-robin). Spring Cloud LoadBalancer lo implementa. Server-side discovery: un load balancer (NGINX, kube-proxy, istio) recibe la petición y elige la instancia. Kubernetes usa DNS + Services (kube-proxy con iptables/IPVS) para server-side. La diferencia: client-side permite más control y es más eficiente (menos hops), server-side simplifica el cliente.",
      followUpQuestion: "¿Cómo implementarías canary deployments o A/B testing usando Kubernetes Ingress y pesos de tráfico?",
    ),
    InterviewQuestion(
      id: "mock_m8_q6",
      worldId: "mundo_8",
      category: "Observabilidad Distribuida",
      title: "Distributed Tracing con OpenTelemetry",
      question:
          "¿Cómo propagas trazas distribuidas entre microservicios usando OpenTelemetry? ¿Qué son los spans y cómo construyes un trace tree para diagnosticar latencia?",
      timeLimitSeconds: 70,
      keyConcepts: ["TraceId compartido entre servicios", "SpanId único por operación", "propagación via HTTP headers W3C", "Jaeger / Zipkin para visualización"],
      idealResponse:
          "Una traza distribuida es un árbol de spans: el span raíz en el API Gateway crea el TraceId. Cada microservicio crea un span hijo con su SpanId referenciando el parent SpanId. Los IDs se propagan via headers HTTP (W3C: traceparent: version-traceId-parentId-flags). Con Spring Boot 3 y Micrometer Tracing, la propagación es automática con RestTemplate y WebClient. Para diagnosticar latencia: en Jaeger se visualiza el flame graph del trace y se identifica qué span tomó más tiempo.",
      followUpQuestion: "¿Cómo agregarías atributos de negocio personalizados (como orderId o userId) a un span para facilitar la investigación?",
    ),
    InterviewQuestion(
      id: "mock_m8_q7",
      worldId: "mundo_8",
      category: "Arquitectura Avanzada",
      title: "DDD: Aggregates, Bounded Contexts y Anti-Corruption Layer",
      question:
          "¿Cómo aplicas Domain-Driven Design en una arquitectura de microservicios? ¿Qué es un Aggregate Root y cómo define los límites de transacción?",
      timeLimitSeconds: 70,
      keyConcepts: ["Bounded Context = microservicio candidato", "Aggregate Root como punto de entrada", "invariantes de negocio dentro del aggregate", "Anti-Corruption Layer para legacy"],
      idealResponse:
          "En DDD, un Bounded Context delimita el dominio donde un modelo específico es consistente y válido. Cada microservicio típicamente corresponde a un BC. Un Aggregate es un cluster de entidades que deben ser consistentes entre sí. El Aggregate Root es el único punto de entrada externo: accedes al aggregate a través de la raíz, nunca directamente a entidades internas. Las invariantes del negocio se mantienen dentro del aggregate. El Anti-Corruption Layer traduce entre modelos de dominios diferentes sin contaminar el dominio propio.",
      followUpQuestion: "¿Cómo diseñarías los Bounded Contexts y Aggregates para un sistema de e-commerce con Carrito, Pedido e Inventario?",
    ),

    // ==========================================
    // MUNDO 9: JPA Avanzado & Hibernate
    // ==========================================
    InterviewQuestion(
      id: "mock_m9_q1",
      worldId: "mundo_9",
      category: "Spring Data JPA",
      title: "FetchType EAGER vs LAZY y sus trade-offs",
      question:
          "¿Por qué arquitectos senior consideran que FetchType.EAGER es un 'code smell' en JPA y qué impacto tiene en consultas complejas?",
      timeLimitSeconds: 65,
      keyConcepts: ["EAGER siempre carga relacionados sin importar si se necesitan", "joins adicionales en toda consulta", "LAZY carga bajo demanda", "LazyInitializationException fuera de sesión"],
      idealResponse:
          "EAGER carga las relaciones automáticamente en cada consulta a la entidad, añadiendo JOINs innecesarios cuando las relaciones no se usan. En entidades con múltiples relaciones EAGER, puede generar queries masivas incluso para operaciones simples. LAZY carga las relaciones bajo demanda al primer acceso. El desafío: LazyInitializationException ocurre al acceder a una relación lazy fuera del contexto de persistencia (en el controller). La solución: open-session-in-view (antipatrón) o cargar lo necesario con JOIN FETCH en la query.",
      followUpQuestion: "¿Cómo evitarías el LazyInitializationException sin usar EAGER ni open-session-in-view pattern?",
    ),
    InterviewQuestion(
      id: "mock_m9_q2",
      worldId: "mundo_9",
      category: "Hibernate Avanzado",
      title: "Second Level Cache y estrategias de caché en Hibernate",
      question:
          "¿Qué es el Second Level Cache de Hibernate y cómo configuras Ehcache o Redis como provider? ¿Qué entidades son candidatas y cuáles no?",
      timeLimitSeconds: 65,
      keyConcepts: ["L1 cache: por sesión/EntityManager", "L2 cache: compartido entre sesiones", "@Cache con estrategia READ_ONLY vs READ_WRITE", "no cachear entidades con alta contención de escritura"],
      idealResponse:
          "El L1 cache (first level) es el contexto de persistencia, local a cada EntityManager, automático. El L2 cache es compartido entre sesiones y persiste entre transacciones. Se configura con @Cache(usage = CacheConcurrencyStrategy.READ_WRITE) en la entidad. Candidatos: entidades de referencia casi inmutables (países, categorías, configuraciones). No candidatos: entidades con alta frecuencia de escritura o con muchos cambios concurrentes (transacciones financieras). READ_ONLY para entidades inmutables, NONSTRICT_READ_WRITE para eventual consistency aceptable.",
      followUpQuestion: "¿Cómo invalidarías el L2 cache de Hibernate en un cluster cuando una entidad se actualiza desde una instancia diferente?",
    ),
    InterviewQuestion(
      id: "mock_m9_q3",
      worldId: "mundo_9",
      category: "Performance JPA",
      title: "Batch Processing y optimización de inserciones masivas",
      question:
          "¿Cómo insertas 100.000 registros eficientemente con JPA/Hibernate? ¿Qué configuraciones de batch insert son necesarias y por qué el ID generado en secuencia es importante?",
      timeLimitSeconds: 70,
      keyConcepts: ["hibernate.jdbc.batch_size=50", "GenerationType.SEQUENCE obligatorio (no IDENTITY)", "flush y clear periódico en loop", "saveAll vs manual batch"],
      idealResponse:
          "Para batch inserts: configurar hibernate.jdbc.batch_size=50 en properties. CRÍTICO: usar @GeneratedValue(strategy=SEQUENCE) - con IDENTITY cada INSERT requiere un SELECT para obtener el ID generado, rompiendo el batching. Con SEQUENCE, Hibernate puede generar IDs en bloque (allocationSize=50). En el loop: cada 50 registros hacer entityManager.flush() y entityManager.clear() para liberar el L1 cache y evitar OutOfMemoryError. Con Spring Data: usar saveAll() que delega, pero el control manual con flush/clear es más predecible.",
      followUpQuestion: "¿Cómo compararías el rendimiento de JPA batch insert vs JDBC bulk insert directo con PreparedStatement para 1 millón de registros?",
    ),
    InterviewQuestion(
      id: "mock_m9_q4",
      worldId: "mundo_9",
      category: "Relaciones JPA",
      title: "Mapeo de herencia con JPA: SINGLE_TABLE vs JOINED",
      question:
          "Compara las estrategias de herencia JPA: SINGLE_TABLE, TABLE_PER_CLASS y JOINED. ¿Qué trade-offs tienen en términos de performance y normalización?",
      timeLimitSeconds: 65,
      keyConcepts: ["SINGLE_TABLE: una tabla con columna discriminadora", "JOINED: tablas separadas con JOIN", "TABLE_PER_CLASS: queries UNION costosos", "SINGLE_TABLE más rápido, menos normalizado"],
      idealResponse:
          "SINGLE_TABLE: todas las subclases en una tabla con discriminator_value. Ventaja: queries simples, sin JOINs. Desventaja: columnas nullable para atributos de subclases específicas, viola normalización. JOINED: tabla padre + tabla por subclase. Ventaja: normalizado, sin nullables. Desventaja: JOINs en cada consulta polimórfica. TABLE_PER_CLASS: tabla completa por subclase. Queries polimórficas (padre.findAll()) generan UNION de todas las tablas, muy ineficiente. SINGLE_TABLE es el más común para jerarquías pequeñas; JOINED para modelos complejos.",
      followUpQuestion: "¿Cómo manejarías una consulta polimórfica eficiente sobre 5 subclases con la estrategia JOINED?",
    ),
    InterviewQuestion(
      id: "mock_m9_q5",
      worldId: "mundo_9",
      category: "Índices y SQL",
      title: "Diseño de índices y EXPLAIN ANALYZE en producción",
      question:
          "¿Cómo identificas y creas los índices correctos para optimizar una consulta SQL lenta? ¿Qué información te da EXPLAIN ANALYZE y qué métricas son las más importantes?",
      timeLimitSeconds: 70,
      keyConcepts: ["Seq Scan vs Index Scan", "cost y rows estimados", "índice compuesto: orden importa", "covering index para evitar table lookups"],
      idealResponse:
          "EXPLAIN ANALYZE muestra el plan de ejecución real. Métricas clave: Seq Scan significa que no usa índice (considera crear uno). Index Scan es ideal. El costo en paréntesis (cost=0..1000) indica el costo relativo. Para seleccionar qué indexar: columnas en WHERE, JOIN ON, ORDER BY y GROUP BY. Para índices compuestos, el orden debe coincidir con los filtros más selectivos primero. Un covering index incluye todas las columnas requeridas (SELECT + WHERE) evitando acceder a la tabla principal.",
      followUpQuestion: "¿Cuándo un índice empeora el rendimiento y cómo sabrías cuándo eliminarlo?",
    ),
    InterviewQuestion(
      id: "mock_m9_q6",
      worldId: "mundo_9",
      category: "NoSQL vs SQL",
      title: "Teorema CAP y cuándo elegir NoSQL vs SQL",
      question:
          "Explica el teorema CAP. ¿Cómo aplicas este conocimiento para elegir entre PostgreSQL, MongoDB, Cassandra y Redis para diferentes componentes de un sistema?",
      timeLimitSeconds: 70,
      keyConcepts: ["Consistency Availability Partition Tolerance", "ACID de SQL vs BASE de NoSQL", "MongoDB: CP o AP configurable", "Cassandra: AP con eventual consistency"],
      idealResponse:
          "El teorema CAP dice que un sistema distribuido solo puede garantizar 2 de 3: Consistencia (todos los nodos ven el mismo dato), Disponibilidad (siempre responde) y Tolerancia a Particiones (funciona aunque haya partición de red). PostgreSQL (CP): ACID completo, ideal para transacciones financieras. MongoDB (CP/AP configurable): documentos flexibles, bueno para catálogos. Cassandra (AP): alta disponibilidad y escalabilidad horizontal, ideal para métricas de series temporales o datos de usuario con eventual consistency. Redis (CP con Sentinel): caché en memoria, sessiones.",
      followUpQuestion: "¿Cómo diseñarías la base de datos de un sistema de mensajería como WhatsApp teniendo en cuenta CAP y los patrones de acceso?",
    ),
    InterviewQuestion(
      id: "mock_m9_q7",
      worldId: "mundo_9",
      category: "Sharding y Escalabilidad",
      title: "Database Sharding y Consistent Hashing",
      question:
          "¿Qué es el sharding de base de datos y cuáles son los principales desafíos? ¿Cómo el Consistent Hashing resuelve el problema de redistribución al agregar o eliminar shards?",
      timeLimitSeconds: 70,
      keyConcepts: ["horizontal partitioning por shard key", "cross-shard queries problemáticas", "hotspot con mala shard key", "consistent hashing en ring"],
      idealResponse:
          "Sharding divide los datos en múltiples instancias de DB (shards). La shard key determina en qué shard va cada dato. Desafíos: joins cross-shard son muy costosos o imposibles; transacciones distribuidas; hotspots si la shard key no distribuye bien (ej. fecha). Consistent Hashing: los nodos y las claves se mapean en un anillo circular. Cada clave va al nodo en sentido horario. Al agregar un nodo, solo una fracción de los datos necesita moverse (en lugar de redistribuir todo). Virtual nodes mejoran la distribución uniforme.",
      followUpQuestion: "¿Cómo manejarías cross-shard queries para reportes analíticos en una arquitectura sharded?",
    ),

    // ==========================================
    // MUNDO 10: Concurrencia, Virtual Threads & Microservicios Avanzados
    // ==========================================
    InterviewQuestion(
      id: "mock_m10_q1",
      worldId: "mundo_10",
      category: "Concurrencia Avanzada",
      title: "CompletableFuture y composición asíncrona",
      question:
          "¿Cómo encadenas y combinas múltiples operaciones asíncronas con CompletableFuture? Explica thenApply, thenCompose, thenCombine y el manejo de excepciones con exceptionally.",
      timeLimitSeconds: 65,
      keyConcepts: ["thenApply: transforma el resultado síncrono", "thenCompose: encadena futuros async", "thenCombine: combina dos futuros independientes", "exceptionally: fallback ante error"],
      idealResponse:
          "thenApply(f): transforma el resultado cuando está disponible (síncrono, no retorna CompletableFuture). thenCompose(f): cuando f retorna CompletableFuture, aplana el resultado (como flatMap). Usar para encadenar operaciones async dependientes. thenCombine(other, f): cuando los dos futuros son independientes y quieres combinar sus resultados cuando ambos terminen. exceptionally(e -> fallback): maneja excepciones y provee valor alternativo. allOf() espera a que todos terminen; anyOf() cuando el primero termina.",
      followUpQuestion: "¿Cuál es la diferencia entre thenApply y thenApplyAsync y en qué thread pool se ejecuta cada uno?",
    ),
    InterviewQuestion(
      id: "mock_m10_q2",
      worldId: "mundo_10",
      category: "Java Memory Model & Concurrencia",
      title: "Java Memory Model (JMM), 'volatile' y Happens-Before",
      question:
          "¿Qué problema de visibilidad de hardware resuelve la palabra clave 'volatile' en Java y cuál es la garantía del principio 'Happens-Before' en el JMM?",
      timeLimitSeconds: 65,
      keyConcepts: ["visibilidad en caché L1/L2 de núcleos CPU", "lecturas y escrituras directas a memoria principal", "prohibición de reordenamiento de instrucciones", "no garantiza atomicidad en operaciones compuestas"],
      idealResponse:
          "En CPUs multinúcleo, cada hilo puede almacenar valores en su propia caché local, haciendo que cambios de un hilo sean invisibles para otros. 'volatile' garantiza que lecturas y escrituras ocurran directamente en memoria principal y prohíbe el reordenamiento de instrucciones por el compilador o CPU (regla Happens-Before). Sin embargo, volatile NO garantiza atomicidad en operaciones compuestas como count++; para eso se requiere AtomicInteger o synchronized.",
      followUpQuestion: "¿Cómo funciona internamente la instrucción hardware Compare-And-Swap (CAS) utilizada en las clases atómicas?",
    ),
    InterviewQuestion(
      id: "mock_m10_q3",
      worldId: "mundo_10",
      category: "Seguridad & Microservicios",
      title: "Arquitectura de Seguridad con JWT y Spring Security 6",
      question:
          "¿Cómo diseñas una arquitectura de autenticación Stateless con tokens JWT en Spring Security 6? ¿Cuál es el rol de un Access Token de corta duración junto a un Refresh Token?",
      timeLimitSeconds: 65,
      keyConcepts: ["SecurityFilterChain y SessionCreationPolicy.STATELESS", "OncePerRequestFilter para validar firma JWT", "access token de corta vida", "refresh token seguro y revocación"],
      idealResponse:
          "En Spring Security 6 se configura el SecurityFilterChain con sesión STATELESS, desactivando sesiones HTTP de servidor. Un filtro personalizado (OncePerRequestFilter) extrae el token del header Authorization Bearer, valida su firma criptográfica y establece la autenticación en el SecurityContextHolder. El Access Token tiene corta duración (ej. 15 min) para minimizar impacto si es interceptado, mientras que el Refresh Token permite renovarlo de forma segura.",
      followUpQuestion: "¿Cómo manejarías la invalidación inmediata de tokens en caso de robo si los JWT son autónomos y stateless?",
    ),
    InterviewQuestion(
      id: "mock_m10_q4",
      worldId: "mundo_10",
      category: "Virtual Threads",
      title: "Virtual Threads de Java 21 y Project Loom",
      question:
          "¿Cómo cambian los Virtual Threads (Java 21) el modelo de concurrencia en Java? ¿Qué es el pinning y cuándo ocurre con synchronized?",
      timeLimitSeconds: 70,
      keyConcepts: ["JVM-managed scheduling", "desmontaje del carrier thread en I/O", "millones de hilos virtuales ligeros", "pinning con synchronized y natives"],
      idealResponse:
          "Los Virtual Threads son hilos ligeros gestionados por la JVM, no por el OS. Cuando un virtual thread hace I/O bloqueante, la JVM lo desmonta del carrier thread (OS thread) y el carrier queda libre para otros virtual threads. Esto permite millones de virtual threads concurrentes con pocos OS threads. Pinning ocurre cuando un virtual thread dentro de un bloque synchronized o native method no puede desmontarse del carrier, bloqueándolo. Solución: reemplazar synchronized con ReentrantLock en código crítico de performance.",
      followUpQuestion: "¿Cuándo NO deberías usar Virtual Threads y por qué la CPU-bound workload no se beneficia de ellos?",
    ),
    InterviewQuestion(
      id: "mock_m10_q5",
      worldId: "mundo_10",
      category: "Structured Concurrency",
      title: "Structured Concurrency y StructuredTaskScope (Java 21)",
      question:
          "¿Qué es Structured Concurrency en Java 21 y cómo StructuredTaskScope garantiza que las tareas hijo no sobrevivan a la tarea padre?",
      timeLimitSeconds: 65,
      keyConcepts: ["lifetime de tareas hijo ligado al scope", "ShutdownOnFailure vs ShutdownOnSuccess", "cancellation automática", "error propagation limpia"],
      idealResponse:
          "Structured Concurrency garantiza que las tareas lanzadas dentro de un scope no puedan escapar de él: todas terminan (con éxito o error) antes de que el scope cierre. StructuredTaskScope.ShutdownOnFailure: si cualquier tarea falla, cancela las demás y propaga el error. ShutdownOnSuccess: retorna cuando la primera tarea tiene éxito y cancela el resto (útil para estrategia de racing). La ventaja es que elimina los task leaks: tasks huérfanas que siguen corriendo sin que nadie las monitoree, problema común con CompletableFuture.",
      followUpQuestion: "¿Cómo migraría un código con CompletableFuture.allOf() a Structured Concurrency para mejorar la gestión de errores?",
    ),
    InterviewQuestion(
      id: "mock_m10_q6",
      worldId: "mundo_10",
      category: "Kafka & Streams",
      title: "Kafka: particiones, consumer groups y garantías de entrega",
      question:
          "¿Cómo funcionan las particiones de Kafka y los Consumer Groups? ¿Cuál es la diferencia entre at-most-once, at-least-once y exactly-once semantics?",
      timeLimitSeconds: 70,
      keyConcepts: ["partición = unidad de paralelismo", "consumer group: un consumer por partición", "offset commit determina la semántica", "idempotent producer + transacciones para exactly-once"],
      idealResponse:
          "Un topic de Kafka tiene N particiones. Un Consumer Group puede tener hasta N consumers (uno por partición máximo). El offset determina la semántica: at-most-once: commit antes de procesar (puede perder mensajes). at-least-once: commit después de procesar exitosamente (puede duplicar si el proceso falla tras procesar pero antes de commitear). exactly-once: requiere Kafka Transactions + idempotent producer (enable.idempotence=true). Kafka garantiza ordering solo dentro de una misma partición.",
      followUpQuestion: "¿Cómo diseñarías la shard key (message key) de Kafka para garantizar ordering de eventos de un mismo usuario?",
    ),
    InterviewQuestion(
      id: "mock_m10_q7",
      worldId: "mundo_10",
      category: "System Design",
      title: "Diseño de sistema: URL Shortener escalable",
      question:
          "Diseña un servicio de acortamiento de URLs (como bit.ly) que maneje 100 millones de URLs y 10 billones de redirecciones al mes. ¿Cuál sería tu arquitectura completa?",
      timeLimitSeconds: 90,
      keyConcepts: ["base62 encoding para short code", "CDN + caché para redirecciones", "DB para persistencia", "estimación de capacidad"],
      idealResponse:
          "Estimación: 10B redirecciones/mes = ~4000 RPS en lectura. 100M URLs. Generación del código: ID numérico generado en DB + Base62 encoding (a-z, A-Z, 0-9) = 7 caracteres para 62^7 = 3.5T combinaciones. API Gateway -> ShortenerService (escala horizontal) -> DB (PostgreSQL con índice en short_code). Para redirecciones: CDN como CloudFront cachea los redirects 301/302. Para redirecciones raras: Caché Redis. DB: sharding por shard_key si es necesario. Rate limiting en la API de creación contra abuso.",
      followUpQuestion: "¿Cómo agregarías analytics en tiempo real (clicks por país, dispositivo) sin impactar la latencia de las redirecciones?",
    ),
  ];

  /// Obtener preguntas filtradas por mundo
  static List<InterviewQuestion> getQuestionsForWorld(String worldId) {
    final list = allQuestions.where((q) => q.worldId == worldId).toList();
    if (list.isNotEmpty) return list;
    return allQuestions;
  }
}
