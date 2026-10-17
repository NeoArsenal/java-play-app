const http = require('http');
const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

// Zero-dependency .env loader
const envPath = path.join(__dirname, '.env');
if (fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, 'utf8');
  envContent.split('\n').forEach(line => {
    const trimmed = line.trim();
    if (trimmed && !trimmed.startsWith('#')) {
      const eqIdx = trimmed.indexOf('=');
      if (eqIdx > 0) {
        const key = trimmed.substring(0, eqIdx).trim();
        let val = trimmed.substring(eqIdx + 1).trim();
        if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
          val = val.slice(1, -1);
        }
        if (!process.env[key]) process.env[key] = val;
      }
    }
  });
}

const PORT = process.env.PORT || 8080;
const CURRICULUM_PATH = path.join(__dirname, '../assets/data/curriculum.json');
const SCHEMA_PATH = path.join(__dirname, 'schema.sql');
const DATABASE_URL = process.env.DATABASE_URL || '';
const DB_HOST = process.env.DB_HOST || '';
const DB_USER = process.env.DB_USER || '';
const DB_PASSWORD = process.env.DB_PASSWORD || '';
const DB_NAME = process.env.DB_NAME || 'postgres';
const DB_PORT = process.env.DB_PORT || 5432;

let pool = null;

const isSupabase = DATABASE_URL.includes('supabase.co') || DATABASE_URL.includes('supabase.com') || DB_HOST.includes('supabase');

// Initialize PostgreSQL Connection (via DATABASE_URL or individual params)
if (DATABASE_URL || DB_HOST) {
  try {
    if (DATABASE_URL) {
      pool = new Pool({
        connectionString: DATABASE_URL,
        ssl: { rejectUnauthorized: false }
      });
    } else {
      pool = new Pool({
        host: DB_HOST,
        port: parseInt(DB_PORT, 10),
        user: DB_USER,
        password: DB_PASSWORD,
        database: DB_NAME,
        ssl: { rejectUnauthorized: false }
      });
    }
    console.log(`🔌 Conectando a Base de Datos PostgreSQL (${isSupabase ? 'Supabase' : 'Remota'})...`);
    initPostgresSchema();
  } catch (e) {
    console.error('⚠️ No se pudo inicializar el Pool PostgreSQL:', e.message);
  }
} else {
  console.log('ℹ️ Base de datos no configurada en .env. Ejecutando con base de datos en memoria (modo local).');
}

async function initPostgresSchema() {
  if (!pool) return;
  try {
    const client = await pool.connect();
    if (fs.existsSync(SCHEMA_PATH)) {
      const sql = fs.readFileSync(SCHEMA_PATH, 'utf8');
      await client.query(sql);
      // Ensure mock_interview_submissions has latest columns
      await client.query(`
        ALTER TABLE public.mock_interview_submissions 
        ADD COLUMN IF NOT EXISTS technical_score NUMERIC(5,2) DEFAULT 0,
        ADD COLUMN IF NOT EXISTS communication_score NUMERIC(5,2) DEFAULT 0,
        ADD COLUMN IF NOT EXISTS tradeoff_score NUMERIC(5,2) DEFAULT 0,
        ADD COLUMN IF NOT EXISTS seniority_verdict VARCHAR(64) DEFAULT 'Mid-Level',
        ADD COLUMN IF NOT EXISTS user_transcript TEXT DEFAULT '',
        ADD COLUMN IF NOT EXISTS feedback TEXT DEFAULT '';

        CREATE TABLE IF NOT EXISTS public.boss_challenges (
            id BIGSERIAL PRIMARY KEY,
            user_id VARCHAR(64) REFERENCES public.users(id) ON DELETE CASCADE,
            world_id VARCHAR(64) NOT NULL,
            boss_id VARCHAR(64) NOT NULL,
            score INTEGER NOT NULL,
            passed BOOLEAN NOT NULL DEFAULT TRUE,
            xp_awarded INTEGER DEFAULT 150,
            completed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT unique_user_world_boss UNIQUE (user_id, world_id)
        );
      `);
      console.log('✅ Esquema PostgreSQL inicializado y verificado correctamente en Supabase.');
    }
    client.release();
  } catch (err) {
    console.error('⚠️ Error al inicializar esquema PostgreSQL en Supabase:', err.message);
  }
}

// In-Memory Database fallback
const memDb = {
  users: {
    'user_1': {
      id: 'user_1',
      name: 'Alonso (Dev)',
      xp: 180,
      lives: 5,
      streak: 3,
      currentLevel: 4,
      completedLessons: []
    }
  },
  leaderboard: [
    { rank: 1, name: 'Elena (Staff JVM)', xp: 1420, league: 'Diamond 💎' },
    { rank: 2, name: 'Carlos (Spring Lead)', xp: 1190, league: 'Diamond 💎' },
    { rank: 3, name: 'Alonso (Dev)', xp: 180, league: 'Diamond 💎' },
    { rank: 4, name: 'Lucía (Junior)', xp: 95, league: 'Diamond 💎' },
    { rank: 5, name: 'Mateo (Intern)', xp: 40, league: 'Diamond 💎' }
  ],
  srs_items: [
    {
      id: 'user_1:n0_ex1',
      user_id: 'user_1',
      exercise_id: 'n0_ex1',
      world_id: 'nivel_0',
      repetitions: 2,
      interval_days: 6,
      ease_factor: 2.6,
      next_review_at: new Date(Date.now() - 3600000).toISOString(),
      last_reviewed_at: new Date(Date.now() - 86400000).toISOString()
    },
    {
      id: 'user_1:n0_ex2',
      user_id: 'user_1',
      exercise_id: 'n0_ex2',
      world_id: 'nivel_0',
      repetitions: 1,
      interval_days: 1,
      ease_factor: 2.5,
      next_review_at: new Date(Date.now() - 7200000).toISOString(),
      last_reviewed_at: new Date(Date.now() - 86400000).toISOString()
    },
    {
      id: 'user_1:n1_ex2',
      user_id: 'user_1',
      exercise_id: 'n1_ex2',
      world_id: 'nivel_1',
      repetitions: 0,
      interval_days: 1,
      ease_factor: 2.4,
      next_review_at: new Date().toISOString(),
      last_reviewed_at: new Date(Date.now() - 86400000).toISOString()
    },
    {
      id: 'user_1:n2_ex2',
      user_id: 'user_1',
      exercise_id: 'n2_ex2',
      world_id: 'nivel_2',
      repetitions: 3,
      interval_days: 15,
      ease_factor: 2.7,
      next_review_at: new Date(Date.now() + 5 * 86400000).toISOString(),
      last_reviewed_at: new Date().toISOString()
    },
    {
      id: 'user_1:n4_ex2',
      user_id: 'user_1',
      exercise_id: 'n4_ex2',
      world_id: 'nivel_4',
      repetitions: 1,
      interval_days: 3,
      ease_factor: 2.36,
      next_review_at: new Date(Date.now() - 1800000).toISOString(),
      last_reviewed_at: new Date(Date.now() - 86400000).toISOString()
    }
  ]
};

// Algoritmo SuperMemo-2 (SM-2) para Repetición Espaciada
function calculateSM2(item, quality) {
  const currentEF = parseFloat(item.ease_factor || item.easeFactor || 2.5);
  const reps = parseInt(item.repetitions || 0, 10);
  const currentInterval = parseInt(item.interval_days || item.intervalDays || 1, 10);

  // EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
  let newEF = currentEF + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
  if (newEF < 1.3) newEF = 1.3;

  let newReps = reps;
  let newInterval = currentInterval;

  if (quality < 3) {
    // Si la calificación fue deficiente, resetea a revisión inmediata/mañana
    newReps = 0;
    newInterval = 1;
  } else {
    if (reps === 0) {
      newInterval = 1;
    } else if (reps === 1) {
      newInterval = 6;
    } else {
      newInterval = Math.round(currentInterval * newEF);
    }
    newReps += 1;
  }

  const nextDate = new Date();
  nextDate.setDate(nextDate.getDate() + newInterval);

  return {
    repetitions: newReps,
    interval_days: newInterval,
    ease_factor: parseFloat(newEF.toFixed(2)),
    next_review_at: nextDate.toISOString(),
    last_reviewed_at: new Date().toISOString(),
    last_quality: quality
  };
}

// ==============================================================
// FASE 3: CATÁLOGO DE PREGUNTAS Y EVALUADOR SEMÁNTICO CON IA
// ==============================================================

const mockInterviewQuestions = [
  {
    "id": "mock_m0_q1",
    "worldId": "mundo_0",
    "category": "Fundamentos Básicos",
    "title": "Variables y Tipado Fuerte",
    "question": "En una entrevista te piden explicar con tus propias palabras: ¿Qué es una variable en memoria y por qué Java exige especificar el tipo de dato (como int o String)?",
    "timeLimitSeconds": 45,
    "keyConcepts": [
      "caja / contenedor",
      "memoria RAM",
      "tipo de dato",
      "seguridad / prevención de errores"
    ],
    "idealResponse": "Una variable es un espacio reservado en la memoria RAM con un nombre para almacenar un dato. Java es de tipado estático y fuerte, lo que significa que debemos especificar el tipo (como int o String) para que el compilador sepa cuánta memoria reservar y qué operaciones son válidas, previniendo errores antes de ejecutar el programa.",
    "followUpQuestion": "¿Cuál es la diferencia entre un tipo primitivo como 'int' y un texto como 'String' en Java?"
  },
  {
    "id": "mock_m0_q2",
    "worldId": "mundo_0",
    "category": "Control de Flujo",
    "title": "Condicionales vs Bucles",
    "question": "Explica la diferencia lógica fundamental entre una estructura condicional (if/else) y un bucle (while o for). ¿Qué riesgo existe si no se define bien una condición de parada?",
    "timeLimitSeconds": 45,
    "keyConcepts": [
      "condición booleana",
      "ejecución única",
      "repetición / iteración",
      "bucle infinito"
    ],
    "idealResponse": "El 'if/else' evalúa una condición booleana una sola vez para decidir qué camino tomar. Un bucle 'while' o 'for' repite un bloque de código continuamente mientras la condición sea verdadera. Si la condición nunca se vuelve falsa, se produce un bucle infinito que puede congelar el programa y saturar la CPU.",
    "followUpQuestion": "¿En qué situación prefieres utilizar un bucle 'for' en lugar de un 'while'?"
  },
  {
    "id": "mock_m0_q3",
    "worldId": "mundo_0",
    "category": "Estructura del Programa",
    "title": "El método main y 'public static void'",
    "question": "¿Por qué todo programa en Java comienza en 'public static void main(String[] args)' y qué significa cada una de esas palabras clave?",
    "timeLimitSeconds": 50,
    "keyConcepts": [
      "punto de entrada",
      "public accesible por JVM",
      "static sin instanciar",
      "void no retorna valor"
    ],
    "idealResponse": "Es el punto de entrada que busca la JVM para iniciar la ejecución. 'public' permite que la JVM lo ejecute desde fuera de la clase; 'static' permite llamarlo sin crear antes un objeto de la clase; 'void' indica que no devuelve ningún valor; y 'main' es el nombre estándar reconocido por la máquina virtual.",
    "followUpQuestion": "¿Para qué sirve el parámetro 'String[] args' en la firma del método main?"
  },
  {
    "id": "mock_m1_q1",
    "worldId": "mundo_1",
    "category": "JVM Internals & Memoria",
    "title": "Stack vs Heap y Diagnóstico de OOM",
    "question": "Explica la diferencia entre la memoria Stack y Heap en la JVM. ¿Puede ocurrir una fuga de memoria (Memory Leak) en Java a pesar del Garbage Collector? ¿Cómo sucede?",
    "timeLimitSeconds": 60,
    "keyConcepts": [
      "stack para frames y variables locales",
      "heap para objetos",
      "hilos independientes",
      "GC roots / referencias vivas"
    ],
    "idealResponse": "El Stack almacena variables locales, frames de llamada a métodos y referencias por cada hilo de ejecución de forma rápida y efímera. El Heap es la memoria compartida donde residen todos los objetos instanciados gestionados por el Garbage Collector. Sí puede haber Memory Leaks si objetos en desuso quedan referenciados desde una GC Root (como colecciones estáticas o listeners), impidiendo que el GC los libere.",
    "followUpQuestion": "¿Qué parámetros de la JVM activarías en producción para capturar automáticamente un Heap Dump ante un OutOfMemoryError?"
  },
  {
    "id": "mock_m1_q2",
    "worldId": "mundo_1",
    "category": "Manejo de Texto & Memoria",
    "title": "Inmutabilidad de String y el String Pool",
    "question": "¿Por qué la clase String es inmutable en Java? ¿Qué es el String Pool y por qué se recomienda usar StringBuilder al concatenar dentro de bucles?",
    "timeLimitSeconds": 55,
    "keyConcepts": [
      "inmutabilidad",
      "string pool en heap",
      "seguridad / thread-safety",
      "stringbuilder mutable"
    ],
    "idealResponse": "String es inmutable por seguridad, caching de hashCodes y para permitir el String Pool en el Heap, donde literales idénticos comparten la misma instancia. Concatenar con '+' en bucles crea cientos de objetos intermedios efímeros que saturan el Garbage Collector. StringBuilder es mutable y permite modificar buffers en memoria sin instanciar objetos intermedios.",
    "followUpQuestion": "¿Cuál es la diferencia entre StringBuilder y StringBuffer en términos de concurrencia y sincronización?"
  },
  {
    "id": "mock_m1_q3",
    "worldId": "mundo_1",
    "category": "Tipos de Datos",
    "title": "Primitivos vs Wrappers y Autoboxing",
    "question": "¿Cuál es la diferencia entre un tipo primitivo (int) y su Wrapper (Integer)? ¿Qué peligro oculto de rendimiento o de excepciones presenta el Autoboxing no controlado?",
    "timeLimitSeconds": 50,
    "keyConcepts": [
      "primitivo en stack por valor",
      "wrapper objeto en heap",
      "autoboxing automático",
      "NullPointerException en unboxing"
    ],
    "idealResponse": "Los primitivos se almacenan por valor directamente en el Stack con bajo costo de memoria. Los Wrappers son objetos completos en el Heap que admiten null y métodos utilitarios. El Autoboxing convierte automáticamente entre ambos, pero si un Wrapper es null y se evalúa como primitivo, lanza NullPointerException en tiempo de ejecución. Además, en bucles intensivos genera overhead masivo de memoria.",
    "followUpQuestion": "¿Qué es el Integer Cache en Java y en qué rango de valores funciona por defecto?"
  },
  {
    "id": "mock_m2_q1",
    "worldId": "mundo_2",
    "category": "POO & Modelado",
    "title": "El Contrato Sagrado: equals() y hashCode()",
    "question": "¿Por qué es obligatorio sobrescribir hashCode() cuando se sobrescribe equals()? ¿Qué ocurre internamente en un HashMap o HashSet si violas este contrato?",
    "timeLimitSeconds": 60,
    "keyConcepts": [
      "contrato equals y hashCode",
      "cálculo del bucket",
      "objetos iguales mismo hash",
      "pérdida de elementos / get null"
    ],
    "idealResponse": "El contrato estipula que si dos objetos son iguales según equals(), deben retornar exactamente el mismo hashCode(). Un HashMap utiliza hashCode() para determinar el índice del 'bucket' donde guardará o buscará el objeto. Si violas el contrato, dos objetos idénticos caerán en buckets diferentes, provocando que un HashSet almacene duplicados o que map.get(key) retorne null aunque la clave exista.",
    "followUpQuestion": "¿Qué sucede internamente cuando dos objetos distintos producen el mismo hashCode (colisión)?"
  },
  {
    "id": "mock_m2_q2",
    "worldId": "mundo_2",
    "category": "POO & Polimorfismo",
    "title": "Polimorfismo en Tiempo de Ejecución y Dynamic Dispatch",
    "question": "Explica cómo funciona el Polimorfismo dinámico en Java. ¿Cuál es la diferencia entre sobrecarga (overload) y sobrescritura (override) a nivel de compilación y ejecución?",
    "timeLimitSeconds": 55,
    "keyConcepts": [
      "dynamic dispatch",
      "sobrescritura en tiempo de ejecución",
      "sobrecarga en compilación",
      "referencia polimórfica"
    ],
    "idealResponse": "La sobrecarga resuelve qué método invocar en tiempo de compilación según la cantidad y tipo de parámetros. La sobrescritura (@Override) permite que una subclase redefina el comportamiento de un método del padre, y en tiempo de ejecución la JVM usa 'dynamic dispatch' para invocar la implementación del objeto real instanciado, independientemente del tipo de referencia.",
    "followUpQuestion": "¿Se pueden sobrescribir métodos 'static' o 'final' en Java? Justifica por qué."
  },
  {
    "id": "mock_m2_q3",
    "worldId": "mundo_2",
    "category": "Diseño de Software",
    "title": "Composición sobre Herencia",
    "question": "¿Por qué en diseño de software orientado a objetos se recomienda 'favorecer la composición sobre la herencia'? Menciona un problema clásico de la herencia profunda.",
    "timeLimitSeconds": 55,
    "keyConcepts": [
      "acoplamiento rígido",
      "fragile base class",
      "delegación de responsabilidades",
      "flexibilidad en tiempo de ejecución"
    ],
    "idealResponse": "La herencia genera un acoplamiento rígido de caja blanca donde cambios en la clase base pueden romper subclases sin advertencia (problema de la clase base frágil). La composición encapsula la funcionalidad en componentes independientes y delega tareas, permitiendo cambiar comportamientos en tiempo de ejecución mediante interfaces y facilitando el testing unitario con mocks.",
    "followUpQuestion": "¿Cómo se relaciona la composición con el principio de Inyección de Dependencias?"
  },
  {
    "id": "mock_m3_q1",
    "worldId": "mundo_3",
    "category": "Abstracción & Contratos",
    "title": "Interfaces vs Clases Abstractas y Métodos Default",
    "question": "¿En qué se diferencian conceptualmente las Interfaces de las Clases Abstractas en Java moderno? ¿Por qué se introdujeron los 'default methods' en Java 8?",
    "timeLimitSeconds": 60,
    "keyConcepts": [
      "contrato de comportamiento",
      "estado con variables de instancia",
      "métodos default",
      "compatibilidad hacia atrás"
    ],
    "idealResponse": "Una interfaz define un contrato de comportamiento puro sin estado de instancia, permitiendo herencia múltiple de tipos. Una clase abstracta puede mantener estado mutable protegido y constructores compartidos. Los métodos default se introdujeron en Java 8 para permitir la evolución de interfaces existentes (como Collections) agregando métodos nuevos sin romper las implementaciones previas.",
    "followUpQuestion": "¿Cómo resuelve Java la ambigüedad si una clase implementa dos interfaces con el mismo método default (problema del diamante)?"
  },
  {
    "id": "mock_m3_q2",
    "worldId": "mundo_3",
    "category": "Principios SOLID",
    "title": "Inversión de Dependencias (DIP) y Programar hacia Interfaces",
    "question": "Explica el Principio de Inversión de Dependencias (la 'D' de SOLID). ¿Por qué decimos que los módulos de alto nivel no deben depender de implementaciones concretas?",
    "timeLimitSeconds": 55,
    "keyConcepts": [
      "depender de abstracciones",
      "desacoplamiento",
      "inyección de dependencias",
      "mantenibilidad y testing"
    ],
    "idealResponse": "El principio DIP estipula que los módulos de alto nivel no deben depender de detalles o clases concretas de bajo nivel, sino de abstracciones (interfaces). Esto desacopla la lógica de negocio del framework o tecnología subyacente, permitiendo sustituir implementaciones (por ejemplo, cambiar PostgreSQL por MongoDB o usar un Mock en pruebas) sin modificar la capa de negocio.",
    "followUpQuestion": "¿Cómo ayuda este principio cuando configuramos perfiles de base de datos en Spring Boot?"
  },
  {
    "id": "mock_m3_q3",
    "worldId": "mundo_3",
    "category": "Java Moderno",
    "title": "Sealed Interfaces y Jerarquías Cerradas (Java 17+)",
    "question": "¿Qué problema resuelven las Sealed Interfaces y clases selladas introducidas en Java 17? ¿Cómo colaboran con el Pattern Matching en sentencias switch?",
    "timeLimitSeconds": 55,
    "keyConcepts": [
      "cláusula permits",
      "jerarquía finita y cerrada",
      "exhaustividad en switch",
      "modelado de dominio seguro"
    ],
    "idealResponse": "Las Sealed Interfaces permiten al autor restringir explícitamente qué clases o interfaces pueden extenderla mediante la cláusula 'permits'. Esto modela tipos de datos algebraicos donde se conoce el conjunto cerrado de subtipos posibles. El compilador puede verificar la exhaustividad de los casos en un switch sin requerir una cláusula 'default', advirtiendo si falta algún subtipo.",
    "followUpQuestion": "¿Qué modificadores obligatorios deben llevar los subtipos que implementan una sealed interface?"
  },
  {
    "id": "mock_m4_q1",
    "worldId": "mundo_4",
    "category": "Excepciones & Resiliencia",
    "title": "Checked vs Unchecked (Runtime) Exceptions",
    "question": "¿Cuál es el criterio de diseño para elegir entre una Checked Exception (Exception) y una Unchecked Exception (RuntimeException)? ¿Por qué los frameworks modernos prefieren RuntimeExceptions?",
    "timeLimitSeconds": 60,
    "keyConcepts": [
      "checked obligan manejo en compilador",
      "condiciones recuperables",
      "unchecked errores de programación",
      "código limpio sin throws masivos"
    ],
    "idealResponse": "Las Checked Exceptions obligan al llamador a manejarlas con try-catch o declararlas con throws, pensadas para fallos externos recuperables (como archivo no encontrado). Las Unchecked (RuntimeException) representan errores lógicos irrecuperables del desarrollador o fallos de infraestructura. Frameworks como Spring las prefieren para evitar ensuciar firmas de métodos y centralizar el manejo de errores.",
    "followUpQuestion": "¿Qué sucede si una RuntimeException no se captura en el hilo de ejecución?"
  },
  {
    "id": "mock_m4_q2",
    "worldId": "mundo_4",
    "category": "Gestión de Recursos",
    "title": "try-with-resources y AutoCloseable",
    "question": "¿Cómo funciona la sentencia try-with-resources en Java y qué requisitos debe cumplir el objeto utilizado? ¿Qué ventaja tiene sobre el bloque finally tradicional?",
    "timeLimitSeconds": 55,
    "keyConcepts": [
      "interfaz AutoCloseable",
      "cierre garantizado",
      "evita fugas de recursos / connections",
      "gestión de excepciones suprimidas"
    ],
    "idealResponse": "try-with-resources asegura que los recursos (como streams de red, ficheros o conexiones JDBC) se cierren automáticamente al terminar el bloque, incluso si ocurre una excepción. El recurso debe implementar AutoCloseable. Es superior al bloque finally porque es mucho más conciso y maneja limpiamente las 'excepciones suprimidas' si ocurre un error tanto en la operación como en el cierre.",
    "followUpQuestion": "¿Qué es una excepción suprimida y cómo se accede a ella en el código de diagnóstico?"
  },
  {
    "id": "mock_m4_q3",
    "worldId": "mundo_4",
    "category": "Calidad & Diagnóstico",
    "title": "Antipatrón: 'Swallowing Exceptions' y Chained Exceptions",
    "question": "¿Por qué capturar una excepción con un bloque catch vacío o solo imprimiendo un mensaje genérico se considera un antipatrón crítico en producción? ¿Cómo se deben encadenar excepciones?",
    "timeLimitSeconds": 55,
    "keyConcepts": [
      "pérdida de stacktrace",
      "fallos silenciosos difíciles de depurar",
      "encadenar con cause",
      "excepciones de dominio"
    ],
    "idealResponse": "'Tragarse la excepción' oculta la causa raíz del fallo en producción, dejando al sistema en estado inconsistente sin logs que permitan diagnosticar el incidente. La buena práctica consiste en relanzar una excepción de dominio envolviendo la original mediante 'throw new DomainException(msg, originalException)', preservando la causa raíz y todo el stacktrace para trazabilidad.",
    "followUpQuestion": "¿Cómo ayuda la observabilidad y el logging estructurado con SLF4J a evitar este problema?"
  },
  {
    "id": "mock_m5_q1",
    "worldId": "mundo_5",
    "category": "Java Collections & Big-O",
    "title": "HashMap Internals: Buckets, Colisiones y Árboles Rojo-Negro",
    "question": "Explica cómo funciona internamente un HashMap en Java. ¿Cómo calcula el índice del bucket y cómo se gestionan las colisiones a partir de Java 8?",
    "timeLimitSeconds": 65,
    "keyConcepts": [
      "cálculo de hash y módulo bucket",
      "colisión en misma posición",
      "lista enlazada inicial",
      "conversión a árbol rojo-negro (TREEIFY)"
    ],
    "idealResponse": "HashMap mantiene un arreglo interno de buckets. Al hacer put(k, v), aplica una función hash a k.hashCode() y calcula el índice mediante operación bitwise. Si dos claves tienen el mismo índice (colisión), se guardan en una lista enlazada en ese bucket. A partir de Java 8, si una lista supera 8 elementos (TREEIFY_THRESHOLD), se transforma en un Árbol Rojo-Negro, mejorando la búsqueda de O(n) a O(log n).",
    "followUpQuestion": "¿Qué es el 'Load Factor' y qué ocurre cuando el HashMap alcanza el umbral de capacidad?"
  },
  {
    "id": "mock_m5_q2",
    "worldId": "mundo_5",
    "category": "Estructuras de Datos & CPU",
    "title": "ArrayList vs LinkedList: Cache Locality y Rendimiento Real",
    "question": "En teoría, LinkedList inserta al inicio en O(1) y ArrayList en O(n). ¿Por qué en entornos de producción con hardware moderno ArrayList suele ser significativamente más rápido en casi todos los escenarios?",
    "timeLimitSeconds": 60,
    "keyConcepts": [
      "array contiguo en memoria",
      "cache locality del CPU",
      "punteros dispersos de LinkedList",
      "acceso O(1) indexado"
    ],
    "idealResponse": "ArrayList almacena sus elementos en un bloque contiguo de memoria, lo que aprovecha la 'Cache Locality' y la precarga de la caché L1/L2 del CPU. LinkedList almacena nodos independientes dispersos por el Heap con múltiples punteros, provocando constantes Cache Misses y mayor sobrecarga de memoria por nodo. Para lecturas e iteraciones, ArrayList es drásticamente más eficiente.",
    "followUpQuestion": "¿Cuándo recomendarías usar una Queue o Deque en lugar de una lista?"
  },
  {
    "id": "mock_m5_q3",
    "worldId": "mundo_5",
    "category": "Colecciones Concurrentes",
    "title": "ConcurrentHashMap vs Collections.synchronizedMap()",
    "question": "¿Por qué nunca se debe usar Collections.synchronizedMap() en aplicaciones con alta concurrencia y qué técnica de bloqueo utiliza ConcurrentHashMap?",
    "timeLimitSeconds": 60,
    "keyConcepts": [
      "bloqueo global en synchronizedMap",
      "bloqueo por segmento / bucket",
      "lecturas sin bloqueo con volatile",
      "escalabilidad con múltiples hilos"
    ],
    "idealResponse": "synchronizedMap bloquea toda la colección con un único cerrojo global para cada operación, creando un cuello de botella donde todos los hilos compiten por el mismo recurso. ConcurrentHashMap implementa 'Lock Striping' y operaciones atómicas CAS a nivel de bucket: las lecturas no se bloquean y las escrituras solo bloquean el nodo cabecera del bucket afectado, permitiendo alta concurrencia.",
    "followUpQuestion": "¿Permite ConcurrentHashMap almacenar claves o valores 'null'? ¿Por qué?"
  },
  {
    "id": "mock_m6_q1",
    "worldId": "mundo_6",
    "category": "Programación Funcional",
    "title": "Streams API: Operaciones Intermedias vs Terminales",
    "question": "¿Cuál es la diferencia fundamental entre una operación intermedia y una terminal en el Java Streams API? ¿Qué significa que las operaciones intermedias sean 'Lazy'?",
    "timeLimitSeconds": 60,
    "keyConcepts": [
      "evaluación lazy / perezosa",
      "operación terminal dispara procesamiento",
      "inmutabilidad de la fuente",
      "cortocircuito / short-circuiting"
    ],
    "idealResponse": "Las operaciones intermedias (como filter o map) devuelven un nuevo Stream y son 'Lazy' (perezosas): no ejecutan ningún cómputo hasta que se invoca una operación terminal (como collect, forEach o reduce). Esto permite optimizaciones como fusionar transformaciones en una sola pasada o aplicar cortocircuito (findFirst) sin procesar elementos innecesarios.",
    "followUpQuestion": "¿Qué sucede si intentas reutilizar un Stream que ya fue consumido por una operación terminal?"
  },
  {
    "id": "mock_m6_q2",
    "worldId": "mundo_6",
    "category": "Java Idiomático",
    "title": "Uso Idiomático de Optional y Prevención de Antipatrones",
    "question": "¿Cuál es el propósito original de Optional en Java y cuáles son los dos antipatrones más comunes que debes evitar al usarlo?",
    "timeLimitSeconds": 60,
    "keyConcepts": [
      "retorno de métodos sin valor",
      "evitar op.get() sin isPresent",
      "no usar como parámetro de método",
      "evitar orElse cuando hay cómputo pesado (usar orElseGet)"
    ],
    "idealResponse": "Optional fue diseñado exclusivamente como tipo de retorno para métodos que pueden no tener valor, forzando al cliente a pensar en la ausencia sin lanzar NPE. Los antipatrones comunes son: 1) llamar a opt.get() directamente recreando el peligro de NPE, 2) usarlo como parámetro de método o en atributos de clase sobrecargando la memoria, y 3) usar orElse(llamadaPesada()) en lugar de orElseGet(() -> llamadaPesada()).",
    "followUpQuestion": "¿Por qué Optional no implementa java.io.Serializable?"
  },
  {
    "id": "mock_m6_q3",
    "worldId": "mundo_6",
    "category": "Streams & Transformaciones",
    "title": "Diferencia entre map() y flatMap() en Streams",
    "question": "Explica con un ejemplo claro la diferencia entre stream.map() y stream.flatMap(). ¿Cuándo es indispensable utilizar flatMap?",
    "timeLimitSeconds": 55,
    "keyConcepts": [
      "map transforma 1 a 1",
      "flatMap aplana estructuras anidadas 1 a N",
      "desempaquetado de Stream<Stream<T>>",
      "evita listas dentro de listas"
    ],
    "idealResponse": "map() aplica una función transformadora 1 a 1 (por ejemplo, transformar un String a su longitud int). flatMap() se utiliza cuando la función transformadora devuelve una colección o un Stream por cada elemento (1 a N), y necesitamos 'aplanar' (flatten) esos múltiples streams en un único Stream continuo de primer nivel, evitando tener Stream<Stream<T>>.",
    "followUpQuestion": "¿Cómo se utiliza flatMap en conjunto con Optional para evitar comprobaciones null anidadas?"
  },
  {
    "id": "mock_m7_q1",
    "worldId": "mundo_7",
    "category": "Spring Boot & Inyección",
    "title": "Inversión de Control (IoC) e Inyección por Constructor",
    "question": "¿Por qué Spring Boot recomienda la Inyección de Dependencias por Constructor sobre el uso de la anotación @Autowired en campos privados (Field Injection)?",
    "timeLimitSeconds": 60,
    "keyConcepts": [
      "atributos inmutables final",
      "facilidad de pruebas unitarias sin Spring",
      "prevención de NullPointerException",
      "detección de dependencias circulares en inicio"
    ],
    "idealResponse": "La inyección por constructor permite declarar las dependencias como 'final' garantizando inmutabilidad. Facilita las pruebas unitarias porque podemos instanciar la clase pasando mocks manualmente sin necesidad de levantar el contexto de Spring ni usar reflexión. Además, previene estados inconsistentes y permite al contenedor detectar dependencias circulares inmediatamente en tiempo de arranque.",
    "followUpQuestion": "¿Cómo ayuda la anotación @RequiredArgsConstructor de Lombok en este patrón?"
  },
  {
    "id": "mock_m7_q2",
    "worldId": "mundo_7",
    "category": "Spring Boot & Concurrencia",
    "title": "Ámbitos de Beans: Singleton, Concurrencia y Stateless",
    "question": "Si los Beans de Spring son Singleton por defecto y la aplicación atiende cientos de peticiones en paralelo con hilos distintos, ¿qué riesgos de concurrencia existen y cómo garantizas Thread-Safety?",
    "timeLimitSeconds": 60,
    "keyConcepts": [
      "beans singleton compartidos",
      "diseño stateless sin estado mutable",
      "call stack de hilos independientes",
      "variables locales de método"
    ],
    "idealResponse": "Los beans de Spring son Singleton por defecto y compartidos por múltiples hilos del Servlet Container (Tomcat). Para garantizar Thread-Safety, los beans deben ser Stateless (sin variables de instancia mutables). Los datos de cada petición deben fluir en variables locales de método, las cuales residen en el Call Stack de cada hilo de forma aislada. Si se requiere estado por petición, se debe usar @RequestScope.",
    "followUpQuestion": "Si forzosamente necesitas un contador en memoria en un bean Singleton, ¿qué estructura de java.util.concurrent usarías?"
  },
  {
    "id": "mock_m7_q3",
    "worldId": "mundo_7",
    "category": "Spring AOP & Proxies",
    "title": "Spring AOP y Proxies Dinámicos (JDK vs CGLIB)",
    "question": "¿Cómo implementa Spring Boot anotaciones como @Transactional o @Async mediante Proxies dinámicos y qué problema ocurre con la auto-invocación interna (self-invocation)?",
    "timeLimitSeconds": 65,
    "keyConcepts": [
      "envoltorio proxy dinámico",
      "interceptación de llamadas",
      "self-invocation evade el proxy",
      "cglib para clases concretas"
    ],
    "idealResponse": "Spring envuelve los beans en proxies (JDK Dynamic Proxies para interfaces o CGLIB para clases concretas) que interceptan las llamadas externas para aplicar aspectos transversales (abrir/cerrar transacciones o cambiar de hilo). Si un método llama a otro método de la misma clase mediante 'this.metodoB()', la llamada no pasa por el proxy externo y las anotaciones como @Transactional son ignoradas.",
    "followUpQuestion": "¿Cómo resolverías el problema de auto-invocación si no quieres dividir el bean en dos servicios diferentes?"
  },
  {
    "id": "mock_m8_q1",
    "worldId": "mundo_8",
    "category": "Diseño de APIs HTTP",
    "title": "Idempotencia y Semántica HTTP: POST vs PUT vs PATCH",
    "question": "Explica el concepto de idempotencia en HTTP y contrasta la semántica técnica de los verbos POST, PUT y PATCH en una API REST de producción.",
    "timeLimitSeconds": 60,
    "keyConcepts": [
      "idempotencia mismo resultado en llamadas repetidas",
      "POST crea recurso nuevo (no idempotente)",
      "PUT reemplazo total (idempotente)",
      "PATCH modificación parcial"
    ],
    "idealResponse": "Un método HTTP es idempotente si ejecutar la misma petición múltiples veces produce exactamente el mismo estado en el servidor. POST no es idempotente porque cada llamada crea un nuevo recurso. PUT es idempotente porque envía la representación completa para reemplazar o crear el recurso en una URI fija. PATCH aplica modificaciones parciales a campos específicos del recurso.",
    "followUpQuestion": "¿Qué códigos de estado HTTP retornarías para un POST exitoso y para un PUT exitoso que no devuelve cuerpo?"
  },
  {
    "id": "mock_m8_q2",
    "worldId": "mundo_8",
    "category": "Manejo Global de Errores",
    "title": "RFC 7807 (ProblemDetail) y @RestControllerAdvice",
    "question": "¿Por qué es una mala práctica dejar que las excepciones de Spring Boot salgan sin formato al cliente? ¿Cómo ayuda @RestControllerAdvice y el estándar RFC 7807 (ProblemDetail)?",
    "timeLimitSeconds": 60,
    "keyConcepts": [
      "@RestControllerAdvice centralizado",
      "RFC 7807 ProblemDetail estándar",
      "ocultar stacktraces sensibles",
      "códigos de error claros para el frontend"
    ],
    "idealResponse": "Dejar escapar excepciones crudas expone detalles internos de la arquitectura (stacktraces, tablas de base de datos) facilitando vulnerabilidades de seguridad. @RestControllerAdvice intercepta excepciones globalmente y las mapea al estándar RFC 7807 (ProblemDetail en Spring 6), retornando JSON estructurado con status, title, detail y type para que clientes consuman errores con precisión sin ver datos sensibles.",
    "followUpQuestion": "¿Cómo manejas los errores de validación de argumentos (@Valid) para devolver una lista amigable de campos inválidos?"
  },
  {
    "id": "mock_m8_q3",
    "worldId": "mundo_8",
    "category": "Arquitectura & DTOs",
    "title": "Separación Entidades JPA vs DTOs y Validación Declarativa",
    "question": "¿Por qué exponer entidades JPA directamente como parámetros o respuestas en controladores REST es un antipatrón grave y cómo los DTOs y Jakarta Validation lo solucionan?",
    "timeLimitSeconds": 60,
    "keyConcepts": [
      "desacoplamiento de modelo de datos",
      "prevención de sobreexposición (Over-posting)",
      "evitar serializar lazy proxies",
      "validación declarativa con @Valid"
    ],
    "idealResponse": "Exponer entidades JPA directamente causa: 1) vulnerabilidades de seguridad por Over-posting donde clientes pueden alterar campos sensibles como roles, 2) fallos de serialización al intentar serializar relaciones Lazy fuera de la sesión transaccional, y 3) acoplamiento estricto del API a la base de datos. Los DTOs aíslan el contrato público y permiten validación estricta con Jakarta Validation (@NotNull, @Size, @Email).",
    "followUpQuestion": "¿Qué biblioteca de mapeo recomiendas en Java moderno (ej. MapStruct) y por qué supera a la reflexión en tiempo de ejecución?"
  },
  {
    "id": "mock_m9_q1",
    "worldId": "mundo_9",
    "category": "Spring Data JPA & Hibernate",
    "title": "El Problema de N+1 Selects en Hibernate y Soluciones",
    "question": "¿En qué consiste el clásico problema de N+1 Selects en Hibernate/JPA y cuáles son las mejores estrategias para resolverlo en producción?",
    "timeLimitSeconds": 65,
    "keyConcepts": [
      "lazy loading en bucle",
      "1 consulta padre + N consultas hijas",
      "JOIN FETCH en JPQL",
      "EntityGraph y batch size"
    ],
    "idealResponse": "El problema N+1 ocurre al recuperar una lista de entidades padre (1 consulta) y luego acceder a una relación Lazy en cada una dentro de un bucle, disparando N consultas adicionales a la base de datos (1 + N queries), saturando el pool de conexiones. Se soluciona utilizando 'JOIN FETCH' en consultas JPQL, @EntityGraph para especificar relaciones eager dinámicas, o configurando hibernate.default_batch_fetch_size para agrupar consultas con cláusulas IN.",
    "followUpQuestion": "¿Por qué no se debe solucionar el N+1 cambiando todas las relaciones a FetchType.EAGER de manera permanente en el modelo de entidades?"
  },
  {
    "id": "mock_m9_q2",
    "worldId": "mundo_9",
    "category": "Persistencia & Rendimiento",
    "title": "Peligros de FetchType.EAGER y por qué LAZY es la regla",
    "question": "¿Por qué arquitectos senior consideran que FetchType.EAGER es un 'code smell' en JPA y qué impacto tiene en consultas complejas?",
    "timeLimitSeconds": 55,
    "keyConcepts": [
      "carga innecesaria en memoria",
      "producto cartesiano en joins",
      "imposibilidad de desactivar en runtime",
      "LAZY como estándar con fetching específico"
    ],
    "idealResponse": "FetchType.EAGER obliga a Hibernate a traer siempre la relación aunque no se necesite en ese caso de uso, saturando la memoria y multiplicando joins innecesarios (generando problemas de producto cartesiano). Además, no se puede apagar dinámicamente en consultas específicas. La regla de oro es configurar todo como LAZY y activar la carga solo cuando se necesite con JOIN FETCH o EntityGraph.",
    "followUpQuestion": "¿Qué excepción lanza Hibernate si intentas acceder a una relación LAZY cuando la sesión/transacción ya está cerrada?"
  },
  {
    "id": "mock_m9_q3",
    "worldId": "mundo_9",
    "category": "Transaccionalidad & Concurrencia",
    "title": "@Transactional y Bloqueo Optimista (@Version) vs Pesimista",
    "question": "¿Cómo garantiza @Transactional la integridad atómica en la base de datos y cómo previene el Bloqueo Optimista (@Version) las actualizaciones perdidas (Lost Updates)?",
    "timeLimitSeconds": 65,
    "keyConcepts": [
      "ACID y rollback ante RuntimeException",
      "columna version incremental",
      "OptimisticLockException",
      "bloqueo pesimista con for update"
    ],
    "idealResponse": "@Transactional delimita el contexto de persistencia y aplica rollback automático si se lanza una RuntimeException, asegurando atomicidad ACID. El Bloqueo Optimista añade una columna '@Version' a la entidad: al hacer update, verifica que la versión en BD coincida con la que leyó; si otro hilo la modificó antes, la versión no coincide y lanza OptimisticLockException sin bloquear físicamente registros en el motor de base de datos.",
    "followUpQuestion": "¿En qué tipo de sistemas de alta contención prefieres Bloqueo Pesimista (PESSIMISTIC_WRITE) sobre el optimista?"
  },
  {
    "id": "mock_m10_q1",
    "worldId": "mundo_10",
    "category": "Java 21 Moderno & Loom",
    "title": "Virtual Threads en Java 21 vs Platform Threads",
    "question": "¿Qué son los Virtual Threads de Java 21 y en qué se diferencian de los Platform Threads del sistema operativo? ¿En qué escenarios marcan la diferencia y en cuáles no?",
    "timeLimitSeconds": 65,
    "keyConcepts": [
      "virtual threads administrados por JVM",
      "platform threads 1 a 1 con SO",
      "operaciones bloqueantes I/O desmontan hilo",
      "sin beneficio en tareas CPU-bound"
    ],
    "idealResponse": "Los Platform Threads son hilos pesados mapeados 1:1 al SO con ~1MB de memoria dedicada cada uno. Los Virtual Threads son gestionados enteramente por la JVM en memoria Heap (pocos bytes). Cuando un Virtual Thread ejecuta una operación I/O bloqueante (DB o red), la JVM lo desmonta del 'Carrier Thread' del SO, permitiendo procesar millones de peticiones concurrentes en aplicaciones I/O Bound sin agotar los hilos del sistema. No aportan en tareas intensivas de CPU pura.",
    "followUpQuestion": "¿Qué es el fenómeno de 'Thread Pinning' en Virtual Threads y cómo lo evitas (por ejemplo, reemplazando bloques synchronized por ReentrantLock)?"
  },
  {
    "id": "mock_m10_q2",
    "worldId": "mundo_10",
    "category": "Java Memory Model & Concurrencia",
    "title": "Java Memory Model (JMM), 'volatile' y Happens-Before",
    "question": "¿Qué problema de visibilidad de hardware resuelve la palabra clave 'volatile' en Java y cuál es la garantía del principio 'Happens-Before' en el JMM?",
    "timeLimitSeconds": 65,
    "keyConcepts": [
      "visibilidad en caché L1/L2 de núcleos CPU",
      "lecturas y escrituras directas a memoria principal",
      "prohibición de reordenamiento de instrucciones",
      "no garantiza atomicidad en operaciones compuestas"
    ],
    "idealResponse": "En CPUs multinúcleo, cada hilo puede almacenar valores en su propia caché local, haciendo que cambios de un hilo sean invisibles para otros. 'volatile' garantiza que lecturas y escrituras ocurran directamente en memoria principal y prohíbe el reordenamiento de instrucciones por el compilador o CPU (regla Happens-Before). Sin embargo, volatile NO garantiza atomicidad en operaciones compuestas como count++; para eso se requiere AtomicInteger o synchronized.",
    "followUpQuestion": "¿Cómo funciona internamente la instrucción hardware Compare-And-Swap (CAS) utilizada en las clases atómicas?"
  },
  {
    "id": "mock_m10_q3",
    "worldId": "mundo_10",
    "category": "Seguridad & Microservicios",
    "title": "Arquitectura de Seguridad con JWT y Spring Security 6",
    "question": "¿Cómo diseñas una arquitectura de autenticación Stateless con tokens JWT en Spring Security 6? ¿Cuál es el rol de un Access Token de corta duración junto a un Refresh Token?",
    "timeLimitSeconds": 65,
    "keyConcepts": [
      "SecurityFilterChain y SessionCreationPolicy.STATELESS",
      "OncePerRequestFilter para validar firma JWT",
      "access token de corta vida",
      "refresh token seguro y revocación"
    ],
    "idealResponse": "En Spring Security 6 se configura el SecurityFilterChain con sesión STATELESS, desactivando sesiones HTTP de servidor. Un filtro personalizado (OncePerRequestFilter) extrae el token del header Authorization Bearer, valida su firma criptográfica y establece la autenticación en el SecurityContextHolder. El Access Token tiene corta duración (ej. 15 min) para minimizar impacto si es interceptado, mientras que el Refresh Token permite renovarlo de forma segura.",
    "followUpQuestion": "¿Cómo manejarías la invalidación inmediata de tokens en caso de robo si los JWT son autónomos y stateless?"
  }
];

async function callGeminiApi(questionObj, userTranscript) {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) return null;
  const https = require('https');

  const prompt = `Eres un Principal Staff Java Architect y Technical Interviewer en Google/Netflix.
Evalúa la siguiente respuesta de un candidato a una pregunta de entrevista técnica.

PREGUNTA DE ENTREVISTA:
"${questionObj.question}"

CONCEPTOS CLAVE ESPERADOS:
${JSON.stringify(questionObj.keyConcepts)}

RESPUESTA IDEAL DEL SENIOR:
"${questionObj.idealResponse}"

RESPUESTA TRANSCRITA DEL CANDIDATO:
"${userTranscript}"

Debes responder ÚNICAMENTE en formato JSON válido con esta estructura:
{
  "score": number (0-100),
  "technicalScore": number (0-100),
  "communicationScore": number (0-100),
  "tradeoffScore": number (0-100),
  "seniorityVerdict": "Staff / Principal Architect" | "Senior Java Engineer" | "Mid-Level Software Engineer" | "Junior Developer (En Crecimiento)",
  "verdictBadge": string,
  "conceptsCovered": [string],
  "conceptsMissed": [string],
  "strengths": [string],
  "improvements": [string],
  "feedback": string,
  "followUpQuestion": string
}`;

  return new Promise((resolve) => {
    const reqData = JSON.stringify({
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: { responseMimeType: "application/json" }
    });

    const options = {
      hostname: 'generativelanguage.googleapis.com',
      path: `/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(reqData)
      },
      timeout: 8000
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          const rawText = parsed.candidates?.[0]?.content?.parts?.[0]?.text;
          if (rawText) {
            const evalJson = JSON.parse(rawText);
            evalJson.idealResponse = questionObj.idealResponse;
            evalJson.xpEarned = 50;
            return resolve(evalJson);
          }
          resolve(null);
        } catch (e) {
          resolve(null);
        }
      });
    });

    req.on('error', () => resolve(null));
    req.on('timeout', () => { req.destroy(); resolve(null); });
    req.write(reqData);
    req.end();
  });
}

async function evaluateInterviewWithAi(questionObj, userTranscript) {
  // If GEMINI_API_KEY is present, attempt Gemini evaluation
  if (process.env.GEMINI_API_KEY) {
    try {
      const geminiResult = await callGeminiApi(questionObj, userTranscript);
      if (geminiResult) return geminiResult;
    } catch (e) {
      console.warn('Gemini API call failed, falling back to local semantic evaluator:', e.message);
    }
  }

  // Built-in Semantic & Rubric Engine (Deterministic, Zero-latency, Highly accurate)
  const normalized = (userTranscript || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");

  const words = normalized.split(/\s+/).filter(w => w.length > 2);
  const wordCount = words.length;

  // 1. Concept matching
  const conceptsCovered = [];
  const conceptsMissed = [];

  questionObj.keyConcepts.forEach(concept => {
    const normConcept = concept.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
    const parts = normConcept.split(/\s*\/\s*|\s+/);
    const matched = normConcept.split(/\s*\/\s*/).some(sub => {
      const cleanSub = sub.trim();
      return cleanSub && normalized.includes(cleanSub);
    }) || parts.filter(p => p.length > 3).some(p => normalized.includes(p));

    if (matched) {
      conceptsCovered.push(concept);
    } else {
      conceptsMissed.push(concept);
    }
  });

  const conceptCoverageRatio = questionObj.keyConcepts.length > 0 
    ? conceptsCovered.length / questionObj.keyConcepts.length 
    : 0.5;

  // 2. Technical Accuracy Score (30 - 100)
  let technicalScore = Math.round(35 + (conceptCoverageRatio * 60));
  if (wordCount < 10) technicalScore = Math.min(30, technicalScore);
  else if (wordCount > 40 && conceptCoverageRatio >= 0.7) technicalScore = Math.min(100, technicalScore + 5);

  // 3. Communication & Structure Score (35 - 100)
  const structureMarkers = ["porque", "por defecto", "debido", "para", "ejemplo", "es decir", "por lo tanto", "en consecuencia", "adicionalmente", "sin embargo", "internamente"];
  const structureHits = structureMarkers.filter(m => normalized.includes(m)).length;
  let communicationScore = Math.min(98, Math.max(40, Math.round(45 + (structureHits * 10) + (Math.min(wordCount, 80) * 0.4))));
  if (wordCount < 15) communicationScore = Math.min(40, communicationScore);

  // 4. Trade-off & Engineering Depth Score (25 - 100)
  const tradeoffMarkers = ["trade-off", "tradeoff", "memoria", "rendimiento", "latencia", "overhead", "concurrencia", "hilos", "seguridad", "recurso", "limite", "costoso", "produccion", "riesgo"];
  const tradeoffHits = tradeoffMarkers.filter(m => normalized.includes(m)).length;
  let tradeoffScore = Math.min(95, Math.max(30, Math.round(30 + (tradeoffHits * 12) + (conceptCoverageRatio * 35))));

  // Overall Score
  const overallScore = Math.min(100, Math.max(10, Math.round(technicalScore * 0.5 + communicationScore * 0.3 + tradeoffScore * 0.2)));

  // Seniority Verdict
  let seniorityVerdict = "";
  let verdictBadge = "";
  if (overallScore >= 88) {
    seniorityVerdict = "Staff / Principal Architect";
    verdictBadge = "👑 STAFF ARCHITECT";
  } else if (overallScore >= 75) {
    seniorityVerdict = "Senior Java Engineer";
    verdictBadge = "⭐ SENIOR DEV";
  } else if (overallScore >= 55) {
    seniorityVerdict = "Mid-Level Software Engineer";
    verdictBadge = "💡 MID-LEVEL DEV";
  } else {
    seniorityVerdict = "Junior Developer (En Crecimiento)";
    verdictBadge = "🌱 JUNIOR DEV";
  }

  // Generate strengths & improvements
  const strengths = [];
  if (conceptsCovered.length > 0) {
    strengths.push(`Identificaste acertadamente conceptos clave: ${conceptsCovered.slice(0, 3).map(c => `"${c}"`).join(', ')}.`);
  }
  if (tradeoffHits > 0) {
    strengths.push(`Consideraste el impacto arquitectónico (mencionaste aspectos como ${tradeoffMarkers.filter(m => normalized.includes(m)).slice(0, 2).join(' y ')}).`);
  }
  if (wordCount >= 25 && structureHits >= 2) {
    strengths.push("Estructura clara de comunicación, conectando la causa técnica con la solución práctica.");
  }
  if (strengths.length === 0) {
    strengths.push("Buen intento inicial; abordaste la pregunta y mantuviste el foco técnico.");
  }

  const improvements = [];
  if (conceptsMissed.length > 0) {
    improvements.push(`Para un nivel Senior/Staff, te sugiero profundizar en: ${conceptsMissed.slice(0, 3).map(c => `"${c}"`).join(', ')}.`);
  }
  if (tradeoffHits === 0) {
    improvements.push("Agrega siempre una mención a los trade-offs: ¿Qué impacto tiene en latencia, memoria o consumo de CPU en producción?");
  }
  if (wordCount < 20) {
    improvements.push("Tu respuesta fue concisa; elabora un poco más la mecánica interna de la JVM o del framework.");
  }

  return {
    score: overallScore,
    technicalScore,
    communicationScore,
    tradeoffScore,
    seniorityVerdict,
    verdictBadge,
    conceptsCovered,
    conceptsMissed,
    strengths,
    improvements,
    feedback: overallScore >= 75 
      ? "Excelente articulación técnica. Demostraste un entendimiento sólido de los contratos y el comportamiento en tiempo de ejecución requerido para roles Senior."
      : "Buena base conceptual. Con un poco más de precisión en los mecanismos internos y trade-offs alcanzarás el estándar de entrevista Senior.",
    followUpQuestion: questionObj.followUpQuestion,
    idealResponse: questionObj.idealResponse,
    xpEarned: 50
  };
}

// ==============================================================
// VALIDACIONES DE ENTRADA Y SEGURIDAD
// ==============================================================

// TODO: Endurecer a solo UUID v4 estricto una vez concluida la transición de APKs antiguos
const UUID_V4_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const LEGACY_USER_ID_REGEX = /^[A-Za-z0-9_-]{3,64}$/;

function isValidUserId(userId) {
  if (!userId || typeof userId !== 'string') return false;
  return UUID_V4_REGEX.test(userId) || LEGACY_USER_ID_REGEX.test(userId);
}

// Rate limiting en memoria por IP y por userId
const rateLimits = {
  mockUser: new Map(), // userId -> [timestamps]
  mockIp: new Map(),   // ip -> [timestamps]
  generalIp: new Map() // ip -> [timestamps]
};

function getClientIp(req) {
  const forwarded = req.headers['x-forwarded-for'];
  if (forwarded && typeof forwarded === 'string') {
    return forwarded.split(',')[0].trim();
  }
  return req.socket?.remoteAddress || req.connection?.remoteAddress || '127.0.0.1';
}

function checkRateLimit(map, key, maxRequests, windowMs) {
  const now = Date.now();
  const windowStart = now - windowMs;
  let timestamps = map.get(key) || [];
  timestamps = timestamps.filter(ts => ts > windowStart);

  if (timestamps.length >= maxRequests) {
    const oldest = timestamps[0];
    const retryAfter = Math.ceil((oldest + windowMs - now) / 1000);
    return { limited: true, retryAfter: Math.max(1, retryAfter) };
  }

  timestamps.push(now);
  map.set(key, timestamps);
  return { limited: false, retryAfter: 0 };
}

// Limpieza periódica de rate limits cada 10 minutos
setInterval(() => {
  const now = Date.now();
  for (const map of [rateLimits.mockUser, rateLimits.mockIp, rateLimits.generalIp]) {
    for (const [key, timestamps] of map.entries()) {
      const active = timestamps.filter(ts => ts > now - 3600000);
      if (active.length === 0) map.delete(key);
      else map.set(key, active);
    }
  }
}, 600000).unref();

function readCurriculum() {
  try {
    const raw = fs.readFileSync(CURRICULUM_PATH, 'utf8');
    return JSON.parse(raw);
  } catch (e) {
    console.error('Error reading curriculum.json:', e.message);
    return { worlds: [], mockInterviews: [] };
  }
}

function sendJson(res, statusCode, data, extraHeaders = {}) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    ...extraHeaders
  });
  res.end(JSON.stringify(data, null, 2));
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const clientIp = getClientIp(req);

  // Rate limiting general por IP para endpoints /api/ (300 peticiones / minuto)
  if (url.pathname.startsWith('/api/')) {
    const generalLimit = checkRateLimit(rateLimits.generalIp, clientIp, 300, 60000);
    if (generalLimit.limited) {
      return sendJson(res, 429, {
        error: 'Too Many Requests',
        message: 'Límite general de peticiones por minuto excedido. Intente más tarde.'
      }, { 'Retry-After': String(generalLimit.retryAfter) });
    }
  }

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization'
    });
    res.end();
    return;
  }

  // 0. Serve Frontend Web Preview (Render Cloud & Local Host)
  if (req.method === 'GET' && (url.pathname === '/' || url.pathname === '/index.html' || url.pathname === '/app')) {
    const indexPath = path.join(__dirname, '../web_preview/index.html');
    if (fs.existsSync(indexPath)) {
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      return res.end(fs.readFileSync(indexPath, 'utf8'));
    }
  }

  // 1. Healthcheck
  if (url.pathname === '/api/health') {
    return sendJson(res, 200, {
      status: 'UP',
      service: 'JavaPlay Backend API',
      database: pool ? (isSupabase ? 'PostgreSQL (Supabase Conectado)' : 'PostgreSQL Remoto') : 'In-Memory',
      timestamp: new Date().toISOString()
    });
  }

  // 2. GET Curriculum (Worlds 0 to 10)
  if (req.method === 'GET' && url.pathname === '/api/curriculum') {
    const curriculum = readCurriculum();
    return sendJson(res, 200, curriculum);
  }

  // 3. GET Leaderboard
  if (req.method === 'GET' && url.pathname === '/api/leaderboard') {
    if (pool) {
      try {
        const { rows } = await pool.query(`
          SELECT l.rank, u.username as name, p.xp, l.league 
          FROM leaderboard l
          JOIN users u ON l.user_id = u.id
          JOIN user_progress p ON l.user_id = p.user_id
          ORDER BY p.xp DESC
          LIMIT 10
        `);
        return sendJson(res, 200, rows);
      } catch (err) {
        console.warn('Fallback to mem leaderboard:', err.message);
      }
    }
    return sendJson(res, 200, memDb.leaderboard);
  }

  // 4. GET User Progress
  if (req.method === 'GET' && url.pathname.startsWith('/api/progress/')) {
    const userId = url.pathname.replace('/api/progress/', '');
    if (!isValidUserId(userId)) {
      return sendJson(res, 400, { error: 'Bad Request', message: 'Identificador de usuario no válido' });
    }

    if (pool) {
      try {
        const { rows } = await pool.query(`
          SELECT u.id, u.username as name, p.xp, p.lives, p.streak, p.current_level as "currentLevel"
          FROM users u
          JOIN user_progress p ON u.id = p.user_id
          WHERE u.id = $1
        `, [userId]);
        if (rows.length > 0) return sendJson(res, 200, rows[0]);
      } catch (err) {
        console.warn('DB query failed, using mem:', err.message);
      }
    }

    const user = memDb.users[userId] || {
      id: userId,
      name: 'Alonso (Dev)',
      xp: 180,
      lives: 5,
      streak: 3,
      currentLevel: 4,
      completedLessons: []
    };
    return sendJson(res, 200, user);
  }

  // 5. POST User Progress Update
  if (req.method === 'POST' && url.pathname.startsWith('/api/progress/')) {
    const userId = url.pathname.replace('/api/progress/', '');
    if (!isValidUserId(userId)) {
      return sendJson(res, 400, { error: 'Bad Request', message: 'Identificador de usuario no válido' });
    }

    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', async () => {
      try {
        const payload = JSON.parse(body || '{}');

        if (payload.xpDelta !== undefined) {
          if (!Number.isInteger(payload.xpDelta) || payload.xpDelta < 0 || payload.xpDelta > 1000) {
            return sendJson(res, 400, { error: 'Bad Request', message: 'xpDelta debe ser un entero entre 0 y 1000' });
          }
        }
        if (payload.lives !== undefined && (!Number.isInteger(payload.lives) || payload.lives < 0 || payload.lives > 5)) {
          return sendJson(res, 400, { error: 'Bad Request', message: 'lives debe ser un entero entre 0 y 5' });
        }
        if (payload.streak !== undefined && (!Number.isInteger(payload.streak) || payload.streak < 0 || payload.streak > 100000)) {
          return sendJson(res, 400, { error: 'Bad Request', message: 'streak debe ser un entero no negativo' });
        }

        const user = memDb.users[userId] || { id: userId, name: 'Alonso', xp: 180, lives: 5, streak: 3, completedLessons: [] };

        if (payload.xpDelta) user.xp += payload.xpDelta;
        if (payload.lives !== undefined) user.lives = Math.max(0, Math.min(5, payload.lives));
        if (payload.streak !== undefined) user.streak = payload.streak;

        memDb.users[userId] = user;

        if (pool) {
          try {
            await pool.query(`
              INSERT INTO user_progress (user_id, xp, lives, streak, updated_at)
              VALUES ($1, $2, $3, $4, NOW())
              ON CONFLICT (user_id) 
              DO UPDATE SET xp = $2, lives = $3, streak = $4, updated_at = NOW()
            `, [userId, user.xp, user.lives, user.streak]);
          } catch (dbErr) {
            console.warn('Error saving to Postgres:', dbErr.message);
          }
        }

        // Update Leaderboard
        const me = memDb.leaderboard.find(u => u.name.includes('Alonso'));
        if (me) me.xp = user.xp;
        memDb.leaderboard.sort((a, b) => b.xp - a.xp);
        memDb.leaderboard.forEach((u, i) => u.rank = i + 1);

        return sendJson(res, 200, { success: true, user });
      } catch (err) {
        return sendJson(res, 400, { error: 'Bad Request', message: 'Cuerpo de la petición inválido' });
      }
    });
    return;
  }

  // 6. POST Verify Exercise Answer
  if (req.method === 'POST' && url.pathname === '/api/verify') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const { exerciseId, answer } = JSON.parse(body || '{}');
        const curriculum = readCurriculum();
        let targetEx = null;

        for (const world of curriculum.worlds) {
          for (const lesson of world.lessons) {
            for (const ex of lesson.exercises) {
              if (ex.id === exerciseId) {
                targetEx = ex;
                break;
              }
            }
          }
        }

        if (!targetEx) {
          return sendJson(res, 404, { error: 'Ejercicio no encontrado' });
        }

        let isCorrect = false;
        if (targetEx.type === 'FLASHCARD') {
          isCorrect = true;
        } else if (targetEx.type === 'MULTIPLE_CHOICE') {
          isCorrect = answer === targetEx.correctAnswerIndex;
        } else if (targetEx.type === 'SPOT_THE_BUG') {
          isCorrect = answer === targetEx.buggyLineIndex;
        } else if (targetEx.type === 'TOKEN_REORDER') {
          isCorrect = JSON.stringify(answer) === JSON.stringify(targetEx.correctOrder);
        } else if (targetEx.type === 'FILL_BLANK') {
          isCorrect = JSON.stringify(answer) === JSON.stringify(targetEx.correctAnswers);
        }

        return sendJson(res, 200, {
          exerciseId,
          isCorrect,
          explanation: targetEx.explanation,
          xpEarned: isCorrect ? 15 : 0
        });
      } catch (err) {
        return sendJson(res, 400, { error: 'Invalid request' });
      }
    });
    return;
  }

  // 7. GET /api/srs/:userId/due - Ejercicios pendientes para repaso hoy según SM-2
  if (req.method === 'GET' && url.pathname.match(/^\/api\/srs\/[^/]+\/due$/)) {
    const parts = url.pathname.split('/');
    const userId = parts[3];
    if (!isValidUserId(userId)) {
      return sendJson(res, 400, { error: 'Bad Request', message: 'Identificador de usuario no válido' });
    }
    const curriculum = readCurriculum();

    const findExercise = (exId) => {
      for (const w of curriculum.worlds || []) {
        for (const l of w.lessons || []) {
          for (const e of l.exercises || []) {
            if (e.id === exId) return { ...e, worldTitle: w.title, worldId: w.id };
          }
        }
      }
      return null;
    };

    if (pool) {
      try {
        const { rows } = await pool.query(`
          SELECT * FROM srs_items 
          WHERE user_id = $1 AND next_review_at <= NOW()
          ORDER BY next_review_at ASC
        `, [userId]);

        const dueItems = rows.map(r => ({
          ...r,
          exercise: findExercise(r.exercise_id)
        })).filter(r => r.exercise != null);

        return sendJson(res, 200, dueItems);
      } catch (err) {
        console.warn('DB error fetching due SRS items, using mem:', err.message);
      }
    }

    const now = new Date();
    const memDue = (memDb.srs_items || [])
      .filter(i => i.user_id === userId && new Date(i.next_review_at) <= now)
      .map(i => ({ ...i, exercise: findExercise(i.exercise_id) }))
      .filter(i => i.exercise != null);

    return sendJson(res, 200, memDue);
  }

  // 8. POST /api/srs/:userId/review - Registrar repaso con calificación SM-2 (0 a 5)
  if (req.method === 'POST' && url.pathname.match(/^\/api\/srs\/[^/]+\/review$/)) {
    const parts = url.pathname.split('/');
    const userId = parts[3];
    if (!isValidUserId(userId)) {
      return sendJson(res, 400, { error: 'Bad Request', message: 'Identificador de usuario no válido' });
    }

    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', async () => {
      try {
        const { exerciseId, worldId, quality } = JSON.parse(body || '{}');

        // Validar quality (entero 0 a 5)
        if (quality === undefined || !Number.isInteger(quality) || quality < 0 || quality > 5) {
          return sendJson(res, 400, { error: 'Bad Request', message: 'quality debe ser un número entero entre 0 y 5' });
        }

        // Validar exerciseId (cadena no vacía de hasta 64 caracteres)
        if (!exerciseId || typeof exerciseId !== 'string' || exerciseId.trim().length === 0 || exerciseId.length > 64) {
          return sendJson(res, 400, { error: 'Bad Request', message: 'exerciseId debe ser una cadena no vacía de hasta 64 caracteres' });
        }

        const q = quality;

        let existingItem = null;
        if (pool) {
          try {
            const { rows } = await pool.query(
              'SELECT * FROM srs_items WHERE user_id = $1 AND exercise_id = $2',
              [userId, exerciseId]
            );
            if (rows.length > 0) existingItem = rows[0];
          } catch (e) {
            console.warn('DB check srs_item error:', e.message);
          }
        }

        if (!existingItem) {
          existingItem = (memDb.srs_items || []).find(i => i.user_id === userId && i.exercise_id === exerciseId) || {
            user_id: userId,
            exercise_id: exerciseId,
            world_id: worldId || 'nivel_0',
            repetitions: 0,
            interval_days: 1,
            ease_factor: 2.50
          };
        }

        // Ejecutar Algoritmo SM-2
        const sm2Result = calculateSM2(existingItem, q);
        const srsId = `${userId}:${exerciseId}`;

        if (pool) {
          try {
            await pool.query(`
              INSERT INTO srs_items (id, user_id, exercise_id, world_id, repetitions, interval_days, ease_factor, last_quality, next_review_at, last_reviewed_at)
              VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
              ON CONFLICT (id) DO UPDATE SET
                repetitions = $5,
                interval_days = $6,
                ease_factor = $7,
                last_quality = $8,
                next_review_at = $9,
                last_reviewed_at = $10
            `, [
              srsId,
              userId,
              exerciseId,
              worldId || existingItem.world_id || 'nivel_0',
              sm2Result.repetitions,
              sm2Result.interval_days,
              sm2Result.ease_factor,
              sm2Result.last_quality,
              sm2Result.next_review_at,
              sm2Result.last_reviewed_at
            ]);

            // Sumar +10 XP de repaso espaciado
            await pool.query(`
              UPDATE user_progress SET xp = xp + 10, updated_at = NOW() WHERE user_id = $1
            `, [userId]);
          } catch (dbErr) {
            console.warn('DB error saving SM-2 item:', dbErr.message);
          }
        }

        // Actualizar en memoria
        if (!memDb.srs_items) memDb.srs_items = [];
        const memIdx = memDb.srs_items.findIndex(i => i.id === srsId);
        const updatedMem = { id: srsId, user_id: userId, exercise_id: exerciseId, world_id: worldId || 'nivel_0', ...sm2Result };
        if (memIdx >= 0) memDb.srs_items[memIdx] = updatedMem;
        else memDb.srs_items.push(updatedMem);

        if (memDb.users[userId]) memDb.users[userId].xp += 10;

        return sendJson(res, 200, {
          success: true,
          message: 'Repaso SM-2 procesado exitosamente',
          sm2: sm2Result,
          xpGained: 10
        });
      } catch (err) {
        return sendJson(res, 400, { error: 'Bad Request', message: 'Error procesando solicitud de repaso SM-2' });
      }
    });
    return;
  }

  // 9. GET /api/srs/:userId/stats - Métricas de curva de olvido y memoria a largo plazo
  if (req.method === 'GET' && url.pathname.match(/^\/api\/srs\/[^/]+\/stats$/)) {
    const parts = url.pathname.split('/');
    const userId = parts[3];
    if (!isValidUserId(userId)) {
      return sendJson(res, 400, { error: 'Bad Request', message: 'Identificador de usuario no válido' });
    }

    let items = [];
    if (pool) {
      try {
        const { rows } = await pool.query('SELECT * FROM srs_items WHERE user_id = $1', [userId]);
        items = rows;
      } catch (e) {
        items = memDb.srs_items || [];
      }
    } else {
      items = memDb.srs_items || [];
    }

    const now = new Date();
    const dueCount = items.filter(i => new Date(i.next_review_at) <= now).length;
    const masteredCount = items.filter(i => (i.repetitions || 0) >= 3 && (i.interval_days || 0) >= 10).length;
    const learningCount = items.filter(i => (i.repetitions || 0) < 3).length;

    let avgEF = 2.5;
    if (items.length > 0) {
      const sumEF = items.reduce((acc, curr) => acc + parseFloat(curr.ease_factor || 2.5), 0);
      avgEF = sumEF / items.length;
    }
    const retentionRate = Math.min(99, Math.max(70, Math.round(82 + (avgEF - 2.5) * 12)));

    return sendJson(res, 200, {
      totalCards: items.length,
      dueToday: dueCount,
      mastered: masteredCount,
      learning: learningCount,
      avgEaseFactor: parseFloat(avgEF.toFixed(2)),
      retentionRate: `${retentionRate}%`
    });
  }

  // ==============================================================
  // FASE 3: SIMULADOR DE ENTREVISTAS TÉCNICAS CON IA (MOCK INTERVIEW)
  // ==============================================================

  // 10. GET /api/mock/questions - Catálogo de preguntas técnicas de entrevista
  if (req.method === 'GET' && url.pathname === '/api/mock/questions') {
    return sendJson(res, 200, mockInterviewQuestions);
  }

  // 11. POST /api/mock/evaluate - Evaluación Semántica con IA (Gemini / Rúbrica Senior)
  if (req.method === 'POST' && url.pathname === '/api/mock/evaluate') {
    // Rate limit por IP para evaluaciones con IA (30 / hora)
    const ipLimit = checkRateLimit(rateLimits.mockIp, clientIp, 30, 3600000);
    if (ipLimit.limited) {
      return sendJson(res, 429, {
        error: 'Too Many Requests',
        message: 'Límite de evaluaciones con IA por IP excedido (máximo 30 por hora).'
      }, { 'Retry-After': String(ipLimit.retryAfter) });
    }

    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', async () => {
      try {
        const payload = JSON.parse(body || '{}');
        const { questionId, transcript, durationSeconds, userId = 'user_1' } = payload;

        if (!isValidUserId(userId)) {
          return sendJson(res, 400, { error: 'Bad Request', message: 'userId no válido' });
        }

        // Rate limit por userId para evaluaciones con IA (10 / hora)
        const userLimit = checkRateLimit(rateLimits.mockUser, userId, 10, 3600000);
        if (userLimit.limited) {
          return sendJson(res, 429, {
            error: 'Too Many Requests',
            message: 'Límite de evaluaciones con IA por usuario excedido (máximo 10 por hora).'
          }, { 'Retry-After': String(userLimit.retryAfter) });
        }

        if (typeof transcript !== 'string' || transcript.length > 3000) {
          return sendJson(res, 400, {
            error: 'Bad Request',
            message: 'transcript debe ser una cadena de texto de hasta 3000 caracteres'
          });
        }

        if (!questionId || typeof questionId !== 'string' || questionId.length > 64) {
          return sendJson(res, 400, { error: 'Bad Request', message: 'questionId no válido' });
        }

        const questionObj = mockInterviewQuestions.find(q => q.id === questionId);
        if (!questionObj) {
          return sendJson(res, 400, { error: 'Bad Request', message: 'questionId no encontrado en el catálogo' });
        }

        if (durationSeconds !== undefined && (!Number.isInteger(durationSeconds) || durationSeconds < 0 || durationSeconds > 3600)) {
          return sendJson(res, 400, { error: 'Bad Request', message: 'durationSeconds debe ser un entero entre 0 y 3600' });
        }

        // Evaluar con IA (Gemini si hay key, o Evaluador Semántico Experto)
        const evaluation = await evaluateInterviewWithAi(questionObj, transcript);

        // Guardar en PostgreSQL Supabase si está disponible
        if (pool) {
          try {
            await pool.query(`
              INSERT INTO public.mock_interview_submissions 
                (user_id, question_id, duration_seconds, score_percentage, technical_score, communication_score, tradeoff_score, seniority_verdict, user_transcript, feedback, key_concepts_covered)
              VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
            `, [
              userId,
              questionObj.id,
              durationSeconds || 45,
              evaluation.score,
              evaluation.technicalScore,
              evaluation.communicationScore,
              evaluation.tradeoffScore,
              evaluation.seniorityVerdict,
              transcript || '',
              evaluation.feedback || '',
              JSON.stringify(evaluation.conceptsCovered || [])
            ]);

            // Sumar +50 XP por simular entrevista
            await pool.query(`
              UPDATE public.user_progress SET xp = xp + 50, updated_at = NOW() WHERE user_id = $1
            `, [userId]);
          } catch (dbErr) {
            console.warn('DB error saving mock evaluation:', dbErr.message);
          }
        }

        // Guardar en memoria
        if (!memDb.mock_evaluations) memDb.mock_evaluations = [];
        memDb.mock_evaluations.push({
          userId,
          questionId: questionObj.id,
          createdAt: new Date().toISOString(),
          ...evaluation
        });

        if (memDb.users[userId]) {
          memDb.users[userId].xp += 50;
        }

        return sendJson(res, 200, {
          success: true,
          question: questionObj,
          evaluation: evaluation,
          xpEarned: 50
        });

      } catch (err) {
        return sendJson(res, 400, { error: 'Bad Request', message: 'Error procesando evaluación con IA' });
      }
    });
    return;
  }

  // 12. GET /api/mock/history/:userId - Historial de entrevistas simuladas
  if (req.method === 'GET' && url.pathname.startsWith('/api/mock/history/')) {
    const userId = url.pathname.replace('/api/mock/history/', '');
    if (!isValidUserId(userId)) {
      return sendJson(res, 400, { error: 'Bad Request', message: 'Identificador de usuario no válido' });
    }
    if (pool) {
      try {
        const { rows } = await pool.query(`
          SELECT * FROM public.mock_interview_submissions 
          WHERE user_id = $1 
          ORDER BY created_at DESC 
          LIMIT 10
        `, [userId]);
        return sendJson(res, 200, rows);
      } catch (e) {
        console.warn('DB error reading mock history:', e.message);
      }
    }
    const memHistory = (memDb.mock_evaluations || []).filter(e => e.userId === userId);
    return sendJson(res, 200, memHistory);
  }

  // 13. GET /api/boss/:userId - Obtener desafíos finales (Boss Challenges) completados por el usuario
  if (req.method === 'GET' && url.pathname.startsWith('/api/boss/')) {
    const userId = url.pathname.replace('/api/boss/', '');
    if (!isValidUserId(userId)) {
      return sendJson(res, 400, { error: 'Bad Request', message: 'Identificador de usuario no válido' });
    }
    if (pool) {
      try {
        const { rows } = await pool.query(`
          SELECT * FROM public.boss_challenges 
          WHERE user_id = $1 AND passed = TRUE
          ORDER BY completed_at DESC
        `, [userId]);
        return sendJson(res, 200, rows);
      } catch (e) {
        console.warn('DB error reading boss challenges:', e.message);
      }
    }
    const memBosses = (memDb.boss_challenges || []).filter(b => b.user_id === userId && b.passed);
    return sendJson(res, 200, memBosses);
  }

  // 14. POST /api/boss/:userId - Registrar victoria en Desafío Final (Boss Challenge)
  if (req.method === 'POST' && url.pathname.startsWith('/api/boss/')) {
    const userId = url.pathname.replace('/api/boss/', '');
    if (!isValidUserId(userId)) {
      return sendJson(res, 400, { error: 'Bad Request', message: 'Identificador de usuario no válido' });
    }

    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', async () => {
      try {
        const payload = JSON.parse(body || '{}');
        const { worldId, bossId, score, xpAwarded = 150 } = payload;

        if (!worldId || typeof worldId !== 'string' || worldId.length > 64) {
          return sendJson(res, 400, { error: 'Bad Request', message: 'worldId no válido' });
        }
        if (!bossId || typeof bossId !== 'string' || bossId.length > 64) {
          return sendJson(res, 400, { error: 'Bad Request', message: 'bossId no válido' });
        }
        if (score === undefined || !Number.isInteger(score) || score < 0 || score > 100) {
          return sendJson(res, 400, { error: 'Bad Request', message: 'score debe ser un entero entre 0 y 100' });
        }
        if (!Number.isInteger(xpAwarded) || xpAwarded < 0 || xpAwarded > 1000) {
          return sendJson(res, 400, { error: 'Bad Request', message: 'xpAwarded debe ser un entero entre 0 y 1000' });
        }

        if (pool) {
          try {
            await pool.query(`
              INSERT INTO public.boss_challenges (user_id, world_id, boss_id, score, passed, xp_awarded, completed_at)
              VALUES ($1, $2, $3, $4, TRUE, $5, NOW())
              ON CONFLICT (user_id, world_id)
              DO UPDATE SET score = GREATEST(boss_challenges.score, $4), xp_awarded = $5, completed_at = NOW()
            `, [userId, worldId, bossId, score, xpAwarded]);

            // Sumar XP por derrotar al Jefe en Supabase
            await pool.query(`
              UPDATE public.user_progress SET xp = xp + $2, updated_at = NOW() WHERE user_id = $1
            `, [userId, xpAwarded]);
          } catch (dbErr) {
            console.warn('DB error saving boss challenge victory:', dbErr.message);
          }
        }

        // Mem DB fallback
        if (!memDb.boss_challenges) memDb.boss_challenges = [];
        const existing = memDb.boss_challenges.find(b => b.user_id === userId && b.world_id === worldId);
        if (existing) {
          existing.score = Math.max(existing.score, score);
          existing.completed_at = new Date().toISOString();
        } else {
          memDb.boss_challenges.push({
            user_id: userId,
            world_id: worldId,
            boss_id: bossId,
            score,
            passed: true,
            xp_awarded: xpAwarded,
            completed_at: new Date().toISOString()
          });
        }

        if (memDb.users[userId]) {
          memDb.users[userId].xp += xpAwarded;
        }

        return sendJson(res, 200, {
          success: true,
          message: '¡Desafío Final registrado con éxito en Supabase!',
          xpGained: xpAwarded,
          worldId,
          bossId
        });
      } catch (err) {
        return sendJson(res, 400, { error: 'Error procesando desafío final: ' + err.message });
      }
    });
    return;
  }

  // 404 Fallback
  sendJson(res, 404, { error: 'Ruta no encontrada' });
});

server.listen(PORT, () => {
  console.log(`🚀 JavaPlay Backend REST Server ejecutándose en http://localhost:${PORT}`);
  console.log(`   Base de datos: ${pool ? '🐘 PostgreSQL (Render Conectado)' : '💾 En Memoria (Local)'}`);
});
