-- ============================================
-- Stored Procedures
-- Project: MIS686 Term Project
-- ============================================

-- Example: Procedure to process an order
DELIMITER //
CREATE PROCEDURE sp_process_order(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_order_id INT;
    
    -- Insert into orders table
    INSERT INTO orders (customer_id, order_date, status)
    VALUES (p_customer_id, NOW(), 'Processing');
    
    SET v_order_id = LAST_INSERT_ID();
    
    -- Insert into order_details
    INSERT INTO order_details (order_id, product_id, quantity)
    VALUES (v_order_id, p_product_id, p_quantity);
    
    -- Return order ID
    SELECT v_order_id AS new_order_id;
END//
DELIMITER ;

-- Add more stored procedures as needed
