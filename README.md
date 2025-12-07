# Enterprise Cybersecurity Incident & Threat Intelligence Analysis
## Security Operations Center (SOC) Database System

A comprehensive database management solution for tracking and analyzing cybersecurity incidents, threats, and vulnerabilities in enterprise environments.

---

## 📋 Project Overview

This project implements a complete Security Operations Center (SOC) database system including:
- Incident tracking and management
- Threat intelligence monitoring
- Alert correlation and escalation
- Asset and vulnerability management
- Network traffic analysis
- User activity monitoring
- Interactive analytics dashboard

**Team:** Syntax Soldiers  
**Members:** Swasthika Rajendran, Moses Kanagaraj, Riya Gupta

---

## 🗂️ Project Structure

```
Enterprise-Cybersecurity-Analysis/
├── step1_topic_selection/          # Domain analysis & business requirements
│   └── README.md
├── step2_database_design/          # ERD & database schema design
│   └── README.md
├── step3_implementation/           # Database implementation
│   ├── ddl/
│   │   └── create_tables.sql      # 14 table definitions
│   ├── dml/
│   │   └── insert_data.sql        # Sample security data
│   └── README.md
├── step4_deployment/              # AWS RDS deployment
│   ├── indexes.sql                # Performance optimization
│   ├── views.sql                  # Security analytics views
│   ├── triggers.sql               # Automated incident tracking
│   ├── stored_procedures.sql      # Business logic
│   ├── user_management.sql        # Role-based access control
│   └── README.md
├── step5_analytics_dashboard/     # Python analytics dashboard
│   ├── 686.py                     # Main dashboard generator
│   ├── SOC_Analytics_Colab.ipynb  # Jupyter/Colab notebook
│   ├── MATPLOTLIB_DASHBOARD.html  # Generated dashboard
│   ├── analytical_queries.sql     # 8 analytical queries
│   ├── charts/                    # Generated visualizations
│   └── README.md
├── .venv/                         # Python virtual environment
├── requirements.txt               # Python dependencies
└── README.md
```

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/swasthi-raj/Enterprise-Cybersecurity-Analysis.git
cd Enterprise-Cybersecurity-Analysis
```

### 2. Setup Python Environment

**Windows PowerShell:**
```powershell
# Run Python directly from venv
.\.venv\Scripts\python.exe step5_analytics_dashboard\686.py
```

### 3. Install Dependencies

```powershell
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

### 4. Database Configuration

The system connects to AWS RDS MySQL database:
- **Host:** soc-db-instance.clg6uiiq0hr9.us-east-1.rds.amazonaws.com
- **Database:** soc_db
- **Tables:** 14 interconnected tables for security operations

---

## 📊 Database Schema

### Core Tables (14 Total)

1. **employees** - Organization personnel records
2. **departments** - Organizational units
3. **incidents** - Security incident tracking
4. **alerts** - Security alert monitoring
5. **assets** - IT asset inventory
6. **detection_rules** - SIEM detection logic
7. **incident_iocs** - Incident-IOC relationships
8. **iocs** - Indicators of Compromise
9. **network_logs** - Network traffic records
10. **threat_actors** - Known threat entities
11. **threat_intel** - Threat intelligence feeds
12. **users** - System user accounts
13. **asset_vulnerabilities** - Asset security weaknesses
14. **network_connections** - Network relationship mapping

---

## 📈 Analytics Dashboard

### 8 Key Analytical Questions

**Q1: Departmental Risk Density**
- Quadrant analysis of high-severity incidents per employee/asset
- Identifies high-risk departments requiring additional security measures

**Q2: Incident Response Timing**
- MTTD (Mean Time To Detect), MTTC (Mean Time To Contain), MTTR (Mean Time To Resolve)
- Performance metrics by severity level

**Q3: Threat Actor Mapping**
- Analysis of threat actors by motivation and sophistication
- Incident attribution and attack pattern recognition

**Q4: Network Traffic Analysis**
- Traffic volume distribution by source category
- Alert correlation with network activity

**Q5: Alert Escalation Rate**
- Conversion rate from alerts to incidents by severity
- False positive identification

**Q6: User Privilege Risk Analysis**
- Alert and incident rates by user privilege level
- Insider threat indicators

**Q7: IOC Confidence & Impact**
- Indicator of Compromise analysis by type
- Confidence scoring and incident correlation

**Q8: Temporal Alert Spike Detection**
- 24-hour cycle analysis for anomaly detection
- Time-based threat pattern identification

### Running the Dashboard

**Python Script:**
```powershell
cd step5_analytics_dashboard
..\​.venv\Scripts\python.exe 686.py
```

**Jupyter Notebook:**
- Open `SOC_Analytics_Colab.ipynb` in Jupyter or Google Colab
- Run all cells to generate inline visualizations
- Dashboard HTML automatically generated

---

## 🛠️ Technologies Used

- **Database:** MySQL 8.4.7 on AWS RDS
- **Cloud Platform:** Amazon Web Services (RDS)
- **Languages:** SQL, Python 3.13
- **Python Libraries:**
  - `pandas 2.3.3` - Data manipulation and analysis
  - `sqlalchemy 2.0.44` - Database connectivity
  - `pymysql 1.1.2` - MySQL driver
  - `matplotlib 3.10.7` - Static chart generation
  - `numpy 2.3.5` - Numerical computing
  - `mysql-connector-python 9.5.0` - Alternative MySQL connector

---

## 🔐 Security Features

### User Role Management
- **Admin:** Full database access and management
- **Data Entry:** Insert/update capabilities
- **Read-Only:** Query and view permissions only

### Database Objects
- **Indexes:** Optimized query performance on critical tables
- **Views:** Pre-built analytical queries for common use cases
- **Triggers:** Automated incident tracking and alert escalation
- **Stored Procedures:** Complex business logic encapsulation

---

## 📊 Visualizations

All charts generated at 300 DPI resolution:
- Scatter plots for risk quadrant analysis
- Bar charts for comparative metrics
- Line graphs for temporal patterns
- Pie charts for distribution analysis
- Multi-panel dashboards for comprehensive insights

**Output Formats:**
- PNG images (charts/)
- Interactive HTML dashboard (MATPLOTLIB_DASHBOARD.html)
- Jupyter notebook with inline visualizations

---

## 📝 Key Features

✅ **14 Interconnected Tables** - Comprehensive security data model  
✅ **AWS RDS Deployment** - Cloud-based scalable infrastructure  
✅ **Role-Based Access Control** - Secure multi-user environment  
✅ **8 Analytical Queries** - Deep security insights  
✅ **Automated Triggers** - Real-time incident tracking  
✅ **Performance Indexes** - Optimized query execution  
✅ **Python Dashboard** - Interactive data visualization  
✅ **Jupyter Notebook** - Portable analysis environment

---

## 👥 Team Information

**Team Name:** Syntax Soldiers

**Group Members:**
1. Swasthika Rajendran
2. Moses Kanagaraj
3. Riya Gupta

---

## 📚 Documentation

Detailed documentation available in each directory:
- [Step 1: Domain Selection](step1_topic_selection/README.md)
- [Step 2: Database Design](step2_database_design/README.md)
- [Step 3: Implementation](step3_implementation/README.md)
- [Step 4: AWS Deployment](step4_deployment/README.md)
- [Step 5: Analytics Dashboard](step5_analytics_dashboard/README.md)

---

## 🚀 Usage Examples

### Generate Dashboard
```powershell
# Navigate to dashboard directory
cd step5_analytics_dashboard

# Run dashboard generator
..\​.venv\Scripts\python.exe 686.py

# Output: MATPLOTLIB_DASHBOARD.html opens in browser
# Charts saved to: charts/*.png
```

### Run Jupyter Notebook
```bash
# Upload SOC_Analytics_Colab.ipynb to Google Colab
# Or run locally with Jupyter
jupyter notebook SOC_Analytics_Colab.ipynb
```

### Query Database Directly
```python
from sqlalchemy import create_engine
import pandas as pd

engine = create_engine('mysql+pymysql://admin:password@host/soc_db')
df = pd.read_sql("SELECT * FROM incidents WHERE severity='critical'", engine)
```

---

## 👥 Team

**Team Name:** Syntax Soldiers

**Members:**
- Swasthika Rajendran
- Moses Kanagaraj
- Riya Gupta

---

## 📄 License

This project is part of academic coursework for MIS686 Enterprise Database Management.

---

**Last Updated:** December 2025
