from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import date

class EmployeeBase(BaseModel):
    first_name: str
    last_name: str
    job_title: Optional[str] = None
    hire_date: date
    is_manager: Optional[bool] = False
    department_id: Optional[int] = None

class EmployeeCreate(EmployeeBase):
    pass  # Inherits all fields for creating a new employee

class EmployeeUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    job_title: Optional[str] = None
    is_manager: Optional[bool] = None
    department_id: Optional[int] = None

class EmployeeRead(EmployeeBase):
    id: int
    email: str
    department: Optional["DepartmentRead"] = None  # Nested relationship

    class Config:
        orm_mode = True
        from_attributes = True 

class DepartmentBase(BaseModel):
    name: str
    created_at: date


class DepartmentCreate(DepartmentBase):
    pass  # Inherits all fields for creating a new department

class DepartmentUpdate(BaseModel):
    name: Optional[str] = None
    manager_id: Optional[int] = None

class DepartmentRead(DepartmentBase):
    id: int
    manager_id: Optional[int] = None
    created_at: Optional[date]

    class Config:
        orm_mode = True
        from_attributes = True 
