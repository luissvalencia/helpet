<?php
// conexion.php — Configurado para Railway

class Database {
    private $host = "mysql.railway.internal";
    private $db_name = "railway";
    private $username = "root";
    private $password = "hFkPvTClSJEJXfVjTWuLvXSkfxCKCKbt";
    private $port = 3306;
    public $conn;

    public function getConnection() {
        $this->conn = null;
        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . 
                ";port=" . $this->port . 
                ";dbname=" . $this->db_name . 
                ";charset=utf8",
                $this->username,
                $this->password,
                array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
            );
        } catch (PDOException $exception) {
            error_log("❌ Error de conexión: " . $exception->getMessage());
            echo json_encode(["error" => "Error de conexión a la base de datos"]);
        }
        return $this->conn;
    }
}
?>
