-- ============================================
-- Advanced Features Database Schema
-- Recommendations #4-7: Monitoring, Security, Premium, Marketing
-- Created: 2025-11-03
-- ============================================

-- ============================================
-- RECOMMENDATION #4: MONITORING & ANALYTICS
-- ============================================

-- Daily Reports Table
CREATE TABLE IF NOT EXISTS daily_reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    report_date DATE UNIQUE NOT NULL,
    health_score INTEGER CHECK (health_score >= 0 AND health_score <= 100),
    status TEXT CHECK (status IN ('healthy', 'warning', 'critical')),

    -- User metrics
    total_users INTEGER DEFAULT 0,
    active_24h INTEGER DEFAULT 0,
    active_7d INTEGER DEFAULT 0,
    new_users_24h INTEGER DEFAULT 0,

    -- Usage metrics
    requests_24h INTEGER DEFAULT 0,
    quota_exceeded_24h INTEGER DEFAULT 0,

    -- Revenue metrics
    revenue_24h DECIMAL(10, 2) DEFAULT 0,
    current_mrr DECIMAL(10, 2) DEFAULT 0,
    conversion_rate DECIMAL(5, 2) DEFAULT 0,

    -- System metrics
    webhook_errors INTEGER DEFAULT 0,
    webhook_processed INTEGER DEFAULT 0,

    -- Full report data
    report_data JSONB,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_daily_reports_date ON daily_reports(report_date DESC);
CREATE INDEX idx_daily_reports_status ON daily_reports(status);
CREATE INDEX idx_daily_reports_health ON daily_reports(health_score);

-- ============================================
-- RECOMMENDATION #5: SECURITY & COMPLIANCE
-- ============================================

-- Audit Logs Table
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    telegram_id TEXT,
    action TEXT NOT NULL,
    command TEXT,
    ip_address TEXT,
    user_agent TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB,

    -- GDPR compliance
    data_exported BOOLEAN DEFAULT false,
    data_deleted BOOLEAN DEFAULT false
);

CREATE INDEX idx_audit_logs_telegram_id ON audit_logs(telegram_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp DESC);

-- GDPR Requests Table
CREATE TABLE IF NOT EXISTS gdpr_requests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    telegram_id TEXT NOT NULL,
    request_type TEXT CHECK (request_type IN ('export', 'delete', 'opt_out', 'correction')),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'rejected')),
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    processed_by TEXT
);

CREATE INDEX idx_gdpr_requests_telegram_id ON gdpr_requests(telegram_id);
CREATE INDEX idx_gdpr_requests_status ON gdpr_requests(status);

-- ============================================
-- RECOMMENDATION #6: PREMIUM FEATURES
-- ============================================

-- Custom Training Data Table (Pro users upload PDFs)
CREATE TABLE IF NOT EXISTS custom_training_data (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    telegram_id TEXT NOT NULL REFERENCES users(telegram_id) ON DELETE CASCADE,
    document_name TEXT NOT NULL,
    file_url TEXT,
    file_size INTEGER,
    document_type TEXT,
    upload_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed BOOLEAN DEFAULT false,
    processed_at TIMESTAMP WITH TIME ZONE,
    vector_count INTEGER DEFAULT 0,
    metadata JSONB
);

CREATE INDEX idx_custom_training_telegram_id ON custom_training_data(telegram_id);
CREATE INDEX idx_custom_training_processed ON custom_training_data(processed);

-- User Analytics Cache Table
CREATE TABLE IF NOT EXISTS user_analytics_cache (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    telegram_id TEXT UNIQUE NOT NULL REFERENCES users(telegram_id) ON DELETE CASCADE,

    -- 30-day stats
    total_requests_30d INTEGER DEFAULT 0,
    active_days_30d INTEGER DEFAULT 0,
    avg_cost_per_request DECIMAL(10, 4) DEFAULT 0,
    total_cost_30d DECIMAL(10, 2) DEFAULT 0,

    -- Feature usage
    features_used JSONB,

    -- Last calculated
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_analytics_cache_telegram_id ON user_analytics_cache(telegram_id);
CREATE INDEX idx_analytics_cache_updated ON user_analytics_cache(last_updated DESC);

-- ============================================
-- RECOMMENDATION #7: MARKETING & RETENTION
-- ============================================

-- Update users table with marketing fields
ALTER TABLE users
ADD COLUMN IF NOT EXISTS bonus_requests INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS referred_by TEXT,
ADD COLUMN IF NOT EXISTS referral_code TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS last_engagement_at TIMESTAMP WITH TIME ZONE;

-- Generate unique referral code for existing users
UPDATE users SET referral_code = telegram_id WHERE referral_code IS NULL;

-- Create index for referral tracking
CREATE INDEX IF NOT EXISTS idx_users_referred_by ON users(referred_by);
CREATE INDEX IF NOT EXISTS idx_users_referral_code ON users(referral_code);

-- Referrals Table
CREATE TABLE IF NOT EXISTS referrals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    referrer_telegram_id TEXT NOT NULL REFERENCES users(telegram_id) ON DELETE CASCADE,
    referred_telegram_id TEXT NOT NULL REFERENCES users(telegram_id) ON DELETE CASCADE,
    referral_code TEXT NOT NULL,
    bonus_granted BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(referrer_telegram_id, referred_telegram_id)
);

CREATE INDEX idx_referrals_referrer ON referrals(referrer_telegram_id);
CREATE INDEX idx_referrals_referred ON referrals(referred_telegram_id);
CREATE INDEX idx_referrals_created ON referrals(created_at DESC);

-- Feedback Table
CREATE TABLE IF NOT EXISTS feedback (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    telegram_id TEXT NOT NULL REFERENCES users(telegram_id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    feedback_text TEXT,
    feedback_type TEXT DEFAULT 'general',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    responded_to BOOLEAN DEFAULT false
);

CREATE INDEX idx_feedback_telegram_id ON feedback(telegram_id);
CREATE INDEX idx_feedback_rating ON feedback(rating);
CREATE INDEX idx_feedback_created ON feedback(created_at DESC);

-- Engagement Events Table
CREATE TABLE IF NOT EXISTS engagement_events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    telegram_id TEXT NOT NULL REFERENCES users(telegram_id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    event_data JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_engagement_telegram_id ON engagement_events(telegram_id);
CREATE INDEX idx_engagement_type ON engagement_events(event_type);
CREATE INDEX idx_engagement_timestamp ON engagement_events(timestamp DESC);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to calculate health score
CREATE OR REPLACE FUNCTION calculate_health_score()
RETURNS INTEGER AS $$
DECLARE
    total_users INTEGER;
    active_24h INTEGER;
    conversion_rate DECIMAL;
    webhook_errors INTEGER;
    score INTEGER;
BEGIN
    -- Get metrics
    SELECT COUNT(*) INTO total_users FROM users;
    SELECT COUNT(*) INTO active_24h FROM users WHERE last_request_at >= NOW() - INTERVAL '24 hours';
    SELECT COUNT(CASE WHEN subscription_status IN ('basic', 'pro') THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)
        INTO conversion_rate FROM users;
    SELECT COUNT(*) INTO webhook_errors FROM webhook_logs
        WHERE error_message IS NOT NULL AND processed_at >= NOW() - INTERVAL '24 hours';

    -- Calculate score (0-100)
    score := 0;

    -- DAU component (50 points)
    score := score + LEAST(50, ROUND((active_24h::DECIMAL / NULLIF(total_users, 1)) * 50));

    -- Conversion component (30 points)
    score := score + LEAST(30, ROUND(conversion_rate));

    -- System health component (20 points)
    IF webhook_errors = 0 THEN
        score := score + 20;
    ELSIF webhook_errors < 5 THEN
        score := score + 10;
    END IF;

    RETURN LEAST(100, score);
END;
$$ LANGUAGE plpgsql;

-- Function to get user's total referrals
CREATE OR REPLACE FUNCTION get_user_referral_count(user_telegram_id TEXT)
RETURNS INTEGER AS $$
DECLARE
    referral_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO referral_count
    FROM users
    WHERE referred_by = user_telegram_id;

    RETURN referral_count;
END;
$$ LANGUAGE plpgsql;

-- Function to log engagement event
CREATE OR REPLACE FUNCTION log_engagement(
    user_telegram_id TEXT,
    event_type TEXT,
    event_data JSONB DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO engagement_events (telegram_id, event_type, event_data)
    VALUES (user_telegram_id, event_type, event_data);

    -- Update last engagement
    UPDATE users
    SET last_engagement_at = NOW()
    WHERE telegram_id = user_telegram_id;
END;
$$ LANGUAGE plpgsql;

-- Function to identify at-risk users (inactive)
CREATE OR REPLACE FUNCTION get_at_risk_users(days_inactive INTEGER DEFAULT 7)
RETURNS TABLE (
    telegram_id TEXT,
    username TEXT,
    subscription_status TEXT,
    last_request_at TIMESTAMP WITH TIME ZONE,
    days_since_last_activity INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.telegram_id,
        u.username,
        u.subscription_status,
        u.last_request_at,
        EXTRACT(DAY FROM (NOW() - u.last_request_at))::INTEGER as days_since_last_activity
    FROM users u
    WHERE u.last_request_at < NOW() - (days_inactive || ' days')::INTERVAL
        AND u.subscription_status IN ('basic', 'pro') -- Focus on paying customers
    ORDER BY u.last_request_at ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VIEWS
-- ============================================

-- Marketing Dashboard View
CREATE OR REPLACE VIEW marketing_dashboard AS
SELECT
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM users WHERE created_at >= NOW() - INTERVAL '24 hours') as signups_24h,
    (SELECT COUNT(*) FROM users WHERE created_at >= NOW() - INTERVAL '7 days') as signups_7d,
    (SELECT COUNT(*) FROM users WHERE referred_by IS NOT NULL) as referred_users,
    (SELECT COUNT(*) FROM users WHERE bonus_requests > 0) as users_with_bonus,
    (SELECT SUM(bonus_requests) FROM users) as total_bonus_requests_granted,
    (SELECT AVG(get_user_referral_count(telegram_id)) FROM users) as avg_referrals_per_user,
    (SELECT COUNT(*) FROM feedback) as total_feedback,
    (SELECT AVG(rating) FROM feedback) as avg_rating;

-- Premium Users Analytics
CREATE OR REPLACE VIEW premium_users_analytics AS
SELECT
    u.telegram_id,
    u.username,
    u.subscription_status,
    u.usage_count,
    u.created_at,
    u.last_request_at,
    EXTRACT(DAY FROM (NOW() - u.created_at))::INTEGER as days_as_customer,
    (SELECT SUM(amount) FROM invoices WHERE telegram_id = u.telegram_id AND status = 'paid') as lifetime_value,
    (SELECT COUNT(*) FROM custom_training_data WHERE telegram_id = u.telegram_id) as custom_docs_uploaded
FROM users u
WHERE u.subscription_status IN ('basic', 'pro')
ORDER BY lifetime_value DESC NULLS LAST;

-- Referral Leaderboard
CREATE OR REPLACE VIEW referral_leaderboard AS
SELECT
    u.telegram_id,
    u.username,
    u.subscription_status,
    get_user_referral_count(u.telegram_id) as total_referrals,
    u.bonus_requests as bonus_balance
FROM users u
WHERE get_user_referral_count(u.telegram_id) > 0
ORDER BY total_referrals DESC
LIMIT 50;

-- System Health Overview
CREATE OR REPLACE VIEW system_health_overview AS
SELECT
    dr.report_date,
    dr.health_score,
    dr.status,
    dr.total_users,
    dr.active_24h,
    ROUND((dr.active_24h::DECIMAL / NULLIF(dr.total_users, 0) * 100), 2) as dau_rate,
    dr.current_mrr,
    dr.conversion_rate,
    dr.webhook_errors
FROM daily_reports dr
ORDER BY dr.report_date DESC
LIMIT 30;

-- ============================================
-- SAMPLE QUERIES
-- ============================================

-- Get today's health score
/*
SELECT calculate_health_score();
*/

-- Get at-risk users (inactive for 7+ days)
/*
SELECT * FROM get_at_risk_users(7);
*/

-- Get referral stats for specific user
/*
SELECT get_user_referral_count('YOUR_TELEGRAM_ID');
*/

-- Marketing dashboard
/*
SELECT * FROM marketing_dashboard;
*/

-- Top referrers
/*
SELECT * FROM referral_leaderboard;
*/

-- Recent feedback
/*
SELECT * FROM feedback ORDER BY created_at DESC LIMIT 20;
*/

-- System health trend
/*
SELECT * FROM system_health_overview;
*/

-- Premium users by LTV
/*
SELECT * FROM premium_users_analytics ORDER BY lifetime_value DESC LIMIT 20;
*/

-- ============================================
-- VERIFICATION
-- ============================================

-- Check all new tables created
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
    AND table_name IN (
        'daily_reports', 'audit_logs', 'gdpr_requests',
        'custom_training_data', 'user_analytics_cache',
        'referrals', 'feedback', 'engagement_events'
    )
ORDER BY table_name;

-- Check new columns added to users
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'users'
    AND column_name IN ('bonus_requests', 'referred_by', 'referral_code', 'onboarding_completed', 'last_engagement_at')
ORDER BY column_name;

-- Check views created
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
    AND (table_name LIKE '%marketing%' OR table_name LIKE '%premium%' OR table_name LIKE '%health%' OR table_name LIKE '%referral%')
ORDER BY table_name;

-- Sample data counts
SELECT 'Daily Reports' as table_name, COUNT(*) FROM daily_reports
UNION ALL
SELECT 'Audit Logs', COUNT(*) FROM audit_logs
UNION ALL
SELECT 'GDPR Requests', COUNT(*) FROM gdpr_requests
UNION ALL
SELECT 'Custom Training Data', COUNT(*) FROM custom_training_data
UNION ALL
SELECT 'Referrals', COUNT(*) FROM referrals
UNION ALL
SELECT 'Feedback', COUNT(*) FROM feedback
UNION ALL
SELECT 'Engagement Events', COUNT(*) FROM engagement_events;
