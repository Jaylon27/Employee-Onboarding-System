from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from urllib.parse import quote

# Database credentials
username = "jaylonjones"
password = "Panthers27!"  # Replace with your actual password
encoded_password = quote(password)

# Updated DATABASE_URL for Azure SQL Database
DATABASE_URL = f"mssql+pyodbc://{username}:{encoded_password}@employeesystem.database.windows.net:1433/EmployeeSystemOnboardingDatabaseSQL?driver=ODBC+Driver+18+for+SQL+Server&Encrypt=yes&TrustServerCertificate=no&Connection+Timeout=30"

# Create the database engine
engine = create_engine(
    DATABASE_URL, connect_args={"check_same_thread": False}  # SQLite-specific
)

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