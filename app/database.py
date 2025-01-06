from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import pyodbc 

# Database credentials
username = "jaylonjones"
password = "Panthers27!"  
server = "employeesystemdatabaseforonboarding.database.windows.net"
database = "EmployeeSystemOnboardingDatabaseSQL"

# Correct Connection string for SQLAlchemy
connection_string = f"mssql+pyodbc://{username}:{password}@{server}:1433/{database}?driver=ODBC+Driver+18+for+SQL+Server&Encrypt=yes&TrustServerCertificate=no&Connection+Timeout=30"

# Test connection
try:
    with pyodbc.connect(connection_string) as conn:
        print("Connection successful!")
except Exception as e:
    print(f"Connection failed: {e}")

# Create the database engine
engine = create_engine(connection_string)

# Create a sessionmaker
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class for models
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()