upstream professional_management { server pm-green:8080; keepalive 16; }
map $host $served_by { default "green eeb08c7"; }
