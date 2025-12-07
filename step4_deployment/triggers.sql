-- ============================================
-- Triggers
-- Project: MIS686 Term Project
-- ============================================

-- Example: Trigger to log updates
DELIMITER //
CREATE TRIGGER trg_log_customer_update
AFTER UPDATE ON customers
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, action, record_id, timestamp)
    VALUES ('customers', 'UPDATE', NEW.customer_id, NOW());
END//
DELIMITER ;

-- Add more triggers as needed
