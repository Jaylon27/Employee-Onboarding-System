from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app import models, schemas, database

router = APIRouter()

@router.post("/employees/", response_model=schemas.EmployeeRead, status_code=status.HTTP_201_CREATED)
def create_employee(employee: schemas.EmployeeCreate, db: Session = Depends(database.get_db)):
    db_employee = models.Employee(
        first_name=employee.first_name, 
        last_name=employee.last_name,
        position=employee.position,
        hire_date=employee.hire_date,
        is_manager=employee.is_manager,
        department_id=employee.department_id
        )
    
    db.add(db_employee)
    db.commit()
    db.refresh(db_employee)

    return schemas.EmployeeRead.from_orm(db_employee)

@router.get("/employees/{employee_id}", response_model=schemas.EmployeeRead, status_code=status.HTTP_200_OK)
def get_employee_details(employee_id: int, db: Session = Depends(database.get_db)):

    return db.query(models.Employee).filter(models.Employee.id == employee_id).first()

@router.patch("/employees/{employee_id}", response_model=schemas.EmployeeRead, status_code=status.HTTP_200_OK)
def update_employee_details(employee_update: schemas.EmployeeUpdate, employee_id: int, db: Session = Depends(database.get_db)):

    employee = db.query(models.Employee).filter(models.Employee.id == employee_id).first()

    if employee is None:  # Check if employee exists
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Employee not found")

    if employee_update.first_name is not None:
        employee.first_name = employee_update.first_name
    if employee_update.last_name is not None:
        employee.last_name = employee_update.last_name
    if employee_update.position is not None:
        employee.position = employee_update.position
    if employee_update.is_manager is not None:
        employee.is_manager = employee_update.is_manager
    if employee_update.department_id is not None:
        employee.department_id = employee_update.department_id
     
    db.commit()
    db.refresh(employee)

    return schemas.EmployeeRead.from_orm(employee)


@router.delete("/employees/{employee_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_employee(employee_id: int, db: Session = Depends(database.get_db)):

    employee = db.query(models.Employee).filter(models.Employee.id == employee_id).first()

    if employee is None:  # Check if employee exists
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Employee not found")

    db.delete(employee)
    db.commit()

