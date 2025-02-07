<?php
try {
    $host = getenv('DB_HOST') ?: 'laravelmysqlsrv.mysql.database.azure.com';
    $username = getenv('DB_USERNAME') ?: 'mysqladmin';
    $password = getenv('DB_PASSWORD');
    $db_name = getenv('DB_DATABASE') ?: 'laraveldb';
    $ssl_cert = getenv('MYSQL_ATTR_SSL_CA') ?: '/etc/ssl/certs/Baltimore_CyberTrust_Root.crt.pem';

    $options = array(
        PDO::MYSQL_ATTR_SSL_CA => $ssl_cert,
        PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => true,
    );

    $dsn = "mysql:host=$host;dbname=$db_name;port=3306;sslmode=required";
    echo "Tentative de connexion avec DSN: $dsn\n";
    
    $conn = new PDO($dsn, $username, $password, $options);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "✅ Connexion réussie à MySQL!\n";
    
    // Test de la base de données
    $stmt = $conn->query("SHOW TABLES");
    echo "\nTables dans la base de données:\n";
    while ($row = $stmt->fetch()) {
        echo "- " . $row[0] . "\n";
    }
    
} catch(PDOException $e) {
    echo "❌ Erreur de connexion: " . $e->getMessage();
    echo "\n\nDébogage:\n";
    echo "Host: " . $host . "\n";
    echo "Username: " . $username . "\n";
    echo "Database: " . $db_name . "\n";
    echo "SSL Cert Path: " . $ssl_cert . "\n";
    echo "DSN: mysql:host=$host;dbname=$db_name;port=3306;sslmode=required\n";
} 