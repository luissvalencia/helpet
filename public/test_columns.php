<?php
require_once 'conexion.php';

$database = new Database();
$conn = $database->getConnection();

echo "<h3>Estructura de usuarios:</h3>";
$stmt = $conn->query("DESCRIBE usuarios");
$columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($columns as $col) {
    echo $col['Field'] . " (" . $col['Type'] . ")<br>";
}

echo "<h3>Estructura de paseadores:</h3>";
$stmt = $conn->query("DESCRIBE paseadores");
$columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($columns as $col) {
    echo $col['Field'] . " (" . $col['Type'] . ")<br>";
}

// Ver datos de ejemplo
echo "<h3>Usuario de ejemplo:</h3>";
$stmt = $conn->query("SELECT * FROM usuarios LIMIT 1");
$user = $stmt->fetch(PDO::FETCH_ASSOC);
print_r($user);
?>