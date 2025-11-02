<?php
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
            error_log("✅ Conexión a BD exitosa: $this->host:$this->port");
        } catch (PDOException $exception) {
            error_log("❌ Error de conexión: " . $exception->getMessage());
            return null;
        }
        return $this->conn;
    }
}
?>