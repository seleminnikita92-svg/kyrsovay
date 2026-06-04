from pydantic import BaseModel, EmailStr, Field, ConfigDict
from typing import Optional
from datetime import datetime

class Token(BaseModel):
    access_token: str
    token_type: str

class UserBase(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    email: EmailStr

class UserCreate(UserBase):
    password: str = Field(..., min_length=6)

class UserLogin(BaseModel):
    username: str
    password: str

class UserOut(UserBase):
    id: int
    is_admin: bool

    model_config = ConfigDict(from_attributes=True)

class ContactBase(BaseModel):
    first_name: str = Field(..., max_length=100)
    last_name: str = Field(..., max_length=100)
    company_name: Optional[str] = None
    phone: Optional[str] = None
    type_id: int

class ContactCreate(ContactBase):
    pass

class ContactOut(ContactBase):
    id: int
    owner_id: int

    model_config = ConfigDict(from_attributes=True)

class TaskBase(BaseModel):
    contact_id: int
    title: str = Field(..., max_length=200)
    due_date: datetime
    status: str = "Новая"

class TaskCreate(TaskBase):
    pass

class TaskOut(TaskBase):
    id: int

    model_config = ConfigDict(from_attributes=True)