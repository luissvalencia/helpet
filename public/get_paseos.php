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
    $user_id = intval($input['user_id'] ?? 0);

    if ($user_id <= 0) {
        echo json_encode([]);
        exit;
    }

    // 🔽 CORREGIDO: Usar PDO en lugar de mysqli
    $sql = "
        -- Solicitudes pendientes (aún no aceptadas)
        SELECT 
            MIN(s.id) AS paseo_id,
            s.paseador_id,
            pa.nombre AS paseador_nombre,
            s.fecha,
            s.estado,
            u.nombre AS dueno_nombre,
            GROUP_CONCAT(DISTINCT m.nombre SEPARATOR ', ') AS mascotas,
            'solicitud' AS tipo
        FROM solicitudespaseo s
        INNER JOIN paseadores pa ON pa.id = s.paseador_id
        INNER JOIN usuarios u ON u.id = s.usuario_id
        INNER JOIN mascotas m ON m.id = s.mascota_id
        WHERE s.usuario_id = ? AND s.estado = 'pendiente'
        GROUP BY s.paseador_id, s.fecha, s.estado, pa.nombre, u.nombre
        
        UNION ALL
        
        -- Paseos aceptados, en curso o finalizados
        SELECT 
            p.id AS paseo_id,
            p.paseador_id,
            pa.nombre AS paseador_nombre,
            p.fecha,
            p.estado,
            u.nombre AS dueno_nombre,
            GROUP_CONCAT(DISTINCT m.nombre SEPARATOR ', ') AS mascotas,
            'paseo' AS tipo
        FROM paseos p
        INNER JOIN paseadores pa ON pa.id = p.paseador_id
        INNER JOIN usuarios u ON u.id = p.usuario_id
        INNER JOIN paseos_mascotas pm ON pm.paseo_id = p.id
        INNER JOIN mascotas m ON m.id = pm.mascota_id
        WHERE p.usuario_id = ?
        GROUP BY p.id, p.paseador_id, p.fecha, p.estado, pa.nombre, u.nombre
        
        ORDER BY fecha DESC
    ";

    $stmt = $conn->prepare($sql);
    $stmt->execute([$user_id, $user_id]);
    $paseos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($paseos, JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    error_log("Error en get_paseos: " . $e->getMessage());
    echo json_encode([
        "error" => "Error del servidor",
        "message" => $e->getMessage()
    ]);
}
?>