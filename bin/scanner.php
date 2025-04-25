<?php
$logFile = "/opt/loxberry/log/plugins/network_plugin/network_scan.log";
$datFile = "/opt/loxberry/data/plugins/network_plugin/scandata.dat";
$mqttConfigFile = "/opt/loxberry/webfrontend/htmlauth/plugins/network_plugin/mqtt_config.ini";

require_once '/opt/loxberry/bin/phpmqtt/phpMQTT.php';

function logChange($message) {
    global $logFile;
    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "[$timestamp] $message\n";
    file_put_contents($logFile, $logEntry, FILE_APPEND);
}

function scanNetwork() {
    $command = "sudo nmap -sn $(ip route | awk '/default/ {print $3}')/24 | awk '/Nmap scan report|MAC Address/ {print}'";
    $output = shell_exec($command);

    if (!$output) {
        logChange("Error: nmap command failed or returned empty output.");
        return [];
    }

    $lines = explode("\n", trim($output));
    $newDevices = [];
    $device = [];

    foreach ($lines as $line) {
        if (preg_match('/^Nmap scan report for\s+([^\s]+)(?:\s+\(([\d\.]+)\))?$/', $line, $matches)) {
            if (!empty($device)) {
                if (!isset($device['mac'])) {
                    $device['mac'] = "Unknown";
                }
                $device['last_seen'] = date('Y-m-d H:i:s');
                $key = ($device['mac'] !== "Unknown") ? strtoupper($device['mac']) : $device['ip'];
                $newDevices[$key] = $device;
            }
            $device = [];
            $device['hostname'] = isset($matches[2]) ? $matches[1] : $matches[1];
            $device['ip'] = $matches[2] ?? $matches[1];
        } elseif (preg_match('/^MAC Address:\s+([0-9A-Fa-f:]+)\s+\((.+)\)$/', $line, $matches)) {
            $device['mac'] = strtoupper($matches[1]);
            $device['vendor'] = trim($matches[2]);
        }
    }
    if (!empty($device)) {
        if (!isset($device['mac'])) {
            $device['mac'] = "Unknown";
        }
        $device['last_seen'] = date('Y-m-d H:i:s');
        $key = ($device['mac'] !== "Unknown") ? strtoupper($device['mac']) : $device['ip'];
        $newDevices[$key] = $device;
    }

    return $newDevices;
}

function loadMQTTConfig() {
    global $mqttConfigFile;
    if (!file_exists($mqttConfigFile)) {
        logChange("MQTT config file not found.");
        return [];
    }
    return parse_ini_file($mqttConfigFile);
}

function publishToMQTT($topic, $message) {
    $config = loadMQTTConfig();
    if (empty($config)) return;

    $mqtt = new phpMQTT($config['broker_host'], $config['broker_port'], "loxberry_network_scanner");
    if ($mqtt->connect(true, NULL, $config['user'], $config['password'])) {
        $mqtt->publish($topic, $message, 0);
        $mqtt->close();
    } else {
        logChange("Failed to connect to MQTT broker.");
    }
}

function performScan() {
    $timestamp = date('Y-m-d H:i:s');
    
    $existingDevices = loadExistingData();
    $newDevices = scanNetwork();

    if (empty($newDevices)) {
        logChange("No new devices found or nmap scan failed.");
        return;
    }

    $changes = compareDevices($existingDevices, $newDevices);
    foreach ($changes as $change) {
        logChange($change);
        publishToMQTT("loxberry/network/changes", json_encode(["timestamp" => $timestamp, "message" => $change]));
    }

    saveToDatFile($newDevices);
    logChange("Network scan complete. Data saved.");
}

if (php_sapi_name() == "cli") {
    echo "Running Network Scan...\n";
    performScan();
    echo "Scan complete. Results logged and published to MQTT.\n";
}
