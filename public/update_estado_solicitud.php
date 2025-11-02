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


$paseador_id = intval($_POST['paseador_id'] ?? 0);
$usuario_id = intval($_POST['usuario_id'] ?? 0);
$fecha = $_POST['fecha'] ?? '';
$estado = $_POST['estado'] ?? '';

if ($paseador_id <= 0 || $usuario_id <= 0 || empty($fecha) || !in_array($estado, ['aceptado', 'rechazado'])) {
    echo json_encode(["success" => false, "message" => "Datos inválidos"]);
    exit;
}

// Actualizamos todas las solicitudes del mismo paseo (mismo dueño y fecha)
$stmt = $conn->prepare("UPDATE solicitudespaseo 
                        SET estado = ? 
                        WHERE paseador_id = ? AND usuario_id = ? AND fecha = ?");
$stmt->bind_param("siis", $estado, $paseador_id, $usuario_id, $fecha);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Solicitud actualizada a $estado"]);
} else {
    echo json_encode(["success" => false, "message" => "Error al actualizar"]);
}

$stmt->close();
$conn->close();
?>
