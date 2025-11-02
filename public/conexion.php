<?php
// conexion.php — Configurado para Railway desde Render

class Database {
    private $host = "metro.proxy.rlwy.net";
    private $db_name = "railway";
    private $username = "root";
    private $password = "hFkPvTClSJEJXfVjTWuLvXSkfxCKCKbt";
    private $port = 25195;
    public $conn;

    public function getConnection() {
        $this->conn = null;
        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . 
                ";port=" . $this->port . 
                ";dbname=" . $this->db_name . 
                ";charset=utf8mb4",
                $this->username,
                $this->password,
                array(
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
                )
            );
            error_log("✅ Conexión a BD exitosa");
        } catch (PDOException $exception) {
            error_log("❌ Error de conexión: " . $exception->getMessage());
            // No mostrar el error real en producción
            echo json_encode(["error" => "Error de conexión a la base de datos"]);
        }
        return $this->conn;
    }
}
?>