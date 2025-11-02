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


$paseo_id = intval($_POST['paseo_id'] ?? 0);

if ($paseo_id <= 0) {
    echo json_encode(["success" => false, "message" => "ID de paseo inválido"]);
    exit;
}

$query = "SELECT latitud, longitud, fecha_hora 
          FROM ubicaciones_paseo 
          WHERE paseo_id = ? 
          ORDER BY fecha_hora ASC";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $paseo_id);
$stmt->execute();
$result = $stmt->get_result();

$ubicaciones = [];
while ($row = $result->fetch_assoc()) {
    $ubicaciones[] = $row;
}

echo json_encode([
    "success" => true, 
    "ubicaciones" => $ubicaciones
]);

$stmt->close();
$conn->close();
?>