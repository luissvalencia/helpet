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


if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $paseador_id = intval($_POST['paseador_id'] ?? 0);

    if ($paseador_id <= 0) {
        echo json_encode(["success" => false, "message" => "Falta el ID del paseador"]);
        exit;
    }

    // ✅ CONSULTA CORREGIDA - Agrupar por paseo para evitar duplicados
    $sql = "
        SELECT 
            p.id AS paseo_id,
            p.fecha,
            p.estado,
            u.id AS dueno_id,
            u.nombre AS dueno_nombre,
            GROUP_CONCAT(DISTINCT m.nombre SEPARATOR ', ') AS mascotas
        FROM paseos p
        INNER JOIN usuarios u ON p.usuario_id = u.id
        INNER JOIN paseos_mascotas pm ON pm.paseo_id = p.id
        INNER JOIN mascotas m ON m.id = pm.mascota_id
        WHERE p.paseador_id = ?
        AND (p.estado = 'aceptado' OR p.estado = 'en_curso')
        GROUP BY p.id, p.fecha, u.id, u.nombre, p.estado  -- ✅ Agrupar por paseo, no por mascota
        ORDER BY p.fecha DESC
    ";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $paseador_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $paseos = [];
    while ($row = $result->fetch_assoc()) {
        $paseos[] = [
            "paseo_id" => intval($row["paseo_id"]),
            "fecha" => $row["fecha"],
            "estado" => $row["estado"],
            "dueno_id" => intval($row["dueno_id"]),
            "dueno_nombre" => $row["dueno_nombre"],
            "mascotas" => $row["mascotas"]
        ];
    }

    echo json_encode($paseos, JSON_UNESCAPED_UNICODE);
    $stmt->close();
    $conn->close();

} else {
    echo json_encode(["success" => false, "message" => "Método no permitido"]);
}
?>