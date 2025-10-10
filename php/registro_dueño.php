<?php
session_start();
include 'conexion.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $nombre = htmlspecialchars(trim($_POST['nombre']));
    $email = htmlspecialchars(trim($_POST['email']));
    $password = password_hash($_POST['password'], PASSWORD_DEFAULT);
    $telefono = htmlspecialchars(trim($_POST['telefono']));
    $direccion = htmlspecialchars(trim($_POST['direccion']));

    if (empty($nombre) || empty($email) || empty($password)) {
        die("Por favor, complete todos los campos obligatorios.");
    }

    // Verificar si el correo ya existe
    $sql_check = "SELECT id FROM Usuarios WHERE email = ?";
    $stmt_check = $conn->prepare($sql_check);
    $stmt_check->bind_param("s", $email);
    $stmt_check->execute();
    $stmt_check->store_result();

    if ($stmt_check->num_rows > 0) {
        die("El correo ya está registrado. Use otro.");
    }
    $stmt_check->close();

    // Insertar usuario
    $sql_insert = "INSERT INTO Usuarios (nombre, email, contraseña, telefono, direccion, created_at) 
                   VALUES (?, ?, ?, ?, ?, NOW())";
    $stmt_insert = $conn->prepare($sql_insert);
    $stmt_insert->bind_param("sssss", $nombre, $email, $password, $telefono, $direccion);

    if ($stmt_insert->execute()) {
        // Crear sesión automática
        $_SESSION['user_id'] = $stmt_insert->insert_id;
        $_SESSION['user_name'] = $nombre;
        $_SESSION['user_role'] = 'dueño';

        // Redirigir al dashboard correspondiente
        header("Location: ../pages/dashboard_dueño.html");
        exit();
    } else {
        echo "Error al registrar usuario: " . $conn->error;
    }

    $stmt_insert->close();
    $conn->close();
} else {
    header("Location: ../pages/registro_dueño.html");
    exit();
}
?>
