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

    if ($paseo_id <= 0) {
        echo json_encode(["success" => false, "message" => "ID de paseo inválido"]);
        exit;
    }

    $sql = "SELECT latitud, longitud, fecha_hora FROM ubicaciones_paseo 
            WHERE paseo_id = ? ORDER BY fecha_hora ASC";
    $stmt = $conn->prepare($sql);
    $stmt->execute([$paseo_id]);
    $historial = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "success" => true,
        "historial" => $historial,
        "total_puntos" => count($historial)
    ]);

} catch (Exception $e) {
    error_log("Error en get_historial_ubicacion: " . $e->getMessage());
    echo json_encode([
        "success" => false, 
        "message" => "Error del servidor",
        "error" => $e->getMessage()
    ]);
}
?>