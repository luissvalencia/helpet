<?php
include 'conexion.php';
session_start();
header('Content-Type: application/json; charset=utf-8');

$paseador_id = $_SESSION['usuario_id'] ?? null;

if (!$paseador_id) {
    echo json_encode([]);
    exit;
}

$query = "SELECT s.id, u.nombre AS duenio, m.nombre AS mascota, s.fecha, s.estado
          FROM solicitudespaseo s
          INNER JOIN usuarios u ON s.usuario_id = u.id
          INNER JOIN mascotas m ON s.mascota_id = m.id
          WHERE s.paseador_id = '$paseador_id' AND s.estado = 'pendiente'
          ORDER BY s.fecha ASC";

$result = mysqli_query($conn, $query);

$data = [];
while ($row = mysqli_fetch_assoc($result)) {
    $data[] = $row;
}

echo json_encode($data);
