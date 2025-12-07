-- ============================================
-- Indexes
-- Project: MIS686 Term Project
-- ============================================

-- Example: Create index on frequently queried columns
CREATE INDEX idx_customer_email ON customers(email);

-- Add more indexes based on your analytical queries
-- Consider columns used in:
-- - WHERE clauses
-- - JOIN conditions
-- - ORDER BY clauses
