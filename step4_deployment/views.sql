-- ============================================
-- Views
-- Project: MIS686 Term Project
-- ============================================

-- Example: View showing customer order summary
CREATE VIEW view_customer_orders AS
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.order_amount) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- Add more views as needed
