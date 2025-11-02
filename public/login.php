<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

session_start();
require_once 'conexion.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $email = htmlspecialchars(trim($input['email']));
    $password = $input['password'];
    $tipo_usuario = htmlspecialchars(trim($input['tipo_usuario']));

    if (empty($email) || empty($password) || empty($tipo_usuario)) {
        echo json_encode(["success" => false, "message" => "Por favor, complete todos los campos."]);
        exit();
    }

    try {
        $database = new Database();
        $conn = $database->getConnection();

        if (!$conn) {
            echo json_encode(["success" => false, "message" => "Error de conexión a la base de datos"]);
            exit();
        }

        // Determinar tabla
        $tabla = ($tipo_usuario === 'paseador') ? 'Paseadores' : 'Usuarios';

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
    } catch (Exception $e) {
        error_log("Error en login: " . $e->getMessage());
        echo json_encode(["success" => false, "message" => "Error del servidor."]);
    }

} else {
    http_response_code(405);
    echo json_encode(["success" => false, "message" => "Método no permitido."]);
}
?>