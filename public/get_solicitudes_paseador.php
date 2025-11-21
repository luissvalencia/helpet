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
        echo json_encode(["error" => "Error de conexión a la base de datos"]);
        exit;
    }

    // Obtener datos desde JSON
    $input = json_decode(file_get_contents('php://input'), true);
    $paseador_id = intval($input['paseador_id'] ?? 0);

    if ($paseador_id <= 0) {
        echo json_encode(["error" => "ID de paseador no válido"]);
        exit;
    }

    // 🔽 CORREGIDO: Usar PDO
    $sql = "
        SELECT 
            MIN(s.id) AS paseo_id,
            s.usuario_id,
            u.nombre AS dueno_nombre,
            s.paseador_id,
            s.fecha,
            s.estado,
            GROUP_CONCAT(DISTINCT m.nombre SEPARATOR ', ') AS mascotas
        FROM solicitudespaseo s
        INNER JOIN usuarios u ON u.id = s.usuario_id
        INNER JOIN mascotas m ON m.id = s.mascota_id
        WHERE s.paseador_id = ? AND s.estado = 'pendiente'
        GROUP BY s.usuario_id, s.fecha, s.paseador_id, s.estado, u.nombre
        ORDER BY s.fecha DESC
    ";

    $stmt = $conn->prepare($sql);
    $stmt->execute([$paseador_id]);
    $solicitudes = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Convertir IDs a enteros
    foreach ($solicitudes as &$solicitud) {
        $solicitud['paseo_id'] = intval($solicitud['paseo_id']);
        $solicitud['usuario_id'] = intval($solicitud['usuario_id']);
        $solicitud['paseador_id'] = intval($solicitud['paseador_id']);
    }

    echo json_encode($solicitudes, JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    error_log("Error en get_solicitudes_paseador: " . $e->getMessage());
    echo json_encode([
        "error" => "Error del servidor",
        "message" => $e->getMessage()
    ]);
}
?>