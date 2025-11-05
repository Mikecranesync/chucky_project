-- ============================================
-- User Management & Authentication Schema
-- For Chucky Monetization Workflow
-- Created: 2025-11-03
-- ============================================

-- Create users table with subscription support
CREATE TABLE users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    telegram_id TEXT UNIQUE NOT NULL,
    username TEXT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    subscription_status TEXT DEFAULT 'free' CHECK (subscription_status IN ('free', 'basic', 'pro')),
    usage_count INTEGER DEFAULT 0,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for fast telegram_id lookups (most common query)
CREATE INDEX idx_users_telegram_id ON users(telegram_id);

-- Create index for subscription tier queries
CREATE INDEX idx_users_subscription ON users(subscription_status);

-- Create index for usage tracking and analytics
CREATE INDEX idx_users_last_login ON users(last_login DESC);

-- ============================================
-- Auto-update updated_at timestamp
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Sample Test Data (Optional)
-- ============================================

INSERT INTO users (telegram_id, username, first_name, subscription_status, usage_count)
VALUES
    ('123456789', 'test_user_free', 'John', 'free', 5),
    ('987654321', 'test_user_basic', 'Jane', 'basic', 25),
    ('555555555', 'test_user_pro', 'Pro', 'pro', 150);

-- ============================================
-- Verification Queries
-- ============================================

-- Check table structure
\d users

-- View all users
SELECT * FROM users ORDER BY created_at DESC;

-- Count users by subscription tier
SELECT
    subscription_status,
    COUNT(*) as user_count,
    AVG(usage_count) as avg_usage
FROM users
GROUP BY subscription_status;

-- Find users approaching limits (for quota alerts)
SELECT
    telegram_id,
    username,
    subscription_status,
    usage_count,
    CASE
        WHEN subscription_status = 'free' THEN 5
        WHEN subscription_status = 'basic' THEN 50
        ELSE 999999
    END as limit,
    CASE
        WHEN subscription_status = 'free' THEN 5 - usage_count
        WHEN subscription_status = 'basic' THEN 50 - usage_count
        ELSE 999999
    END as remaining
FROM users
WHERE
    (subscription_status = 'free' AND usage_count >= 4)
    OR (subscription_status = 'basic' AND usage_count >= 45)
ORDER BY remaining ASC;

-- ============================================
-- Useful Maintenance Queries
-- ============================================

-- Reset usage count for all users (monthly reset)
-- UPDATE users SET usage_count = 0;

-- Upgrade user to pro tier
-- UPDATE users SET subscription_status = 'pro' WHERE telegram_id = 'YOUR_ID';

-- Find inactive users (not logged in for 30 days)
-- SELECT * FROM users WHERE last_login < NOW() - INTERVAL '30 days';

-- Delete test users
-- DELETE FROM users WHERE telegram_id LIKE 'test_%';
