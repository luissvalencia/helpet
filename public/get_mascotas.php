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

    // Obtener user_id desde POST o JSON
    $input = json_decode(file_get_contents('php://input'), true);
    $user_id = isset($input['user_id']) ? intval($input['user_id']) : (isset($_POST['user_id']) ? intval($_POST['user_id']) : 0);

    if ($user_id === 0) {
        echo json_encode([]);
        exit;
    }

    // 🔽 CORREGIDO: usar nombre correcto de columna (usuario_id en lugar de user_id)
    $sql = "SELECT id, nombre, especie, raza, edad FROM mascotas WHERE usuario_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->execute([$user_id]);
    $mascotas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($mascotas, JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    error_log("Error en get_mascotas: " . $e->getMessage());
    echo json_encode(["error" => "Error del servidor"]);
}
?>