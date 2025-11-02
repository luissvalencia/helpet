<?php
// HEADERS PARA CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

// MANEJAR PREFLIGHT
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

// INCLUIR CONEXIÓN
require_once 'conexion.php';

try {
    $database = new Database();
    $conn = $database->getConnection();

    if (!$conn) {
        echo json_encode(["success" => false, "message" => "Error de conexión a la base de datos"]);
        exit;
    }

    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        // Obtener datos desde JSON
        $input = json_decode(file_get_contents('php://input'), true);
        
        $nombre = htmlspecialchars(trim($input['nombre'] ?? ''));
        $email = htmlspecialchars(trim($input['email'] ?? ''));
        $password = $input['password'] ?? '';
        $telefono = htmlspecialchars(trim($input['telefono'] ?? ''));
        $direccion = htmlspecialchars(trim($input['direccion'] ?? ''));
        $experiencia = htmlspecialchars(trim($input['experiencia'] ?? ''));
        $disponibilidad = htmlspecialchars(trim($input['disponibilidad'] ?? ''));

        // Validar campos obligatorios
        if (empty($nombre) || empty($email) || empty($password) || empty($experiencia) || empty($disponibilidad)) {
            echo json_encode(["success" => false, "message" => "Por favor, complete todos los campos obligatorios."]);
            exit;
        }

        // Validar formato de email
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            echo json_encode(["success" => false, "message" => "El formato del email no es válido."]);
            exit;
        }

        // Validar que experiencia sea numérica
        if (!is_numeric($experiencia)) {
            echo json_encode(["success" => false, "message" => "La experiencia debe ser un número."]);
            exit;
        }

        // 🔽 CORREGIDO: Usar PDO y nombre correcto de tabla (paseadores en minúsculas)
        // Verificar si el email ya existe
        $sql_check = "SELECT id FROM paseadores WHERE email = ?";
        $stmt_check = $conn->prepare($sql_check);
        $stmt_check->execute([$email]);
        
        if ($stmt_check->fetch()) {
            echo json_encode(["success" => false, "message" => "El correo ya está registrado. Use otro."]);
            exit;
        }

        // Hash de la contraseña
        $password_hash = password_hash($password, PASSWORD_DEFAULT);

        // Insertar nuevo paseador
        // 🔽 CORREGIDO: Usar nombre correcto de columna (contraseña con ñ)
        $sql_insert = "INSERT INTO paseadores (nombre, email, contraseña, telefono, direccion, experiencia, disponibilidad, created_at)
                       VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
        $stmt_insert = $conn->prepare($sql_insert);
        
        if ($stmt_insert->execute([$nombre, $email, $password_hash, $telefono, $direccion, $experiencia, $disponibilidad])) {
            echo json_encode([
                "success" => true, 
                "message" => "Registro exitoso. Ahora puedes iniciar sesión como paseador."
            ]);
        } else {
            echo json_encode(["success" => false, "message" => "Error al registrar paseador"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Método no permitido"]);
    }

} catch (Exception $e) {
    error_log("Error en registro_paseador: " . $e->getMessage());
    echo json_encode([
        "success" => false, 
        "message" => "Error del servidor: " . $e->getMessage()
    ]);
}
?>