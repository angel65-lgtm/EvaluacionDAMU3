from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy import (
    create_engine,
    Column,
    Integer,
    String,
    TIMESTAMP,
    ForeignKey,
    DECIMAL,
)

from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from pydantic import BaseModel
import hashlib  # Para encriptar con MD5
import requests
from datetime import datetime
from fastapi.middleware.cors import CORSMiddleware

# Conexión a la base de datos
DATABASE_URL = "mysql+pymysql://root:1n2n3m4789@localhost/entregas_paquexpress"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

app = FastAPI()

# Configuración de CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "*"
    ],  # Puedes poner "*" para permitir todos los orígenes, o una lista específica
    allow_credentials=True,
    allow_methods=["*"], # Permite todos los métodos: GET, POST, PUT, DELETE
    allow_headers=["*"], # Permite todas las cabeceras
)


# Modelos SQLAlchemy
class User(Base):
    __tablename__ = "usuario"
    id_usuario = Column(Integer, primary_key=True, index=True)
    usr_nombre = Column(String(50), unique=True, nullable=False)
    usr_password = Column(String(255), nullable=False)


class Attendance(Base):
    __tablename__ = "attendance"
    attendance_id = Column(Integer, primary_key=True, index=True)
    id_usuario = Column(Integer, ForeignKey("usuario.id_usuario"))
    latitude = Column(
        DECIMAL(10, 8), nullable=False
    ) # DECIMAL con precisión 10 y 8 decimales
    longitude = Column(
        DECIMAL(11, 8), nullable=False
    ) # DECIMAL con precisión 11 y 8 decimales
    address = Column(String(255))
    registered_at = Column(TIMESTAMP, default=datetime.utcnow)
    user = relationship("User")

Base.metadata.create_all(bind=engine)


# Modelos Pydantic para validación de datos
class RegisterModel(BaseModel):
    usr_nombre: str
    password: str


class LoginModel(BaseModel):
    usr_nombre: str
    password: str


class AttendanceModel(BaseModel):
    id_usuario: int
    latitude: float
    longitude: float

# Dependencia DB
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# Función para encriptar con MD5
def md5_hash(password: str) -> str:
    return hashlib.md5(password.encode()).hexdigest()


# Endpoint: Registro de usuario
@app.post("/register/")
def register(data: RegisterModel, db=Depends(get_db)):
    hashed_pw = md5_hash(data.password)  # Encriptación con MD5
    user = User(
        usr_nombre=data.usr_nombre, usr_password=hashed_pw
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"msg": "Usuario registrado", "id_usuario": user.id_usuario}


# Endpoint: Login
@app.post("/login/")
def login(data: LoginModel, db=Depends(get_db)):
    user = db.query(User).filter(User.usr_nombre == data.usr_nombre).first()
    if not user or user.usr_password != md5_hash(data.usr_password):
        raise HTTPException(status_code=400, detail="Credenciales inválidas")
    return {"msg": "Login exitoso", "id_usuario": user.id_usuario}


# Endpoint: Pase de lista con GPS y dirección cercana
@app.post("/attendance/")
def attendance(data: AttendanceModel, db=Depends(get_db)):
    try:
        # Consumir API pública de Nominatim con cabecera obligatoria
        url = f"https://nominatim.openstreetmap.org/reverse?format=json&lat={data.latitude}&lon={data.longitude}"
        headers = {"User-Agent": "FastAPIApp/1.0"}  # Cabecera requerida
        response = requests.get(url, headers=headers)

        # Validar que la respuesta sea JSON
        if response.status_code == 200:
            result = response.json()
            address = result.get("display_name", "Dirección no disponible")
        else:
            address = "Error al obtener dirección"

        # Guardar registro en BD
        record = Attendance(
            id_usuario=data.id_usuario,
            latitude=data.latitude,
            longitude=data.longitude,
            address=address,
        )
        db.add(record)
        db.commit()
        db.refresh(record)
        return {
            "msg": "Registro guardado",
            "attendance_id": record.attendance_id,
            "address": address,
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")

@app.get("/attendance/{id_usuario}")
def get_attendance(id_usuario: int, db=Depends(get_db)):
    records = db.query(Attendance).filter(Attendance.id_usuario == id_usuario).all()

    return [
        {
            "attendance_id": r.attendance_id,
            "latitude": float(r.latitude),
            "longitude": float(r.longitude),
            "address": r.address,
            "registered_at": r.registered_at,
        }
        for r in records
    ]