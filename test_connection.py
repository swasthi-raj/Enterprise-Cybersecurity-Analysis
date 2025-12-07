"""Test AWS RDS Connection"""
import mysql.connector
from step5_analytics_dashboard.config import DB_CONFIG

try:
    # Connect to database
    conn = mysql.connector.connect(**DB_CONFIG)
    print("✓ Successfully connected to AWS RDS!\n")
    
    cursor = conn.cursor()
    
    # Get database info
    cursor.execute('SELECT DATABASE(), VERSION()')
    result = cursor.fetchone()
    print(f"Database: {result[0]}")
    print(f"MySQL Version: {result[1]}\n")
    
    # List all tables
    cursor.execute('SHOW TABLES')
    tables = cursor.fetchall()
    print(f"Total Tables: {len(tables)}\n")
    print("Tables in soc_db:")
    for table in tables:
        print(f"  - {table[0]}")
    
    cursor.close()
    conn.close()
    print("\n✓ Connection test successful!")
    
except mysql.connector.Error as err:
    print(f"✗ Error: {err}")
