#!/bin/bash


if [ -f "/home/ubuntu/backendpf/duckdns.env" ]; then
  export $(grep -v '^#' /home/ubuntu/backendpf/duckdns.env | xargs)
else
  echo "El archivo .env no se encuentra en /home/ubuntu/backendpf."
  exit 1
fi

if [ -z "$DUCKDNS_TOKEN" ]; then
  echo "El token de DuckDNS no está definido."
  exit 1
fi

domains=(youdrive-api.duckdns.org youdrive-grafana.duckdns.org)
rsa_key_size=4096
data_path="./nginx/ssl"
email="ema.cuello1010@gmail.com" 
staging=0

for domain in "${domains[@]}"; do
  subdomain=$(echo $domain | cut -d. -f1)
  curl "https://www.duckdns.org/update?domains=$subdomain&token=$DUCKDNS_TOKEN"
done

# Actualizando ip
sleep 15

staging_arg=""
if [ $staging -ne 0 ]; then
  staging_arg="--staging"
fi

if [ -d "$data_path" ]; then
  echo "El directorio $data_path ya existe. Borrando los datos anteriores..."
  sudo rm -rf "$data_path"
fi

mkdir -p "$data_path"
mkdir -p "$data_path/conf"
mkdir -p "$data_path/www"
mkdir -p "$data_path/conf/live"

for domain in "${domains[@]}"; do
  mkdir -p "$data_path/conf/live/$domain"
done

docker-compose run --rm --entrypoint "
  sh -c 'mkdir -p /etc/letsencrypt/www/.well-known/acme-challenge &&
  certbot certonly --webroot -w /etc/letsencrypt/www --email $email --agree-tos --no-eff-email $staging_arg --rsa-key-size $rsa_key_size -d ${domains[*]}'" certbot

echo "Configuración de SSL completada"

sleep 3

sudo docker-compose up -d