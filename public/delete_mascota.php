<?php
// HEADERS PARA CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

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
        echo json_encode(["success" => false, "message" => "Error de conexión a la base de datos"]);
        exit;
    }

    // Obtener datos desde JSON
    $input = json_decode(file_get_contents('php://input'), true);
    $mascota_id = intval($input['mascota_id'] ?? 0);

    if ($mascota_id <= 0) {
        echo json_encode(["success" => false, "message" => "ID de mascota inválido"]);
        exit;
    }

    // 🔽 CORREGIDO: Usar PDO en lugar de mysqli
    $sql = "DELETE FROM mascotas WHERE id = ?";
    $stmt = $conn->prepare($sql);
    
    if ($stmt->execute([$mascota_id])) {
        if ($stmt->rowCount() > 0) {
            echo json_encode(["success" => true, "message" => "Mascota eliminada correctamente"]);
        } else {
            echo json_encode(["success" => false, "message" => "No se encontró la mascota"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Error al eliminar mascota"]);
    }

} catch (Exception $e) {
    error_log("Error en delete_mascota: " . $e->getMessage());
    echo json_encode(["success" => false, "message" => "Error del servidor"]);
}
?>