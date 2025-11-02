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
    $paseo_id = intval($input['paseo_id'] ?? 0);
    $estado = $input['estado'] ?? '';

    if ($paseo_id <= 0 || empty($estado)) {
        echo json_encode(["success" => false, "message" => "Datos incompletos"]);
        exit;
    }

    // 🔽 CORREGIDO: Usar PDO en lugar de mysqli
    // Buscar en paseos primero
    $sql = "SELECT id, usuario_id, paseador_id, fecha, estado FROM paseos WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->execute([$paseo_id]);
    $info = $stmt->fetch(PDO::FETCH_ASSOC);
    
    $tipo = 'paseo';
    
    // Si no se encontró en paseos, buscar en solicitudespaseo
    if (!$info) {
        $sql = "SELECT id, usuario_id, paseador_id, fecha, estado FROM solicitudespaseo WHERE id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->execute([$paseo_id]);
        $info = $stmt->fetch(PDO::FETCH_ASSOC);
        $tipo = 'solicitud';
    }

    if (!$info) {
        echo json_encode(["success" => false, "message" => "No se encontró el paseo con ID: " . $paseo_id]);
        exit;
    }

    $usuario_id = $info['usuario_id'];
    $paseador_id = $info['paseador_id'];
    $fecha = $info['fecha'];

    // Si es un paseo existente, actualizar directamente
    if ($tipo === 'paseo') {
        $sql = "UPDATE paseos SET estado = ? WHERE id = ?";
        $stmt = $conn->prepare($sql);
        
        if ($stmt->execute([$estado, $paseo_id])) {            
            // También actualizar las solicitudes relacionadas si existen
            $sql = "UPDATE solicitudespaseo SET estado = ? WHERE usuario_id = ? AND paseador_id = ? AND fecha = ?";
            $stmt = $conn->prepare($sql);
            $stmt->execute([$estado, $usuario_id, $paseador_id, $fecha]);
            
            echo json_encode([
                "success" => true, 
                "message" => "Paseo actualizado a $estado",
                "tipo" => $tipo
            ]);
        } else {
            echo json_encode(["success" => false, "message" => "Error al actualizar paseo"]);
        }
        
    } else {
        // Si es una solicitud, manejar como antes
        $sql = "UPDATE solicitudespaseo SET estado = ? WHERE usuario_id = ? AND paseador_id = ? AND fecha = ?";
        $stmt = $conn->prepare($sql);
        $stmt->execute([$estado, $usuario_id, $paseador_id, $fecha]);

        if ($estado === 'aceptado') {
            // Verificar si ya existe un paseo
            $sql = "SELECT id FROM paseos WHERE usuario_id = ? AND paseador_id = ? AND fecha = ?";
            $stmt = $conn->prepare($sql);
            $stmt->execute([$usuario_id, $paseador_id, $fecha]);
            $paseoExistente = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$paseoExistente) {
                // Crear nuevo paseo
                $sql = "INSERT INTO paseos (usuario_id, paseador_id, fecha, estado) VALUES (?, ?, ?, 'aceptado')";
                $stmt = $conn->prepare($sql);
                $stmt->execute([$usuario_id, $paseador_id, $fecha]);
                $nuevoPaseoId = $conn->lastInsertId();

                // Obtener mascotas de la solicitud
                $sql = "SELECT DISTINCT mascota_id FROM solicitudespaseo WHERE usuario_id = ? AND paseador_id = ? AND fecha = ?";
                $stmt = $conn->prepare($sql);
                $stmt->execute([$usuario_id, $paseador_id, $fecha]);
                $mascotas = $stmt->fetchAll(PDO::FETCH_ASSOC);

                // Insertar mascotas en paseos_mascotas
                foreach ($mascotas as $mascota) {
                    $sql = "INSERT INTO paseos_mascotas (paseo_id, mascota_id) VALUES (?, ?)";
                    $stmt = $conn->prepare($sql);
                    $stmt->execute([$nuevoPaseoId, $mascota['mascota_id']]);
                }
            }
        }

        if (in_array($estado, ['en_curso', 'finalizado'])) {
            $sql = "UPDATE paseos SET estado = ? WHERE usuario_id = ? AND paseador_id = ? AND fecha = ?";
            $stmt = $conn->prepare($sql);
            $stmt->execute([$estado, $usuario_id, $paseador_id, $fecha]);
        }

        echo json_encode([
            "success" => true, 
            "message" => "Estado actualizado correctamente",
            "tipo" => $tipo
        ]);
    }

} catch (Exception $e) {
    error_log("Error en update_estado_paseo: " . $e->getMessage());
    echo json_encode(["success" => false, "message" => "Error del servidor"]);
}
?>