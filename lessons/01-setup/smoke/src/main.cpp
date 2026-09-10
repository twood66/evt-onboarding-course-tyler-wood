#include <Arduino.h>

namespace {
constexpr unsigned long kHeartbeatIntervalMs = 1000;
unsigned long lastHeartbeatMs = 0;
}  // namespace

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  const unsigned long now = millis();
  if (now - lastHeartbeatMs >= kHeartbeatIntervalMs) {
    lastHeartbeatMs = now;
    digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
  }
}
