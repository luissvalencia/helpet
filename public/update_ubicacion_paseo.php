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
    $paseo_id = intval($input['paseo_id'] ?? 0);
    $latitud = floatval($input['latitud'] ?? 0);
    $longitud = floatval($input['longitud'] ?? 0);

    // Validar datos
    if ($paseo_id <= 0 || $latitud == 0 || $longitud == 0) {
        echo json_encode(["success" => false, "message" => "Datos incompletos o inválidos"]);
        exit;
    }

    // Validar que el paseo existe
    $sql_check = "SELECT id FROM paseos WHERE id = ?";
    $stmt_check = $conn->prepare($sql_check);
    $stmt_check->execute([$paseo_id]);
    
    if (!$stmt_check->fetch()) {
        echo json_encode(["success" => false, "message" => "El paseo no existe"]);
        exit;
    }

    // 🔽 CORREGIDO: Usar PDO
    $sql = "INSERT INTO ubicaciones_paseo (paseo_id, latitud, longitud, fecha_hora) VALUES (?, ?, ?, NOW())";
    $stmt = $conn->prepare($sql);
    
    if ($stmt->execute([$paseo_id, $latitud, $longitud])) {
        echo json_encode([
            "success" => true, 
            "message" => "Ubicación actualizada correctamente",
            "paseo_id" => $paseo_id,
            "latitud" => $latitud,
            "longitud" => $longitud
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al guardar ubicación"]);
    }

} catch (Exception $e) {
    error_log("Error en update_ubicacion_paseo: " . $e->getMessage());
    echo json_encode([
        "success" => false, 
        "message" => "Error del servidor",
        "error" => $e->getMessage()
    ]);
}
?>