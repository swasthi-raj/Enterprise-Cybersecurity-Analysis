-- Use (or create) a database
CREATE DATABASE soc_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE soc_db;

-- ENUMs (inline in MySQL; no separate CREATE TYPE)
-- severity: 'low','medium','high','critical'
-- status_open: 'open','in_progress','contained','resolved','false_positive'

/* 1) Organizations / Departments / Employees */

CREATE TABLE organizations (
  org_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  sector VARCHAR(100),
  region VARCHAR(50),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (org_id),
  UNIQUE KEY uk_org_name (name)
) ENGINE=InnoDB;

CREATE TABLE departments (
  dept_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  org_id INT UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  PRIMARY KEY (dept_id),
  UNIQUE KEY uk_dept_org_name (org_id, name),
  CONSTRAINT fk_dept_org
    FOREIGN KEY (org_id) REFERENCES organizations(org_id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE employees (
  emp_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  dept_id INT UNSIGNED,
  full_name VARCHAR(200) NOT NULL,
  email VARCHAR(255) NOT NULL,
  role VARCHAR(100),
  hired_on DATE,
  PRIMARY KEY (emp_id),
  UNIQUE KEY uk_emp_email (email),
  CONSTRAINT fk_emp_dept
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
    ON DELETE SET NULL
) ENGINE=InnoDB;

/* 2) Assets & Accounts */

CREATE TABLE assets (
  asset_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  dept_id INT UNSIGNED,
  hostname VARCHAR(255) NOT NULL,
  asset_type ENUM('workstation','server','network','cloud','mobile') NOT NULL,
  criticality ENUM('low','medium','high','critical') NOT NULL DEFAULT 'medium',
  ip_address VARCHAR(45),           -- IPv4 or IPv6
  os VARCHAR(100),
  PRIMARY KEY (asset_id),
  UNIQUE KEY uk_asset_hostname (hostname),
  KEY idx_asset_dept (dept_id),
  CONSTRAINT fk_asset_dept
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
    ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE user_accounts (
  account_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  emp_id INT UNSIGNED,
  username VARCHAR(150) NOT NULL,
  email VARCHAR(255),
  is_privileged TINYINT(1) NOT NULL DEFAULT 0,
  last_login DATETIME,
  PRIMARY KEY (account_id),
  UNIQUE KEY uk_username (username),
  UNIQUE KEY uk_account_email (email),
  KEY idx_account_emp (emp_id),
  CONSTRAINT fk_account_emp
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
    ON DELETE SET NULL
) ENGINE=InnoDB;

/* 3) Telemetry → Alerts → Incidents */

CREATE TABLE network_logs (
  log_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  event_time DATETIME NOT NULL,
  src_ip VARCHAR(45),
  dest_ip VARCHAR(45),
  src_port INT,
  dest_port INT,
  protocol VARCHAR(20),
  action VARCHAR(20),                -- e.g., allowed/blocked
  bytes_sent BIGINT,
  bytes_received BIGINT,
  asset_id INT UNSIGNED,
  PRIMARY KEY (log_id),
  KEY idx_logs_time (event_time),
  KEY idx_logs_ips (src_ip, dest_ip),
  KEY idx_logs_asset (asset_id),
  CONSTRAINT fk_logs_asset
    FOREIGN KEY (asset_id) REFERENCES assets(asset_id)
    ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE detection_rules (
  rule_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(200) NOT NULL,
  description TEXT,
  tactic VARCHAR(100),               -- MITRE tactic
  technique VARCHAR(50),             -- MITRE technique id (e.g., T1059)
  severity ENUM('low','medium','high','critical') NOT NULL DEFAULT 'medium',
  is_enabled TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (rule_id),
  UNIQUE KEY uk_rule_name (name)
) ENGINE=InnoDB;

CREATE TABLE alerts (
  alert_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  detected_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  rule_id INT UNSIGNED NOT NULL,
  log_id BIGINT UNSIGNED,
  severity ENUM('low','medium','high','critical') NOT NULL,
  status ENUM('open','in_progress','contained','resolved','false_positive') NOT NULL DEFAULT 'open',
  summary TEXT,
  PRIMARY KEY (alert_id),
  KEY idx_alerts_rule_time (rule_id, detected_at),
  KEY idx_alerts_log (log_id),
  CONSTRAINT fk_alert_rule
    FOREIGN KEY (rule_id) REFERENCES detection_rules(rule_id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_alert_log
    FOREIGN KEY (log_id) REFERENCES network_logs(log_id)
    ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE incidents (
  incident_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  opened_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  closed_at DATETIME NULL,
  created_by INT UNSIGNED,
  severity ENUM('low','medium','high','critical') NOT NULL,
  status ENUM('open','in_progress','contained','resolved') NOT NULL DEFAULT 'open',
  title VARCHAR(255) NOT NULL,
  description TEXT,
  PRIMARY KEY (incident_id),
  KEY idx_inc_status (status),
  KEY idx_inc_severity (severity),
  CONSTRAINT fk_inc_creator
    FOREIGN KEY (created_by) REFERENCES employees(emp_id)
    ON DELETE SET NULL
) ENGINE=InnoDB;

/* 4) Threat Intel */

CREATE TABLE iocs (
  ioc_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  ioc_type ENUM('ip','domain','url','hash','email') NOT NULL,
  ioc_value VARCHAR(512) NOT NULL,
  first_seen DATE,
  last_seen DATE,
  confidence TINYINT UNSIGNED,  -- 0..100
  PRIMARY KEY (ioc_id),
  UNIQUE KEY uk_ioc (ioc_type, ioc_value)
) ENGINE=InnoDB;

CREATE TABLE threat_actors (
  actor_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(200) NOT NULL,
  origin VARCHAR(100),
  motivation VARCHAR(100),
  sophistication ENUM('Low','Moderate','High'),
  PRIMARY KEY (actor_id),
  UNIQUE KEY uk_actor_name (name)
) ENGINE=InnoDB;

/* 5) Join: incidents ↔ iocs (M:N) */

CREATE TABLE incident_iocs (
  incident_id INT UNSIGNED NOT NULL,
  ioc_id INT UNSIGNED NOT NULL,
  actor_id INT UNSIGNED NULL,
  first_observed DATETIME,
  PRIMARY KEY (incident_id, ioc_id),
  KEY idx_inc_ioc_actor (actor_id),
  CONSTRAINT fk_inc_iocs_inc
    FOREIGN KEY (incident_id) REFERENCES incidents(incident_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_inc_iocs_ioc
    FOREIGN KEY (ioc_id) REFERENCES iocs(ioc_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_inc_iocs_actor
    FOREIGN KEY (actor_id) REFERENCES threat_actors(actor_id)
    ON DELETE SET NULL
) ENGINE=InnoDB;

Select * From detection_rules;

INSERT INTO organizations (name, sector, region)
VALUES
('CyberShield Inc', 'Technology', 'NA'),
('DataSecure Labs', 'Finance', 'EU'),
('SafeNet Systems', 'Healthcare', 'APAC'),
('FortiCloud', 'Tech', 'NA'),
('SecureLine', 'Retail', 'LATAM'),
('NetGuard Solutions', 'Finance', 'EU'),
('ShieldOps', 'Tech', 'NA'),
('CyberArmor', 'Education', 'APAC'),
('TrustVault', 'Energy', 'NA'),
('ByteDefence', 'Tech', 'EU'),
('CloudFence', 'Finance', 'LATAM'),
('SentinelWorks', 'Healthcare', 'APAC'),
('CyberSphere', 'Education', 'NA'),
('HexaShield', 'Retail', 'EU'),
('DarkWatch', 'Tech', 'NA'),
('NovaDefend', 'Energy', 'APAC'),
('SafeLink', 'Finance', 'NA'),
('GuardianSys', 'Healthcare', 'EU'),
('AlphaSec', 'Tech', 'LATAM'),
('QuantumDefence', 'Finance', 'NA');

INSERT INTO departments (org_id, name)
VALUES
(1,'SOC'),(1,'IT'),(2,'Engineering'),(2,'HR'),
(3,'Finance'),(3,'Sales'),(4,'Compliance'),(4,'Operations'),
(5,'SOC'),(6,'IR'),(7,'IT'),(8,'Engineering'),
(9,'Security'),(10,'SOC'),(11,'HR'),(12,'Finance'),
(13,'Engineering'),(14,'IT'),(15,'Security'),(16,'SOC');


INSERT INTO employees (dept_id, full_name, email, role, hired_on)
VALUES
(1,'Alice Johnson','alice@cybershield.com','Analyst','2020-04-12'),
(2,'Bob Smith','bob@cybershield.com','Manager','2019-08-10'),
(3,'Carol Davis','carol@datasecure.com','SecEng','2021-05-22'),
(4,'David Brown','david@datasecure.com','Admin','2022-01-10'),
(5,'Eve Wilson','eve@safenet.com','Analyst','2021-03-02'),
(6,'Frank Harris','frank@forticloud.com','SecEng','2019-11-11'),
(7,'Grace Hall','grace@secureline.com','IR Lead','2020-09-07'),
(8,'Henry Allen','henry@netguard.com','Manager','2018-07-04'),
(9,'Ivy White','ivy@shieldops.com','Analyst','2021-10-16'),
(10,'Jack Lee','jack@cyberarmor.com','SecEng','2020-02-28'),
(11,'Kate Miller','kate@trustvault.com','Analyst','2019-06-09'),
(12,'Leo Green','leo@bytefence.com','Admin','2021-11-20'),
(13,'Mia Clark','mia@cloudfence.com','SecEng','2022-04-02'),
(14,'Nina Scott','nina@sentinel.com','Manager','2020-05-05'),
(15,'Owen Moore','owen@cybersphere.com','Analyst','2021-08-13'),
(16,'Paul King','paul@hexashield.com','IR Lead','2018-10-15'),
(17,'Quinn Adams','quinn@darkwatch.com','SecEng','2019-03-10'),
(18,'Rita Lopez','rita@novadefend.com','Analyst','2020-07-07'),
(19,'Sam Price','sam@safelink.com','Admin','2021-09-01'),
(20,'Tina Ross','tina@guardian.com','Manager','2022-02-02');

INSERT INTO assets (dept_id, hostname, asset_type, criticality, ip_address, os)
VALUES
(1,'host001.corp','server','critical','10.0.1.1','Linux'),
(2,'host002.corp','workstation','high','10.0.1.2','Windows'),
(3,'host003.corp','cloud','medium','10.0.1.3','Linux'),
(4,'host004.corp','network','high','10.0.1.4','NetworkOS'),
(5,'host005.corp','server','critical','10.0.1.5','Linux'),
(6,'host006.corp','mobile','low','10.0.1.6','Android'),
(7,'host007.corp','workstation','medium','10.0.1.7','Windows'),
(8,'host008.corp','server','high','10.0.1.8','Linux'),
(9,'host009.corp','cloud','medium','10.0.1.9','Linux'),
(10,'host010.corp','network','low','10.0.1.10','NetworkOS'),
(11,'host011.corp','server','critical','10.0.1.11','Linux'),
(12,'host012.corp','workstation','medium','10.0.1.12','Windows'),
(13,'host013.corp','mobile','low','10.0.1.13','Android'),
(14,'host014.corp','server','high','10.0.1.14','Linux'),
(15,'host015.corp','cloud','critical','10.0.1.15','Linux'),
(16,'host016.corp','network','high','10.0.1.16','NetworkOS'),
(17,'host017.corp','workstation','medium','10.0.1.17','Windows'),
(18,'host018.corp','server','low','10.0.1.18','Linux'),
(19,'host019.corp','cloud','high','10.0.1.19','Linux'),
(20,'host020.corp','server','critical','10.0.1.20','Linux');
 
 INSERT INTO detection_rules (name, description, tactic, technique, severity, is_enabled)
VALUES
('Rule_001','Suspicious PowerShell use','Execution','T1059','high',1),
('Rule_002','Brute-force login attempts','Credential Access','T1110','medium',1),
('Rule_003','Unusual outbound DNS queries','Command and Control','T1071','medium',1),
('Rule_004','RDP login from new IP','Lateral Movement','T1021','high',1),
('Rule_005','Malicious file hash detected','Execution','T1204','critical',1),
('Rule_006','Admin privilege escalation','Privilege Escalation','T1068','critical',1),
('Rule_007','Data exfiltration attempt','Exfiltration','T1041','high',1),
('Rule_008','Unusual user agent','Command and Control','T1071','medium',1),
('Rule_009','Suspicious process injection','Execution','T1055','high',1),
('Rule_010','Disabled antivirus service','Defense Evasion','T1562','medium',1),
('Rule_011','Unauthorized registry change','Persistence','T1112','medium',1),
('Rule_012','New scheduled task created','Persistence','T1053','low',1),
('Rule_013','Remote service creation','Lateral Movement','T1021','medium',1),
('Rule_014','SMB brute force','Credential Access','T1110','medium',1),
('Rule_015','Port scanning activity','Discovery','T1046','low',1),
('Rule_016','Unusual process chain','Execution','T1059','medium',1),
('Rule_017','File encryption process','Impact','T1486','critical',1),
('Rule_018','Suspicious network beacon','Command and Control','T1071','high',1),
('Rule_019','New admin account creation','Privilege Escalation','T1078','high',1),
('Rule_020','Unauthorized USB device','Collection','T1123','medium',1);

INSERT INTO user_accounts (emp_id, username, email, is_privileged, last_login)
VALUES
(1,'alice01','alice01@cybershield.com',1,'2025-11-17 08:45:00'),
(2,'bob02','bob02@cybershield.com',0,'2025-11-18 10:00:00'),
(3,'carol03','carol03@datasecure.com',0,'2025-11-18 11:20:00'),
(4,'david04','david04@datasecure.com',1,'2025-11-15 15:30:00'),
(5,'eve05','eve05@safenet.com',0,'2025-11-16 09:12:00'),
(6,'frank06','frank06@forticloud.com',0,'2025-11-17 12:22:00'),
(7,'grace07','grace07@secureline.com',1,'2025-11-18 08:40:00'),
(8,'henry08','henry08@netguard.com',0,'2025-11-16 10:45:00'),
(9,'ivy09','ivy09@shieldops.com',0,'2025-11-18 14:20:00'),
(10,'jack10','jack10@cyberarmor.com',1,'2025-11-17 16:00:00'),
(11,'kate11','kate11@trustvault.com',0,'2025-11-15 13:25:00'),
(12,'leo12','leo12@bytefence.com',1,'2025-11-18 07:35:00'),
(13,'mia13','mia13@cloudfence.com',0,'2025-11-17 09:10:00'),
(14,'nina14','nina14@sentinel.com',0,'2025-11-18 11:50:00'),
(15,'owen15','owen15@cybersphere.com',1,'2025-11-16 10:00:00'),
(16,'paul16','paul16@hexashield.com',0,'2025-11-18 13:45:00'),
(17,'quinn17','quinn17@darkwatch.com',1,'2025-11-17 08:30:00'),
(18,'rita18','rita18@novadefend.com',0,'2025-11-18 17:00:00'),
(19,'sam19','sam19@safelink.com',1,'2025-11-17 19:40:00'),
(20,'tina20','tina20@guardian.com',0,'2025-11-18 20:00:00');

INSERT INTO network_logs (event_time, src_ip, dest_ip, src_port, dest_port, protocol, action, bytes_sent, bytes_received, asset_id)
VALUES
('2025-11-18 10:00:00','172.16.0.11','10.0.1.1',54321,443,'TCP','allowed',12000,30000,1),
('2025-11-18 10:02:00','172.16.0.12','10.0.1.2',55321,80,'TCP','allowed',5000,8000,2),
('2025-11-18 10:05:00','172.16.0.13','10.0.1.3',56321,22,'TCP','blocked',120,0,3),
('2025-11-18 10:06:00','172.16.0.14','10.0.1.4',57321,3389,'TCP','blocked',350,0,4),
('2025-11-18 10:07:00','172.16.0.15','10.0.1.5',58321,443,'TCP','allowed',22000,34000,5),
('2025-11-18 10:09:00','172.16.0.16','10.0.1.6',59321,80,'TCP','allowed',45000,22000,6),
('2025-11-18 10:10:00','172.16.0.17','10.0.1.7',60321,22,'TCP','blocked',0,0,7),
('2025-11-18 10:11:00','172.16.0.18','10.0.1.8',61321,443,'TCP','allowed',21000,31000,8),
('2025-11-18 10:12:00','172.16.0.19','10.0.1.9',62321,80,'TCP','allowed',15000,24000,9),
('2025-11-18 10:14:00','172.16.0.20','10.0.1.10',63321,22,'TCP','blocked',0,0,10),
('2025-11-18 10:16:00','172.16.0.21','10.0.1.11',64321,443,'TCP','allowed',18000,22000,11),
('2025-11-18 10:17:00','172.16.0.22','10.0.1.12',65321,80,'TCP','allowed',6000,9000,12),
('2025-11-18 10:18:00','172.16.0.23','10.0.1.13',66321,22,'TCP','blocked',0,0,13),
('2025-11-18 10:19:00','172.16.0.24','10.0.1.14',67321,443,'TCP','allowed',16000,23000,14),
('2025-11-18 10:20:00','172.16.0.25','10.0.1.15',68321,80,'TCP','allowed',12000,20000,15),
('2025-11-18 10:21:00','172.16.0.26','10.0.1.16',69321,22,'TCP','blocked',0,0,16),
('2025-11-18 10:22:00','172.16.0.27','10.0.1.17',70321,443,'TCP','allowed',17000,28000,17),
('2025-11-18 10:23:00','172.16.0.28','10.0.1.18',71321,80,'TCP','allowed',19000,26000,18),
('2025-11-18 10:24:00','172.16.0.29','10.0.1.19',72321,22,'TCP','blocked',0,0,19),
('2025-11-18 10:25:00','172.16.0.30','10.0.1.20',73321,443,'TCP','allowed',21000,33000,20);


INSERT INTO alerts (detected_at, rule_id, log_id, severity, status, summary)
VALUES
('2025-11-18 11:00:00',1,1,'high','open','Suspicious PowerShell execution detected'),
('2025-11-18 11:05:00',2,2,'medium','resolved','Brute force login attempts detected'),
('2025-11-18 11:10:00',3,3,'medium','open','DNS anomaly observed'),
('2025-11-18 11:15:00',4,4,'high','contained','RDP login from unknown IP'),
('2025-11-18 11:20:00',5,5,'critical','open','Malware file hash matched'),
('2025-11-18 11:25:00',6,6,'critical','open','Privilege escalation alert'),
('2025-11-18 11:30:00',7,7,'high','resolved','Exfiltration behavior detected'),
('2025-11-18 11:35:00',8,8,'medium','open','Unusual user agent observed'),
('2025-11-18 11:40:00',9,9,'high','in_progress','Process injection activity'),
('2025-11-18 11:45:00',10,10,'medium','resolved','Antivirus service disabled'),
('2025-11-18 11:50:00',11,11,'medium','open','Unauthorized registry change'),
('2025-11-18 11:55:00',12,12,'low','open','New scheduled task created'),
('2025-11-18 12:00:00',13,13,'medium','contained','Remote service creation event'),
('2025-11-18 12:05:00',14,14,'medium','resolved','SMB brute force activity'),
('2025-11-18 12:10:00',15,15,'low','open','Port scan detected'),
('2025-11-18 12:15:00',16,16,'medium','open','Unusual process chain'),
('2025-11-18 12:20:00',17,17,'critical','open','Ransomware encryption process'),
('2025-11-18 12:25:00',18,18,'high','open','Network beacon pattern'),
('2025-11-18 12:30:00',19,19,'high','in_progress','Unauthorized admin account creation'),
('2025-11-18 12:35:00',20,20,'medium','resolved','USB device mounted');

INSERT INTO incidents (opened_at, closed_at, created_by, severity, status, title, description)
VALUES
('2025-11-18 12:00:00','2025-11-18 16:00:00',1,'high','resolved','PowerShell Incident','Investigated malicious PowerShell use'),
('2025-11-18 12:05:00','2025-11-18 15:30:00',2,'medium','resolved','Brute Force Attack','Multiple failed logins detected'),
('2025-11-18 12:10:00',NULL,3,'medium','open','DNS Anomaly','Investigating suspicious DNS queries'),
('2025-11-18 12:15:00',NULL,4,'high','in_progress','RDP Access','Unauthorized RDP connection attempt'),
('2025-11-18 12:20:00','2025-11-18 17:00:00',5,'critical','resolved','Malware Infection','Detected known malicious hash'),
('2025-11-18 12:25:00',NULL,6,'critical','open','Privilege Escalation','User escalated privileges unexpectedly'),
('2025-11-18 12:30:00','2025-11-18 18:00:00',7,'high','resolved','Data Exfiltration','Outbound data transfer spike'),
('2025-11-18 12:35:00',NULL,8,'medium','open','User Agent Alert','Suspicious browser string'),
('2025-11-18 12:40:00','2025-11-18 19:00:00',9,'high','resolved','Injection Detected','Process injection blocked'),
('2025-11-18 12:45:00',NULL,10,'medium','in_progress','Antivirus Disabled','Protection disabled manually'),
('2025-11-18 12:50:00',NULL,11,'medium','open','Registry Change','Registry key modified'),
('2025-11-18 12:55:00',NULL,12,'low','open','Scheduled Task','New task created'),
('2025-11-18 13:00:00',NULL,13,'medium','contained','Remote Service','Remote service creation observed'),
('2025-11-18 13:05:00','2025-11-18 19:30:00',14,'medium','resolved','SMB Brute Force','Excessive SMB authentication'),
('2025-11-18 13:10:00',NULL,15,'low','open','Port Scan','Multiple ports probed'),
('2025-11-18 13:15:00',NULL,16,'medium','open','Process Chain','Abnormal process execution'),
('2025-11-18 13:20:00','2025-11-18 21:00:00',17,'critical','resolved','Encryption Attack','Ransomware encrypted files'),
('2025-11-18 13:25:00',NULL,18,'high','open','Beacon Detected','C2 beaconing observed'),
('2025-11-18 13:30:00',NULL,19,'high','in_progress','Admin Account','Unauthorized admin creation'),
('2025-11-18 13:35:00',NULL,20,'medium','open','USB Use','Unauthorized USB usage');

INSERT INTO iocs (ioc_type, ioc_value, first_seen, last_seen, confidence)
VALUES
('ip','192.168.10.1','2025-09-15','2025-10-10',90),
('domain','evil-domain.com','2025-09-20','2025-10-12',85),
('url','http://malicious-site.com','2025-09-25','2025-10-13',80),
('hash','a1b2c3d4e5f6g7h8i9j0','2025-09-27','2025-10-14',95),
('email','phish@scam.com','2025-09-30','2025-10-15',75),
('ip','10.10.10.10','2025-09-28','2025-10-11',70),
('domain','compromise.net','2025-09-25','2025-10-16',80),
('url','http://dropper.exe','2025-09-26','2025-10-17',88),
('hash','abcd1234efgh5678ijkl','2025-09-21','2025-10-18',90),
('email','attack@badmail.com','2025-09-22','2025-10-19',85),
('ip','203.0.113.5','2025-09-23','2025-10-20',70),
('domain','infected-site.org','2025-09-24','2025-10-21',75),
('url','http://payload.exe','2025-09-26','2025-10-22',95),
('hash','ffff1111aaaa2222bbbb','2025-09-27','2025-10-23',80),
('email','spoof@fake.com','2025-09-28','2025-10-24',70),
('ip','198.51.100.3','2025-09-29','2025-10-25',85),
('domain','malnet.biz','2025-09-30','2025-10-26',90),
('url','http://ransom.com/key','2025-10-01','2025-10-27',92),
('hash','deadbeefcafef00d1234','2025-10-02','2025-10-28',88),
('email','target@evilcorp.com','2025-10-03','2025-10-29',95);

INSERT INTO threat_actors (name, origin, motivation, sophistication)
VALUES
('APT-001','RU','Espionage','High'),
('APT-002','CN','Financial','Moderate'),
('APT-003','IR','Disruption','High'),
('APT-004','KP','Financial','High'),
('APT-005','US','Unknown','Low'),
('APT-006','BR','Financial','Moderate'),
('APT-007','RU','Espionage','High'),
('APT-008','CN','Disruption','High'),
('APT-009','IR','Espionage','Moderate'),
('APT-010','KP','Financial','High'),
('APT-011','RU','Financial','Low'),
('APT-012','CN','Disruption','High'),
('APT-013','IR','Espionage','Moderate'),
('APT-014','KP','Financial','High'),
('APT-015','US','Unknown','Low'),
('APT-016','BR','Financial','Moderate'),
('APT-017','RU','Espionage','High'),
('APT-018','CN','Disruption','High'),
('APT-019','IR','Espionage','Moderate'),
('APT-020','KP','Financial','High');


INSERT INTO incident_iocs (incident_id, ioc_id, actor_id, first_observed)
VALUES
(1,1,1,'2025-11-18 12:00:00'),
(2,2,2,'2025-11-18 12:05:00'),
(3,3,3,'2025-11-18 12:10:00'),
(4,4,4,'2025-11-18 12:15:00'),
(5,5,5,'2025-11-18 12:20:00'),
(6,6,6,'2025-11-18 12:25:00'),
(7,7,7,'2025-11-18 12:30:00'),
(8,8,8,'2025-11-18 12:35:00'),
(9,9,9,'2025-11-18 12:40:00'),
(10,10,10,'2025-11-18 12:45:00'),
(11,11,11,'2025-11-18 12:50:00'),
(12,12,12,'2025-11-18 12:51:01');

SHOW TABLES;
SELECT * FROM employees LIMIT 5;


