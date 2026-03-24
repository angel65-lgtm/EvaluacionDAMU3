from fastapi import FastAPI, Depends, HTTPException, Form, UploadFile, File
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, Enum, DECIMAL, TIMESTAMP
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship, Session
from fastapi.middleware.cors import CORSMiddleware
import hashlib
import shutil
import os
from datetime import datetime
from sqlalchemy import Enum
from pydantic import BaseModel
from fastapi.staticfiles import StaticFiles

# =======================
# CONFIG
# =======================
DATABASE_URL = "mysql+pymysql://root:1n2n3m4789@localhost/entregas_paquexpress"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# =======================
# MODELOS
# =======================
class Usuario(Base):
    __tablename__ = "usuario"

    id_usuario = Column(Integer, primary_key=True, index=True)
    usr_nombre = Column(String(100))
    usr_password = Column(String(255))

class PaqueteCreate(BaseModel):
    nombre: str
    descripcion: str
    origen: str
    destino: str
    imagen: str = None

class Paquete(Base):
    __tablename__ = "paquetes"

    id_paquete = Column(Integer, primary_key=True, index=True)
    pa_nombre = Column(String(100))
    pa_descripcion = Column(String)
    pa_dirOrigen = Column(String)
    pa_dirDestino = Column(String)
    pa_imagen = Column(String)

    status = Column(
        Enum('asignado','recolectado','entregado', name='status_enum'),
        default='asignado'
    )

    usuario_id = Column(Integer, ForeignKey("usuario.id_usuario"))

    usuario = relationship("Usuario", backref="paquetes")

class Entrega(Base):
    __tablename__ = "entregas"

    id = Column(Integer, primary_key=True, index=True)
    paquete_id = Column(Integer, ForeignKey("paquetes.id_paquete"))
    foto = Column(String)
    latitud = Column(DECIMAL(10,8))
    longitud = Column(DECIMAL(11,8))
    fecha = Column(TIMESTAMP, default=datetime.utcnow)

# =======================
# DB
# =======================
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# =======================
# SEGURIDAD
# =======================
def hash_password(password: str):
    return hashlib.md5(password.encode()).hexdigest()

# =======================
# AUTH
# =======================

# REGISTRO
@app.post("/register/")
def register(
    usr_nombre: str = Form(...),
    password: str = Form(...),
    db: Session = Depends(get_db)
):
    user = Usuario(
        usr_nombre=usr_nombre,
        usr_password=hash_password(password)
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return {"msg": "Usuario registrado", "id_usuario": user.id_usuario}


# LOGIN
@app.post("/login/")
def login(
    usr_nombre: str = Form(...),
    password: str = Form(...),
    db: Session = Depends(get_db)
):
    user = db.query(Usuario).filter(Usuario.usr_nombre == usr_nombre).first()

    if not user or user.usr_password != hash_password(password):
        raise HTTPException(status_code=400, detail="Credenciales incorrectas")

    return {"id_usuario": user.id_usuario, "nombre": user.usr_nombre}


# =======================
# PAQUETES
# =======================

@app.post("/paquetes/")
def crear_paquete(data: PaqueteCreate, db=Depends(get_db)):

    paquete = Paquete(
        pa_nombre=data.nombre,
        pa_descripcion=data.descripcion,
        pa_dirOrigen=data.origen,
        pa_dirDestino=data.destino,
        pa_imagen=data.imagen,
        status="asignado", 
        usuario_id=None 
    )

    db.add(paquete)
    db.commit()
    db.refresh(paquete)

    return {
        "msg": "Paquete creado",
        "id_paquete": paquete.id_paquete
    }

@app.put("/paquete/{id}/asignar/{usuario_id}")
def asignar_paquete(id: int, usuario_id: int, db=Depends(get_db)):

    paquete = db.query(Paquete).filter(
        Paquete.id_paquete == id
    ).first()

    if not paquete:
        raise HTTPException(status_code=404, detail="Paquete no encontrado")

    paquete.usuario_id = usuario_id
    paquete.status = "asignado"

    db.commit()

    return {"msg": "Paquete asignado"}

#obtener usuarios
@app.get("/usuarios/todos")
def obtener_todos_los_usuarios(db: Session = Depends(get_db)):
    try:
        usuarios = db.query(Usuario).all()
        return [
            {
                "id_usuario": u.id_usuario,
                "nombre": u.usr_nombre
            } for u in usuarios
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

#obtener paquetes de la DB
@app.get("/paquetes/todos")
def obtener_todos_los_paquetes(db: Session = Depends(get_db)):
    try:
        paquetes = db.query(Paquete).all()
        return [
            {
                "id": p.id_paquete,
                "nombre": p.pa_nombre,
                "descripcion": p.pa_descripcion,
                "origen": p.pa_dirOrigen,
                "destino": p.pa_dirDestino,
                "status": p.status,
                "usuario_id": p.usuario_id,
                "imagen": p.pa_imagen
            } for p in paquetes
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
# VER PAQUETES DEL USUARIO
@app.get("/paquetes/{usuario_id}")
def get_paquetes(usuario_id: int, db=Depends(get_db)):

    paquetes = db.query(Paquete).filter(
        Paquete.usuario_id == usuario_id
    ).all()

    return [
        {
            "id": p.id_paquete,
            "nombre": p.pa_nombre,
            "descripcion": p.pa_descripcion,
            "destino": p.pa_dirDestino,
            "status": p.status,
            "imagen": p.pa_imagen
        }
        for p in paquetes
    ]

# RECOLECTAR PAQUETE
@app.put("/paquete/{id}/recolectar")
def recolectar(id: int, db: Session = Depends(get_db)):
    paquete = db.query(Paquete).filter(Paquete.id_paquete == id).first()

    if not paquete:
        raise HTTPException(status_code=404, detail="Paquete no encontrado")

    paquete.status = "recolectado"
    db.commit()

    return {"msg": "Paquete recolectado"}


# ENTREGAR PAQUETE (foto + ubicación)
@app.put("/paquete/{id}/entregar")
def entregar(
    id: int,
    latitud: float = Form(...),
    longitud: float = Form(...),
    foto: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    paquete = db.query(Paquete).get(id)

    if not paquete:
        raise HTTPException(status_code=404, detail="Paquete no encontrado")

    # Guardar imagen
    os.makedirs("uploads", exist_ok=True)
    file_path = f"uploads/{foto.filename}"

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(foto.file, buffer)

    # Guardar entrega
    entrega = Entrega(
        paquete_id=id,
        foto=file_path,
        latitud=latitud,
        longitud=longitud
    )

    paquete.status = "entregado"

    db.add(entrega)
    db.commit()

    return {"msg": "Paquete entregado correctamente"}

# =======================
# CREAR TABLAS
# =======================
Base.metadata.create_all(bind=engine)