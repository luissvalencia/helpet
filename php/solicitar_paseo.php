<?php
session_start();
require_once __DIR__ . '/conexion.php';
header('Content-Type: application/json; charset=utf-8');

// Obtener usuario desde sesión o POST
$usuario_id = null;
if (!empty($_SESSION['user_id'])) {
    $usuario_id = intval($_SESSION['user_id']);
} elseif (!empty($_POST['usuario_id'])) {
    $usuario_id = intval($_POST['usuario_id']);
}

// Obtener campos enviados
$mascota_id  = isset($_POST['mascota_id']) ? intval($_POST['mascota_id']) : null;
$paseador_id = isset($_POST['paseador_id']) ? intval($_POST['paseador_id']) : null;
$fecha       = isset($_POST['fecha']) ? trim($_POST['fecha']) : null;

// Validación básica
if (!$usuario_id || !$mascota_id || !$paseador_id || !$fecha) {
    echo json_encode([
        "status" => "error",
        "msg" => "Datos incompletos",
        "debug" => [
            "session_user_id" => $_SESSION['user_id'] ?? null,
            "post_usuario_id" => $_POST['usuario_id'] ?? null,
            "mascota_id" => $mascota_id,
            "paseador_id" => $paseador_id,
            "fecha" => $fecha
        ]
    ]);
    exit;
}

// Insertar con prepared statement
$stmt = $conn->prepare("INSERT INTO solicitudespaseo (usuario_id, paseador_id, mascota_id, fecha, estado) VALUES (?, ?, ?, ?, 'pendiente')");
if (!$stmt) {
    echo json_encode(["status"=>"error", "msg"=>"Error preparación consulta: ".$conn->error]);
    exit;
}
$stmt->bind_param("iiis", $usuario_id, $paseador_id, $mascota_id, $fecha);

if ($stmt->execute()) {
    echo json_encode(["status" => "ok", "msg" => "Solicitud enviada correctamente"]);
} else {
    echo json_encode(["status" => "error", "msg" => $stmt->error]);
}

$stmt->close();
$conn->close();
?>
