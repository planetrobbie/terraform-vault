# nginx configuration for PKI as a Service Vault Demo.
server {
    listen              443 ssl;
    server_name         www.${dns_domain};
    ssl_certificate     /home/${ssh_user}/pki/ssl/cert.crt;
    ssl_certificate_key /home/${ssh_user}/pki/ssl/cert.key;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    location / {
      root   /usr/share/nginx/html;
      index  index.html index.htm;
    }
}
