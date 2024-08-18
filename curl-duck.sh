#!/bin/bash

cd /home/ubuntu/backendpf


if [ -f "/home/ubuntu/backendpf/duckdns.env" ]; then
  export $(grep -v '^#' /home/ubuntu/backendpf/duckdns.env | xargs)
else
  echo "El archivo duckdns.env no se encuentra en /home/ubuntu."
  exit 1
fi

if [ -z "$DUCKDNS_TOKEN" ]; then
  echo "El token de DuckDNS no está definido."
  exit 1
fi


IP=$(curl -s http://ifconfig.me)

sleep 1

echo $IP
echo $DUCKDNS_TOKEN

curl -s "https://www.duckdns.org/update?domains=youdrive-api.duckdns.org&token=$DUCKDNS_TOKEN&ip=$IP"

response1=$(curl -s "https://www.duckdns.org/update?domains=youdrive-api.duckdns.org&token=$DUCKDNS_TOKEN&ip=$IP")

echo $response1

sleep 2

curl -s "https://www.duckdns.org/update?domains=youdrive-grafana.duckdns.org&token=$DUCKDNS_TOKEN&ip=$IP"

response=$(curl -s "https://www.duckdns.org/update?domains=youdrive-grafana.duckdns.org&token=$DUCKDNS_TOKEN&ip=$IP")

echo $response

sleep 15

echo "Curl completado"