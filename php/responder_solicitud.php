<?php
include 'conexion.php';
session_start();
header('Content-Type: application/json; charset=utf-8');

$paseador_id = $_SESSION['usuario_id'] ?? null;
$solicitud_id = $_POST['solicitud_id'] ?? null;
$accion = $_POST['accion'] ?? null; // "aceptar" o "rechazar"

if (!$paseador_id || !$solicitud_id || !$accion) {
    echo json_encode(["status"=>"error", "msg"=>"Datos incompletos"]);
    exit;
}

if ($accion === "aceptar") {
    // Actualizar solicitud
    mysqli_query($conn, "UPDATE solicitudespaseo SET estado='aceptada' WHERE id='$solicitud_id'");

    // Crear paseo
    mysqli_query($conn, "INSERT INTO paseos (solicitud_id, inicio, estado) VALUES ('$solicitud_id', NOW(), 'activo')");

    echo json_encode(["status"=>"ok", "msg"=>"Solicitud aceptada y paseo creado"]);
} elseif ($accion === "rechazar") {
    mysqli_query($conn, "UPDATE solicitudespaseo SET estado='rechazada' WHERE id='$solicitud_id'");
    echo json_encode(["status"=>"ok", "msg"=>"Solicitud rechazada"]);
} else {
    echo json_encode(["status"=>"error", "msg"=>"Acción inválida"]);
}
