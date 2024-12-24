from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# SQLite URL format: sqlite:///<relative_path_to_db>
DATABASE_URL = "mssql+pyodbc://jaylonjones:Panthers27!@employeesystem.database.windows.net/EmployeeSystemOnboardingDatabaseSQL?driver=ODBC+17+for+SQL+Server"



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