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

    // Obtener datos desde JSON
    $input = json_decode(file_get_contents('php://input'), true);
    
    $user_id = intval($input['user_id'] ?? 0);
    $nombre = trim($input['nombre'] ?? '');
    $especie = trim($input['especie'] ?? '');
    $raza = trim($input['raza'] ?? '');
    $edad = intval($input['edad'] ?? 0);

    if ($user_id <= 0 || empty($nombre) || empty($especie)) {
        echo json_encode(["success" => false, "message" => "Datos incompletos"]);
        exit;
    }

    // 🔽 CORREGIDO: Usar PDO en lugar de mysqli
    $sql = "INSERT INTO mascotas (usuario_id, nombre, especie, raza, edad) VALUES (?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    
    if ($stmt->execute([$user_id, $nombre, $especie, $raza, $edad])) {
        echo json_encode(["success" => true, "message" => "Mascota agregada correctamente"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al guardar mascota"]);
    }

} catch (Exception $e) {
    error_log("Error en add_mascota: " . $e->getMessage());
    echo json_encode(["success" => false, "message" => "Error del servidor"]);
}
?>