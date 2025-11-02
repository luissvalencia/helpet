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


$paseador_id = intval($_POST['paseador_id'] ?? 0);

if ($paseador_id <= 0) {
    echo json_encode(["error" => "ID de paseador no válido"]);
    exit;
}

// ✅ CONSULTA CORREGIDA - Buscar en SOLICITUDESPASEO donde el paseador ve sus solicitudes pendientes
$query = "
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

$stmt = $conn->prepare($query);
$stmt->bind_param("i", $paseador_id);
$stmt->execute();
$result = $stmt->get_result();

$solicitudes = [];
while ($row = $result->fetch_assoc()) {
    $solicitudes[] = [
        "paseo_id"      => intval($row["paseo_id"]),
        "usuario_id"    => intval($row["usuario_id"]),
        "dueno_nombre"  => $row["dueno_nombre"],
        "paseador_id"   => intval($row["paseador_id"]),
        "fecha"         => $row["fecha"],
        "estado"        => $row["estado"],
        "mascotas"      => $row["mascotas"]
    ];
}

echo json_encode($solicitudes, JSON_UNESCAPED_UNICODE);

$stmt->close();
$conn->close();
?>