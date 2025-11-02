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
require_once '../config/database.php';

$database = new Database();
$conn = $database->getConnection();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $paseo_id = intval($_POST['paseo_id'] ?? 0);
    $estado = $_POST['estado'] ?? '';

    if ($paseo_id <= 0 || empty($estado)) {
        echo json_encode(["success" => false, "message" => "Datos incompletos"]);
        exit;
    }

    // ✅ BUSCAR PRIMERO EN PASEOS (PORQUE ESE ES EL ID QUE LLEGA DESDE FLUTTER)
    $info = null;
    $tipo = 'paseo';
    
    // 1. Buscar en paseos (PRIMERO - porque Flutter envía IDs de paseos)
    $stmt = $conn->prepare("
        SELECT id, usuario_id, paseador_id, fecha, estado 
        FROM paseos 
        WHERE id = ?
    ");
    $stmt->bind_param("i", $paseo_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        $info = $result->fetch_assoc();
        $tipo = 'paseo';
    }
    $stmt->close();

    // 2. Si no se encontró en paseos, buscar en solicitudespaseo
    if (!$info) {
        $stmt = $conn->prepare("
            SELECT id, usuario_id, paseador_id, fecha, estado 
            FROM solicitudespaseo 
            WHERE id = ?
        ");
        $stmt->bind_param("i", $paseo_id);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows > 0) {
            $info = $result->fetch_assoc();
            $tipo = 'solicitud';
        }
        $stmt->close();
    }

    if (!$info) {
        echo json_encode(["success" => false, "message" => "No se encontró el paseo con ID: " . $paseo_id]);
        exit;
    }

    $usuario_id = $info['usuario_id'];
    $paseador_id = $info['paseador_id'];
    $fecha = $info['fecha'];

    // ✅ SI ES UN PASEO EXISTENTE, ACTUALIZAR DIRECTAMENTE
    if ($tipo === 'paseo') {
        $updatePaseo = $conn->prepare("
            UPDATE paseos 
            SET estado = ?
            WHERE id = ?
        ");
        $updatePaseo->bind_param("si", $estado, $paseo_id);
        
        if ($updatePaseo->execute()) {            
            // También actualizar las solicitudes relacionadas si existen
            $updateSolicitudes = $conn->prepare("
                UPDATE solicitudespaseo 
                SET estado = ? 
                WHERE usuario_id = ? AND paseador_id = ? AND fecha = ?
            ");
            $updateSolicitudes->bind_param("siis", $estado, $usuario_id, $paseador_id, $fecha);
            $updateSolicitudes->execute();
            $updateSolicitudes->close();
            
            echo json_encode([
                "success" => true, 
                "message" => "Paseo actualizado a $estado",
                "tipo" => $tipo
            ]);
        } else {
            echo json_encode(["success" => false, "message" => "Error al actualizar paseo"]);
        }
        $updatePaseo->close();
        
    } else {
        // ✅ SI ES UNA SOLICITUD, MANEJAR COMO ANTES
        $updateSolicitudes = $conn->prepare("
            UPDATE solicitudespaseo 
            SET estado = ? 
            WHERE usuario_id = ? AND paseador_id = ? AND fecha = ?
        ");
        $updateSolicitudes->bind_param("siis", $estado, $usuario_id, $paseador_id, $fecha);
        $updateSolicitudes->execute();
        $updateSolicitudes->close();

        if ($estado === 'aceptado') {
            $checkPaseo = $conn->prepare("
                SELECT id FROM paseos 
                WHERE usuario_id = ? AND paseador_id = ? AND fecha = ?
            ");
            $checkPaseo->bind_param("iis", $usuario_id, $paseador_id, $fecha);
            $checkPaseo->execute();
            $paseoExistente = $checkPaseo->get_result()->fetch_assoc();
            $checkPaseo->close();

            if (!$paseoExistente) {
                $insertPaseo = $conn->prepare("
                    INSERT INTO paseos (usuario_id, paseador_id, fecha, estado)
                    VALUES (?, ?, ?, 'aceptado')
                ");
                $insertPaseo->bind_param("iis", $usuario_id, $paseador_id, $fecha);
                $insertPaseo->execute();
                $nuevoPaseoId = $insertPaseo->insert_id;
                $insertPaseo->close();

                $mascotasStmt = $conn->prepare("
                    SELECT DISTINCT mascota_id FROM solicitudespaseo
                    WHERE usuario_id = ? AND paseador_id = ? AND fecha = ?
                ");
                $mascotasStmt->bind_param("iis", $usuario_id, $paseador_id, $fecha);
                $mascotasStmt->execute();
                $mascotasResult = $mascotasStmt->get_result();

                while ($mascota = $mascotasResult->fetch_assoc()) {
                    $insertMascota = $conn->prepare("
                        INSERT INTO paseos_mascotas (paseo_id, mascota_id)
                        VALUES (?, ?)
                    ");
                    $insertMascota->bind_param("ii", $nuevoPaseoId, $mascota['mascota_id']);
                    $insertMascota->execute();
                    $insertMascota->close();
                }
                $mascotasStmt->close();
            }
        }

        if (in_array($estado, ['en_curso', 'finalizado'])) {
            $updatePaseo = $conn->prepare("
                UPDATE paseos 
                SET estado = ?
                WHERE usuario_id = ? AND paseador_id = ? AND fecha = ?
            ");
            $updatePaseo->bind_param("siis", $estado, $usuario_id, $paseador_id, $fecha);
            $updatePaseo->execute();
            $updatePaseo->close();
        }

        echo json_encode([
            "success" => true, 
            "message" => "Estado actualizado correctamente",
            "tipo" => $tipo
        ]);
    }
    
    $conn->close();
} else {
    echo json_encode(["success" => false, "message" => "Método no permitido"]);
}
?>