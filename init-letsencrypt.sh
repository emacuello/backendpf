#!/bin/bash

domains=(youdrive-api.duckdns.org youdrive-grafana.duckdns.org)
rsa_key_size=4096
data_path="./nginx/ssl"
email="ema.cuello1010@gmail.com" 
staging=0

sudo cp /home/ubuntu/backendpf/nginx.conf /home/ubuntu/backendpf/nginx/nginx.conf
sudo cp /home/ubuntu/backendpf/youdrive.conf.temp /home/ubuntu/backendpf/nginx/conf.d/youdrive.conf

sudo docker-compose up -d nginx

sleep 15


function check_domain {
  local domain=$1
  local url="http://$domain/.well-known/acme-challenge/testfile"
  
  echo "Verificando dominio $domain..."
  
  
  sudo mkdir -p /var/www/certbot/.well-known/acme-challenge
  echo "test" | sudo tee /var/www/certbot/.well-known/acme-challenge/testfile > /dev/null

  
  response=$(curl -s -o /dev/null -w "%{http_code}" $url)
  
  if [ "$response" -ne 200 ]; then
    echo "El dominio $domain no es accesible. Código de respuesta: $response"
    return 1
  else
    echo "El dominio $domain es accesible."
    return 0
  fi
}

# Verificar todos los dominios
for domain in "${domains[@]}"; do
  while ! check_domain $domain; do
    echo "Esperando a que el dominio $domain esté disponible..."
    sleep 30
  done
done

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

sleep 15

docker-compose run --rm --entrypoint "
  sh -c 'mkdir -p /etc/letsencrypt/www/.well-known/acme-challenge &&
  certbot certonly --webroot -w /etc/letsencrypt/www --email $email --agree-tos --no-eff-email $staging_arg --rsa-key-size $rsa_key_size $domain_args'" certbot

echo "Configuración de SSL completada"

sudo cp /home/ubuntu/backendpf/nginx.conf /home/ubuntu/backendpf/nginx/nginx.conf
sudo cp /home/ubuntu/backendpf/youdrive.conf /home/ubuntu/backendpf/nginx/conf.d/youdrive.conf
sudo cp /home/ubuntu/backendpf/grafana.conf /home/ubuntu/backendpf/nginx/conf.d/grafana.conf

sleep 1

sudo docker-compose restart nginx

echo "Reiniciando nginx"

sleep 2

sudo docker-compose up -d