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


$user_id = intval($_POST['user_id'] ?? 0);

if ($user_id === 0) {
    echo json_encode([]);
    exit;
}

$query = $conn->prepare("SELECT id, nombre, especie, raza, edad FROM mascotas WHERE usuario_id = ?");
$query->bind_param("i", $user_id);
$query->execute();
$result = $query->get_result();

$mascotas = [];
while ($row = $result->fetch_assoc()) {
    $mascotas[] = $row;
}

echo json_encode($mascotas, JSON_UNESCAPED_UNICODE);
