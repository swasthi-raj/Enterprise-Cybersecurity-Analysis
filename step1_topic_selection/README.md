# Step 1: Topic/Domain Selection

## Deliverables
- [ ] Detailed explanation of the selected topic
- [ ] List of business rules for the chosen domain
- [ ] Use cases identifying possible industries or areas

## Topic Selection

**Domain:** Enterprise Cybersecurity Incident & Threat Intelligence

### Description
This database system manages cybersecurity incidents, threat intelligence, vulnerabilities, and security events within an enterprise environment. It tracks security incidents from detection through resolution, manages threat intelligence data, monitors vulnerabilities, and maintains security event logs. The system supports security operations centers (SOC), incident response teams, and threat intelligence analysts in protecting organizational assets.

### Business Rules
1. Each security incident must be assigned to at least one security analyst
2. Incidents must have a severity level (Critical, High, Medium, Low) and status (Open, In Progress, Resolved, Closed)
3. Threat intelligence indicators must be categorized by type (IP address, domain, file hash, URL, etc.)
4. All vulnerabilities must be linked to specific assets and assigned a CVSS score
5. Security events must be timestamped and linked to source systems
6. Incident resolution must be documented with remediation steps
7. Threat intelligence sources must be tracked for credibility scoring
8. User access to sensitive incident data requires role-based permissions
9. Incidents may be related to multiple vulnerabilities and threat indicators
10. All changes to critical incidents must be logged in an audit trail

### Use Cases
1. **Incident Management:** Security analysts track and manage cybersecurity incidents from detection through resolution
2. **Threat Intelligence Correlation:** Correlate threat indicators (IPs, domains, hashes) with active incidents
3. **Vulnerability Tracking:** Monitor and prioritize vulnerabilities across enterprise assets
4. **Security Event Analysis:** Analyze security events and logs to identify patterns and anomalies
5. **Compliance Reporting:** Generate reports for compliance requirements (SOC 2, ISO 27001, etc.)
6. **Threat Hunting:** Proactively search for indicators of compromise using threat intelligence
7. **Incident Response Coordination:** Coordinate response activities across teams and track progress
8. **Risk Assessment:** Assess risk based on vulnerability severity and threat intelligence

### Industries/Applications
- Financial Services (Banking, Insurance)
- Healthcare Organizations (HIPAA compliance)
- Government Agencies (National security)
- Technology Companies (Protecting IP and customer data)
- Retail & E-commerce (PCI-DSS compliance)
- Critical Infrastructure (Energy, Utilities)
- Managed Security Service Providers (MSSPs)
- Enterprise Security Operations Centers (SOC)

---
**Group Members:**
- Member 1: [Name]
- Member 2: [Name]
- Member 3: [Name]
- Member 4: [Name]
