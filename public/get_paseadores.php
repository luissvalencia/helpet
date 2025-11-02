<?php

// HEADERS PARA CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json; charset=utf-8');

// MANEJAR PREFLIGHT
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

// INCLUIR CONEXIÓN
require_once '../config/database.php';

$database = new Database();
$conn = $database->getConnection();


if (!$conn) {
    echo json_encode(["error" => "Error de conexión a la base de datos"]);
    exit;
}

$query = "SELECT id, nombre, experiencia, calificacion_promedio FROM paseadores";
$result = mysqli_query($conn, $query);

if (!$result) {
    echo json_encode(["error" => "Error en la consulta"]);
    exit;
}

$paseadores = [];
while ($row = mysqli_fetch_assoc($result)) {
    $paseadores[] = $row;
}

echo json_encode($paseadores, JSON_UNESCAPED_UNICODE);
mysqli_close($conn);
?>
