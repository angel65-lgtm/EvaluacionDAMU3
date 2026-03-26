# flutter_application_1

# Proceso de instalación de la app flutter para Paquexpress.

1.- Instalar el lenguaje de flutter, [link para descargar e instalar flutter](https://youtu.be/tiOCrXG3Fq4?si=Tx4wNeWZgh2da-gJ)

2.- Descargar los archivos ".dart" en la carpeta "lib" del repositorio y el archivo main.py

3.- Abrir visual code studio

4.- Con el comando "ctrl + shift + p" abrirá la barra de búsqueda, escribe "flutter: new project" y selecciona la opción de "aplicación" y nombra la carpeta

5.- Los archivos ".dart" descargados anteriormente, córtalos y pegale en la carpeta "lib" de la carpeta de la aplicación

6.- Abre una terminal y cambia a la carpeta de la aplicación con el comando "cd nombreDeTuCarpetaDeAplicación"

7.- Crear un entorno virtual para la API en Visual Studio:
    python -m venv env

8.- Activar entorno:
    env\Scripts\activate
        si no funciona, usar: 
    env/Scripts/activate.bat

9.- Instalar FastAPI y Uvicorn(servidor para ejecutar FastAPI)
    pip install "fastapi[standard]" uvicorn

10.- Instala el conector para la API a la Base de datos de MySQL:
    pip install sqlalchemy mysql-connector-python

11.- Instala Pydantic para la validación de datos en la API:
    pip install fastapi uvicorn sqlalchemy pymysql pydantic requests

12.- En tu carpeta de aplicación, busca el archivo "pubspec.yaml" y busca "dependences", posteriormente copia y pega los siguientes pluggins sin alterar los espaciados: 
    geolocator: ^10.1.0
http: ^1.6.0
image_picker: ^1.0.4

13.- Abre una nueva terminal, cambia a la carpeta de tu aplicación, si ya estas ahí, ejecuta: 
    uvicorn main:app --reload
abre tu navegador y escribe: http://127.0.0.1:8000/docs#/ en la barra de búsqueda

14.- Una vex abierta tu API, dirigete al endpoint de POST "crear usuario", ingresa un nombre de usuario y contraseña

15.- Descarga o mueve una foto de tu ordenador la carpeta "uploads" que se encuentra en la carpeta raiz de tu aplicación

16.- Ve al endpoint POST "crear paquete" e ingresa los datos requeridos, en la image, agrega la ruta de la imagen del tipo "uploads/nombreDeLaImagen" y ejecuta el endpoint

17.- Dirigete a los endpoints de tipo GET "obetener usuarios" y "obtener paquetes" para visualizar un registro de datos exitoso además de sus id's

18.- Dirigete al endpoint "asignar" paquete, posterior ingresa el id del paquete y después el id del usuario y ejecuta el endpoint

19.- Regresa a VS y vuelve a abrir otra terminal, en la carpeta de tu aplicación, ejecuta:
    flutter run -d chrome

20.- Abrirá tu aplicación en la página de login, ingresa tu usario y contraseña

21.- Dirigete al apartado "mis paquete" para visualizar los paquetes que se han asignado

22.- Da click en el botón de "Recolectar"

23.- Da click en el paquete, verás la descripción del paquete, además de poder ingresar los datos requeridos para hacer válida la entrega

Listo, ya sabes usar la app de PaqueXpress.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
