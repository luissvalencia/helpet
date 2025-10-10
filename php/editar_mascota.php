<?php
session_start();
require_once __DIR__ . '/conexion.php';

if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo "No autorizado";
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $mascota_id = intval($_POST['id']);
    $user_id = intval($_SESSION['user_id']);

    $nombre = trim($_POST['nombre'] ?? '');
    $especie = trim($_POST['especie'] ?? '');
    $raza = trim($_POST['raza'] ?? '');
    $edad = intval($_POST['edad'] ?? 0);

    if ($nombre === '' || $especie === '') {
        echo "Datos incompletos";
        exit;
    }

    $stmt = $conn->prepare("UPDATE mascotas 
                            SET nombre = ?, especie = ?, raza = ?, edad = ?
                            WHERE id = ? AND usuario_id = ?");
    $stmt->bind_param("sssiii", $nombre, $especie, $raza, $edad, $mascota_id, $user_id);

    if ($stmt->execute() && $stmt->affected_rows > 0) {
        echo "ok";
    } else {
        echo "error";
    }
} else {
    echo "error";
}
