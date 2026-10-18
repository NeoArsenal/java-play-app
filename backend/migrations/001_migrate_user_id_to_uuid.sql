-- =============================================================================
-- MIGRACIÓN PROPUESTA (SIN APLICAR): Transición de VARCHAR(64) a UUID nativo
-- Archivo: backend/migrations/001_migrate_user_id_to_uuid.sql
--
-- NOTA IMPORTANTE:
-- En el esquema actual (schema.sql), todas las columnas de user_id son VARCHAR(64),
-- por lo que tanto 'user_1' (6 caracteres) como los UUID v4 (36 caracteres) caben
-- perfectamente sin truncamiento ni error en la base de datos actual.
--
-- Esta migración está diseñada para ejecutarse en el futuro, ÚNICAMENTE cuando
-- se decida abandonar el soporte de IDs alfanuméricos heredados y migrar al tipo
-- nativo UUID de PostgreSQL (16 bytes en almacenamiento e indexación óptima).
-- =============================================================================

BEGIN;

-- 1. Habilitar extensión pgcrypto o uuid-ossp si no existen
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Migrar IDs legacy si aún existen registros con formato no UUID
-- Asigna un UUID v5 determinista en el namespace DNS para no romper relaciones existentes
UPDATE public.users 
SET id = uuid_generate_v5(uuid_ns_dns(), id)::text 
WHERE id NOT ~* '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$';

-- 3. Temporalmente relajar llaves foráneas para permitir el cambio de tipo de datos
ALTER TABLE public.user_progress DROP CONSTRAINT IF EXISTS user_progress_user_id_fkey;
ALTER TABLE public.completed_exercises DROP CONSTRAINT IF EXISTS completed_exercises_user_id_fkey;
ALTER TABLE public.mock_interview_submissions DROP CONSTRAINT IF EXISTS mock_interview_submissions_user_id_fkey;
ALTER TABLE public.leaderboard DROP CONSTRAINT IF EXISTS leaderboard_user_id_fkey;
ALTER TABLE public.srs_items DROP CONSTRAINT IF EXISTS srs_items_user_id_fkey;
ALTER TABLE public.boss_challenges DROP CONSTRAINT IF EXISTS boss_challenges_user_id_fkey;

-- 4. Modificar tipo de columna a UUID nativo en la tabla principal
ALTER TABLE public.users 
    ALTER COLUMN id TYPE UUID USING id::uuid;

-- 5. Modificar tipo de columna a UUID nativo en tablas dependientes
ALTER TABLE public.user_progress 
    ALTER COLUMN user_id TYPE UUID USING user_id::uuid;

ALTER TABLE public.completed_exercises 
    ALTER COLUMN user_id TYPE UUID USING user_id::uuid;

ALTER TABLE public.mock_interview_submissions 
    ALTER COLUMN user_id TYPE UUID USING user_id::uuid;

ALTER TABLE public.leaderboard 
    ALTER COLUMN user_id TYPE UUID USING user_id::uuid;

ALTER TABLE public.srs_items 
    ALTER COLUMN user_id TYPE UUID USING user_id::uuid;

ALTER TABLE public.boss_challenges 
    ALTER COLUMN user_id TYPE UUID USING user_id::uuid;

-- 6. Restaurar llaves foráneas con CASCADE
ALTER TABLE public.user_progress
    ADD CONSTRAINT user_progress_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.completed_exercises
    ADD CONSTRAINT completed_exercises_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.mock_interview_submissions
    ADD CONSTRAINT mock_interview_submissions_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.leaderboard
    ADD CONSTRAINT leaderboard_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.srs_items
    ADD CONSTRAINT srs_items_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.boss_challenges
    ADD CONSTRAINT boss_challenges_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

COMMIT;
