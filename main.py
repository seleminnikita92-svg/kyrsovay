from typing import List, Any
from fastapi import FastAPI, Depends, HTTPException, status, Request
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text
from sqlalchemy.exc import IntegrityError
from jose import jwt, JWTError

import models
import schemas
import security
import database

app = FastAPI(title="Система управления контактами (Web Version)")

app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

async def get_current_user(
    token: str = Depends(oauth2_scheme), 
    db: AsyncSession = Depends(database.get_db)
) -> models.User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Не удалось проверить учетные данные",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, security.SECRET_KEY, algorithms=[security.ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    result = await db.execute(select(models.User).where(models.User.username == username))
    user = result.scalars().first()
    if user is None:
        raise credentials_exception
    return user

@app.get("/", response_class=HTMLResponse, tags=["Интерфейс"])
async def login_page(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.get("/dashboard", response_class=HTMLResponse, tags=["Интерфейс"])
async def dashboard_page(request: Request):
    return templates.TemplateResponse("dashboard.html", {"request": request})

@app.post("/register", response_model=schemas.Token, tags=["Авторизация"])
async def register(user_in: schemas.UserCreate, db: AsyncSession = Depends(database.get_db)):
    query = select(models.User).where(
        (models.User.username == user_in.username) | (models.User.email == user_in.email)
    )
    result = await db.execute(query)
    if result.scalars().first():
        raise HTTPException(status_code=400, detail="Такой логин или email уже занят! Придумай другой.")

    hashed = security.get_password_hash(user_in.password)
    new_user = models.User(
        username=user_in.username, 
        email=user_in.email, 
        hashed_password=hashed
    )
    db.add(new_user)
    await db.commit()

    token = security.create_access_token({"sub": new_user.username})
    return {"access_token": token, "token_type": "bearer"}

@app.post("/login", response_model=schemas.Token, tags=["Авторизация"])
async def login(user_in: schemas.UserLogin, db: AsyncSession = Depends(database.get_db)):
    result = await db.execute(select(models.User).where(models.User.username == user_in.username))
    user = result.scalars().first()

    if not user or not security.verify_password(user_in.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Неверный логин или пароль")

    token = security.create_access_token({"sub": user.username})
    return {"access_token": token, "token_type": "bearer"}

@app.get("/api/me", response_model=schemas.UserOut, tags=["Авторизация"])
async def get_me(current_user: models.User = Depends(get_current_user)):
    return current_user

@app.get("/api/contact-types", tags=["API Контакты"])
async def get_contact_types(
    db: AsyncSession = Depends(database.get_db), 
    current_user: models.User = Depends(get_current_user)
):
    result = await db.execute(select(models.ContactType))
    return result.scalars().all()

@app.get("/api/contacts", response_model=List[schemas.ContactOut], tags=["API Контакты"])
async def read_contacts(
    db: AsyncSession = Depends(database.get_db), 
    current_user: models.User = Depends(get_current_user)
):
    if current_user.is_admin:
        stmt = select(models.Contact)
    else:
        stmt = select(models.Contact).where(models.Contact.owner_id == current_user.id)

    result = await db.execute(stmt)
    return result.scalars().all()

@app.post("/api/contacts", response_model=schemas.ContactOut, tags=["API Контакты"])
async def add_contact(
    contact: schemas.ContactCreate, 
    db: AsyncSession = Depends(database.get_db), 
    current_user: models.User = Depends(get_current_user)
):
    new_contact = models.Contact(**contact.model_dump(), owner_id=current_user.id) 
    db.add(new_contact)
    await db.commit()
    await db.refresh(new_contact)
    return new_contact

@app.delete("/api/contacts/{contact_id}", tags=["API Контакты"])
async def delete_contact(
    contact_id: int, 
    db: AsyncSession = Depends(database.get_db), 
    current_user: models.User = Depends(get_current_user)
):
    stmt = select(models.Contact).where(models.Contact.id == contact_id)
    if not current_user.is_admin:
        stmt = stmt.where(models.Contact.owner_id == current_user.id)

    result = await db.execute(stmt)
    contact = result.scalars().first()

    if not contact:
        raise HTTPException(status_code=404, detail="Контакт не найден или нет доступа")

    try:
        await db.delete(contact)
        await db.commit()
        return {"message": "Контакт успешно удален"}
    except IntegrityError:
        await db.rollback()
        raise HTTPException(
            status_code=400, 
            detail="Невозможно удалить: есть связанные данные (например, активные задачи)"
        )

@app.get("/api/tasks", response_model=List[schemas.TaskOut], tags=["API Задачи"])
async def get_tasks(
    db: AsyncSession = Depends(database.get_db), 
    current_user: models.User = Depends(get_current_user)
):
    if current_user.is_admin:
        stmt = select(models.Task)
    else:
        stmt = select(models.Task).join(models.Contact).where(models.Contact.owner_id == current_user.id)

    result = await db.execute(stmt)
    return result.scalars().all()

@app.post("/api/tasks", response_model=schemas.TaskOut, tags=["API Задачи"])
async def create_task(
    task: schemas.TaskCreate, 
    db: AsyncSession = Depends(database.get_db), 
    current_user: models.User = Depends(get_current_user)
):
    stmt = select(models.Contact).where(models.Contact.id == task.contact_id)
    if not current_user.is_admin:
        stmt = stmt.where(models.Contact.owner_id == current_user.id)

    contact_res = await db.execute(stmt)
    if not contact_res.scalars().first():
        raise HTTPException(status_code=403, detail="Доступ запрещен или контакт не найден")

    task_data = task.model_dump()
    if task_data.get("due_date") and task_data["due_date"].tzinfo:
        task_data["due_date"] = task_data["due_date"].replace(tzinfo=None)

    new_task = models.Task(**task_data)
    db.add(new_task)
    await db.commit()
    await db.refresh(new_task)
    return new_task

@app.get("/api/analytics", tags=["Аналитика (Админ)"])
async def get_analytics(
    db: AsyncSession = Depends(database.get_db), 
    current_user: models.User = Depends(get_current_user)
):
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Только для администраторов")

    query = text("""
        WITH InteractionCounts AS (
            SELECT contact_id, COUNT(*) as total_calls 
            FROM interactions 
            GROUP BY contact_id
        )
        SELECT 
            c.first_name, 
            c.last_name, 
            t.title as task_title,
            t.due_date,
            ROW_NUMBER() OVER(PARTITION BY c.id ORDER BY t.due_date ASC) as task_priority,
            COALESCE(ic.total_calls, 0) as total_calls
        FROM contacts c
        JOIN tasks t ON c.id = t.contact_id
        LEFT JOIN InteractionCounts ic ON c.id = ic.contact_id
        WHERE t.status != 'Завершена'
    """)
    result = await db.execute(query)
    return result.mappings().all()

@app.get("/api/users", response_model=List[schemas.UserOut], tags=["Аналитика (Админ)"])
async def get_users(
    db: AsyncSession = Depends(database.get_db), 
    current_user: models.User = Depends(get_current_user)
):
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Только для администраторов")

    result = await db.execute(select(models.User))
    return result.scalars().all()

@app.post("/api/interactions", tags=["API Взаимодействия"])
async def add_interaction(contact_id: int, db: AsyncSession = Depends(database.get_db), current_user: models.User = Depends(get_current_user)):
    new_interaction = models.Interaction(contact_id=contact_id, user_id=current_user.id, notes="Быстрый звонок с сайта")
    db.add(new_interaction)
    await db.commit()
    return {"message": "Звонок добавлен"}

@app.delete("/api/users/{user_id}", tags=["Аналитика (Админ)"])
async def delete_user(
    user_id: int, 
    db: AsyncSession = Depends(database.get_db), 
    current_user: models.User = Depends(get_current_user)
):
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Только для администраторов")

    if current_user.id == user_id:
        raise HTTPException(status_code=400, detail="Нельзя удалить самого себя")

    result = await db.execute(select(models.User).where(models.User.id == user_id))
    user = result.scalars().first()

    if not user:
        raise HTTPException(status_code=404, detail="Пользователь не найден")

    await db.delete(user)
    await db.commit()
    return {"message": "Пользователь успешно удален"}