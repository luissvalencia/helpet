<?php
session_start();
require_once __DIR__ . '/conexion.php';

if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo "No autorizado";
    exit;
}

if (isset($_GET['id'])) {
    $mascota_id = intval($_GET['id']);
    $user_id = intval($_SESSION['user_id']);

    // Validar que la mascota pertenezca al dueño logueado
    $stmt = $conn->prepare("DELETE FROM mascotas WHERE id = ? AND usuario_id = ?");
    $stmt->bind_param("ii", $mascota_id, $user_id);

    if ($stmt->execute() && $stmt->affected_rows > 0) {
        echo "ok";
    } else {
        echo "error";
    }
} else {
    echo "error";
}
