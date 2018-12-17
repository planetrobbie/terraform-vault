# nginx configuration for PKI as a Service Vault Demo.

# redirect traffic from http to https.
server {
listen              80;
listen              [::]:80;
server_name         ${dns_domain} www.${dns_domain};
return 301          https://${dns_domain}$request_uri;
return 301          https://www.${dns_domain}$request_uri;
}

server {
    listen              443 ssl;
    server_name         www.${dns_domain};
    ssl_certificate     /etc/nginx/certs/cert.crt;
    ssl_certificate_key /etc/nginx/certs/cert.key;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    location / {
      root   /usr/share/nginx/html;
      index  index.html index.htm;
    }
}
