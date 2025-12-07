# Import Guide for Existing SQL Files

## 📂 Where to Place Your Files

### Step 3: Implementation Files

**DDL (CREATE TABLE) Scripts:**
```
c:\Users\swast\MIS686\step3_implementation\ddl\
```
Place files like:
- `create_tables.sql`
- `create_database.sql`
- Any schema creation scripts

**DML (INSERT) Scripts:**
```
c:\Users\swast\MIS686\step3_implementation\dml\
```
Place files like:
- `insert_data.sql`
- `populate_tables.sql`
- Any data insertion scripts

**Data Files (Optional):**
```
c:\Users\swast\MIS686\step3_implementation\data\
```
Place files like:
- `*.csv`
- `*.json`
- Any raw data files

### Step 4: Deployment Files

**All deployment scripts go here:**
```
c:\Users\swast\MIS686\step4_deployment\
```

Rename/organize as follows:
- `indexes.sql` - All index creation statements
- `views.sql` - All view definitions
- `triggers.sql` - All trigger definitions
- `stored_procedures.sql` - All stored procedure definitions
- `user_management.sql` - User creation and permission grants

---

## 🚀 Quick Import Methods

### Option 1: Manual Copy in VS Code
1. Open VS Code File Explorer (Ctrl+Shift+E)
2. Navigate to destination folder
3. Drag files from Windows Explorer
4. Drop into VS Code folder

### Option 2: Windows Explorer
1. Open `c:\Users\swast\MIS686\` in Windows Explorer
2. Navigate to appropriate subfolder
3. Copy/paste your files

### Option 3: PowerShell Commands

**Example: If your files are in `C:\Downloads\sql_files\`**

```powershell
# Copy DDL files
Copy-Item "C:\Downloads\sql_files\create_*.sql" -Destination "c:\Users\swast\MIS686\step3_implementation\ddl\"

# Copy DML files
Copy-Item "C:\Downloads\sql_files\insert_*.sql" -Destination "c:\Users\swast\MIS686\step3_implementation\dml\"

# Copy deployment files (adjust names as needed)
Copy-Item "C:\Downloads\sql_files\indexes.sql" -Destination "c:\Users\swast\MIS686\step4_deployment\"
Copy-Item "C:\Downloads\sql_files\views.sql" -Destination "c:\Users\swast\MIS686\step4_deployment\"
Copy-Item "C:\Downloads\sql_files\triggers.sql" -Destination "c:\Users\swast\MIS686\step4_deployment\"
Copy-Item "C:\Downloads\sql_files\stored_procedures.sql" -Destination "c:\Users\swast\MIS686\step4_deployment\"
Copy-Item "C:\Downloads\sql_files\users.sql" -Destination "c:\Users\swast\MIS686\step4_deployment\user_management.sql"
```

---

## ✅ After Importing

### Update Step 3 README
Edit `step3_implementation\README.md` and check off completed items:
- [x] DDL SQL statements (CREATE TABLE, ALTER TABLE, etc.)
- [x] Dummy/fake data generation
- [x] Data population scripts

### Update Step 4 README
Edit `step4_deployment\README.md` and document:
- AWS RDS endpoint and connection details
- List of indexes created
- List of views created
- List of triggers created
- List of stored procedures created
- User roles and permissions

### Update Database Config
Edit `step5_analytics_dashboard\config.py` with your AWS RDS credentials:
```python
DB_CONFIG = {
    'host': 'your-actual-rds-endpoint.amazonaws.com',
    'port': 3306,  # or 5432 for PostgreSQL
    'database': 'your_database_name',
    'user': 'your_username',
    'password': 'your_password'
}
```

---

## 🎯 Next Steps

1. **Import all SQL files** to appropriate directories
2. **Document your database schema** in `step2_database_design\README.md`
3. **Create/import your ERD** in `step2_database_design\` folder
4. **Update connection config** in `step5_analytics_dashboard\config.py`
5. **Develop analytical queries** for your dashboard (Step 5)

---

## 💡 Tips

- Keep original filenames or use descriptive names
- Add comments in SQL files if not already present
- Document any special setup requirements in README files
- Test database connection before running dashboard
- Consider creating a `.env` file for sensitive credentials (see `.env.example`)

---

## ❓ Need Help?

If you encounter issues:
1. Check file permissions
2. Verify file paths are correct
3. Ensure SQL syntax matches your database engine (MySQL/PostgreSQL)
4. Review README files in each step directory
