"""
Database Configuration
MIS686 Term Project
"""

# AWS RDS Database Configuration
DB_CONFIG = {
    'host': 'soc-db-instance.clg6uiiq0hr9.us-east-1.rds.amazonaws.com',
    'port': 3306,
    'database': 'soc_db',
    'user': 'admin',
    'password': 'syntaxsoldiers3'
}

# For security, consider using environment variables instead:
# import os
# DB_CONFIG = {
#     'host': os.getenv('DB_HOST'),
#     'port': int(os.getenv('DB_PORT', 3306)),
#     'database': os.getenv('DB_NAME'),
#     'user': os.getenv('DB_USER'),
#     'password': os.getenv('DB_PASSWORD')
# }
