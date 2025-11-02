<?php
session_start();


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
session_start();

$database = new Database();
$conn = $database->getConnection();


if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $nombre = htmlspecialchars(trim($_POST['nombre']));
    $email = htmlspecialchars(trim($_POST['email']));
    $password = password_hash($_POST['password'], PASSWORD_DEFAULT);
    $telefono = htmlspecialchars(trim($_POST['telefono']));
    $direccion = htmlspecialchars(trim($_POST['direccion']));
    $experiencia = htmlspecialchars(trim($_POST['experiencia']));
    $disponibilidad = htmlspecialchars(trim($_POST['disponibilidad']));

    if (empty($nombre) || empty($email) || empty($_POST['password']) || empty($experiencia) || empty($disponibilidad)) {
        die("Por favor, complete todos los campos obligatorios.");
    }

    $sql_check = "SELECT id FROM Paseadores WHERE email = ?";
    $stmt_check = $conn->prepare($sql_check);
    $stmt_check->bind_param("s", $email);
    $stmt_check->execute();
    $stmt_check->store_result();

    if ($stmt_check->num_rows > 0) {
        die("El correo ya está registrado. Use otro.");
    }
    $stmt_check->close();

    $sql_insert = "INSERT INTO Paseadores (nombre, email, contraseña, telefono, direccion, experiencia, disponibilidad, created_at)
                   VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
    $stmt_insert = $conn->prepare($sql_insert);
    $stmt_insert->bind_param("sssssss", $nombre, $email, $password, $telefono, $direccion, $experiencia, $disponibilidad);

    if ($stmt_insert->execute()) {
        echo json_encode(["success" => true, "message" => "Registro exitoso"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al registrar paseador"]);
    }

    $stmt_insert->close();
    $conn->close();
}
?>
