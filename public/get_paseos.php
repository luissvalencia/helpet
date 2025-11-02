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
require_once '../config/database.php';

$database = new Database();
$conn = $database->getConnection();


$user_id = intval($_POST['user_id'] ?? 0);

if ($user_id <= 0) {
    echo json_encode([]);
    exit;
}

// ✅ CONSULTA UNIFICADA - Mostrar tanto solicitudes pendientes como paseos aceptados
$query = "
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

$stmt = $conn->prepare($query);
$stmt->bind_param("ii", $user_id, $user_id);
$stmt->execute();
$result = $stmt->get_result();

$paseos = [];
while ($row = $result->fetch_assoc()) {
    $paseos[] = $row;
}

echo json_encode($paseos, JSON_UNESCAPED_UNICODE);

$stmt->close();
$conn->close();
?>