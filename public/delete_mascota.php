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
    $mascota_id = intval($_POST['mascota_id'] ?? 0);

    if ($mascota_id <= 0) {
        echo json_encode(["success" => false, "message" => "ID de mascota inválido"]);
        exit;
    }

    $stmt = $conn->prepare("DELETE FROM mascotas WHERE id = ?");
    $stmt->bind_param("i", $mascota_id);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Mascota eliminada correctamente"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al eliminar mascota"]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["success" => false, "message" => "Método no permitido"]);
}
?>