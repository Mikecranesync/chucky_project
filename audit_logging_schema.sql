-- Supabase Audit Logging Schema for Chucky Remote Access
-- Version: 1.0.0
-- Date: 2025-11-04
-- Purpose: Track all remote /chucky command executions

-- Create audit table
CREATE TABLE IF NOT EXISTS chucky_audit (
  id SERIAL PRIMARY KEY,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  user_id TEXT NOT NULL,
  username TEXT,
  command TEXT NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('telegram', 'discord', 'ssh', 'api')),
  execution_time_ms INT,
  success BOOLEAN NOT NULL DEFAULT false,
  error TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_chucky_audit_timestamp
  ON chucky_audit(timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_chucky_audit_user
  ON chucky_audit(user_id);

CREATE INDEX IF NOT EXISTS idx_chucky_audit_platform
  ON chucky_audit(platform);

CREATE INDEX IF NOT EXISTS idx_chucky_audit_success
  ON chucky_audit(success);

-- Create composite index for common queries
CREATE INDEX IF NOT EXISTS idx_chucky_audit_user_timestamp
  ON chucky_audit(user_id, timestamp DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE chucky_audit ENABLE ROW LEVEL SECURITY;

-- Create policy for service role (full access)
CREATE POLICY IF NOT EXISTS "Service role has full access"
  ON chucky_audit
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Create view for recent activity
CREATE OR REPLACE VIEW chucky_audit_recent AS
SELECT
  timestamp,
  username,
  command,
  platform,
  execution_time_ms,
  success,
  CASE
    WHEN success THEN '✅'
    ELSE '❌'
  END as status_icon
FROM chucky_audit
ORDER BY timestamp DESC
LIMIT 100;

-- Create view for user statistics
CREATE OR REPLACE VIEW chucky_audit_user_stats AS
SELECT
  user_id,
  username,
  platform,
  COUNT(*) as total_commands,
  COUNT(*) FILTER (WHERE success = true) as successful_commands,
  COUNT(*) FILTER (WHERE success = false) as failed_commands,
  ROUND(AVG(execution_time_ms), 2) as avg_execution_ms,
  MIN(timestamp) as first_command,
  MAX(timestamp) as last_command
FROM chucky_audit
GROUP BY user_id, username, platform
ORDER BY total_commands DESC;

-- Create view for command patterns
CREATE OR REPLACE VIEW chucky_audit_command_patterns AS
SELECT
  CASE
    WHEN command ILIKE '%create%node%' THEN 'Create Node'
    WHEN command ILIKE '%validate%' THEN 'Validate Workflow'
    WHEN command ILIKE '%production-ready%' THEN 'Production Ready'
    WHEN command ILIKE '%new-feature%' THEN 'New Feature'
    WHEN command ILIKE '%debug%' THEN 'Debug'
    WHEN command ILIKE '%deploy-prep%' THEN 'Deploy Prep'
    WHEN command ILIKE '%help%' OR command ILIKE '%what%can%' THEN 'Help/Info'
    ELSE 'Other'
  END as command_type,
  platform,
  COUNT(*) as usage_count,
  ROUND(AVG(execution_time_ms), 2) as avg_execution_ms,
  COUNT(*) FILTER (WHERE success = true) as success_count,
  COUNT(*) FILTER (WHERE success = false) as failure_count
FROM chucky_audit
GROUP BY command_type, platform
ORDER BY usage_count DESC;

-- Create function to clean old audit logs (optional)
CREATE OR REPLACE FUNCTION clean_old_audit_logs(days_to_keep INT DEFAULT 90)
RETURNS INT AS $$
DECLARE
  deleted_count INT;
BEGIN
  DELETE FROM chucky_audit
  WHERE timestamp < NOW() - (days_to_keep || ' days')::INTERVAL;

  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Example: Clean logs older than 90 days
-- SELECT clean_old_audit_logs(90);

-- Useful queries

-- 1. Recent commands by user
-- SELECT username, command, timestamp, success, execution_time_ms
-- FROM chucky_audit
-- WHERE user_id = 'YOUR_USER_ID'
-- ORDER BY timestamp DESC
-- LIMIT 20;

-- 2. Failed commands for troubleshooting
-- SELECT timestamp, username, command, error
-- FROM chucky_audit
-- WHERE success = false
-- ORDER BY timestamp DESC;

-- 3. Slow commands (> 30 seconds)
-- SELECT timestamp, username, command, execution_time_ms
-- FROM chucky_audit
-- WHERE execution_time_ms > 30000
-- ORDER BY execution_time_ms DESC;

-- 4. Most used commands
-- SELECT command, COUNT(*) as usage_count
-- FROM chucky_audit
-- WHERE timestamp > NOW() - INTERVAL '7 days'
-- GROUP BY command
-- ORDER BY usage_count DESC
-- LIMIT 10;

-- 5. Platform usage statistics
-- SELECT platform, COUNT(*) as total,
--        COUNT(*) FILTER (WHERE success = true) as successful
-- FROM chucky_audit
-- GROUP BY platform;

-- Grant permissions (if using specific roles)
-- GRANT SELECT, INSERT ON chucky_audit TO authenticated;
-- GRANT SELECT ON chucky_audit_recent TO authenticated;
-- GRANT SELECT ON chucky_audit_user_stats TO authenticated;
-- GRANT SELECT ON chucky_audit_command_patterns TO authenticated;

-- Comments
COMMENT ON TABLE chucky_audit IS 'Audit log for all remote /chucky command executions';
COMMENT ON COLUMN chucky_audit.user_id IS 'Telegram/Discord user ID or SSH username';
COMMENT ON COLUMN chucky_audit.platform IS 'Platform used: telegram, discord, ssh, or api';
COMMENT ON COLUMN chucky_audit.execution_time_ms IS 'Command execution time in milliseconds';
COMMENT ON COLUMN chucky_audit.success IS 'Whether command executed successfully';

-- Done! Run this entire file in Supabase SQL Editor
