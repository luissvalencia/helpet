<?php
session_start();
require_once __DIR__ . '/conexion.php';

if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo "No autorizado";
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $usuario_id = intval($_SESSION['user_id']);
    $nombre = trim($_POST['nombre'] ?? '');
    $especie = trim($_POST['especie'] ?? '');
    $raza = trim($_POST['raza'] ?? '');
    $edad = intval($_POST['edad'] ?? 0);

    if ($nombre === '' || $especie === '') {
        echo "Datos incompletos";
        exit;
    }

    $stmt = $conn->prepare("INSERT INTO mascotas (usuario_id, nombre, especie, raza, edad) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("isssi", $usuario_id, $nombre, $especie, $raza, $edad);
    if ($stmt->execute()) {
        echo "ok";
    } else {
        echo "error";
    }
}
