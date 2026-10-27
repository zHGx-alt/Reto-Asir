#!/usr/bin/env bash
# Instala el servidor web de Almi Chain en una EC2 con Ubuntu 24.04 (tarea 30).
# Sirve con nginx la web guardada en el bucket S3 y pide el certificado de Let's Encrypt.
# Uso: sudo BUCKET=almi-chain-web-2026 DOMINIO=almichain1.duckdns.org EMAIL=tu@correo ./instalar-servidor-web.sh
set -euo pipefail

: "${BUCKET:?Falta BUCKET (nombre del bucket S3)}"
: "${DOMINIO:?Falta DOMINIO (por ejemplo almichain1.duckdns.org)}"
: "${EMAIL:?Falta EMAIL (avisos de caducidad del certificado)}"
REGION="${REGION:-us-east-1}"
WEBROOT=/var/www/almichain

if [[ $EUID -ne 0 ]]; then
  echo "Ejecutar con sudo." >&2
  exit 1
fi

apt-get update
apt-get install -y nginx certbot python3-certbot-nginx
snap install aws-cli --classic

# Descarga de la web desde S3; cron la repite cada 5 minutos para publicar los cambios.
mkdir -p "$WEBROOT"
cat > /usr/local/bin/actualizar-web <<EOF
#!/usr/bin/env bash
set -euo pipefail
/snap/bin/aws s3 sync "s3://$BUCKET/" "$WEBROOT/" --delete --only-show-errors --region "$REGION"
EOF
chmod 755 /usr/local/bin/actualizar-web
/usr/local/bin/actualizar-web
echo "*/5 * * * * root /usr/local/bin/actualizar-web" > /etc/cron.d/actualizar-web

# Sitio de nginx. Certbot añade después el bloque HTTPS y la redirección desde HTTP.
cat > /etc/nginx/sites-available/almichain <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMINIO;
    root $WEBROOT;
    index index.html;

    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    # CSP: solo se cargan los ficheros propios, las fotos de Unsplash, el favicon en línea (data:) y el mapa de OpenStreetMap.
    # Sin scripts ni estilos en línea ni de otros dominios. Si se añade un recurso externo a la web, hay que añadirlo aquí.
    add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; frame-src https://www.openstreetmap.org; connect-src 'self'; font-src 'self'; form-action 'self'; base-uri 'self'; object-src 'none'; frame-ancestors 'self'; upgrade-insecure-requests" always;
    # La geolocalización solo la puede pedir la propia web (no el iframe del mapa); cámara, micrófono y pagos, nadie.
    add_header Permissions-Policy "geolocation=(self), camera=(), microphone=(), payment=(), usb=()" always;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
ln -sf /etc/nginx/sites-available/almichain /etc/nginx/sites-enabled/almichain
rm -f /etc/nginx/sites-enabled/default
# En el bloque http, para que también se aplique a la redirección que crea certbot.
echo "server_tokens off;" > /etc/nginx/conf.d/ocultar-version.conf
# Ubuntu solo comprime el HTML; se añaden el CSS, el JS y el SVG.
printf 'gzip_vary on;\ngzip_types text/css application/javascript image/svg+xml;\n' > /etc/nginx/conf.d/compresion.conf
nginx -t
systemctl reload nginx

certbot --nginx -d "$DOMINIO" -m "$EMAIL" --agree-tos --no-eff-email --redirect --non-interactive

echo "Listo: https://$DOMINIO"
