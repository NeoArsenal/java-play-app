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
    id: "mock_spring_concurrency",
    worldId: "mundo_7",
    category: "Spring Boot & Concurrencia",
    title: "Arquitectura y Concurrencia en Spring Boot",
    question: "Si los Beans de Spring son Singleton por defecto y la aplicación atiende cientos de peticiones en paralelo con hilos distintos, ¿qué riesgos de concurrencia existen y cómo garantizas Thread-Safety?",
    timeLimitSeconds: 60,
    keyConcepts: [
      "singleton",
      "stateless",
      "hilo independiente",
      "call stack / variables locales",
      "variables de instancia mutables",
      "request scope / threadlocal"
    ],
    idealResponse: "Los beans de Spring son Singleton por defecto y compartidos por múltiples hilos del Servlet Container (Tomcat). Para garantizar Thread-Safety, los beans deben ser Stateless (sin estado mutable en variables de instancia). Los datos deben fluir en variables locales de método, las cuales residen en el Call Stack de cada hilo de forma aislada. Si se requiere estado por petición, se debe usar @RequestScope o ThreadLocal con limpieza garantizada en un bloque finally.",
    followUpQuestion: "Excelente. Si tuvieras un bean que forzosamente necesita acumular métricas o un contador mutable en memoria, ¿qué estructura de java.util.concurrent utilizarías y por qué evitarías synchronized?"
  },
  {
    id: "mock_jvm_memory_leak",
    worldId: "mundo_1",
    category: "JVM Internals & Memoria",
    title: "Stack vs Heap y Diagnóstico de OutOfMemoryError (OOM)",
    question: "Explica la diferencia entre la memoria Stack y Heap en la JVM. ¿Puede ocurrir una fuga de memoria (Memory Leak) en Java a pesar del Garbage Collector? ¿Cómo sucede?",
    timeLimitSeconds: 60,
    keyConcepts: [
      "stack almacena frames y primitivos/referencias",
      "heap almacena objetos instanciados",
      "gc raíces / gc roots",
      "referencias vivas retenidas",
      "colecciones estáticas / listeners sin desuscribir",
      "outofmemoryerror"
    ],
    idealResponse: "El Stack almacena variables locales, llamadas a métodos y referencias a objetos por cada hilo de forma rápida y efímera. El Heap es la memoria compartida donde residen todos los objetos instanciados gestionados por el GC. Sí ocurren Memory Leaks en Java cuando objetos que ya no se necesitan siguen siendo accesibles desde una 'GC Root' (por ejemplo, colecciones static que crecen sin límite o listeners sin desuscribir), impidiendo que el GC los reclame y provocando un OutOfMemoryError.",
    followUpQuestion: "¿Qué parámetros de la JVM activarías en producción para capturar automáticamente un Heap Dump ante un OutOfMemoryError y cómo lo analizarías?"
  },
  {
    id: "mock_equals_hashcode",
    worldId: "mundo_2",
    category: "POO & Modelado",
    title: "El Contrato Sagrado: equals() y hashCode()",
    question: "¿Por qué es obligatorio sobrescribir hashCode() cuando se sobrescribe equals()? ¿Qué ocurre internamente en un HashMap o HashSet si violas este contrato?",
    timeLimitSeconds: 60,
    keyConcepts: [
      "contrato equals y hashcode",
      "si equals es true hashcode debe ser igual",
      "calculo del bucket",
      "perdida de elementos / get retorna null",
      "duplicados en hashset"
    ],
    idealResponse: "El contrato estipula que si dos objetos son iguales según equals(), deben retornar exactamente el mismo hashCode(). Un HashMap utiliza hashCode() para determinar el índice del 'bucket' donde guardará o buscará el objeto. Si violas el contrato, dos objetos lógicamente idénticos tendrán hashes distintos y caerán en buckets diferentes, provocando que un HashSet almacene duplicados o que map.get(key) retorne null aunque la clave exista.",
    followUpQuestion: "¿Qué sucede internamente cuando dos objetos distintos producen el mismo hashCode (colisión) y cómo lo optimizó Java 8 con árboles rojo-negro?"
  },
  {
    id: "mock_jpa_nplus1",
    worldId: "mundo_9",
    category: "Spring Data JPA & Hibernate",
    title: "El Problema de N+1 Selects en Hibernate",
    question: "¿En qué consiste el clásico problema de N+1 Selects en Hibernate/JPA y cuáles son las mejores estrategias para resolverlo en producción?",
    timeLimitSeconds: 60,
    keyConcepts: [
      "lazy loading",
      "1 consulta inicial mas n consultas hijas",
      "join fetch",
      "entitygraph",
      "batch size",
      "saturacion del pool"
    ],
    idealResponse: "El problema N+1 ocurre al recuperar una lista de entidades padre (1 consulta) y luego acceder a una relación Lazy en cada una dentro de un bucle, disparando N consultas adicionales a la base de datos (1 + N queries). En producción satura el pool de conexiones. Se soluciona utilizando 'JOIN FETCH' en consultas JPQL, @EntityGraph para especificar relaciones eager dinámicas, o configurando hibernate.default_batch_fetch_size para agrupar consultas con cláusulas IN.",
    followUpQuestion: "¿Por qué no se debe solucionar el N+1 cambiando todas las relaciones a FetchType.EAGER de manera permanente en el modelo de entidades?"
  },
  {
    id: "mock_virtual_threads",
    worldId: "mundo_10",
    category: "Java Moderno & Loom",
    title: "Virtual Threads en Java 21 vs Platform Threads",
    question: "¿Qué son los Virtual Threads de Java 21 y en qué se diferencian de los Platform Threads del sistema operativo? ¿En qué escenarios marcan la diferencia y en cuáles no?",
    timeLimitSeconds: 60,
    keyConcepts: [
      "virtual threads administrados por jvm",
      "platform threads 1 a 1 con so",
      "operaciones bloqueantes io no bloquean hilo so",
      "desmontaje en carrier thread",
      "no aportan en tareas cpu bound",
      "overhead de memoria minimo"
    ],
    idealResponse: "Los Platform Threads son hilos pesados mapeados 1:1 al SO con ~1MB de memoria dedicada cada uno. Los Virtual Threads son gestionados enteramente por la JVM en memoria Heap (pocos bytes). Cuando un Virtual Thread ejecuta una operación I/O bloqueante (DB o red), la JVM lo desmonta del 'Carrier Thread' del SO, permitiendo procesar millones de peticiones concurrentes en aplicaciones I/O Bound sin agotar los hilos del sistema. No aportan en tareas intensivas de CPU pura.",
    followUpQuestion: "¿Qué es el fenómeno de 'Thread Pinning' en Virtual Threads y cómo lo evitas (por ejemplo, reemplazando bloques synchronized por ReentrantLock)?"
  },
  {
    id: "mock_fundamentals_recipes",
    worldId: "mundo_0",
    category: "Onboarding & Fundamentos",
    title: "Fundamentos: Explicando Variables y Memoria",
    question: "En una entrevista te piden explicar a alguien que nunca ha programado: ¿Qué es una variable en memoria y por qué Java exige especificar el tipo de dato (como int o String)?",
    timeLimitSeconds: 45,
    keyConcepts: [
      "caja o contenedor con etiqueta",
      "espacio reservado en memoria ram",
      "tipo define tamano y operaciones permitidas",
      "seguridad y prevencion de errores"
    ],
    idealResponse: "Una variable es como una caja rotulada con un nombre donde guardamos un dato en la memoria RAM de la computadora. El tipo de dato (como int o String) le indica a la computadora qué tamaño de caja reservar y qué operaciones son válidas: permite sumar números, pero impide sumar un número con una foto. Esto garantiza orden, previene errores y aprovecha eficientemente la memoria.",
    followUpQuestion: "¿Cómo le explicarías la diferencia entre una condición 'if' y una repetición 'while' usando un ejemplo de la vida cotidiana?"
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
    verdictBadge = "⭐ SENIOR ENGINEER";
  } else if (overallScore >= 55) {
    seniorityVerdict = "Mid-Level Software Engineer";
    verdictBadge = "💡 MID-LEVEL DEVELOPER";
  } else {
    seniorityVerdict = "Junior Developer (En Crecimiento)";
    verdictBadge = "🌱 JUNIOR EN FORMACIÓN";
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

function readCurriculum() {
  try {
    const raw = fs.readFileSync(CURRICULUM_PATH, 'utf8');
    return JSON.parse(raw);
  } catch (e) {
    console.error('Error reading curriculum.json:', e.message);
    return { worlds: [], mockInterviews: [] };
  }
}

function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization'
  });
  res.end(JSON.stringify(data, null, 2));
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);

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
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', async () => {
      try {
        const payload = JSON.parse(body || '{}');
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
        return sendJson(res, 400, { error: 'Invalid JSON body' });
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

    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', async () => {
      try {
        const { exerciseId, worldId, quality } = JSON.parse(body || '{}');
        const q = Math.max(0, Math.min(5, parseInt(quality !== undefined ? quality : 4, 10)));

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
        return sendJson(res, 400, { error: 'Error procesando SM-2 review: ' + err.message });
      }
    });
    return;
  }

  // 9. GET /api/srs/:userId/stats - Métricas de curva de olvido y memoria a largo plazo
  if (req.method === 'GET' && url.pathname.match(/^\/api\/srs\/[^/]+\/stats$/)) {
    const parts = url.pathname.split('/');
    const userId = parts[3];

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
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', async () => {
      try {
        const payload = JSON.parse(body || '{}');
        const { questionId, transcript, durationSeconds, userId = 'user_1' } = payload;

        const questionObj = mockInterviewQuestions.find(q => q.id === questionId) || mockInterviewQuestions[0];
        
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
        return sendJson(res, 400, { error: 'Error evaluando entrevista con IA: ' + err.message });
      }
    });
    return;
  }

  // 12. GET /api/mock/history/:userId - Historial de entrevistas simuladas
  if (req.method === 'GET' && url.pathname.startsWith('/api/mock/history/')) {
    const userId = url.pathname.replace('/api/mock/history/', '');
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

  // 404 Fallback
  sendJson(res, 404, { error: 'Ruta no encontrada' });
});

server.listen(PORT, () => {
  console.log(`🚀 JavaPlay Backend REST Server ejecutándose en http://localhost:${PORT}`);
  console.log(`   Base de datos: ${pool ? '🐘 PostgreSQL (Render Conectado)' : '💾 En Memoria (Local)'}`);
});
