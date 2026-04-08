#!/bin/bash
KIOSK_IP="192.168.0.201"
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
curl -X POST "http://$KIOSK_IP/api/settings-update-key" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "path": "blik.enabled",
    "value": true
  }'

curl -X POST "http://$KIOSK_IP/api/settings-update-key" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "path": "blik.client_credentials.apikey",
    "value": "a811b4d6-1111-1111-1111-83a0e11cee5c"
  }'

curl -X POST "http://$KIOSK_IP/api/settings-update-key" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "path": "blik.client_credentials.signkey",
    "value": "9b117a8e-1111-1111-1111-e1461211abb8"
  }'

curl -X POST "http://$KIOSK_IP/api/settings-update-key" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "path": "blik.client_credentials.url",
    "value": "https://api.sandbox.paynow.pl"
  }'
