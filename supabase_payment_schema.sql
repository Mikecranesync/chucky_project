-- ============================================
-- Payment & Billing Database Schema
-- For Chucky Monetization - Recommendation #2
-- Created: 2025-11-03
-- ============================================

-- ============================================
-- 1. UPDATE EXISTING USERS TABLE
-- Add payment-related fields to users table
-- ============================================

ALTER TABLE users
ADD COLUMN IF NOT EXISTS stripe_customer_id TEXT,
ADD COLUMN IF NOT EXISTS stripe_subscription_id TEXT,
ADD COLUMN IF NOT EXISTS subscription_start_date TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS billing_email TEXT;

-- Add indexes for Stripe IDs
CREATE INDEX IF NOT EXISTS idx_users_stripe_customer ON users(stripe_customer_id);
CREATE INDEX IF NOT EXISTS idx_users_stripe_subscription ON users(stripe_subscription_id);

-- ============================================
-- 2. PAYMENT SESSIONS TABLE
-- Track Stripe checkout sessions
-- ============================================

CREATE TABLE payment_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    session_id TEXT UNIQUE NOT NULL,
    telegram_id TEXT NOT NULL REFERENCES users(telegram_id) ON DELETE CASCADE,
    plan_type TEXT NOT NULL CHECK (plan_type IN ('free', 'basic', 'pro', 'pay_per_use')),
    amount DECIMAL(10, 2) NOT NULL,
    currency TEXT DEFAULT 'usd',
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'expired', 'cancelled')),
    checkout_url TEXT,
    payment_intent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() + INTERVAL '24 hours'
);

-- Indexes for payment session queries
CREATE INDEX idx_payment_sessions_telegram_id ON payment_sessions(telegram_id);
CREATE INDEX idx_payment_sessions_session_id ON payment_sessions(session_id);
CREATE INDEX idx_payment_sessions_status ON payment_sessions(status);
CREATE INDEX idx_payment_sessions_created ON payment_sessions(created_at DESC);

-- ============================================
-- 3. INVOICES TABLE
-- Store invoice records for payments
-- ============================================

CREATE TABLE invoices (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    invoice_number TEXT UNIQUE NOT NULL,
    telegram_id TEXT NOT NULL REFERENCES users(telegram_id) ON DELETE CASCADE,
    session_id TEXT REFERENCES payment_sessions(session_id),
    amount DECIMAL(10, 2) NOT NULL,
    currency TEXT DEFAULT 'usd',
    plan_type TEXT NOT NULL,
    payment_intent TEXT,
    status TEXT DEFAULT 'paid' CHECK (status IN ('draft', 'paid', 'void', 'uncollectible')),
    invoice_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    due_date TIMESTAMP WITH TIME ZONE,
    paid_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    pdf_url TEXT,
    stripe_invoice_id TEXT,
    notes TEXT
);

-- Auto-generate invoice number
CREATE OR REPLACE FUNCTION generate_invoice_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.invoice_number IS NULL THEN
        NEW.invoice_number := 'INV-' ||
            TO_CHAR(NEW.invoice_date, 'YYYYMMDD') || '-' ||
            LPAD(NEXTVAL('invoice_number_seq')::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE SEQUENCE IF NOT EXISTS invoice_number_seq START 1;

CREATE TRIGGER set_invoice_number
    BEFORE INSERT ON invoices
    FOR EACH ROW
    EXECUTE FUNCTION generate_invoice_number();

-- Indexes for invoice queries
CREATE INDEX idx_invoices_telegram_id ON invoices(telegram_id);
CREATE INDEX idx_invoices_invoice_number ON invoices(invoice_number);
CREATE INDEX idx_invoices_date ON invoices(invoice_date DESC);
CREATE INDEX idx_invoices_status ON invoices(status);

-- ============================================
-- 4. WEBHOOK LOGS TABLE
-- Log all Stripe webhook events for debugging
-- ============================================

CREATE TABLE webhook_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    event_id TEXT UNIQUE NOT NULL,
    event_type TEXT NOT NULL,
    telegram_id TEXT,
    session_id TEXT,
    processed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    payload JSONB,
    error_message TEXT
);

-- Indexes for webhook logs
CREATE INDEX idx_webhook_logs_event_id ON webhook_logs(event_id);
CREATE INDEX idx_webhook_logs_event_type ON webhook_logs(event_type);
CREATE INDEX idx_webhook_logs_processed ON webhook_logs(processed_at DESC);

-- ============================================
-- 5. USAGE TRACKING TABLE (for pay-per-use)
-- Track individual API usage for billing
-- ============================================

CREATE TABLE usage_tracking (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    telegram_id TEXT NOT NULL REFERENCES users(telegram_id) ON DELETE CASCADE,
    action_type TEXT NOT NULL CHECK (action_type IN ('image_analysis', 'pdf_generation', 'api_query', 'other')),
    cost DECIMAL(10, 4) DEFAULT 0.00,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB
);

-- Indexes for usage tracking
CREATE INDEX idx_usage_tracking_telegram_id ON usage_tracking(telegram_id);
CREATE INDEX idx_usage_tracking_timestamp ON usage_tracking(timestamp DESC);
CREATE INDEX idx_usage_tracking_action_type ON usage_tracking(action_type);

-- ============================================
-- 6. SAMPLE DATA (Optional - for testing)
-- ============================================

-- Sample payment session
INSERT INTO payment_sessions (session_id, telegram_id, plan_type, amount, status)
VALUES ('cs_test_123456', '123456789', 'basic', 4.99, 'pending');

-- Sample invoice
INSERT INTO invoices (telegram_id, session_id, amount, plan_type, status, invoice_date)
VALUES ('123456789', 'cs_test_123456', 4.99, 'basic', 'paid', NOW());

-- Sample usage tracking
INSERT INTO usage_tracking (telegram_id, action_type, cost)
VALUES ('123456789', 'pdf_generation', 0.10);

-- ============================================
-- 7. USEFUL QUERIES
-- ============================================

-- Get all payments for a user
/*
SELECT
    p.session_id,
    p.plan_type,
    p.amount,
    p.status,
    p.created_at,
    i.invoice_number
FROM payment_sessions p
LEFT JOIN invoices i ON p.session_id = i.session_id
WHERE p.telegram_id = 'YOUR_TELEGRAM_ID'
ORDER BY p.created_at DESC;
*/

-- Get revenue summary by plan
/*
SELECT
    plan_type,
    COUNT(*) as payment_count,
    SUM(amount) as total_revenue,
    AVG(amount) as avg_payment
FROM payment_sessions
WHERE status = 'completed'
GROUP BY plan_type
ORDER BY total_revenue DESC;
*/

-- Get monthly recurring revenue (MRR)
/*
SELECT
    DATE_TRUNC('month', subscription_start_date) as month,
    subscription_status,
    COUNT(*) as active_subscriptions,
    SUM(CASE
        WHEN subscription_status = 'basic' THEN 4.99
        WHEN subscription_status = 'pro' THEN 19.99
        ELSE 0
    END) as mrr
FROM users
WHERE subscription_status IN ('basic', 'pro')
    AND subscription_start_date IS NOT NULL
GROUP BY month, subscription_status
ORDER BY month DESC;
*/

-- Find users with expired payment sessions
/*
SELECT
    u.telegram_id,
    u.username,
    p.plan_type,
    p.amount,
    p.created_at,
    p.expires_at
FROM payment_sessions p
JOIN users u ON p.telegram_id = u.telegram_id
WHERE p.status = 'pending'
    AND p.expires_at < NOW()
ORDER BY p.created_at DESC;
*/

-- Track usage costs per user
/*
SELECT
    u.telegram_id,
    u.username,
    u.subscription_status,
    COUNT(ut.id) as total_actions,
    SUM(ut.cost) as total_cost
FROM users u
LEFT JOIN usage_tracking ut ON u.telegram_id = ut.telegram_id
WHERE ut.timestamp >= NOW() - INTERVAL '30 days'
GROUP BY u.telegram_id, u.username, u.subscription_status
ORDER BY total_cost DESC;
*/

-- Recent webhook events
/*
SELECT
    event_type,
    telegram_id,
    processed_at,
    error_message
FROM webhook_logs
ORDER BY processed_at DESC
LIMIT 50;
*/

-- ============================================
-- 8. MAINTENANCE FUNCTIONS
-- ============================================

-- Function to expire old pending sessions
CREATE OR REPLACE FUNCTION expire_old_sessions()
RETURNS INTEGER AS $$
DECLARE
    expired_count INTEGER;
BEGIN
    UPDATE payment_sessions
    SET status = 'expired'
    WHERE status = 'pending'
        AND expires_at < NOW();

    GET DIAGNOSTICS expired_count = ROW_COUNT;
    RETURN expired_count;
END;
$$ LANGUAGE plpgsql;

-- Schedule this function to run daily
-- Example: SELECT cron.schedule('expire-sessions', '0 2 * * *', 'SELECT expire_old_sessions();');

-- Function to calculate user lifetime value (LTV)
CREATE OR REPLACE FUNCTION calculate_user_ltv(user_telegram_id TEXT)
RETURNS DECIMAL AS $$
DECLARE
    total_spent DECIMAL;
BEGIN
    SELECT COALESCE(SUM(amount), 0)
    INTO total_spent
    FROM invoices
    WHERE telegram_id = user_telegram_id
        AND status = 'paid';

    RETURN total_spent;
END;
$$ LANGUAGE plpgsql;

-- Example usage: SELECT calculate_user_ltv('123456789');

-- ============================================
-- 9. VIEWS FOR ANALYTICS
-- ============================================

-- Active subscriptions view
CREATE OR REPLACE VIEW active_subscriptions AS
SELECT
    u.telegram_id,
    u.username,
    u.subscription_status as plan,
    u.subscription_start_date,
    u.stripe_customer_id,
    u.stripe_subscription_id,
    CASE
        WHEN u.subscription_status = 'basic' THEN 4.99
        WHEN u.subscription_status = 'pro' THEN 19.99
        ELSE 0
    END as monthly_value
FROM users u
WHERE u.subscription_status IN ('basic', 'pro')
ORDER BY u.subscription_start_date DESC;

-- Revenue by month view
CREATE OR REPLACE VIEW revenue_by_month AS
SELECT
    DATE_TRUNC('month', invoice_date) as month,
    plan_type,
    COUNT(*) as invoice_count,
    SUM(amount) as revenue,
    AVG(amount) as avg_invoice
FROM invoices
WHERE status = 'paid'
GROUP BY month, plan_type
ORDER BY month DESC, revenue DESC;

-- User payment history view
CREATE OR REPLACE VIEW user_payment_history AS
SELECT
    u.telegram_id,
    u.username,
    i.invoice_number,
    i.amount,
    i.plan_type,
    i.invoice_date,
    i.status,
    p.session_id
FROM users u
LEFT JOIN invoices i ON u.telegram_id = i.telegram_id
LEFT JOIN payment_sessions p ON i.session_id = p.session_id
ORDER BY u.telegram_id, i.invoice_date DESC;

-- ============================================
-- 10. PERMISSIONS (Optional - if using RLS)
-- ============================================

-- Enable Row Level Security
-- ALTER TABLE payment_sessions ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE usage_tracking ENABLE ROW LEVEL SECURITY;

-- Users can only see their own data
-- CREATE POLICY "Users can view own payment sessions" ON payment_sessions
--     FOR SELECT USING (telegram_id = current_setting('app.current_user_telegram_id'));

-- CREATE POLICY "Users can view own invoices" ON invoices
--     FOR SELECT USING (telegram_id = current_setting('app.current_user_telegram_id'));

-- ============================================
-- VERIFICATION
-- ============================================

-- Check all tables created
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
    AND table_name IN ('payment_sessions', 'invoices', 'webhook_logs', 'usage_tracking')
ORDER BY table_name;

-- Check users table has new columns
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'users'
    AND column_name IN ('stripe_customer_id', 'stripe_subscription_id', 'subscription_start_date')
ORDER BY column_name;

-- Sample data check
SELECT 'Payment Sessions' as table_name, COUNT(*) as record_count FROM payment_sessions
UNION ALL
SELECT 'Invoices', COUNT(*) FROM invoices
UNION ALL
SELECT 'Webhook Logs', COUNT(*) FROM webhook_logs
UNION ALL
SELECT 'Usage Tracking', COUNT(*) FROM usage_tracking;
