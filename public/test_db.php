<?php
require_once 'conexion.php';

$database = new Database();
$conn = $database->getConnection();

if ($conn) {
    echo "✅ Conexión exitosa<br>";
    
    // Listar tablas
    $stmt = $conn->query("SHOW TABLES");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "📊 Tablas: " . implode(', ', $tables) . "<br>";
    
    // Ver estructura de Usuarios
    if (in_array('Usuarios', $tables)) {
        $stmt = $conn->query("DESCRIBE Usuarios");
        $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
        echo "📋 Columnas de Usuarios: " . implode(', ', $columns) . "<br>";
    }
    
    // Ver estructura de Paseadores  
    if (in_array('Paseadores', $tables)) {
        $stmt = $conn->query("DESCRIBE Paseadores");
        $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
        echo "📋 Columnas de Paseadores: " . implode(', ', $columns) . "<br>";
    }
    
} else {
    echo "❌ Error de conexión";
}
?>