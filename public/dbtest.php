<?php
try {
    $host = 'laravelmysqlsrv.mysql.database.azure.com';
    $username = 'mysqladmin@laravelmysqlsrv';
    $password = getenv('DB_PASSWORD');
    $db_name = 'laraveldb';

    $options = array(
        PDO::MYSQL_ATTR_SSL_CA => '/etc/ssl/certs/Baltimore_CyberTrust_Root.crt.pem',
        PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => true,
    );

    $conn = new PDO(
        "mysql:host=$host;dbname=$db_name;port=3306;sslmode=required",
        $username,
        $password,
        $options
    );
    
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "✅ Connexion réussie à MySQL!";
    
    // Test de la base de données
    $stmt = $conn->query("SHOW TABLES");
    echo "\n\nTables dans la base de données:\n";
    while ($row = $stmt->fetch()) {
        echo "- " . $row[0] . "\n";
    }
    
} catch(PDOException $e) {
    echo "❌ Erreur de connexion: " . $e->getMessage();
} 