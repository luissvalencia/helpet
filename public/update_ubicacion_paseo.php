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
$latitud = floatval($_POST['latitud'] ?? 0);
$longitud = floatval($_POST['longitud'] ?? 0);

if ($paseo_id <= 0 || !$latitud || !$longitud) {
    echo json_encode(["success" => false, "message" => "Datos incompletos"]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO ubicaciones_paseo (paseo_id, latitud, longitud) VALUES (?, ?, ?)");
$stmt->bind_param("idd", $paseo_id, $latitud, $longitud);
$stmt->execute();
$stmt->close();

echo json_encode(["success" => true, "message" => "Ubicación actualizada"]);
$conn->close();
?>
