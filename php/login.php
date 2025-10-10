<?php
// Incluir archivo de conexión
include 'conexion.php';

// Iniciar sesión
session_start();

// Verificar si se envió el formulario
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Recoger y sanitizar los datos del formulario
    $email = htmlspecialchars(trim($_POST['email']));
    $password = $_POST['password'];
    $tipo_usuario = htmlspecialchars(trim($_POST['tipo_usuario']));
    
    // Validar datos
    if (empty($email) || empty($password) || empty($tipo_usuario)) {
        die("Por favor, complete todos los campos.");
    }
    
    // Determinar en qué tabla buscar según el tipo de usuario
    if ($tipo_usuario === 'paseador') {
        $tabla = 'Paseadores';
        $campo_id = 'id';
        $redireccion = '../pages/dashboard_paseador.html';
    } else {
        $tabla = 'Usuarios';
        $campo_id = 'id';
        $redireccion = '../pages/dashboard_dueño.html';
    }
    
    // Buscar el usuario en la base de datos
    $sql = "SELECT * FROM $tabla WHERE email = ? LIMIT 1";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 1) {
        $usuario = $result->fetch_assoc();
        
        // Verificar la contraseña (usa password_hash en el registro)
        if (password_verify($password, $usuario['contraseña'])) {
            // Guardar datos en sesión (IMPORTANTE: usamos siempre 'user_id')
            $_SESSION['usuario_id'] = $usuario[$campo_id];
            $_SESSION['user_id'] = $usuario[$campo_id]; // alias, para compatibilidad
            $_SESSION['email'] = $usuario['email'];
            $_SESSION['nombre'] = $usuario['nombre'];
            $_SESSION['tipo_usuario'] = $tipo_usuario;
            
            // Redirigir al dashboard correspondiente
            header("Location: $redireccion");
            exit();
        } else {
            echo "Contraseña incorrecta. <a href='../pages/login.html'>Intentar de nuevo</a>";
        }
    } else {
        echo "No se encontró una cuenta con ese email. <a href='../pages/registro.html'>Registrarse</a>";
    }
    
    $stmt->close();
    $conn->close();
} else {
    // Si alguien intenta acceder directamente a este archivo
    header("Location: ../pages/login.html");
    exit();
}
?>
