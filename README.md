🐾 HelPet - Plataforma de Paseo de Mascotas
https://via.placeholder.com/1200x400/4CAF50/FFFFFF?text=HelPet+-+Tu+Compa%C3%B1ero+de+Confianza

📖 Descripción
HelPet es una aplicación móvil innovadora que conecta dueños de mascotas con paseadores verificados. La plataforma ofrece seguimiento en tiempo real, comunicación directa y un sistema de calificaciones para garantizar la mejor experiencia tanto para las mascotas como para sus dueños.

✨ Características Principales
🏠 Para Dueños de Mascotas
📱 Registro y gestión de perfiles de mascotas

🔍 Búsqueda y filtrado de paseadores cercanos

📅 Solicitud de paseos con fecha y hora específicas

🗺️ Seguimiento en tiempo real con mapa interactivo

⭐ Sistema de calificaciones y comentarios

💬 Chat en tiempo real con paseadores

📊 Historial completo de paseos realizados

🚶‍♂️ Para Paseadores
👤 Perfil profesional con experiencia y especialidades

📋 Gestión de solicitudes de paseo

🗓️ Agenda integrada para organizar horarios

📍 Sistema de seguimiento GPS durante paseos

💰 Gestión de servicios y reportes automáticos

⭐ Sistema de reputación basado en calificaciones

🛠️ Tecnologías Utilizadas
Frontend (Flutter)
Framework: Flutter 3.0+

Lenguaje: Dart

Mapas: flutter_map + OpenStreetMap

Navegación: Navigator 2.0

Estado: Provider/SetState

HTTP: http package

Backend (PHP)
Lenguaje: PHP 8.2+

Base de Datos: MySQL

Servidor: Apache

Hosting: Render

CORS: Headers personalizados

Base de Datos
Motor: MySQL

Tablas Principales: usuarios, paseadores, mascotas, paseos, solicitudespaseo, ubicaciones_paseo, calificaciones


🚀 Instalación y Configuración
Prerrequisitos
Flutter SDK 3.0+

PHP 8.2+

MySQL 8.0+

Servidor web (Apache/Nginx)

Backend Setup
Clonar el repositorio

bash
git clone https://github.com/tuusuario/helpet-backend.git
cd helpet-backend
Configurar base de datos

sql
-- Importar la estructura de la base de datos
mysql -u usuario -p helpet < database/schema.sql
Configurar variables de entorno

php
// config/database.php
class Database {
    private $host = "tu_host_mysql";
    private $db_name = "helpet";
    private $username = "tu_usuario";
    private $password = "tu_contraseña";
    private $port = 3306;
}
Configurar servidor web

apache
# Asegurar que mod_rewrite esté habilitado
# Configurar DocumentRoot a la carpeta public/
Frontend Setup
Clonar el proyecto Flutter

bash
git clone https://github.com/tuusuario/helpet-flutter.git
cd helpet-flutter
Instalar dependencias

bash
flutter pub get
Configurar URLs del backend

dart
// lib/services/api_service.dart
static const String baseUrl = "https://tu-backend.render.com";
Ejecutar la aplicación

bash
flutter run



