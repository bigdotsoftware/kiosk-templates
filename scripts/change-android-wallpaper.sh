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

curl -X POST http://$KIOSK_IP/api/androidtv/wallpaper/upload \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@kiosk-os.png"
