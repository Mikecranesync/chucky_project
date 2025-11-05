-- ============================================
-- Quota Management & Usage Tracking Schema
-- For Chucky Monetization - Recommendation #3
-- Created: 2025-11-03
-- ============================================

-- ============================================
-- 1. UPDATE USERS TABLE
-- Add quota tracking fields
-- ============================================

ALTER TABLE users
ADD COLUMN IF NOT EXISTS last_request_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS last_reset_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS quota_warnings_sent INTEGER DEFAULT 0;

-- Add index for quota queries
CREATE INDEX IF NOT EXISTS idx_users_usage_count ON users(usage_count);
CREATE INDEX IF NOT EXISTS idx_users_last_request ON users(last_request_at DESC);

-- Add comment for documentation
COMMENT ON COLUMN users.usage_count IS 'Number of requests made in current billing period';
COMMENT ON COLUMN users.last_request_at IS 'Timestamp of last API request';
COMMENT ON COLUMN users.last_reset_at IS 'Timestamp of last quota reset (monthly)';
COMMENT ON COLUMN users.quota_warnings_sent IS 'Number of quota warning messages sent this period';

-- ============================================
-- 2. MONTHLY REPORTS TABLE
-- Store monthly usage statistics
-- ============================================

CREATE TABLE IF NOT EXISTS monthly_reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    report_month TEXT NOT NULL UNIQUE,
    report_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- User statistics
    total_users INTEGER DEFAULT 0,
    free_users INTEGER DEFAULT 0,
    basic_users INTEGER DEFAULT 0,
    pro_users INTEGER DEFAULT 0,

    -- Usage statistics
    total_requests INTEGER DEFAULT 0,
    avg_requests_per_user DECIMAL(10, 2) DEFAULT 0,
    users_at_limit INTEGER DEFAULT 0,

    -- Revenue metrics (calculated from other tables)
    mrr DECIMAL(10, 2) DEFAULT 0,
    conversion_rate DECIMAL(5, 2) DEFAULT 0,

    -- Additional metrics
    new_users INTEGER DEFAULT 0,
    churned_users INTEGER DEFAULT 0,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for month queries
CREATE INDEX IF NOT EXISTS idx_monthly_reports_month ON monthly_reports(report_month);
CREATE INDEX IF NOT EXISTS idx_monthly_reports_date ON monthly_reports(report_date DESC);

-- ============================================
-- 3. USAGE TRACKING ARCHIVE TABLE
-- Archive old usage data for long-term analytics
-- ============================================

CREATE TABLE IF NOT EXISTS usage_tracking_archive (
    id UUID,
    telegram_id TEXT NOT NULL,
    action_type TEXT NOT NULL,
    cost DECIMAL(10, 4) DEFAULT 0.00,
    timestamp TIMESTAMP WITH TIME ZONE,
    metadata JSONB,
    archived_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for archive queries
CREATE INDEX IF NOT EXISTS idx_usage_archive_telegram_id ON usage_tracking_archive(telegram_id);
CREATE INDEX IF NOT EXISTS idx_usage_archive_timestamp ON usage_tracking_archive(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_usage_archive_action_type ON usage_tracking_archive(action_type);

-- ============================================
-- 4. QUOTA TIERS CONFIGURATION TABLE
-- Centralized quota limits (optional - can also hardcode)
-- ============================================

CREATE TABLE IF NOT EXISTS quota_tiers (
    tier_name TEXT PRIMARY KEY CHECK (tier_name IN ('free', 'basic', 'pro', 'pay_per_use')),
    monthly_limit INTEGER NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    features JSONB,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default tier configurations
INSERT INTO quota_tiers (tier_name, monthly_limit, price, features, description)
VALUES
    ('free', 5, 0.00, '{"pdf_delivery": false, "priority_support": false, "custom_reports": false}', 'Basic image categorization only'),
    ('basic', 50, 4.99, '{"pdf_delivery": true, "priority_support": false, "custom_reports": false}', 'Full PDF delivery and 50 queries per month'),
    ('pro', 999999, 19.99, '{"pdf_delivery": true, "priority_support": true, "custom_reports": true, "advanced_analytics": true}', 'Unlimited queries with all premium features'),
    ('pay_per_use', 999999, 0.10, '{"pdf_delivery": true, "priority_support": false, "custom_reports": false}', 'Pay per analysis, no subscription')
ON CONFLICT (tier_name) DO UPDATE SET
    monthly_limit = EXCLUDED.monthly_limit,
    price = EXCLUDED.price,
    features = EXCLUDED.features,
    description = EXCLUDED.description,
    updated_at = NOW();

-- ============================================
-- 5. QUOTA EVENTS LOG TABLE
-- Track quota enforcement events
-- ============================================

CREATE TABLE IF NOT EXISTS quota_events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    telegram_id TEXT NOT NULL REFERENCES users(telegram_id) ON DELETE CASCADE,
    event_type TEXT NOT NULL CHECK (event_type IN ('quota_exceeded', 'quota_warning', 'quota_reset', 'tier_upgraded', 'tier_downgraded')),
    tier TEXT NOT NULL,
    usage_at_event INTEGER,
    limit_at_event INTEGER,
    message_sent BOOLEAN DEFAULT false,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB
);

-- Indexes for quota events
CREATE INDEX IF NOT EXISTS idx_quota_events_telegram_id ON quota_events(telegram_id);
CREATE INDEX IF NOT EXISTS idx_quota_events_type ON quota_events(event_type);
CREATE INDEX IF NOT EXISTS idx_quota_events_timestamp ON quota_events(timestamp DESC);

-- ============================================
-- 6. FUNCTIONS
-- ============================================

-- Function to get user quota status
CREATE OR REPLACE FUNCTION get_quota_status(user_telegram_id TEXT)
RETURNS TABLE (
    telegram_id TEXT,
    tier TEXT,
    current_usage INTEGER,
    monthly_limit INTEGER,
    remaining INTEGER,
    usage_percentage DECIMAL,
    quota_exceeded BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.telegram_id,
        u.subscription_status as tier,
        u.usage_count as current_usage,
        qt.monthly_limit,
        GREATEST(0, qt.monthly_limit - u.usage_count) as remaining,
        ROUND((u.usage_count::DECIMAL / NULLIF(qt.monthly_limit, 0) * 100), 2) as usage_percentage,
        u.usage_count >= qt.monthly_limit as quota_exceeded
    FROM users u
    JOIN quota_tiers qt ON u.subscription_status = qt.tier_name
    WHERE u.telegram_id = user_telegram_id;
END;
$$ LANGUAGE plpgsql;

-- Function to increment usage with quota check
CREATE OR REPLACE FUNCTION increment_usage_with_check(user_telegram_id TEXT)
RETURNS TABLE (
    allowed BOOLEAN,
    new_usage INTEGER,
    limit INTEGER,
    message TEXT
) AS $$
DECLARE
    current_status RECORD;
    user_limit INTEGER;
    new_count INTEGER;
BEGIN
    -- Get current user status
    SELECT
        u.usage_count,
        u.subscription_status,
        qt.monthly_limit
    INTO current_status
    FROM users u
    JOIN quota_tiers qt ON u.subscription_status = qt.tier_name
    WHERE u.telegram_id = user_telegram_id;

    user_limit := current_status.monthly_limit;

    -- Check if quota exceeded
    IF current_status.usage_count >= user_limit THEN
        RETURN QUERY SELECT
            false as allowed,
            current_status.usage_count as new_usage,
            user_limit as limit,
            'Quota exceeded' as message;
        RETURN;
    END IF;

    -- Increment usage
    UPDATE users
    SET
        usage_count = usage_count + 1,
        last_request_at = NOW()
    WHERE telegram_id = user_telegram_id
    RETURNING usage_count INTO new_count;

    -- Return success
    RETURN QUERY SELECT
        true as allowed,
        new_count as new_usage,
        user_limit as limit,
        'Request allowed' as message;
END;
$$ LANGUAGE plpgsql;

-- Function to reset all quotas (called monthly)
CREATE OR REPLACE FUNCTION reset_all_quotas()
RETURNS TABLE (
    users_reset INTEGER,
    previous_total_usage BIGINT
) AS $$
DECLARE
    total_before BIGINT;
    reset_count INTEGER;
BEGIN
    -- Get total usage before reset
    SELECT SUM(usage_count) INTO total_before FROM users;

    -- Reset all users
    UPDATE users
    SET
        usage_count = 0,
        last_reset_at = NOW(),
        quota_warnings_sent = 0;

    GET DIAGNOSTICS reset_count = ROW_COUNT;

    -- Log reset event
    INSERT INTO quota_events (telegram_id, event_type, tier, usage_at_event, limit_at_event, metadata)
    SELECT
        u.telegram_id,
        'quota_reset',
        u.subscription_status,
        0, -- usage after reset
        qt.monthly_limit,
        jsonb_build_object('reset_date', NOW(), 'previous_usage', u.usage_count)
    FROM users u
    JOIN quota_tiers qt ON u.subscription_status = qt.tier_name;

    RETURN QUERY SELECT reset_count, total_before;
END;
$$ LANGUAGE plpgsql;

-- Function to get users approaching limit
CREATE OR REPLACE FUNCTION get_users_approaching_limit(threshold_percentage INTEGER DEFAULT 80)
RETURNS TABLE (
    telegram_id TEXT,
    username TEXT,
    tier TEXT,
    usage_count INTEGER,
    limit INTEGER,
    remaining INTEGER,
    usage_percentage DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.telegram_id,
        u.username,
        u.subscription_status as tier,
        u.usage_count,
        qt.monthly_limit as limit,
        qt.monthly_limit - u.usage_count as remaining,
        ROUND((u.usage_count::DECIMAL / qt.monthly_limit * 100), 2) as usage_percentage
    FROM users u
    JOIN quota_tiers qt ON u.subscription_status = qt.tier_name
    WHERE
        u.subscription_status IN ('free', 'basic') -- Don't check pro users
        AND (u.usage_count::DECIMAL / qt.monthly_limit * 100) >= threshold_percentage
        AND u.usage_count < qt.monthly_limit
    ORDER BY usage_percentage DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 7. VIEWS FOR ANALYTICS
-- ============================================

-- Current quota status for all users
CREATE OR REPLACE VIEW user_quota_status AS
SELECT
    u.telegram_id,
    u.username,
    u.subscription_status as tier,
    u.usage_count,
    qt.monthly_limit as limit,
    qt.monthly_limit - u.usage_count as remaining,
    ROUND((u.usage_count::DECIMAL / NULLIF(qt.monthly_limit, 0) * 100), 2) as usage_percentage,
    u.usage_count >= qt.monthly_limit as quota_exceeded,
    u.last_request_at,
    u.last_reset_at
FROM users u
JOIN quota_tiers qt ON u.subscription_status = qt.tier_name
ORDER BY usage_percentage DESC;

-- Users at risk of hitting limit (>80%)
CREATE OR REPLACE VIEW users_at_risk AS
SELECT * FROM user_quota_status
WHERE usage_percentage >= 80 AND usage_percentage < 100
ORDER BY usage_percentage DESC;

-- Users who exceeded quota
CREATE OR REPLACE VIEW users_exceeded_quota AS
SELECT * FROM user_quota_status
WHERE quota_exceeded = true
ORDER BY usage_count DESC;

-- Daily usage trends
CREATE OR REPLACE VIEW daily_usage_trends AS
SELECT
    DATE(timestamp) as date,
    COUNT(*) as total_requests,
    COUNT(DISTINCT telegram_id) as unique_users,
    AVG(cost) as avg_cost,
    SUM(cost) as total_cost
FROM usage_tracking
GROUP BY DATE(timestamp)
ORDER BY date DESC;

-- ============================================
-- 8. TRIGGERS
-- ============================================

-- Trigger to log quota exceeded events
CREATE OR REPLACE FUNCTION log_quota_exceeded()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.usage_count >= (
        SELECT monthly_limit
        FROM quota_tiers
        WHERE tier_name = NEW.subscription_status
    ) AND NEW.usage_count != OLD.usage_count THEN
        INSERT INTO quota_events (
            telegram_id,
            event_type,
            tier,
            usage_at_event,
            limit_at_event,
            metadata
        )
        VALUES (
            NEW.telegram_id,
            'quota_exceeded',
            NEW.subscription_status,
            NEW.usage_count,
            (SELECT monthly_limit FROM quota_tiers WHERE tier_name = NEW.subscription_status),
            jsonb_build_object('exceeded_at', NOW())
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_quota_exceeded
    AFTER UPDATE OF usage_count ON users
    FOR EACH ROW
    EXECUTE FUNCTION log_quota_exceeded();

-- ============================================
-- 9. SAMPLE QUERIES
-- ============================================

-- Get quota status for specific user
/*
SELECT * FROM get_quota_status('YOUR_TELEGRAM_ID');
*/

-- Increment usage with automatic quota check
/*
SELECT * FROM increment_usage_with_check('YOUR_TELEGRAM_ID');
*/

-- Get users approaching their limit (>80%)
/*
SELECT * FROM get_users_approaching_limit(80);
*/

-- Get current quota status for all users
/*
SELECT * FROM user_quota_status;
*/

-- Users at risk (warning zone)
/*
SELECT * FROM users_at_risk;
*/

-- Users who exceeded quota
/*
SELECT * FROM users_exceeded_quota;
*/

-- Daily usage trends
/*
SELECT * FROM daily_usage_trends
WHERE date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY date DESC;
*/

-- Top users by usage
/*
SELECT
    telegram_id,
    username,
    tier,
    usage_count,
    limit,
    usage_percentage
FROM user_quota_status
WHERE tier IN ('free', 'basic')
ORDER BY usage_count DESC
LIMIT 20;
*/

-- Conversion opportunity: Heavy free users
/*
SELECT
    telegram_id,
    username,
    usage_count,
    limit,
    usage_percentage
FROM user_quota_status
WHERE tier = 'free'
    AND usage_percentage >= 80
ORDER BY usage_count DESC;
*/

-- Monthly usage summary
/*
SELECT
    subscription_status as tier,
    COUNT(*) as user_count,
    SUM(usage_count) as total_requests,
    AVG(usage_count) as avg_requests,
    MAX(usage_count) as max_requests
FROM users
GROUP BY subscription_status
ORDER BY total_requests DESC;
*/

-- Quota events history
/*
SELECT
    qe.telegram_id,
    u.username,
    qe.event_type,
    qe.tier,
    qe.usage_at_event,
    qe.limit_at_event,
    qe.timestamp
FROM quota_events qe
JOIN users u ON qe.telegram_id = u.telegram_id
ORDER BY qe.timestamp DESC
LIMIT 50;
*/

-- ============================================
-- 10. MAINTENANCE SCRIPTS
-- ============================================

-- Reset all quotas manually (for testing or emergency)
/*
SELECT * FROM reset_all_quotas();
*/

-- Archive old usage data (>90 days)
/*
INSERT INTO usage_tracking_archive
SELECT *, NOW() as archived_at
FROM usage_tracking
WHERE timestamp < NOW() - INTERVAL '90 days';

DELETE FROM usage_tracking
WHERE timestamp < NOW() - INTERVAL '90 days';
*/

-- Clean up old quota events (>1 year)
/*
DELETE FROM quota_events
WHERE timestamp < NOW() - INTERVAL '1 year';
*/

-- Recalculate usage for a user (if data inconsistent)
/*
UPDATE users
SET usage_count = (
    SELECT COUNT(*)
    FROM usage_tracking
    WHERE telegram_id = users.telegram_id
        AND timestamp >= users.last_reset_at
)
WHERE telegram_id = 'YOUR_TELEGRAM_ID';
*/

-- ============================================
-- VERIFICATION
-- ============================================

-- Check all new tables created
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
    AND table_name IN ('monthly_reports', 'usage_tracking_archive', 'quota_tiers', 'quota_events')
ORDER BY table_name;

-- Check users table updated
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'users'
    AND column_name IN ('last_request_at', 'last_reset_at', 'quota_warnings_sent')
ORDER BY column_name;

-- Check views created
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
    AND table_name IN ('user_quota_status', 'users_at_risk', 'users_exceeded_quota', 'daily_usage_trends')
ORDER BY table_name;

-- Check functions created
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
    AND routine_name IN ('get_quota_status', 'increment_usage_with_check', 'reset_all_quotas', 'get_users_approaching_limit')
ORDER BY routine_name;

-- Test quota status function
SELECT * FROM get_quota_status('123456789');

-- Test users approaching limit
SELECT * FROM get_users_approaching_limit(80);

-- View quota tiers
SELECT * FROM quota_tiers ORDER BY price;

-- Sample data check
SELECT 'Monthly Reports' as table_name, COUNT(*) FROM monthly_reports
UNION ALL
SELECT 'Quota Events', COUNT(*) FROM quota_events
UNION ALL
SELECT 'Quota Tiers', COUNT(*) FROM quota_tiers;
