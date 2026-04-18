#!/bin/bash
KIOSK_IP="192.168.0.61"
KIOSK_PIN="1234"

#KIOSK_IP="127.0.0.1:8080"

# 0. Musisz mieć jq
if ! command -v jq > /dev/null 2>&1; then
    sudo apt install jq
fi

# 1. LOGIN → pobierz token
TOKEN=$(curl -s -X POST http://$KIOSK_IP/api/login \
  -H "Content-Type: application/json" \
  -d "{\"pin\":\"$KIOSK_PIN\"}" | jq -r '.token')

echo "TOKEN=$TOKEN"

# 2. Wprowadzaj ustawienia do Kiosku za pomoca API
RESPONSE=$(curl -s -X POST "http://$KIOSK_IP/api/device/logs/webview" \
  -d '{"lines": 10}' \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN")

# Odczytaj i wyswietl logi
echo "$RESPONSE" | jq -r '.log // empty' | while IFS= read -r line; do
    echo "  $line"
done
