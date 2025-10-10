<?php
session_start();
require_once __DIR__ . '/conexion.php';

if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode(["error" => "No autorizado"]);
    exit;
}

$user_id = intval($_SESSION['user_id']);
$stmt = $conn->prepare("SELECT id, nombre, especie, raza, edad FROM mascotas WHERE usuario_id = ?");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

$mascotas = [];
while ($row = $result->fetch_assoc()) {
    $mascotas[] = $row;
}

echo json_encode($mascotas);
