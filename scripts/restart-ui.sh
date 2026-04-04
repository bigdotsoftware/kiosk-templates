#!/bin/bash
KIOSK_IP="192.168.0.201"
KIOSK_PIN="1234"

#KIOSK_IP="127.0.0.1:8080"

# 0. Musisz mieć jq
sudo apt install jq

# 1. LOGIN → pobierz token
TOKEN=$(curl -s -X POST http://$KIOSK_IP/api/login \
  -H "Content-Type: application/json" \
  -d "{\"pin\":\"$KIOSK_PIN\"}" | jq -r '.token')

echo "TOKEN=$TOKEN"

# 2. Wprowadzaj ustawienia do Kiosku za pomoca API
curl -X POST "http://$KIOSK_IP/api/device/restart-ui" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN"
