-- Chucky Telegram Bot Audit Table
-- Purpose: Log all /chucky commands executed via Telegram for security and monitoring
-- Created: 2025-11-05

-- Create the audit table
CREATE TABLE IF NOT EXISTS public.chucky_audit (
  id BIGSERIAL PRIMARY KEY,
  timestamp TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  user_id TEXT NOT NULL,
  username TEXT,
  command TEXT NOT NULL,
  platform TEXT DEFAULT 'telegram' NOT NULL,
  execution_time_ms INTEGER,
  success BOOLEAN DEFAULT false NOT NULL,
  error TEXT
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_chucky_audit_timestamp
  ON public.chucky_audit(timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_chucky_audit_user
  ON public.chucky_audit(user_id);

CREATE INDEX IF NOT EXISTS idx_chucky_audit_success
  ON public.chucky_audit(success);

CREATE INDEX IF NOT EXISTS idx_chucky_audit_platform
  ON public.chucky_audit(platform);

-- Create composite index for common queries (user activity over time)
CREATE INDEX IF NOT EXISTS idx_chucky_audit_user_timestamp
  ON public.chucky_audit(user_id, timestamp DESC);

-- Add helpful comments
COMMENT ON TABLE public.chucky_audit IS 'Audit log for all Chucky bot commands executed via Telegram';
COMMENT ON COLUMN public.chucky_audit.user_id IS 'Telegram user ID who executed the command';
COMMENT ON COLUMN public.chucky_audit.username IS 'Telegram username or first name';
COMMENT ON COLUMN public.chucky_audit.command IS 'The /chucky command that was executed';
COMMENT ON COLUMN public.chucky_audit.platform IS 'Platform used (telegram, discord, etc)';
COMMENT ON COLUMN public.chucky_audit.execution_time_ms IS 'Time taken to execute command in milliseconds';
COMMENT ON COLUMN public.chucky_audit.success IS 'Whether the command succeeded';
COMMENT ON COLUMN public.chucky_audit.error IS 'Error message if command failed';

-- Enable Row Level Security (RLS)
ALTER TABLE public.chucky_audit ENABLE ROW LEVEL SECURITY;

-- Create policy: Service role can do everything
CREATE POLICY "Service role can manage audit logs"
  ON public.chucky_audit
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Create policy: Authenticated users can read their own logs
CREATE POLICY "Users can read their own audit logs"
  ON public.chucky_audit
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid()::TEXT);

-- Grant permissions
GRANT SELECT, INSERT ON public.chucky_audit TO service_role;
GRANT SELECT ON public.chucky_audit TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.chucky_audit_id_seq TO service_role;

-- Create a view for recent activity (optional but useful)
CREATE OR REPLACE VIEW public.chucky_audit_recent AS
SELECT
  id,
  timestamp,
  username,
  command,
  platform,
  execution_time_ms,
  success,
  error
FROM public.chucky_audit
WHERE timestamp > NOW() - INTERVAL '7 days'
ORDER BY timestamp DESC
LIMIT 1000;

COMMENT ON VIEW public.chucky_audit_recent IS 'Recent audit log entries (last 7 days, max 1000)';

-- Create a function to get user stats (optional but useful)
CREATE OR REPLACE FUNCTION public.get_user_command_stats(p_user_id TEXT)
RETURNS TABLE (
  total_commands BIGINT,
  successful_commands BIGINT,
  failed_commands BIGINT,
  avg_execution_time_ms NUMERIC,
  last_command_time TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*) as total_commands,
    COUNT(*) FILTER (WHERE success = true) as successful_commands,
    COUNT(*) FILTER (WHERE success = false) as failed_commands,
    AVG(execution_time_ms) as avg_execution_time_ms,
    MAX(timestamp) as last_command_time
  FROM public.chucky_audit
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.get_user_command_stats IS 'Get command statistics for a specific user';

-- Test the table (run these after creation to verify)
-- INSERT INTO public.chucky_audit (user_id, username, command, platform, execution_time_ms, success)
-- VALUES ('8445149012', 'test_user', 'create a webhook node', 'telegram', 15000, true);

-- SELECT * FROM public.chucky_audit ORDER BY timestamp DESC LIMIT 10;

-- SELECT * FROM public.get_user_command_stats('8445149012');

VACUUM ANALYZE public.chucky_audit;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Chucky audit table created successfully!';
  RAISE NOTICE 'Table: public.chucky_audit';
  RAISE NOTICE 'Indexes: 5 indexes created';
  RAISE NOTICE 'RLS: Enabled with policies';
  RAISE NOTICE 'Ready to use with n8n Supabase node';
END $$;
