from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from . import models, schemas, database

router = APIRouter()

@router.post("/departments/", response_model=schemas.DepartmentRead, status_code=status.HTTP_201_CREATED)
def create_department(department: schemas.DepartmentCreate, db: Session = Depends(database.get_db)):
    # Create a new department instance from the provided data
    db_department = models.Department(
        name=department.name, 
        created_at=department.created_at
        )
    
    # Add the new department to the database session
    db.add(db_department)
    db.commit() # Commit the transaction to save changes
    db.refresh(db_department) # Refresh the instance to get the updated data

    return schemas.DepartmentRead.from_orm(db_department)  # Return the created department

@router.patch("/departments/{department_id}", response_model=schemas.DepartmentRead, status_code=status.HTTP_200_OK)
def update_department_details(department_update: schemas.DepartmentUpdate, department_id: int, db: Session = Depends(database.get_db)):
    # Retrieve the department by ID
    department = db.query(models.Department).filter(models.Department.id == department_id).first()
    
    if department is None:  # Check if department exists
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Department not found")

    # Update department fields if provided in the request
    if department_update.name is not None:
        department.name = department_update.name
    if department_update.manager_id is not None:
        department.manager_id = department_update.manager_id
     
    db.commit() # Commit the changes to the database
    db.refresh(department) # Refresh the instance to get the updated data

    return schemas.DepartmentRead.from_orm(department)  # Return the updated department

@router.get("/departments/{department_id}", response_model=schemas.DepartmentRead, status_code=status.HTTP_200_OK)
def get_department_details(department_id: int, db: Session = Depends(database.get_db)):
    # Retrieve the department by ID
    department = db.query(models.Department).filter(models.Department.id == department_id).first()
    
    if department is None:  # Check if department exists
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Department not found")

    return department # Return the found department

@router.get("/departments/", response_model=List[schemas.DepartmentRead], status_code=status.HTTP_200_OK)
def get_list_of_departments(db: Session = Depends(database.get_db)):
    # Retrieve all departments from the database
    departments = db.query(models.Department).all()

     # Return a list of departments converted to the response schema
    return [schemas.DepartmentRead.from_orm(department) for department in departments]

@router.get("/department/{department_id}/employees", status_code=status.HTTP_200_OK)
def get_list_of_employees(department_id: int, db: Session = Depends(database.get_db)):
    # Retrieve employees belonging to the specified department
    employees = db.query(models.Employee).filter(models.Employee.department_id == department_id).all()
    
    return employees  # Return the list of employees

@router.delete("/departments/{department_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_department(department_id: int, db: Session = Depends(database.get_db)):
    # Retrieve the department by ID
    department = db.query(models.Department).filter(models.Department.id == department_id).first()
    
    if department is None:  # Check if department exists
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Department not found")

    db.delete(department) # Delete the department from the session
    db.commit() # Commit the transaction to save changes
