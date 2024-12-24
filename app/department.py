from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app import models, schemas, database

router = APIRouter()

@router.post("/departments/", response_model=schemas.DepartmentRead, status_code=status.HTTP_201_CREATED)
def create_department(department: schemas.DepartmentCreate, db: Session = Depends(database.get_db)):
    db_department = models.Department(
        name=department.name, 
        created_at=department.created_at
        )
    
    db.add(db_department)
    db.commit()
    db.refresh(db_department)

    return schemas.DepartmentRead.from_orm(db_department)

@router.patch("/departments/{department_id}", response_model=schemas.DepartmentRead, status_code=status.HTTP_200_OK)
def update_department_details(department_update: schemas.DepartmentUpdate, department_id: int, db: Session = Depends(database.get_db)):
    department = db.query(models.Department).filter(models.Department.id == department_id).first()
    
    if department is None:  # Check if department exists
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Department not found")

    if department_update.name is not None:
        department.name = department_update.name
    if department_update.manager_id is not None:
        department.manager_id = department_update.manager_id
     
    db.commit()
    db.refresh(department)

    return schemas.DepartmentRead.from_orm(department)

@router.get("/departments/{department_id}", response_model=schemas.DepartmentRead, status_code=status.HTTP_200_OK)
def get_department_details(department_id: int, db: Session = Depends(database.get_db)):
    department = db.query(models.Department).filter(models.Department.id == department_id).first()
    
    if department is None:  # Check if department exists
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Department not found")

    return department

@router.get("/departments/", response_model=List[schemas.DepartmentRead], status_code=status.HTTP_200_OK)
def get_list_of_departments(db: Session = Depends(database.get_db)):
    departments = db.query(models.Department).all()

    return [schemas.DepartmentRead.from_orm(department) for department in departments]

@router.get("/department/{department_id}/employees", status_code=status.HTTP_200_OK)
def get_list_of_employees(department_id: int, db: Session = Depends(database.get_db)):
    employees = db.query(models.Employee).filter(models.Employee.department_id == department_id).all()
    
    return employees

@router.delete("/departments/{department_id}", response_model=schemas.DepartmentRead, status_code=status.HTTP_204_NO_CONTENT)
def delete_department(department_id: int, db: Session = Depends(database.get_db)):
    department = db.query(models.Department).filter(models.Department.id == department_id).first()
    
    if department is None:  # Check if department exists
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Department not found")

    db.delete(department)
    db.commit()

    return schemas.DepartmentRead.from_orm(department)