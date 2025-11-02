<<<<<<< HEAD
"# helpet_backend" 
=======
# 🐾 Guía para ejecutar el proyecto HelPet

🔧 **Requisitos previos**  
Tener **XAMPP** instalado (versión 7.4 o superior). 👉 [Descargar XAMPP](https://www.apachefriends.org/es/index.html)  
Tener un **navegador web** (Chrome, Edge, Firefox, etc.).  
Tener acceso a **phpMyAdmin** (viene incluido con XAMPP).  
Descargar el proyecto completo desde **GitHub** y colocarlo en la carpeta de XAMPP.

📁 **1. Instalar el proyecto en XAMPP**  
Abre la carpeta donde instalaste XAMPP.  
Normalmente es:  
`C:\xampp\htdocs\`  
Copia la carpeta del proyecto **HelPet** dentro de `htdocs`.  
Debe quedar así:  
`C:\xampp\htdocs\HelPet\`

🗄️ **2. Importar la base de datos**  
Inicia **XAMPP Control Panel** y activa los servicios:  
Apache ✅  
MySQL ✅  
Abre tu navegador y entra a:  
`http://localhost/phpmyadmin`  
Crea una nueva base de datos con este nombre exacto:  
`paseo_mascotas`  
Una vez creada, entra a la base y haz clic en **Importar**.  
Luego selecciona el archivo:  
`paseo_mascotas.sql`  
que viene dentro de la carpeta del proyecto.  
Da clic en **Continuar**.  
Cuando termine, deberías ver todas las tablas creadas correctamente (Usuarios, Paseadores, Mascotas, etc.).

🌐 **3. Ejecutar el sistema**  
Abre tu navegador y entra a:  
`http://localhost/HelPet/`  
Ahí se mostrará la página principal con las opciones:  
- Registrarse como dueño  
- Registrarse como paseador  
Después del registro, te redirigirá automáticamente al dashboard correspondiente según el tipo de usuario.
>>>>>>> 51ac655b8e0afc0b333f8080237ea802616ec0e9
"# helpet_backend" 
"# helpet_backend" 
