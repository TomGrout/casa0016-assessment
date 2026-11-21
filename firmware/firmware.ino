#include <Arduino.h>
#include <WiFi.h>
#include <WebServer.h>
#include "secrets.h"

WebServer server(80);
unsigned long requestCount = 0;

void handleRoot() {
  requestCount++;
  String body = "ESP32-S3-Zero Wi-Fi OK\n";
  body += "IP: " + WiFi.localIP().toString() + "\n";
  body += "RSSI: " + String(WiFi.RSSI()) + " dBm\n";
  body += "Uptime: " + String(millis() / 1000) + " s\n";
  body += "Hits: " + String(requestCount) + "\n";

  Serial.printf("HTTP request #%lu from %s\n", requestCount, server.client().remoteIP().toString().c_str());
  server.send(200, "text/plain", body);
}

void setup() {
  Serial.begin(115200);
  delay(1500);

  Serial.printf("Connecting to %s", WIFI_SSID);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nConnected!");
  Serial.printf("IP Address : %s\n", WiFi.localIP().toString().c_str());
  Serial.printf("Gateway    : %s\n", WiFi.gatewayIP().toString().c_str());
  Serial.printf("RSSI       : %d dBm\n", WiFi.RSSI());

  server.on("/", handleRoot);
  server.begin();
  Serial.println("HTTP server started on port 80");
}

void loop() {
  server.handleClient();
}