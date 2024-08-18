#!/bin/bash

domains=(youdrive-api.duckdns.org youdrive-grafana.duckdns.org)
rsa_key_size=4096
data_path="./nginx/ssl"
email="ema.cuello1010@gmail.com" 
staging=0

sudo mv /home/ubuntu/backendpf/nginx.conf.temp /home/ubuntu/backendpf/nginx/nginx.conf

sudo docker-compose up -d nginx

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

domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

docker-compose run --rm --entrypoint "
  sh -c 'mkdir -p /etc/letsencrypt/www/.well-known/acme-challenge &&
  certbot certonly --webroot -w /etc/letsencrypt/www --email $email --agree-tos --no-eff-email $staging_arg --rsa-key-size $rsa_key_size $domain_args'" certbot

echo "Configuración de SSL completada"

sudo mv /home/ubuntu/backendpf/nginx.conf /home/ubuntu/backendpf/nginx/nginx.conf

sleep 1

sudo docker-compose restart nginx

echo "Reiniciando nginx"

sleep 2

sudo docker-compose up -d