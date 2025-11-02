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
    $usuario_id = intval($_POST['user_id'] ?? 0);
    $paseador_id = intval($_POST['paseador_id'] ?? 0);
    $fecha = $_POST['fecha'] ?? '';
    $mascotas = explode(',', $_POST['mascotas'] ?? ''); // IDs separados por comas

    if ($usuario_id <= 0 || $paseador_id <= 0 || empty($fecha) || empty($mascotas)) {
        echo json_encode(["success" => false, "message" => "Faltan datos obligatorios"]);
        exit;
    }

    $insert = $conn->prepare("INSERT INTO solicitudespaseo (usuario_id, paseador_id, mascota_id, fecha, estado) VALUES (?, ?, ?, ?, 'pendiente')");

    $ok = true;
    foreach ($mascotas as $m_id) {
        $m_id = intval(trim($m_id));
        if ($m_id > 0) {
            $insert->bind_param("iiis", $usuario_id, $paseador_id, $m_id, $fecha);
            if (!$insert->execute()) {
                $ok = false;
            }
        }
    }

    if ($ok) {
        echo json_encode(["success" => true, "message" => "Solicitud de paseo registrada correctamente"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al registrar una o más solicitudes"]);
    }

    $insert->close();
    $conn->close();
} else {
    echo json_encode(["success" => false, "message" => "Método no permitido"]);
}
?>
