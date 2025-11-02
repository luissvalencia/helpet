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
    $user_id = intval($_POST['user_id'] ?? 0);
    $nombre = trim($_POST['nombre'] ?? '');
    $especie = trim($_POST['especie'] ?? '');
    $raza = trim($_POST['raza'] ?? '');
    $edad = intval($_POST['edad'] ?? 0);

    if ($user_id <= 0 || empty($nombre) || empty($especie)) {
        echo json_encode(["success" => false, "message" => "Datos incompletos"]);
        exit;
    }

    $stmt = $conn->prepare("INSERT INTO mascotas (usuario_id, nombre, especie, raza, edad) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("isssi", $user_id, $nombre, $especie, $raza, $edad);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Mascota agregada correctamente"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al guardar mascota"]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["success" => false, "message" => "Método no permitido"]);
}
?>