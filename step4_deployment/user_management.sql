#-- User Access Management (2+ user roles)
CREATE USER 'soc_readonly'@'%' IDENTIFIED BY 'Readonly@123';
GRANT SELECT ON soc_db.* TO 'soc_readonly'@'%';
CREATE USER 'soc_dataentry'@'%' IDENTIFIED BY 'Dataentry@123';
GRANT SELECT, INSERT, UPDATE, DELETE ON soc_db.* TO 'soc_dataentry'@'%';
SHOW GRANTS FOR 'soc_readonly'@'%';
SHOW GRANTS FOR 'soc_dataentry'@'%';
CREATE USER 'soc_admin'@'%' IDENTIFIED BY 'Admin@123';
GRANT ALL PRIVILEGES ON soc_db.* TO 'soc_admin'@'%';
FLUSH PRIVILEGES;

#--Creating Index
CREATE INDEX idx_logs_srcip ON network_logs(src_ip);
#--Creating View
CREATE VIEW v_high_severity_open_alerts AS
SELECT 
    a.alert_id,
    a.detected_at,
    a.severity,
    a.status,
    a.summary,
    r.name AS rule_name,
    r.tactic,
    r.technique
FROM alerts a
JOIN detection_rules r ON a.rule_id = r.rule_id
WHERE a.severity IN ('high', 'critical')
  AND a.status IN ('open', 'in_progress');
  #--Test
  SELECT * FROM v_high_severity_open_alerts;
  
  #--CREATE TRIGGER

CREATE TABLE IF NOT EXISTS alert_status_log (
    log_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    alert_id BIGINT UNSIGNED NOT NULL,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id)
);

DELIMITER $$

CREATE TRIGGER trg_alert_status_update
AFTER UPDATE ON alerts
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO alert_status_log (alert_id, old_status, new_status)
        VALUES (OLD.alert_id, OLD.status, NEW.status);
    END IF;
END$$

DELIMITER ;

#--Create Procedure
DELIMITER $$

CREATE PROCEDURE sp_close_incident(IN p_incident_id INT)
BEGIN
    UPDATE incidents
    SET status = 'resolved',
        closed_at = NOW()
    WHERE incident_id = p_incident_id;
END$$

DELIMITER ;


