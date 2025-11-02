<?php

// HEADERS PARA CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

session_start();
// MANEJAR PREFLIGHT
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

// INCLUIR CONEXIÓN
require_once 'conexion.php';
session_start();

$database = new Database();
$conn = $database->getConnection();


if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = htmlspecialchars(trim($_POST['email']));
    $password = $_POST['password'];
    $tipo_usuario = htmlspecialchars(trim($_POST['tipo_usuario']));

    if (empty($email) || empty($password) || empty($tipo_usuario)) {
        echo json_encode(["success" => false, "message" => "Por favor, complete todos los campos."]);
        exit();
    }

    // Determinar tabla
    if ($tipo_usuario === 'paseador') {
        $tabla = 'Paseadores';
    } else {
        $tabla = 'Usuarios';
    }

    // Buscar usuario
    $sql = "SELECT * FROM $tabla WHERE email = ? LIMIT 1";
    $stmt = $conn->prepare($sql);
    $stmt->execute([$email]);
    $usuario = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($usuario) {
        if (password_verify($password, $usuario['contraseña'])) {
            echo json_encode([
                "success" => true,
                "message" => "Inicio de sesión exitoso",
                "id" => $usuario['id'],
                "nombre" => $usuario['nombre'],
                "tipo" => $tipo_usuario
            ]);
        } else {
            echo json_encode(["success" => false, "message" => "Contraseña incorrecta."]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "No se encontró una cuenta con ese correo."]);
    }


} else {
    echo json_encode(["success" => false, "message" => "Método no permitido."]);
}
?>
