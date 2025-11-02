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
    // Obtener datos JSON
    $rawInput = file_get_contents('php://input');
    $input = json_decode($rawInput, true);
    
    error_log("📨 Datos recibidos: " . print_r($input, true));
    
    if (!isset($input['email']) || !isset($input['password']) || !isset($input['tipo_usuario'])) {
        echo json_encode(["success" => false, "message" => "Por favor, complete todos los campos."]);
        exit();
    }
    
    $email = htmlspecialchars(trim($input['email']));
    $password = $input['password'];
    $tipo_usuario = htmlspecialchars(trim($input['tipo_usuario']));

    try {
        $database = new Database();
        $conn = $database->getConnection();

        if (!$conn) {
            error_log("❌ No hay conexión a BD");
            echo json_encode(["success" => false, "message" => "Error de conexión a la base de datos"]);
            exit();
        }
        
        error_log("✅ Conexión BD exitosa");

        // Determinar tabla
        $tabla = ($tipo_usuario === 'paseador') ? 'Paseadores' : 'Usuarios';
        error_log("🔍 Buscando en tabla: $tabla, email: $email");

        // Buscar usuario
        $sql = "SELECT * FROM $tabla WHERE email = ? LIMIT 1";
        $stmt = $conn->prepare($sql);
        $stmt->execute([$email]);
        $usuario = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($usuario) {
            error_log("✅ Usuario encontrado: " . $usuario['email']);
            
            // Verificar si la columna de contraseña existe
            if (!isset($usuario['contraseña'])) {
                error_log("❌ Columna 'contraseña' no encontrada. Columnas disponibles: " . implode(', ', array_keys($usuario)));
                echo json_encode(["success" => false, "message" => "Error en la estructura de la base de datos"]);
                exit();
            }
            
            if (password_verify($password, $usuario['contraseña'])) {
                error_log("✅ Contraseña correcta");
                echo json_encode([
                    "success" => true,
                    "message" => "Inicio de sesión exitoso",
                    "id" => $usuario['id'],
                    "nombre" => $usuario['nombre'],
                    "tipo" => $tipo_usuario
                ]);
            } else {
                error_log("❌ Contraseña incorrecta");
                echo json_encode(["success" => false, "message" => "Contraseña incorrecta."]);
            }
        } else {
            error_log("❌ Usuario no encontrado: $email");
            echo json_encode(["success" => false, "message" => "No se encontró una cuenta con ese correo."]);
        }
    } catch (Exception $e) {
        error_log("❌ Error en login: " . $e->getMessage());
        echo json_encode(["success" => false, "message" => "Error del servidor: " . $e->getMessage()]);
    }

} else {
    http_response_code(405);
    echo json_encode(["success" => false, "message" => "Método no permitido."]);
}
?>