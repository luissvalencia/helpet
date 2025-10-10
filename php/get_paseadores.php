<?php
include 'conexion.php';
header('Content-Type: application/json; charset=utf-8');

$fecha = $_GET['fecha'] ?? null;
$hora = $_GET['hora'] ?? null;

$query = "SELECT id, nombre, experiencia, calificacion_promedio 
          FROM paseadores";

$result = mysqli_query($conn, $query);

$paseadores = [];
while ($row = mysqli_fetch_assoc($result)) {
    $paseadores[] = $row;
}

echo json_encode($paseadores);
