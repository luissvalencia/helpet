<?php
// HEADERS PARA CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json; charset=utf-8');

// MANEJAR PREFLIGHT
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

// INCLUIR CONEXIÓN
require_once 'conexion.php';

try {
    $database = new Database();
    $conn = $database->getConnection();

    if (!$conn) {
        echo json_encode(["error" => "Error de conexión a la base de datos"]);
        exit;
    }

    // 🔽 CORREGIDO: Usar PDO en lugar de mysqli
    $sql = "SELECT id, nombre, experiencia, calificacion_promedio FROM paseadores";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    $paseadores = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($paseadores, JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    error_log("Error en get_paseadores: " . $e->getMessage());
    echo json_encode([
        "error" => "Error del servidor",
        "message" => $e->getMessage()
    ]);
}
?>