-- ==========================================================
-- JavaPlay Schema para SUPABASE (PostgreSQL)
-- Puedes copiar y pegar este script directamente en el 
-- "SQL Editor" de tu proyecto en Supabase y darle a "Run"
-- ==========================================================

-- Habilitar extensión UUID por si se requiere
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Tabla de Usuarios
CREATE TABLE IF NOT EXISTS public.users (
    id VARCHAR(64) PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Progreso de Gamificación del Usuario (Vidas, XP, Racha)
CREATE TABLE IF NOT EXISTS public.user_progress (
    user_id VARCHAR(64) PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    xp INTEGER NOT NULL DEFAULT 0,
    lives INTEGER NOT NULL DEFAULT 5,
    streak INTEGER NOT NULL DEFAULT 1,
    current_level INTEGER NOT NULL DEFAULT 0,
    last_practice_date DATE DEFAULT CURRENT_DATE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Historial de Ejercicios Completados
CREATE TABLE IF NOT EXISTS public.completed_exercises (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(64) REFERENCES public.users(id) ON DELETE CASCADE,
    exercise_id VARCHAR(64) NOT NULL,
    level INTEGER NOT NULL,
    attempts INTEGER DEFAULT 1,
    is_correct BOOLEAN DEFAULT TRUE,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_exercise UNIQUE (user_id, exercise_id)
);

-- 4. Registro de Evaluaciones de Mock Interview con IA
CREATE TABLE IF NOT EXISTS public.mock_interview_submissions (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(64) REFERENCES public.users(id) ON DELETE CASCADE,
    question_id VARCHAR(64) NOT NULL,
    duration_seconds INTEGER NOT NULL DEFAULT 45,
    score_percentage NUMERIC(5,2) NOT NULL DEFAULT 0,
    technical_score NUMERIC(5,2) DEFAULT 0,
    communication_score NUMERIC(5,2) DEFAULT 0,
    tradeoff_score NUMERIC(5,2) DEFAULT 0,
    seniority_verdict VARCHAR(64) DEFAULT 'Mid-Level',
    user_transcript TEXT DEFAULT '',
    feedback TEXT DEFAULT '',
    key_concepts_covered JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Tabla de Ligas y Clasificación (Leaderboard)
CREATE TABLE IF NOT EXISTS public.leaderboard (
    user_id VARCHAR(64) PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    league VARCHAR(50) DEFAULT 'Diamond 💎',
    weekly_xp INTEGER DEFAULT 0,
    rank INTEGER DEFAULT 1,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Repetición Espaciada (SM-2 Spaced Repetition System)
CREATE TABLE IF NOT EXISTS public.srs_items (
    id VARCHAR(128) PRIMARY KEY,
    user_id VARCHAR(64) REFERENCES public.users(id) ON DELETE CASCADE,
    exercise_id VARCHAR(64) NOT NULL,
    world_id VARCHAR(64) NOT NULL DEFAULT 'nivel_0',
    repetitions INTEGER NOT NULL DEFAULT 0,
    interval_days INTEGER NOT NULL DEFAULT 1,
    ease_factor NUMERIC(4,2) NOT NULL DEFAULT 2.50,
    last_quality INTEGER DEFAULT NULL,
    next_review_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_reviewed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_srs UNIQUE (user_id, exercise_id)
);

-- 7. Habilitar Row Level Security (RLS) recomendado en Supabase
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.completed_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mock_interview_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leaderboard ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.srs_items ENABLE ROW LEVEL SECURITY;

-- Políticas de lectura y escritura pública para la API
DROP POLICY IF EXISTS "Lectura pública de progreso" ON public.user_progress;
CREATE POLICY "Lectura pública de progreso" ON public.user_progress FOR SELECT USING (true);

DROP POLICY IF EXISTS "Actualización de progreso" ON public.user_progress;
CREATE POLICY "Actualización de progreso" ON public.user_progress FOR ALL USING (true);

DROP POLICY IF EXISTS "Lectura pública de leaderboard" ON public.leaderboard;
CREATE POLICY "Lectura pública de leaderboard" ON public.leaderboard FOR SELECT USING (true);

DROP POLICY IF EXISTS "Lectura pública de usuarios" ON public.users;
CREATE POLICY "Lectura pública de usuarios" ON public.users FOR SELECT USING (true);

DROP POLICY IF EXISTS "Acceso total a srs_items" ON public.srs_items;
CREATE POLICY "Acceso total a srs_items" ON public.srs_items FOR ALL USING (true);

-- Datos Semilla Iniciales
INSERT INTO public.users (id, username, email) 
VALUES 
    ('user_1', 'Alonso (Dev)', 'alonso@javaplay.dev'),
    ('user_2', 'Elena (Staff JVM)', 'elena@javaplay.dev'),
    ('user_3', 'Carlos (Spring Lead)', 'carlos@javaplay.dev')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.user_progress (user_id, xp, lives, streak, current_level)
VALUES 
    ('user_1', 180, 5, 3, 4),
    ('user_2', 1420, 5, 12, 10),
    ('user_3', 1190, 4, 8, 9)
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO public.leaderboard (user_id, league, weekly_xp, rank)
VALUES 
    ('user_2', 'Diamond 💎', 1420, 1),
    ('user_3', 'Diamond 💎', 1190, 2),
    ('user_1', 'Diamond 💎', 180, 3)
ON CONFLICT (user_id) DO NOTHING;

-- Semilla inicial de tarjetas SM-2 para user_1
INSERT INTO public.srs_items (id, user_id, exercise_id, world_id, repetitions, interval_days, ease_factor, next_review_at)
VALUES
    ('user_1:n0_ex1', 'user_1', 'n0_ex1', 'nivel_0', 2, 6, 2.60, CURRENT_TIMESTAMP - INTERVAL '1 hour'),
    ('user_1:n0_ex2', 'user_1', 'n0_ex2', 'nivel_0', 1, 1, 2.50, CURRENT_TIMESTAMP - INTERVAL '2 hours'),
    ('user_1:n1_ex2', 'user_1', 'n1_ex2', 'nivel_1', 0, 1, 2.40, CURRENT_TIMESTAMP),
    ('user_1:n2_ex2', 'user_1', 'n2_ex2', 'nivel_2', 3, 15, 2.70, CURRENT_TIMESTAMP + INTERVAL '5 days'),
    ('user_1:n4_ex2', 'user_1', 'n4_ex2', 'nivel_4', 1, 3, 2.36, CURRENT_TIMESTAMP - INTERVAL '30 minutes')
ON CONFLICT (id) DO NOTHING;
