from sqlalchemy import Column, Integer, String, ForeignKey, Boolean, Text, TIMESTAMP, func
from sqlalchemy.orm import relationship, Mapped, mapped_column
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    is_admin = Column(Boolean, default=False)

    contacts = relationship("Contact", back_populates="owner")

class ContactType(Base):
    __tablename__ = "contact_types"

    id = Column(Integer, primary_key=True, index=True)
    type_name = Column(String(50), unique=True, nullable=False)

class Contact(Base):
    __tablename__ = "contacts"

    id = Column(Integer, primary_key=True, index=True)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    company_name = Column(String(200))
    phone = Column(String(20))
    type_id = Column(Integer, ForeignKey("contact_types.id", ondelete="RESTRICT"))
    owner_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))

    owner = relationship("User", back_populates="contacts")

class Interaction(Base):
    __tablename__ = "interactions"

    id = Column(Integer, primary_key=True, index=True)
    contact_id = Column(Integer, ForeignKey("contacts.id", ondelete="CASCADE"))
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    interaction_date = Column(TIMESTAMP, server_default=func.now())
    notes = Column(Text)

class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    contact_id = Column(Integer, ForeignKey("contacts.id", ondelete="CASCADE"))
    title = Column(String(200), nullable=False)
    due_date = Column(TIMESTAMP, nullable=False)
    status = Column(String(50), default="Новая")