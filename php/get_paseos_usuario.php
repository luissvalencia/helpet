<?php
include 'conexion.php';

$mascota_id = $_GET['mascota_id'];

$stmt = $conn->prepare("
    SELECT p.id as paseo_id, m.nombre as mascota, pa.nombre as paseador, s.fecha, p.estado, h.distancia, h.duracion
    FROM paseos p
    INNER JOIN solicitudespaseo s ON s.id = p.solicitud_id
    INNER JOIN mascotas m ON m.id = s.mascota_id
    INNER JOIN paseadores pa ON pa.id = s.paseador_id
    LEFT JOIN historialpaseos h ON h.paseo_id = p.id
    WHERE m.id = ?
    ORDER BY s.fecha DESC
");
$stmt->bind_param("i", $mascota_id);
$stmt->execute();
$result = $stmt->get_result();

$paseos = [];
while($row = $result->fetch_assoc()) {
    $paseos[] = $row;
}

echo json_encode($paseos);
?>
