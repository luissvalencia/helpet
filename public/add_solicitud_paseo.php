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

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Obtener datos desde JSON
        $input = json_decode(file_get_contents('php://input'), true);
        
        $usuario_id = intval($input['user_id'] ?? 0);
        $paseador_id = intval($input['paseador_id'] ?? 0);
        $fecha = $input['fecha'] ?? '';
        $mascotas_str = $input['mascotas'] ?? '';
        $mascotas = explode(',', $mascotas_str);

        // Validar datos
        if ($usuario_id <= 0 || $paseador_id <= 0 || empty($fecha) || empty($mascotas_str)) {
            echo json_encode(["success" => false, "message" => "Faltan datos obligatorios"]);
            exit;
        }

        // Validar formato de fecha
        $fecha_dt = DateTime::createFromFormat('Y-m-d H:i:s', $fecha);
        if (!$fecha_dt) {
            echo json_encode(["success" => false, "message" => "Formato de fecha inválido"]);
            exit;
        }

        // 🔽 CORREGIDO: Usar PDO
        $sql = "INSERT INTO solicitudespaseo (usuario_id, paseador_id, mascota_id, fecha, estado) VALUES (?, ?, ?, ?, 'pendiente')";
        $stmt = $conn->prepare($sql);

        $success_count = 0;
        $error_count = 0;

        foreach ($mascotas as $m_id_str) {
            $m_id = intval(trim($m_id_str));
            if ($m_id > 0) {
                try {
                    if ($stmt->execute([$usuario_id, $paseador_id, $m_id, $fecha])) {
                        $success_count++;
                    } else {
                        $error_count++;
                    }
                } catch (Exception $e) {
                    $error_count++;
                    error_log("Error insertando solicitud para mascota $m_id: " . $e->getMessage());
                }
            }
        }

        if ($error_count === 0) {
            echo json_encode([
                "success" => true, 
                "message" => "Solicitud de paseo registrada correctamente para $success_count mascota(s)"
            ]);
        } else if ($success_count > 0) {
            echo json_encode([
                "success" => true, 
                "message" => "Solicitud parcialmente registrada ($success_count exitosas, $error_count fallidas)"
            ]);
        } else {
            echo json_encode([
                "success" => false, 
                "message" => "Error al registrar las solicitudes"
            ]);
        }

    } else {
        echo json_encode(["success" => false, "message" => "Método no permitido"]);
    }

} catch (Exception $e) {
    error_log("Error en add_solicitud_paseo: " . $e->getMessage());
    echo json_encode([
        "success" => false, 
        "message" => "Error del servidor",
        "error" => $e->getMessage()
    ]);
}
?>