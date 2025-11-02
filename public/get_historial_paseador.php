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
    $paseador_id = intval($input['paseador_id'] ?? 0);

    if ($paseador_id <= 0) {
        echo json_encode(["success" => false, "message" => "ID de paseador inválido"]);
        exit;
    }

    // 🔽 CORREGIDO: Usar PDO en lugar de mysqli
    $sql = "
        SELECT 
            p.id AS paseo_id,
            p.fecha,
            p.estado,
            u.nombre AS dueno_nombre,
            GROUP_CONCAT(DISTINCT m.nombre SEPARATOR ', ') AS mascotas,
            COUNT(DISTINCT up.id) AS puntos_ubicacion
        FROM paseos p
        INNER JOIN usuarios u ON u.id = p.usuario_id
        INNER JOIN paseos_mascotas pm ON pm.paseo_id = p.id
        INNER JOIN mascotas m ON m.id = pm.mascota_id
        LEFT JOIN ubicaciones_paseo up ON up.paseo_id = p.id
        WHERE p.paseador_id = ?
        GROUP BY p.id, p.fecha, p.estado, u.nombre
        ORDER BY p.fecha DESC
    ";

    $stmt = $conn->prepare($sql);
    $stmt->execute([$paseador_id]);
    $historial = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "success" => true,
        "historial" => $historial
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    error_log("Error en get_historial_paseador: " . $e->getMessage());
    echo json_encode([
        "success" => false, 
        "message" => "Error del servidor",
        "error" => $e->getMessage()
    ]);
}
?>