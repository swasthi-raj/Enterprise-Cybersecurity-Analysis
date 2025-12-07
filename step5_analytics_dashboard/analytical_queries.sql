USE soc_db
#1.Which MITRE ATT&amp;CK tactics and techniques generate the most high-severity or critical alerts?
SELECT 
    dr.tactic,
    dr.technique,
    COUNT(*) AS alert_count
FROM alerts AS a
JOIN detection_rules AS dr 
    ON a.rule_id = dr.rule_id
WHERE a.severity IN ('high', 'critical')
GROUP BY dr.tactic, dr.technique
ORDER BY alert_count DESC;

#2. Which assets (servers, workstations, cloud hosts, network systems, mobile devices) generate the 
#highest number of alerts normalized by criticality?
SELECT 
    a.asset_id,
    a.hostname,
    a.asset_type,
    a.criticality,
    COUNT(al.alert_id) AS total_alerts,
    
    -- normalize alert count using criticality weight
    CASE 
        WHEN a.criticality = 'low' THEN COUNT(al.alert_id) * 1
        WHEN a.criticality = 'medium' THEN COUNT(al.alert_id) * 2
        WHEN a.criticality = 'high' THEN COUNT(al.alert_id) * 3
        WHEN a.criticality = 'critical' THEN COUNT(al.alert_id) * 4
    END AS normalized_alert_score

FROM assets a
LEFT JOIN network_logs nl 
    ON nl.asset_id = a.asset_id
LEFT JOIN alerts al 
    ON al.log_id = nl.log_id

GROUP BY 
    a.asset_id, a.hostname, a.asset_type, a.criticality

ORDER BY 
    normalized_alert_score DESC;

#3.Which detection rules have the highest false-positive rate 
#(resolved alerts vs. open/contained incidents)?
SELECT 
    dr.rule_id,
    dr.name AS detection_rule,
    dr.tactic,
    dr.technique,

    -- total alerts for this rule
    COUNT(a.alert_id) AS total_alerts,

    -- false positives
    SUM(a.status = 'false_positive') AS false_positives,

    -- real alerts (open, in_progress, contained, resolved)
    SUM(a.status IN ('open','in_progress','contained','resolved')) AS real_alerts,

    -- false positive rate
    ROUND(
        SUM(a.status = 'false_positive') / COUNT(a.alert_id), 
        3
    ) AS false_positive_rate

FROM detection_rules dr
LEFT JOIN alerts a 
    ON a.rule_id = dr.rule_id

GROUP BY 
    dr.rule_id, dr.name, dr.tactic, dr.technique

HAVING COUNT(a.alert_id) > 0   -- avoid divide-by-zero

ORDER BY 
    false_positive_rate DESC;
    
#4. Which departments have the most high-severity incidents per employee or per asset?
WITH high_inc AS (
    SELECT 
        i.incident_id,
        i.severity,
        e.dept_id
    FROM incidents i
    LEFT JOIN employees e 
        ON i.created_by = e.emp_id
    WHERE i.severity IN ('high', 'critical')
),

emp_counts AS (
    SELECT 
        dept_id,
        COUNT(*) AS num_employees
    FROM employees
    GROUP BY dept_id
),

asset_counts AS (
    SELECT 
        dept_id,
        COUNT(*) AS num_assets
    FROM assets
    GROUP BY dept_id
)

SELECT 
    d.dept_id,
    d.name AS department_name,

    -- total high/critical incidents
    COUNT(h.incident_id) AS high_severity_incidents,

    -- employees and assets
    ec.num_employees,
    ac.num_assets,

    -- normalized metrics
    ROUND(COUNT(h.incident_id) / ec.num_employees, 3) AS incidents_per_employee,
    ROUND(COUNT(h.incident_id) / ac.num_assets, 3) AS incidents_per_asset

FROM departments d
LEFT JOIN high_inc h 
    ON d.dept_id = h.dept_id
LEFT JOIN emp_counts ec 
    ON d.dept_id = ec.dept_id
LEFT JOIN asset_counts ac 
    ON d.dept_id = ac.dept_id

GROUP BY 
    d.dept_id, d.name, ec.num_employees, ac.num_assets

ORDER BY 
    incidents_per_employee DESC;
    
#5. How long does it take on average to detect, contain, and resolve incidents across severity levels? 
#(MTTD, MTTC, MTTR)
ALTER TABLE incidents 
ADD COLUMN detected_at DATETIME NULL AFTER opened_at,
ADD COLUMN contained_at DATETIME NULL AFTER detected_at;

SELECT 
    severity,

    -- MTTD: Mean Time To Detect (detected_at → opened_at)
    ROUND(AVG(TIMESTAMPDIFF(HOUR, detected_at, opened_at)), 2) AS mttd_hours,

    -- MTTC: Mean Time To Contain (detected_at → contained_at)
    ROUND(AVG(TIMESTAMPDIFF(HOUR, detected_at, contained_at)), 2) AS mttc_hours,

    -- MTTR: Mean Time To Resolve (opened_at → closed_at)
    ROUND(AVG(TIMESTAMPDIFF(HOUR, opened_at, closed_at)), 2) AS mttr_hours

FROM incidents
WHERE 
    detected_at IS NOT NULL
    AND opened_at IS NOT NULL
    AND contained_at IS NOT NULL
    AND closed_at IS NOT NULL
GROUP BY severity
ORDER BY FIELD(severity, 'low', 'medium', 'high', 'critical');

#Q6. Which threat actors (from threat intel mapping) are associated with the most incidents, 
#and what are their primary motivations and sophistication levels?
SELECT 
    ta.actor_id,
    ta.name AS threat_actor,
    ta.origin,
    ta.motivation,
    ta.sophistication,
    
    COUNT(DISTINCT ii.incident_id) AS incident_count

FROM threat_actors ta
LEFT JOIN incident_iocs ii 
    ON ta.actor_id = ii.actor_id
LEFT JOIN incidents i
    ON ii.incident_id = i.incident_id

GROUP BY 
    ta.actor_id, ta.name, ta.origin, ta.motivation, ta.sophistication

HAVING incident_count > 0   -- show only actors linked to incidents
ORDER BY incident_count DESC;

#Q7. Which IPs or hostnames appear most frequently across network logs and alerts, and does their 
#traffic pattern correlate with malicious activity (blocked vs. allowed, high bandwidth transfers)?

SELECT 
    nl.src_ip,
    a.hostname,
    COUNT(nl.log_id) AS log_count,

    -- Traffic pattern
    SUM(nl.bytes_sent) AS total_bytes_sent,
    SUM(nl.bytes_received) AS total_bytes_received,

    -- Allowed/Blocked stats
    SUM(CASE WHEN nl.action = 'allowed' THEN 1 ELSE 0 END) AS allowed_count,
    SUM(CASE WHEN nl.action = 'blocked' THEN 1 ELSE 0 END) AS blocked_count,

    -- Alert correlation
    COUNT(al.alert_id) AS related_alerts,
    SUM(CASE WHEN al.severity IN ('high','critical') THEN 1 ELSE 0 END) AS severe_alerts

FROM network_logs nl
LEFT JOIN alerts al ON nl.log_id = al.log_id
LEFT JOIN assets a ON nl.asset_id = a.asset_id

GROUP BY nl.src_ip, a.hostname
ORDER BY log_count DESC;

#8. What is the lifecycle of alerts → incidents → threat intelligence? (How many alerts escalate into 
#real incidents, and which IOCs most frequently appear in active investigations?)

SELECT 
    a.severity,
    COUNT(a.alert_id) AS total_alerts,

    -- Alerts that match incidents in same severity + same hour window
    COUNT(i.incident_id) AS escalated_alerts,

    ROUND(
        COUNT(i.incident_id) / COUNT(a.alert_id) * 100, 2
    ) AS escalation_rate_percent
FROM alerts a
LEFT JOIN incidents i 
    ON a.severity = i.severity
    AND ABS(TIMESTAMPDIFF(MINUTE, a.detected_at, i.opened_at)) <= 60
GROUP BY a.severity
ORDER BY FIELD(a.severity, 'critical','high','medium','low');

SELECT 
    ioc.ioc_type,
    ioc.ioc_value,
    COUNT(ii.incident_id) AS incident_count
FROM incident_iocs ii
JOIN iocs ioc ON ii.ioc_id = ioc.ioc_id
JOIN incidents inc ON ii.incident_id = inc.incident_id
WHERE inc.status IN ('open','in_progress','contained')
GROUP BY ioc.ioc_type, ioc.ioc_value
ORDER BY incident_count DESC;

SELECT 
    ta.name AS threat_actor,
    ta.origin,
    ta.motivation,
    ta.sophistication,
    COUNT(ii.incident_id) AS incidents_linked
FROM incident_iocs ii
JOIN threat_actors ta ON ii.actor_id = ta.actor_id
GROUP BY ta.actor_id
ORDER BY incidents_linked DESC;

#9. Are privileged user accounts involved more often in critical alerts or high-severity incidents?

SELECT 
    ua.username,
    ua.is_privileged,
    e.full_name,
    d.name AS department,
    
    COUNT(a.alert_id) AS total_alerts,
    
    SUM(CASE WHEN a.severity IN ('high','critical') THEN 1 ELSE 0 END) AS severe_alerts,

    ROUND(
        SUM(CASE WHEN a.severity IN ('high','critical') THEN 1 ELSE 0 END) 
        / COUNT(a.alert_id) * 100, 2
    ) AS severe_alert_rate

FROM user_accounts ua
JOIN employees e ON ua.emp_id = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
JOIN assets ass ON d.dept_id = ass.dept_id
JOIN network_logs nl ON nl.asset_id = ass.asset_id
JOIN alerts a ON a.log_id = nl.log_id

GROUP BY ua.account_id
ORDER BY severe_alerts DESC;

SELECT 
    ua.username,
    ua.is_privileged,
    e.full_name,
    d.name AS department,

    COUNT(inc.incident_id) AS total_incidents,

    SUM(CASE WHEN inc.severity IN ('high','critical') THEN 1 ELSE 0 END) AS severe_incidents,

    ROUND(
        SUM(CASE WHEN inc.severity IN ('high','critical') THEN 1 ELSE 0 END) 
        / COUNT(inc.incident_id) * 100, 2
    ) AS severe_incident_rate

FROM user_accounts ua
JOIN employees e ON ua.emp_id = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
LEFT JOIN incidents inc ON inc.created_by = e.emp_id

GROUP BY ua.account_id
ORDER BY severe_incidents DESC;

#10. Which IOC types (IP, domain, URL, hash, email) have the highest confidence score and are seen 
#across the most incidents?
SELECT 
    ioc.ioc_type,
    
    COUNT(DISTINCT ii.incident_id) AS incident_count,
    COUNT(ii.ioc_id) AS total_occurrences,

    AVG(ioc.confidence) AS avg_confidence,
    MAX(ioc.confidence) AS max_confidence

FROM incident_iocs ii
JOIN iocs ioc ON ii.ioc_id = ioc.ioc_id

GROUP BY ioc.ioc_type
ORDER BY incident_count DESC, avg_confidence DESC;

#11. Which time periods (hour/day/week) have spikes in alerts or suspicious network traffic?

SELECT 
    HOUR(detected_at) AS alert_hour,
    COUNT(*) AS alert_count
FROM alerts
GROUP BY alert_hour
ORDER BY alert_hour;


SELECT 
    DATE(detected_at) AS alert_date,
    COUNT(*) AS alert_count
FROM alerts
GROUP BY alert_date
ORDER BY alert_date;



SELECT 
    YEARWEEK(detected_at) AS alert_week,
    COUNT(*) AS alert_count
FROM alerts
GROUP BY alert_week
ORDER BY alert_week;


SELECT 
    HOUR(event_time) AS event_hour,
    COUNT(*) AS blocked_count
FROM network_logs
WHERE action = 'blocked'
GROUP BY event_hour
ORDER BY event_hour;


SELECT
    HOUR(event_time) AS hour,
    SUM(bytes_sent + bytes_received) AS total_bytes
FROM network_logs
GROUP BY hour
ORDER BY total_bytes DESC;

#12. Which assets have repeated alerts tied to the same detection rule?

SELECT 
    ass.hostname,
    dr.name AS detection_rule,
    dr.severity,
    dr.tactic,
    dr.technique,
    
    COUNT(a.alert_id) AS alert_count

FROM alerts a
JOIN network_logs nl ON a.log_id = nl.log_id
JOIN assets ass ON nl.asset_id = ass.asset_id
JOIN detection_rules dr ON a.rule_id = dr.rule_id

GROUP BY ass.asset_id, dr.rule_id
HAVING COUNT(a.alert_id) > 1
ORDER BY alert_count DESC;

