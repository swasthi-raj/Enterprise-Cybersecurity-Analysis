# MIS686 Term Project
## Enterprise Database Management - SDSU

A comprehensive end-to-end database management solution from conceptual design to deployment and analytics.

---

## 📋 Project Overview

This project demonstrates complete database lifecycle management including:
- Domain analysis and conceptual modeling
- ERD design with 10+ entities
- SQL implementation and deployment
- AWS RDS cloud deployment
- Analytics dashboard with Python

**Course:** MIS686 - Enterprise Database Management  
**Institution:** San Diego State University

---

## 🗂️ Project Structure

```
MIS686/
├── step1_topic_selection/          # Domain selection & business rules
│   └── README.md
├── step2_database_design/          # ERD & relational model
│   └── README.md
├── step3_implementation/           # SQL DDL/DML scripts
│   ├── ddl/                       # Table creation scripts
│   ├── dml/                       # Data insertion scripts
│   ├── data/                      # CSV/JSON dummy data
│   └── README.md
├── step4_deployment/              # AWS deployment & DB objects
│   ├── indexes.sql
│   ├── views.sql
│   ├── triggers.sql
│   ├── stored_procedures.sql
│   ├── user_management.sql
│   └── README.md
├── step5_analytics_dashboard/     # Python analytics & visualization
│   ├── dashboard.py
│   ├── config.py
│   ├── analytical_queries.sql
│   ├── charts/
│   └── README.md
├── docs/                          # Project documentation
│   └── PROJECT_OUTLINE.md
├── venv/                          # Python virtual environment
├── requirements.txt               # Python dependencies
└── README.md                      # This file
```

---

## 🚀 Quick Start

### 1. Setup Python Environment

**Activate Virtual Environment:**

Windows PowerShell (if execution policy allows):
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
.\venv\Scripts\Activate.ps1
```

Or use Command Prompt:
```cmd
.\venv\Scripts\activate.bat
```

Or run Python directly:
```powershell
.\venv\Scripts\python.exe dashboard.py
```

### 2. Install Dependencies

```powershell
pip install -r requirements.txt
```

### 3. Configure Database Connection

Edit `step5_analytics_dashboard/config.py` with your AWS RDS credentials:
```python
DB_CONFIG = {
    'host': 'your-rds-endpoint.amazonaws.com',
    'database': 'your_database_name',
    'user': 'your_username',
    'password': 'your_password'
}
```

---

## 📊 Project Steps

### ✅ Step 1: Topic/Domain Selection
- Select business domain
- Define business rules
- Identify use cases
- **Location:** `step1_topic_selection/`

### ✅ Step 2: Database Design
- Create ERD (minimum 10 entities)
- Include supertypes/subtypes
- Transform to relational model
- **Location:** `step2_database_design/`

### ✅ Step 3: Implementation
- Write DDL statements
- Generate dummy data
- Populate database
- **Location:** `step3_implementation/`

### ✅ Step 4: Deployment
- Deploy on AWS RDS
- Create user roles (Admin, Data Entry, Read-Only)
- Implement indexes, views, triggers, stored procedures
- **Location:** `step4_deployment/`

### ✅ Step 5: Analytics Dashboard
- Develop 8+ analytical questions
- Create Python-SQL dashboard
- Visualize insights with charts
- **Location:** `step5_analytics_dashboard/`

---

## 🛠️ Technologies Used

- **Database:** MySQL/PostgreSQL on AWS RDS
- **Cloud Platform:** Amazon Web Services (RDS)
- **Languages:** SQL, Python
- **Python Libraries:**
  - `mysql-connector-python` or `psycopg2` - Database connectivity
  - `pandas` - Data manipulation
  - `matplotlib` - Data visualization
  - `seaborn` - Statistical visualizations
  - `plotly` - Interactive charts (optional)

---

## 📝 Final Deliverables

- [ ] Complete ERD and Relational Models
- [ ] All SQL code (DDL, DML, views, triggers, stored procedures)
- [ ] Database deployment documentation
- [ ] Dashboard with analytical insights
- [ ] Final project report
- [ ] Group presentation

---

## 👥 Team Information

**Group Members:**
1. [Name - Role]
2. [Name - Role]
3. [Name - Role]
4. [Name - Role]

---

## 📚 Documentation

For detailed information on each step, refer to the README files in each directory:
- [Project Outline](docs/PROJECT_OUTLINE.md)
- [Step 1: Topic Selection](step1_topic_selection/README.md)
- [Step 2: Database Design](step2_database_design/README.md)
- [Step 3: Implementation](step3_implementation/README.md)
- [Step 4: Deployment](step4_deployment/README.md)
- [Step 5: Analytics](step5_analytics_dashboard/README.md)

---

## 🔧 Development Notes

### Database Connection
Update credentials in `step5_analytics_dashboard/config.py` before running dashboard.

### Running the Dashboard
```powershell
# Activate environment
.\venv\Scripts\Activate.ps1

# Run dashboard
python step5_analytics_dashboard/dashboard.py
```

### Adding Python Packages
```powershell
pip install package_name
pip freeze > requirements.txt
```

---

## ⚠️ Important Reminders

- All group members must participate in all stages
- Peer assessment affects individual grades
- Project should be resume-worthy
- Consider industry relevance when selecting topic
- Reference textbook Chapter 12 for DMV case study example

---

## 📞 Support

For questions or issues, please refer to:
- Course materials on CANVAS
- Textbook Chapter 12 (DMV Case Study)
- Instructor office hours

---

**Last Updated:** December 2025
